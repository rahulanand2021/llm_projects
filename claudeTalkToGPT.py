import os
import requests
import json
from dotenv import load_dotenv
from openai import OpenAI
import anthropic

openai = None
claude = None

gpt_model = "gpt-4o-mini"
claude_model = "claude-3-haiku-20240307"
gpt_system_message = None
claude_system_message = None

gpt_messages = ["Hi there"]
claude_messages = ["Hi"]

def loadDotenvAndCheckAPIKey():
    load_dotenv(override=True)
    # api_key = os.getenv('OPENAI_API_KEY')
    openai_api_key = os.getenv('OPENAI_API_KEY')
    anthropic_api_key = os.getenv('ANTHROPIC_API_KEY')
    google_api_key = os.getenv('GOOGLE_API_KEY')

    if openai_api_key and openai_api_key.startswith('sk-proj-') and len(openai_api_key)>10:
        print("API key looks good so far")
    else:
        print("There might be a problem with your API key? Please visit the troubleshooting notebook!")
    if anthropic_api_key:
        print(f"Anthropic API Key exists and begins {anthropic_api_key[:7]}")
    else:
        print("Anthropic API Key not set")

    if google_api_key:
        print(f"Google API Key exists and begins {google_api_key[:8]}")
    else:
        print("Google API Key not set")    
    # return api_key

def loadOpenAI():
    global openai
    openai = OpenAI()

def loadAnthropic():
    global claude
    claude = anthropic.Anthropic()

def loadSystemPrompts():
    global gpt_system_message
    global claude_system_message
    gpt_system_message    = "You are a chatbot who is very argumentative; \
                             you disagree with anything in the conversation and you challenge everything, in a snarky way."

    claude_system_message = "You are a very polite, courteous chatbot. You try to agree with \
                             everything the other person says, or find common ground. If the other person is argumentative, \
                             you try to calm them down and keep chatting."
    
    # claude_system_message    = "You are a chatbot who is very argumentative; \
    #                          you disagree with anything in the conversation and you challenge everything, in a snarky way."

    # gpt_system_message = "You are a very polite, courteous chatbot. You try to agree with \
    #                          everything the other person says, or find common ground. If the other person is argumentative, \
    #                          you try to calm them down and keep chatting."


def call_gpt():

    messages = [{"role": "system", "content": gpt_system_message}]

    for gpt, claude in zip(gpt_messages, claude_messages):
        messages.append({"role": "assistant", "content": gpt})
        messages.append({"role": "user", "content": claude})
        completion = openai.chat.completions.create(
        model=gpt_model,
        messages=messages
    )
    return completion.choices[0].message.content

def call_claude():
    messages = []
    for gpt_message, claude_message in zip(gpt_messages, claude_messages):
        messages.append({"role": "user", "content": gpt_message})
        messages.append({"role": "assistant", "content": claude_message})
        messages.append({"role": "user", "content": gpt_messages[-1]})
        message = claude.messages.create(
        model=claude_model,
        system=claude_system_message,
        messages=messages,
        max_tokens=500
    )
    return message.content[0].text

def coversationBetweenClaudeAndGPT():

    print(f"GPT:\n{gpt_messages[0]}\n")
    print(f"Claude:\n{claude_messages[0]}\n")

    for i in range(5):
        gpt_next = call_gpt()
        print(f"GPT:\n{gpt_next}\n")
        gpt_messages.append(gpt_next)
        
        claude_next = call_claude()
        print(f"Claude:\n{claude_next}\n")
        claude_messages.append(claude_next)


if __name__ == "__main__":
    loadDotenvAndCheckAPIKey()
    loadOpenAI()
    loadAnthropic()
    loadSystemPrompts()

    # print(call_gpt())
    # print(call_claude())
    coversationBetweenClaudeAndGPT()
