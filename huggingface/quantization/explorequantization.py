from huggingface_hub import login
from transformers import AutoTokenizer, AutoModelForCausalLM, TextStreamer, BitsAndBytesConfig
from dotenv import load_dotenv
import os
import torch


LLAMA = "meta-llama/Meta-Llama-3.1-8B-Instruct"
# PHI3 = "microsoft/Phi-3-mini-4k-instruct"
# GEMMA2 = "google/gemma-2-2b-it"
# QWEN2 = "Qwen/Qwen2-7B-Instruct" 
# MIXTRAL = "mistralai/Mixtral-8x7B-Instruct-v0.1"
messages = [
                {"role": "system", "content": "You are a helpful assistant"},
                {"role": "user", "content": "Tell a light-hearted joke for a room of Data Scientists"}
            ]

def loadDotenvAndCheckAPIKey():

    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')

    if not huggingface_api_key:
        raise ValueError("HuggingFace API key not found in environment variables")
    if huggingface_api_key and huggingface_api_key.startswith('hf_') and len(huggingface_api_key)>10:
        print("API key looks good so far")
    else:
        print("There might be a problem with your API key? Please visit the troubleshooting notebook!")
    return huggingface_api_key

def generate_withQuantization(model, messages):

    quant_config =  BitsAndBytesConfig(
                        load_in_4bit=True,
                        bnb_4bit_use_double_quant=True,
                        bnb_4bit_compute_dtype=torch.bfloat16,
                        bnb_4bit_quant_type="nf4"
                )
    tokenizer = AutoTokenizer.from_pretrained(model)
    tokenizer.pad_token = tokenizer.eos_token
    inputs = tokenizer.apply_chat_template(messages, return_tensors="pt", add_generation_prompt=True).to("cuda")
    streamer = TextStreamer(tokenizer)
    model = AutoModelForCausalLM.from_pretrained(model, device_map="auto", quantization_config=quant_config)
    outputs = model.generate(inputs, max_new_tokens=80, streamer=streamer)

    del tokenizer, streamer, model, inputs, outputs
    torch.cuda.empty_cache()

def generate_withOutQuantization(model, messages):
    tokenizer = AutoTokenizer.from_pretrained(model)
    tokenizer.pad_token = tokenizer.eos_token
    inputs = tokenizer.apply_chat_template(messages, return_tensors="pt", add_generation_prompt=True).to("cpu")
    streamer = TextStreamer(tokenizer)
    model = AutoModelForCausalLM.from_pretrained(model, device_map="auto")
    outputs = model.generate(inputs, max_new_tokens=80, streamer=streamer)

    del tokenizer, streamer, model, inputs, outputs
    torch.cuda.empty_cache()

if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    generate_withOutQuantization(LLAMA, messages)