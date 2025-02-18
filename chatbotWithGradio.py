import os
from dotenv import load_dotenv
from openai import OpenAI
import gradio as gr
from reusable import *



# gpt_system_message = "You are a helpful assistant"

loadSystemPrompts()

def chat(message, history):
    gpt_system_message = "You are a helpful assistant in a clothes store. You should try to gently encourage \
        the customer to try items that are on sale. Hats are 60% off, and most other items are 50% off. \
        For example, if the customer says 'I'm looking to buy a hat', \
        you could reply something like, 'Wonderful - we have lots of hats - including several that are part of our sales evemt.'\
        Encourage the customer to buy hats if they are unsure what to get."

    gpt_system_message += "\nIf the customer asks for shoes, you should respond that shoes are not on sale today, \
        but remind the customer to look at hats!"
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

    stream = getOpenAI().chat.completions.create(
        model=gpt_model, 
        messages=messages, 
        stream=True)

    response = ""
    for chunk in stream:
        response += chunk.choices[0].delta.content or ''
        yield response

def chatNew(message, history):

    relevant_system_message = gpt_system_message

    if 'belt' in message:
        relevant_system_message += " The store does not sell belts; if you are asked for belts, be sure to point out other items on sale."
    
    messages = [{"role": "system", "content": relevant_system_message}] + history + [{"role": "user", "content": message}]

    stream = getOpenAI().chat.completions.create(
            model=gpt_model, 
            messages=messages, 
            stream=True)

    response = ""
    for chunk in stream:
        response += chunk.choices[0].delta.content or ''
        yield response

if __name__ == "__main__":
    try:
        gr.ChatInterface(fn=chatNew, type="messages").launch(inbrowser=True)
    except Exception as e:
        print(f"Error occurred: {e}")