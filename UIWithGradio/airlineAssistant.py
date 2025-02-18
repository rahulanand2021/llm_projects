import os
import sys
from dotenv import load_dotenv
from openai import OpenAI
import gradio as gr
import json
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(project_root)

from mycomponents import reusable as re

ticket_prices = {"london": "$799", "paris": "$899", "tokyo": "$1400", "berlin": "$499"}

def chat(message, history):
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

def get_ticket_price(destination_city):
    print(f"Tool get_ticket_price called for {destination_city}")
    city = destination_city.lower()
    return ticket_prices.get(city, "Unknown")

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

# And this is included in a list of tools:

tools = [{"type": "function", "function": loadPriceFunction()}]

def handle_tool_call(message):
    tool_call = message.tool_calls[0]
    arguments = json.loads(tool_call.function.arguments)
    city = arguments.get('destination_city')
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

    response = re.getOpenAI().chat.completions.create(
                model=re.gpt_model, 
                messages=messages, 
                tools=tools)
    print(f"Full Response from LLM {response}")
    if response.choices[0].finish_reason=="tool_calls":
        message = response.choices[0].message
        print(f"Message from LLM is {message}" )
        response, city = handle_tool_call(message)
        print(f"Response from the function call is {response}")
        messages.append(message)
        messages.append(response)
        response = re.getOpenAI().chat.completions.create(
            model=re.gpt_model, 
            messages=messages)
    
    return response.choices[0].message.content



if __name__ == "__main__":
    try:
        re.loadSystemPrompts()
        gr.ChatInterface(fn=chatWithTools, type="messages").launch(inbrowser=True)
      #  print(get_ticket_price("dsjflds"))
    except Exception as e:
        print(f"Error occurred: {e}")
