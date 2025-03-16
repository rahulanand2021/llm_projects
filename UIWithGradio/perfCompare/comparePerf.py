import os
import io
import sys
from dotenv import load_dotenv
from openai import OpenAI
import anthropic
import gradio as gr
import subprocess

OPENAI_MODEL = "gpt-4o"
CLAUDE_MODEL = "claude-3-5-sonnet-20240620"
openai = None
claude = None

system_message = "You are an assistant that reimplements Python code in high performance C++ for a Windows PC. "
system_message += "Respond only with C++ code; use comments sparingly and do not provide any explanation other than occasional comments. "
system_message += "The C++ response needs to produce an identical output in the fastest possible time."

pi = """
import time

def calculate(iterations, param1, param2):
    result = 1.0
    for i in range(1, iterations+1):
        j = i * param1 - param2
        result -= (1/j)
        j = i * param1 + param2
        result += (1/j)
    return result

start_time = time.time()
result = calculate(100_000_000, 4, 1) * 4
end_time = time.time()

print(f"Result: {result:.12f}")
print(f"Execution Time: {(end_time - start_time):.6f} seconds")
"""


def loadAPIKeys():
    load_dotenv()
    os.environ['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')
    os.environ['ANTHROPIC_API_KEY'] = os.getenv('ANTHROPIC_API_KEY')
    # openai_key = os.getenv('OPENAI_API_KEY')
    # anthropic_key = os.getenv('ANTHROPIC_API_KEY'

def loadOpenAIAndAnthropic():
    global openai , claude
    openai = OpenAI()
    claude = anthropic.Anthropic()

def user_prompt_for(python):
    user_prompt = "Rewrite this Python code in C++ with the fastest possible implementation that produces identical output in the least time. "
    user_prompt += "Respond only with C++ code; do not explain your work other than a few comments. "
    user_prompt += "Pay attention to number types to ensure no int overflows. Remember to #include all necessary C++ packages such as iomanip.\n\n"
    user_prompt += python
    return user_prompt

def write_output(cpp):
    code = cpp.replace("```cpp","").replace("```","")
    with open("./UIWithGradio/perfCompare/optimized.cpp", "w") as f:
        f.write(code)
def messages_for(python):
    return [
        {"role": "system", "content": system_message},
        {"role": "user", "content": user_prompt_for(python)}
    ]

def optimize_gpt(python):    
    stream = openai.chat.completions.create(model=OPENAI_MODEL, messages=messages_for(python), stream=True)
    reply = ""
    for chunk in stream:
        fragment = chunk.choices[0].delta.content or ""
        reply += fragment
        print(fragment, end='', flush=True)
    write_output(reply)


if __name__== "__main__" :
    loadAPIKeys()
    loadOpenAIAndAnthropic()
    optimize_gpt(pi)


