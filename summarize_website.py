import os
import requests
from dotenv import load_dotenv
from bs4 import BeautifulSoup
from IPython.display import Markdown, display
from openai import OpenAI
from website import Website


def loadDotenv():
    """
    Loads the environment variables from a .env file and retrieves the OpenAI API key.

    Returns:
        str: The OpenAI API key obtained from the environment variables.
    """

    load_dotenv(override=True)
    api_key = os.getenv('OPENAI_API_KEY')
    return api_key

def check_api_key(api_key):

# Check the key
    """
    Check the OpenAI API key to ensure it is valid.

    Args:
        api_key (str): The API key to check.

    Raises:
        ValueError: If the API key is invalid.
    """

    if not api_key:
        print("No API key was found - please head over to the troubleshooting notebook in this folder to identify & fix!")
    elif not api_key.startswith("sk-proj-"):
        print("An API key was found, but it doesn't start sk-proj-; please check you're using the right key - see troubleshooting notebook")
    elif api_key.strip() != api_key:
        print("An API key was found, but it looks like it might have space or tab characters at the start or end - please remove them - see troubleshooting notebook")
    else:
        print("API key found and looks good so far!")

def user_prompt_for(website):
    """
    Returns a user prompt for the OpenAI chat completions API that will lead to a summary of the given website.

    Args:
        website (Website): The website to be summarized.

    Returns:
        str: The user prompt to be passed to the OpenAI API.
    """
    user_prompt = f"You are looking at a website titled {website.title}"
    user_prompt += "\nThe contents of this website is as follows; \
                    please provide a short summary of this website in markdown. \
                    If it includes news or announcements, then summarize these too.\n\n"
    user_prompt += website.text
    return user_prompt

def messages_for(website):
    """
    Returns a list of messages for the OpenAI chat completions API that will lead to a summary of the given website.

    The messages are:
    1. A system message that instructs the model to provide a summary of a website, ignoring navigation-related text.
    2. A user message that includes the contents of the website.

    The model is expected to respond with a markdown-formatted summary of the website content.
    """
    system_prompt = "You are an assistant that analyzes the contents of a website \
                    and provides a short summary, ignoring text that might be navigation related. \
                    Respond in markdown."

    return [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt_for(website)}
    ]

def summarize(url):
    """
    Summarizes the content of a given website URL using OpenAI's GPT-4o-mini model.

    Args:
        url (str): The URL of the website to be summarized.

    Returns:
        str: A markdown-formatted summary of the website content.
    """

    openai = OpenAI()
    website = Website(url)
    response = openai.chat.completions.create(
        model = "gpt-4o-mini",
        messages = messages_for(website)
    )
    return response.choices[0].message.content


def display_summary(url):
    """
    Summarizes the content of a given website URL using OpenAI's GPT-4o-mini model
    and displays the summary to the user.

    Args:
        url (str): The URL of the website to be summarized.
    """
    summary = summarize(url)
    print(summary)

if __name__ == "__main__":
    api_key = loadDotenv()
    check_api_key(api_key)
    display_summary("https://bbc.com")