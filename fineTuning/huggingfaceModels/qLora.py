import os
import re
import math
import json
import random
from dotenv import load_dotenv
from huggingface_hub import login
import matplotlib.pyplot as plt
import numpy as np
import pickle
from tqdm import tqdm
import transformers
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig, TrainingArguments, set_seed
from peft import LoraConfig, PeftModel
from datetime import datetime
import torch
from datasets import load_dataset, Dataset, DatasetDict
from TestingLatest import Tester

BASE_MODEL = 'meta-llama/Meta-Llama-3.1-8B'
FINETUNED_MODEL = "rahulanand2030/pricer-2025-06-14.04.39"

LORA_R = 32
LORA_ALPHA = 64
TARGET_MODULES = ["q_proj", "v_proj", "k_proj", "o_proj"]
DATASET_NAME = f"Rahulanand2030/pricer-data"
tokenizer = any
base_model = any

def loadDotenvAndCheckAPIKey():

    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')
    os.environ['HF_TOKEN'] = os.getenv('HF_TOKEN')
    return huggingface_api_key

def loadOllamaFromHuggingFace():
    global base_model

    try:
        print("Loading the Ollama 8B Model from Huggingface ")
        base_model = AutoModelForCausalLM.from_pretrained(BASE_MODEL,         
                                                        torch_dtype=torch.float16,
                                                        device_map={"": "cpu"},
                                                        low_cpu_mem_usage=True)
        # print(base_model)
        print("Loading Model Complete ")
        return base_model
    except Exception as e:
        print(f"An error occurred: {e}")

def loadDataFromHuggingface():
    dataset = load_dataset(DATASET_NAME)
    train = dataset['train']
    test = dataset['test']
    print(train[0])

def loadTokenizer():
    global tokenizer

    print("Getting Tokenizer from the Ollama Base Model")
    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL, trust_remote_code=True)
    tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "right"
    base_model.generation_config.pad_token_id = tokenizer.pad_token_id
    print("Returning Tokenizer")
    return tokenizer, base_model

def extract_price(s):
    if "Price is $" in s:
      contents = s.split("Price is $")[1]
      contents = contents.replace(',','').replace('$','')
      match = re.search(r"[-+]?\d*\.\d+|\d+", contents)
      return float(match.group()) if match else 0
    return 0

def model_predict(prompt):

    print("Predicting the Price for the given Prompt")
    set_seed(42)
    inputs = tokenizer.encode(prompt, return_tensors="pt").to("cpu")
    attention_mask = torch.ones(inputs.shape, device="cpu")
    outputs = base_model.generate(inputs, max_new_tokens=4, attention_mask=attention_mask, num_return_sequences=1)
    response = tokenizer.decode(outputs[0])
    return extract_price(response)

# def loadOllamaIn8Bits(base_model_32Bits):
#     quant_config = BitsAndBytesConfig(load_in_8bit=True)
#     base_model_8Bits = AutoModelForCausalLM.from_pretrained(BASE_MODEL, quantization_config=quant_config, device_map="auto")
#     print(base_model_8Bits)

if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    base_model_16Bits = loadOllamaFromHuggingFace()
    # loadOllamaIn8Bits(base_model_32Bits)
    # loadDataFromHuggingface()
    loadTokenizer()
    dataset = load_dataset(DATASET_NAME)
    test = dataset['test']
    # print(model_predict(test[0]['text'],tokenizer, base_model))
    Tester.test(model_predict, test)