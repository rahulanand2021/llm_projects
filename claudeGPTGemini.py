import os
import requests
import json
from dotenv import load_dotenv
from IPython.display import Markdown, display, update_display
from openai import OpenAI
import anthropic
import google.generativeai

# Define Global Variables here
openai = None
claude = None
MODEL = 'gpt-4o-mini'
system_message = None
user_prompt = None
prompts = None

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

def loadSystemAndUserPrompts():
    global system_message
    global user_prompt
    global prompts
    system_message = "You are an assistant that is great at telling jokes"
    user_prompt = "Tell a light-hearted joke for an audience of Data Scientists"
    prompts = [
                {"role": "system", "content": system_message},
                {"role": "user", "content": user_prompt}
            ]

def tellJokeGPT(model):
    completion = openai.chat.completions.create(model=model, messages=prompts, temperature=0.7)
    print(completion.choices[0].message.content)

def tellJokeClaude(model):
    message = claude.messages.create(
    model=model,
    max_tokens=200,
    temperature=0.7,
    system=system_message,
    messages=[
        {"role": "user", "content": user_prompt},
    ],
    )
    print(message.content[0].text)

def streamJokeClaude(model):
    result = claude.messages.stream(
                model=model,
                max_tokens=200,
                temperature=0.7,
                system=system_message,
                messages=[
                    {"role": "user", "content": user_prompt},
                    ],
                )
    with result as stream:
        for text in stream.text_stream:
            print(text, end="", flush=True)

def tellJokeGemini(model):
    google_api_key = os.getenv('GOOGLE_API_KEY')
    gemini_via_openai_client = OpenAI(
        api_key=google_api_key, 
        base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
    )

    response = gemini_via_openai_client.chat.completions.create(
        model=model,
        messages=prompts
    )
    print(response.choices[0].message.content)

def streamBusinessProblemGPT(model):
    prompts = [
        {"role": "system", "content": "You are a helpful assistant that responds in Markdown"},
        {"role": "user", "content": "How do I decide if a business problem is suitable for an LLM solution? Please respond in Markdown."}
        ]
    stream = openai.chat.completions.create(
    model=model,
    messages=prompts,
    temperature=0.7,
    stream=True
)
    for chunk in stream:
        if chunk.choices and chunk.choices[0].delta.content:
            print(chunk.choices[0].delta.content, end="", flush=True)

if __name__ == "__main__":
    loadDotenvAndCheckAPIKey()
    loadOpenAI()
    loadAnthropic()
    loadSystemAndUserPrompts()
    # print("-------------Calling GPT 3.5 Turbo------------------------------------------")
    # tellJokeGPT("gpt-3.5-turbo")
    # print("\n\n")
    # print("-------------Calling GPT 4o Mini------------------------------------------")
    # tellJokeGPT("gpt-4o-mini")
    # print("-------------Calling Claude 3.5 Sonnet 20240620------------------------------------------")
    # tellJokeClaude("claude-3-5-sonnet-20240620")
    # print("-------------Stream with Claude 3.5 Sonnet 20240620---------------------------------------")
    # streamJokeClaude("claude-3-5-sonnet-20240620")
    # print("-------------Calling Gemini 1.5 flash------------------------------------------")
    tellJokeGemini("gemini-1.5-flash")
    # print("-------------End-----------------------------------------\U0001F600 ")
    print("-------------End-----------------------------------------\U0001F600 ")
    # streamBusinessProblemGPT("gpt-4o")
    print("\n\n \U0001f386\U0001f386-------------End-----------------------------------------\U0001f386\U0001f386 ")