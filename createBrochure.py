import os
import requests
import json
from typing import List
from dotenv import load_dotenv
from bs4 import BeautifulSoup
from IPython.display import Markdown, display, update_display
from openai import OpenAI
from website import WebsiteAdvanced

openai = None
MODEL = 'gpt-4o-mini'

def loadDotenvAndCheckAPIKey():
    load_dotenv(override=True)
    api_key = os.getenv('OPENAI_API_KEY')

    if api_key and api_key.startswith('sk-proj-') and len(api_key)>10:
        print("API key looks good so far")
    else:
        print("There might be a problem with your API key? Please visit the troubleshooting notebook!")
    return api_key

def loadOpenAI():
    global openai
    openai = OpenAI()

def get_links_user_prompt(website):
    user_prompt = f"Here is the list of links on the website of {website.url} - "
    user_prompt += "please decide which of these are relevant web links for a brochure about the company, \
    respond with the full https URL in JSON format. \
    Do not include Terms of Service, Privacy, email links.\n"
    user_prompt += "Links (some might be relative links):\n"
    user_prompt += "\n".join(website.links)
    return user_prompt

def get_Relevant_links_for_website(url):
    link_system_prompt = "You are provided with a list of links found on a webpage. \
                          You are able to decide which of the links would be most relevant to include in a brochure about the company, \
                          such as links to an About page, or a Company page, or Careers/Jobs pages.\n"
    link_system_prompt += "You should respond in JSON as in this example:"
    link_system_prompt += """
    {
        "links": [
            {"type": "about page", "url": "https://full.url/goes/here/about"},
            {"type": "careers page": "url": "https://another.full.url/careers"}
        ]
    }
    """

    website = WebsiteAdvanced(url)
    response = openai.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": link_system_prompt},
            {"role": "user", "content": get_links_user_prompt(website)}
      ],
        response_format={"type": "json_object"}
    )
    result = response.choices[0].message.content
    return json.loads(result)


def get_all_details(url):
    result = "Landing page:\n"
    result += WebsiteAdvanced(url).get_contents()
    links = get_Relevant_links_for_website(url)
    print("Found links:", links)
    for link in links["links"]:
        result += f"\n\n{link['type']}\n"
        result += WebsiteAdvanced(link["url"]).get_contents()
    return result

def get_brochure_user_prompt(company_name, url):
    user_prompt = f"You are looking at a company called: {company_name}\n"
    user_prompt += f"Here are the contents of its landing page and other relevant pages; use this information to build a short brochure of the company in markdown.\n"
    user_prompt += get_all_details(url)
    user_prompt = user_prompt[:5_000] # Truncate if more than 5,000 characters
    return user_prompt

def create_brochure(company_name, url):
    
    system_prompt = "You are an assistant that analyzes the contents of several relevant pages from a company website \
    and creates a short brochure about the company for prospective customers, investors and recruits. Respond in markdown.\
    Include details of company culture, customers and careers/jobs if you have the information."

    response = openai.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": get_brochure_user_prompt(company_name, url)}
          ],
    )
    result = response.choices[0].message.content
    display(Markdown(result))
    return result


def stream_brochure(company_name, url):
    
    system_prompt = "You are an assistant that analyzes the contents of several relevant pages from a company website \
    and creates a short brochure about the company for prospective customers, investors and recruits. Respond in markdown.\
    Include details of company culture, customers and careers/jobs if you have the information."

    result = openai.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": get_brochure_user_prompt(company_name, url)}
          ],
        stream=True
    )

    # Only used when running in Jutyper Lab for the Streaming output
    
    # response = ""
    # display_handle = display(Markdown(""), display_id=True)
    # for chunk in stream:
    #     response += chunk.choices[0].delta.content or ''
    #     response = response.replace("```","").replace("markdown", "")
    #     # update_display(Markdown(response), display_id=display_handle.display_id)

    for chunk in result:
        if chunk.choices and chunk.choices[0].delta.content:
            print(chunk.choices[0].delta.content, end="", flush=True)

if __name__ == "__main__":
    api_key = loadDotenvAndCheckAPIKey()
    loadOpenAI()
    stream_brochure("OpenAI", "https://openai.com")