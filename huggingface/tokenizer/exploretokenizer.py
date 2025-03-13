from huggingface_hub import login
from transformers import AutoTokenizer
from dotenv import load_dotenv
import os

PHI3_MODEL_NAME = "microsoft/Phi-3-mini-4k-instruct"
QWEN2_MODEL_NAME = "Qwen/Qwen2-7B-Instruct"
STARCODER2_MODEL_NAME = "bigcode/starcoder2-3b"

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

def exploreOtherModelTokens():
    phi3_tokenizer = AutoTokenizer.from_pretrained(PHI3_MODEL_NAME)
    text = "I am excited to show Tokenizers in action to my LLM engineers"
    tokens = phi3_tokenizer.encode(text)
    print(tokens)
    print(phi3_tokenizer.batch_decode(tokens))
    messages = [
                {"role": "system", "content": "You are a helpful assistant"},
                {"role": "user", "content": "Tell a light-hearted joke for a room of Data Scientists"}
            ]
    print(phi3_tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True))

    qwen2_tokenizer = AutoTokenizer.from_pretrained(QWEN2_MODEL_NAME)

    text = "I am excited to show Tokenizers in action to my LLM engineers"
    print(phi3_tokenizer.encode(text))
    print()
    print(qwen2_tokenizer.encode(text))
    
def starcoderToken():
    starcoder2_tokenizer = AutoTokenizer.from_pretrained(STARCODER2_MODEL_NAME, trust_remote_code=True)
    
    code = """
    def hello_world(person):
    print("Hello", person)
    """
    tokens = starcoder2_tokenizer.encode(code)

    for token in tokens:
        print(f"{token}={starcoder2_tokenizer.decode(token)}")

def metaTokens():
    tokenizer = AutoTokenizer.from_pretrained('meta-llama/Meta-Llama-3.1-8B-Instruct', trust_remote_code=True)
    text = "I am excited to show Tokenizers in action to my LLM engineers"
    tokens = tokenizer.encode(text)
    print(len(tokens))
    print(tokens)
    print(tokenizer.decode(tokens))
    print(tokenizer.batch_decode(tokens))

def metaInstructModel():
    tokenizer = AutoTokenizer.from_pretrained('meta-llama/Meta-Llama-3.1-8B-Instruct', trust_remote_code=True)
    messages = [
            {"role": "system", "content": "You are a helpful assistant"},
            {"role": "user", "content": "Tell a light-hearted joke for a room of Data Scientists"}
            ]
    prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True ) 
    print(prompt)

if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    # exploreOtherModelTokens()
    # metaTokens()
    # metaInstructModel()
    starcoderToken()