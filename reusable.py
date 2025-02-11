import os
import requests
import json
from dotenv import load_dotenv
from openai import OpenAI
import anthropic

# Initialize as None
openai = None
claude = None

gpt_model = "gpt-4o-mini"
claude_model = "claude-3-haiku-20240307"
gpt_system_message = "You are a helpful AI Assistant"  # Set default value
claude_system_message = "You are a helpful AI Assistant"  # Set default value

def loadDotenvAndCheckAPIKey():
    load_dotenv(override=True)
    openai_api_key = os.getenv('OPENAI_API_KEY')
    anthropic_api_key = os.getenv('ANTHROPIC_API_KEY')
    google_api_key = os.getenv('GOOGLE_API_KEY')

    if not openai_api_key:
        raise ValueError("OpenAI API key not found in environment variables")

    if openai_api_key and openai_api_key.startswith('sk-') and len(openai_api_key)>10:
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
    return openai_api_key

def loadOpenAI():
    """Initialize the OpenAI client and return it"""
    print("Loading OpenAI API")
    api_key = loadDotenvAndCheckAPIKey()
    global openai
    openai = OpenAI(api_key=api_key)
    return openai

def getOpenAI():
    """Get or initialize the OpenAI client"""
    global openai
    if openai is None:
        openai = loadOpenAI()
    return openai

def loadAnthropic():
    global claude
    claude = anthropic.Anthropic()

def loadSystemPrompts():
    """Load system prompts with default values if not already set"""
    global gpt_system_message
    global claude_system_message
    if gpt_system_message is None:
        gpt_system_message = "You are a helpful AI Assistant"
    if claude_system_message is None:
        claude_system_message = "You are a helpful AI Assistant"