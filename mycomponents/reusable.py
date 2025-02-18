import os
import requests
import json
from dotenv import load_dotenv
from openai import OpenAI
import anthropic

# Initialize as None
openai = None
claude = None
gemini = None

gpt_model = "gpt-4o-mini"
claude_model = "claude-3-haiku-20240307"
gemini_model = "gemini-1.5-flash"

gpt_system_message = "You are a helpful AI Assistant"  # Set default value
claude_system_message = "You are a helpful AI Assistant"  # Set default value
gemini_system_message = "You are a helpful AI Assistant"  # Set default value

def loadDotenvAndCheckAPIKey(modelName):
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

    if modelName == "OpenAI":  
        return openai_api_key
    elif modelName == "Anthropic":
        return anthropic_api_key
    else :
        return google_api_key

def loadOpenAI():
    """Initialize the OpenAI client and return it"""
    print("Loading OpenAI API")
    api_key = loadDotenvAndCheckAPIKey("OpenAI")
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
    """Initialize the Anthropic client and return it"""
    print("Loading Anthropic API")
    api_key = loadDotenvAndCheckAPIKey("Anthropic")
    global claude
    claude = anthropic.Anthropic(api_key=api_key)
    return claude

def getAnthropic():
    """Get or initialize the OpenAI client"""
    global claude
    if claude is None:
        claude = loadAnthropic()
    return claude

def loadGemini():
    """Initialize the Gemini client and return it"""
    print("Loading Gemini API")
    api_key = loadDotenvAndCheckAPIKey("Gemini")
    global gemini
    # claude = anthropic.Anthropic(api_key=api_key)
    gemini = OpenAI(
        api_key=api_key, 
        base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
    )
    return gemini

def getGemini():
    """Get or initialize the OpenAI client"""
    global gemini
    if gemini is None:
        gemini = loadGemini()
    return gemini


def loadSystemPrompts():
    """Load system prompts with default values if not already set"""
    global gpt_system_message
    global claude_system_message
    global gemini_system_message
    if gpt_system_message is None:
        gpt_system_message = "You are a helpful AI Assistant"
    if claude_system_message is None:
        claude_system_message = "You are a helpful AI Assistant"
    if gemini_system_message is None:
        gemini_system_message = "You are a helpful AI Assistant"