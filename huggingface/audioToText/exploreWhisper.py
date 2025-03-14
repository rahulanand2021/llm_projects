from huggingface_hub import login
from transformers import AutoTokenizer, AutoModelForCausalLM, TextStreamer, pipeline
from transformers import AutoProcessor, AutoModelForSpeechSeq2Seq
from dotenv import load_dotenv
import os
import torch
from openai import OpenAI

AUDIO_MODEL = "whisper-1"
LLAMA = "meta-llama/Meta-Llama-3.1-8B-Instruct"
openai_api_key = None

def loadDotenvAndCheckAPIKey():
    global openai_api_key
    load_dotenv(override=True)
    huggingface_api_key = os.getenv('HF_TOKEN')
    openai_api_key = os.getenv('OPENAI_API_KEY')

    if not huggingface_api_key:
        raise ValueError("HuggingFace API key not found in environment variables")
    if huggingface_api_key and huggingface_api_key.startswith('hf_') and len(huggingface_api_key)>10:
        print("Hugging Face API key looks good so far")
    else:
        print("There might be a problem with your Hugging Face API key? Please visit the troubleshooting notebook!")

    if openai_api_key and openai_api_key.startswith('sk-proj-') and len(openai_api_key)>10:
        print("Open AI API key looks good so far")
    else:
        print("There might be a problem with your Open AI API key? Please visit the troubleshooting notebook!")
    return huggingface_api_key

def loadAudioAndTranscribe():
    print("Transcribing Audio")
    audio_filename = "C:\\Learn\\llm\\Audio\\denver_extract.mp3"
    openai = OpenAI(api_key=openai_api_key)
    audio_file = open(audio_filename, "rb")
    transcription = openai.audio.transcriptions.create(model=AUDIO_MODEL, file=audio_file, response_format="text")
    print("Transcribing Audio Completed ....")
    return(transcription)

def loadAudioAndTranscribeUsingPipeline():
    AUDIO_MODEL = "openai/whisper-medium"
    audio_filename = "C:\\Learn\\llm\\Audio\\denver_extract.mp3"
    speech_model = AutoModelForSpeechSeq2Seq.from_pretrained(AUDIO_MODEL, torch_dtype=torch.float16, low_cpu_mem_usage=True, use_safetensors=True)
    speech_model.to('cpu')
    processor = AutoProcessor.from_pretrained(AUDIO_MODEL)

    pipe = pipeline(
        "automatic-speech-recognition",
        model=speech_model,
        tokenizer=processor.tokenizer,
        feature_extractor=processor.feature_extractor,
        torch_dtype=torch.float16,
        return_timestamps=True,
        device='cpu',
        language="en",
    )
    result = pipe(audio_filename)
    transcription = result["text"]
    print(transcription)

def configurePrompt(transcription):
    print("Loading Prompts")
    system_message = "You are an assistant that produces minutes of meetings from transcripts, with summary, key discussion points, takeaways and action items with owners, in markdown."
    user_prompt = f"Below is an extract transcript of a Denver council meeting. Please write minutes in markdown, including a summary with attendees, location and date; discussion points; takeaways; and action items with owners.\n{transcription}"

    messages = [
                {"role": "system", "content": system_message},
                {"role": "user", "content": user_prompt}
    ]
    return messages

def createMinutesOfMeeting(messages):
    print("Starting to Create Minutes of Meeting")
    tokenizer = AutoTokenizer.from_pretrained(LLAMA)
    tokenizer.pad_token = tokenizer.eos_token
    inputs = tokenizer.apply_chat_template(messages, return_tensors="pt")
    streamer = TextStreamer(tokenizer)
    model = AutoModelForCausalLM.from_pretrained(LLAMA, device_map="auto")
    mom = model.generate(inputs, max_new_tokens=2000, streamer=streamer)
    print(mom)

if __name__ == '__main__':
    login(loadDotenvAndCheckAPIKey(), add_to_git_credential=True)
    loadAudioAndTranscribeUsingPipeline()
    # transcription = loadAudioAndTranscribe()
    # messages = configurePrompt(transcription)
    # createMinutesOfMeeting(messages)