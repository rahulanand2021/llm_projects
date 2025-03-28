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
GEMINI_MODEL = "gemini-1.5-flash"
openai = None
claude = None
gemini = None

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
    os.environ['GOOGLE_API_KEY'] = os.getenv('GOOGLE_API_KEY')
    # openai_key = os.getenv('OPENAI_API_KEY')
    # anthropic_key = os.getenv('ANTHROPIC_API_KEY')
    # gemini_key = os.getenv('GOOGLE_API_KEY')

def loadOpenAIAndAnthropic():
    global openai , claude, gemini
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
        yield reply.replace('```cpp\n','').replace('```','')
    # write_output(reply)


def optimize_claude(python):
    result = claude.messages.stream(
        model=CLAUDE_MODEL,
        max_tokens=2000,
        system=system_message,
        messages=[{"role": "user", "content": user_prompt_for(python)}],
    )
    reply = ""
    with result as stream:
        for text in stream.text_stream:
            reply += text
            print(text, end="", flush=True)
            yield reply.replace('```cpp\n','').replace('```','')
    # write_output(reply)

def optimize_gemini_(python):
    gemini_key = os.getenv('GOOGLE_API_KEY')
    prompts = [
                {"role": "system", "content": system_message},
                {"role": "user", "content": user_prompt_for(python)}
            ]
    gemini = OpenAI(
        api_key=gemini_key, 
        base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
    )
    stream = gemini.chat.completions.create(
        model=GEMINI_MODEL,
        messages=prompts,
        stream=True
    )
    content=""
    for chunk in stream:
        if chunk.choices[0].delta.content is not None:
            content += chunk.choices[0].delta.content
            yield content

def optimize(python, model):
    if model=="GPT":
        result = optimize_gpt(python)
    elif model=="Claude":
        result = optimize_claude(python)
    else:
        raise ValueError("Unknown model")
    for stream_so_far in result:
        yield stream_so_far   

def executePython(python) :
    try:
        output = io.StringIO()
        sys.stdout = output
        exec(python)
    finally:
        sys.stdout = sys.__stdout__
    return output.getvalue()

def execute_cpp(code):
        write_output(code)
        try:
            compile_cmd = ["g++", "-Ofast", "-std=c++17", "-march=native", "-o", "./UIWithGradio/perfCompare/optimized.exe", "./UIWithGradio/perfCompare/optimized.cpp"]
            compile_result = subprocess.run(compile_cmd, check=True, text=True, capture_output=True)
            run_cmd = ["./UIWithGradio/perfCompare/optimized.exe"]
            run_result = subprocess.run(run_cmd, check=True, text=True, capture_output=True)
            return run_result.stdout
        except subprocess.CalledProcessError as e:
            return f"An error occurred:\n{e.stderr}"

custom_css = """
.python {background-color: #306998;}
.cpp {background-color: orange;}
.buttonc {background-color: green;}
"""        
def showUI(css=custom_css):
    with gr.Blocks(css=css) as ui:
        with gr.Row():
            python = gr.Textbox(label="Python code:", lines=20, value=pi, elem_classes=["python"])
            cpp = gr.Textbox(label="C++ code:", lines=20 , elem_classes=["cpp"])
        with gr.Row():
            model = gr.Dropdown(["GPT", "Claude"], label="Select model", value="GPT")
        with gr.Row():
            pythonOutput = gr.Textbox(label="Python code output:", lines=2)
            cppOutput = gr.Textbox(label="C++ code output:", lines=2)            
        with gr.Row():
            convert = gr.Button("Convert code" , elem_classes=["buttonc"])
        with gr.Row():
            runPython = gr.Button("Run Python code")
            runCpp = gr.Button("Run C++ code")
        convert.click(optimize, inputs=[python, model], outputs=[cpp])
        runPython.click(executePython, inputs=[python], outputs=[pythonOutput])
        runCpp.click(execute_cpp, inputs=[cpp], outputs=[cppOutput])

    ui.launch(inbrowser=True)

if __name__== "__main__" :
    loadAPIKeys()
    loadOpenAIAndAnthropic()
    showUI()


