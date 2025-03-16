import requests
import os
from dotenv import load_dotenv
import json

# Load environment variables from .env file
load_dotenv()

# Get API token from environment variables
API_TOKEN = os.getenv("HF_TOKEN")

API_URL = "https://api-inference.huggingface.co/models/microsoft/Phi-3-mini-4k-instruct"

headers = {"Authorization": f"Bearer {API_TOKEN}"}
prompt = "Explain cloud computing in details. Pls give examples of the industry"

def query(payload):
    test = []

    response = requests.post(API_URL, headers=headers, json=payload)
    print("Status code:", response.status_code)
    parsed_data = json.loads(response.text)
    generated_text = parsed_data[0]["generated_text"]

    return(generated_text)

output = query({
    "inputs": prompt,
        "parameters": {
        "max_new_tokens": 1250,
        "temperature": 0.1,
        "top_p": 0.95
    }
})

print(output)