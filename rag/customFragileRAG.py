import os
import glob
from dotenv import load_dotenv
import gradio as gr
from openai import OpenAI

MODEL = "gpt-4o-mini"

context = {}
system_message = "You are an expert in answering accurate questions about Insurellm, \
                the Insurance Tech company. Give brief, accurate answers. If you don't know the answer, \
                say so. Do not make anything up if you haven't been provided with relevant context."

def loadAPIKeys():

    load_dotenv()
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')
    # openai = OpenAI()
    # print(openai)

def loadContext():
    global context
    employees = glob.glob("./rag/knowledge-base/employees/*")
    for employee in employees:
        name = employee.split(' ')[-1][:-3]
        doc = None
        with open(employee, "r", encoding="UTF-8") as f:
            doc = f.read()
        context[name] = doc

def loadProducts():
    products = glob.glob("./rag/knowledge-base/products/*")

    for product in products:
        name = product.split(os.sep)[-1][:-3]
        doc = ""
        with open(product, "r", encoding="utf-8") as f:
            doc = f.read()
        context[name]=doc

def loadCompany():
    company = glob.glob("./rag/knowledge-base/company/*")
   
    for co in company:
        name = co.split(os.sep)[-1][:-3]
        doc = ""
        with open(co, "r", encoding="utf-8") as f:
            doc = f.read()
        context[name]=doc

def get_relevant_context(message):
    relevant_context = []
    for context_title, context_details in context.items():
        if context_title.lower() in message.lower():
            relevant_context.append(context_details)
    return relevant_context          

def add_context_to_pass_to_LLM(message):
    relevant_context = get_relevant_context(message)
    if relevant_context:
        message += "\n\nThe following additional context might be relevant in answering this question:\n\n"
        for relevant in relevant_context:
            message += relevant + "\n\n"
    return message

def chat(message, history):
    messages = [{"role": "system", "content": system_message}] + history
    message = add_context_to_pass_to_LLM(message)
    messages.append({"role": "user", "content": message})

    stream = OpenAI().chat.completions.create(model=MODEL, messages=messages, stream=True)

    response = ""
    for chunk in stream:
        response += chunk.choices[0].delta.content or ''
        yield response

if __name__ == "__main__" :
    # loadAPIKeys()
    loadContext()
    loadProducts()
    loadCompany()
    view = gr.ChatInterface(chat, type="messages").launch(inbrowser=True)
