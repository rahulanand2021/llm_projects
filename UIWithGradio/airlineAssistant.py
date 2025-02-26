import os
import sys
from dotenv import load_dotenv
from openai import OpenAI
import gradio as gr
import json
import base64
from io import BytesIO
from PIL import Image
import matplotlib.pyplot as plt
from pydub import AudioSegment
from pydub.playback import play

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(project_root)

from mycomponents import reusable as re

ticket_prices = {"london": "$799", "paris": "$899", "tokyo": "$1400", "berlin": "$499"}

def chat1(message, history):
    gpt_system_message = "You are a helpful assistant for an Airline called FlightAI. "
    gpt_system_message += "Give short, courteous answers, no more than 1 sentence. "
    gpt_system_message += "Always be accurate. If you don't know the answer, say so."
    
    messages = [{"role": "system", "content": gpt_system_message}] + history + [{"role": "user", "content": message}]

    # messages = [{"role": "system", "content": gpt_system_message}] 

    # for user_message, assistant_message in history:
    #     messages.append({"role": "user", "content": user_message})
    #     messages.append({"role": "assistant", "content": assistant_message})
    # messages.append({"role": "user", "content": message})

    print("History is:")
    print(history)
    print("And messages is:")
    print(messages)

    response = re.getOpenAI().chat.completions.create(
        model=re.gpt_model, 
        messages=messages
        )
    return response.choices[0].message.content

def chat(history):
    gpt_system_message = "You are a helpful assistant for an Airline called FlightAI. "
    gpt_system_message += "Give short, courteous answers, no more than 1 sentence. "
    gpt_system_message += "Always be accurate. If you don't know the answer, say so."
    messages = [{"role": "system", "content": gpt_system_message}] + history
    response = re.getOpenAI().chat.completions.create(model=re.gpt_model, messages=messages, tools=getTools())
    image = None
    
    if response.choices[0].finish_reason=="tool_calls":
        message = response.choices[0].message
        response, city = handle_tool_call(message)
        messages.append(message)
        messages.append(response)
        image = artist(city)
        response = re.getOpenAI().chat.completions.create(model=re.gpt_model, messages=messages)
        
    reply = response.choices[0].message.content
    history += [{"role":"assistant", "content":reply}]

    return history, image

def get_ticket_price(destination_city):
    print(f"Tool called : get_ticket_price called for {destination_city}")
    city = destination_city.lower()
    return ticket_prices.get(city, "Unknown")

def book_tickets(destination_city, booking_date, price) :
    confirmation = f" Your Flight have been booked for {destination_city} on {booking_date} for the price of {price}"
    print(confirmation)
    return confirmation

def loadPriceFunction() :
    price_function = {
        "name": "get_ticket_price",
        "description": "Get the price of a return ticket to the destination city. Call this whenever you need to know the ticket price, for example when a customer asks 'How much is a ticket to this city'",
        "parameters": {
            "type": "object",
            "properties": {
                "destination_city": {
                    "type": "string",
                    "description": "The city that the customer wants to travel to",
                },
            },
            "required": ["destination_city"],
            "additionalProperties": False
        }
    }
    return price_function

def loadBookingFunction() :
    book_function = {
        "name": "book_tickets",
        "description": "Book the return ticket to the destination city for the given date. Call this whenever you need to book the actual tickets, for example when a customer asks 'Please book the tickets'",
        "parameters": {
            "type": "object",
            "properties": {
                "destination_city": {
                    "type": "string",
                    "description": "The city that the customer wants to travel to",
                },
                "booking_date": {
                    "type": "string",
                    "description": "The date that the customer wants to Book the tickets on",
                },                
            },
            "required": ["destination_city","booking_date"],
            "additionalProperties": False
        }
    }
    return book_function

# And this is included in a list of tools:
def getTools():
    tools = [{"type": "function", "function": loadPriceFunction()},
             {"type": "function", "function": loadBookingFunction()}]
    return tools

# def getTools():
#     tools = [{"type": "function", "function": loadPriceFunction()}
#              ]
#     return tools

def handle_tool_call(message):
    tool_call = message.tool_calls[0]
    arguments = json.loads(tool_call.function.arguments)
    city = arguments.get('destination_city')
    booking_date = arguments.get('booking_date')
    if booking_date: 
        price = get_ticket_price(city)
        book_tickets(city, booking_date, price)
        response = {
            "role": "tool",
            "content": json.dumps({"destination_city": city,"booking_date": booking_date,"price": price}),
            "tool_call_id": tool_call.id
        }
    else:
        price = get_ticket_price(city)
        response = {
            "role": "tool",
            "content": json.dumps({"destination_city": city,"price": price}),
            "tool_call_id": tool_call.id
        }
    return response, city

def chatWithTools(message, history):
    gpt_system_message = "You are a helpful assistant for an Airline called FlightAI. "
    gpt_system_message += "Give short, courteous answers, no more than 1 sentence. "
    gpt_system_message += "Always be accurate. If you don't know the answer, say so."

    messages = [{"role": "system", "content": gpt_system_message}] + history + [{"role": "user", "content": message}]
    response = re.getOpenAI().chat.completions.create(model=re.gpt_model, messages=messages, tools=getTools())

    if response.choices[0].finish_reason=="tool_calls":
        message = response.choices[0].message
        print(f"Message from Tool Calls : {message}")
        response, city = handle_tool_call(message)
        messages.append(message)
        messages.append(response)
        response =  re.getOpenAI().chat.completions.create(model=re.gpt_model, messages=messages)
    return response.choices[0].message.content

def artist(city):
    image_response = re.getOpenAI().images.generate(
            model="dall-e-3",
            prompt=f"An image representing a vacation in {city}, showing tourist spots and everything unique about {city}, in a vibrant pop-art style",
            size="1024x1024",
            n=1,
            response_format="b64_json",
        )
    image_base64 = image_response.data[0].b64_json
    image_data = base64.b64decode(image_base64)
    print("Image Data in Base 64 Decoded is : ")
    return Image.open(BytesIO(image_data))

def showCustomeUI():
    with gr.Blocks() as ui:
        with gr.Row():
            chatbot = gr.Chatbot(height=500, type="messages")
            image_output = gr.Image(height=500)
        with gr.Row():
            entry = gr.Textbox(label="Chat with our AI Assistant:")
        with gr.Row():
            clear = gr.Button("Clear")

        def do_entry(message, history):
            history += [{"role":"user", "content":message}]
            return "", history

        entry.submit(do_entry, inputs=[entry, chatbot], outputs=[entry, chatbot]).then(
            chat, inputs=chatbot, outputs=[chatbot, image_output]
        )
        clear.click(lambda: None, inputs=None, outputs=chatbot, queue=False)

    ui.launch(inbrowser=True)

if __name__ == "__main__":
    try:
        re.loadSystemPrompts()
        gr.ChatInterface(fn=chatWithTools, type="messages").launch(inbrowser=True)
        # image = artist("New York City")
        # plt.imshow(image)
        # plt.axis('off')  # Hide axes
        # plt.show()  # This will open a new window with the imag
        # showCustomeUI()
    except Exception as e:
        print(f"Error occurred: {e}")
