import os
import re
import math
import json
import random
from dotenv import load_dotenv
from huggingface_hub import login
from items import Item
import matplotlib.pyplot as plt
import numpy as np
import pickle
from collections import Counter
from openai import OpenAI
from anthropic import Anthropic
from Testing import Tester

openai = None
claude = None

def loadDotenvAndCheckAPIKey():

    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')
    os.environ['ANTHROPIC_API_KEY'] = os.getenv('ANTHROPIC_API_KEY')
    os.environ['HF_TOKEN'] = os.getenv('HF_TOKEN')
    return huggingface_api_key

def frontierObject():
    global openai
    global claude
    openai = OpenAI()
    claude = Anthropic()

def loadTestData():

    with open('fineTuning/dataCuration/test.pkl', 'rb') as file:
        curatedTestData = pickle.load(file)

    with open('fineTuning/dataCuration/train.pkl', 'rb') as file:
        curatedTrainData = pickle.load(file)

    fine_tune_train = curatedTrainData[:200]
    fine_tune_validation = curatedTrainData[200:250]

    return fine_tune_train, fine_tune_validation, curatedTestData

def messages_for(item):
    system_message = "You estimate prices of items. Reply only with the price, no explanation"
    user_prompt = item.test_prompt().replace(" to the nearest dollar","").replace("\n\nPrice is $","")
    return [
        {"role": "system", "content": system_message},
        {"role": "user", "content": user_prompt},
        {"role": "assistant", "content": f"Price is ${item.price:.2f}"}
    ]

def messages_for_Test(item):
    system_message = "You estimate prices of items. Reply only with the price, no explanation"
    user_prompt = item.test_prompt().replace(" to the nearest dollar","").replace("\n\nPrice is $","")
    return [
        {"role": "system", "content": system_message},
        {"role": "user", "content": user_prompt},
        {"role": "assistant", "content": "Price is $"}
    ]

def get_price(s):
    s = s.replace('$','').replace(',','')
    match = re.search(r"[-+]?\d*\.\d+|\d+", s)
    return float(match.group()) if match else 0

#JSONL Format is required by the OpenAI to train the Model
def make_jsonl(items):
    result = ""
    for item in items:
        messages = messages_for(item)
        messages_str = json.dumps(messages)
        result += '{"messages": ' + messages_str +'}\n'
    return result.strip()

def write_jsonl(items, filename):
    with open(filename, "w") as f:
        jsonl = make_jsonl(items)
        f.write(jsonl)

def loadTrainAndValidationFile():
    with open("fineTuning/dataCuration/fine_tune_train.jsonl", "rb") as f:
        train_file = openai.files.create(file=f, purpose="fine-tune")
    with open("fineTuning/dataCuration/fine_tune_validation.jsonl", "rb") as f:
        validation_file = openai.files.create(file=f, purpose="fine-tune")

    return train_file, validation_file

def callOpenAIForTraining(train_file, validation_file):

    wandb_integration = {"type": "wandb", "wandb": {"project": "gpt-pricer"}}

    openai.fine_tuning.jobs.create(
        training_file=train_file.id,
        validation_file=validation_file.id,
        model="gpt-4o-mini-2024-07-18",
        seed=42,
        hyperparameters={"n_epochs": 1},
        integrations = [wandb_integration],
        suffix="pricer"
    )
    job_id = openai.fine_tuning.jobs.list(limit=1).data[0].id
    print(job_id)

def checkDetailsOfJobIdForFineTuning(job_id):
    # print(openai.fine_tuning.jobs.retrieve(job_id))
    # print(openai.fine_tuning.jobs.list_events(fine_tuning_job_id=job_id, limit=10).data)
    fine_tuned_model_name = openai.fine_tuning.jobs.retrieve(job_id).fine_tuned_model
    print(f'Fined Tuned Model Name is : {fine_tuned_model_name}')
    return fine_tuned_model_name

def gpt_fine_tuned(item, fine_tuned_model_name ):
    response = openai.chat.completions.create(
        model=fine_tuned_model_name, 
        messages=messages_for_Test(item),
        seed=42,
        max_tokens=7
    )
    reply = response.choices[0].message.content
    return get_price(reply)

def gpt_fine_tunedWithModelName(item):
    response = openai.chat.completions.create(
        model="ft:gpt-4o-mini-2024-07-18:rahulorganization:pricer:Bh0ajKdM", 
        messages=messages_for_Test(item),
        seed=42,
        max_tokens=7
    )
    reply = response.choices[0].message.content
    return get_price(reply)

if __name__ == '__main__':
    # login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    frontierObject()
    fine_tune_train, fine_tune_validation, curatedTestData  = loadTestData()
    # print(make_jsonl(fine_tune_train[:3]))
    # write_jsonl(fine_tune_train, "fineTuning/dataCuration/fine_tune_train.jsonl")
    # write_jsonl(fine_tune_validation, "fineTuning/dataCuration/fine_tune_validation.jsonl")
    # train_file, validation_file = loadTrainAndValidationFile()
    # print(train_file)
    # print(validation_file)
    # callOpenAIForTraining(train_file, validation_file)
    fine_tuned_model_name = checkDetailsOfJobIdForFineTuning("ftjob-1BwgUKKK0nwdRSktq58jPbcO")
    # print(gpt_fine_tuned(curatedTestData[0], fine_tuned_model_name))
    # print(curatedTestData[0].price)
    Tester.test(gpt_fine_tunedWithModelName, curatedTestData)


