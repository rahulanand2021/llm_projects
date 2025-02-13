from reusable import *
import gradio as gr 

def message_gpt(user_prompt):
    # Get or initialize the OpenAI client
    
    # Ensure system message is loaded
    loadSystemPrompts()
    
    messages = [
        {"role": "system", "content": gpt_system_message},
        {"role": "user", "content": user_prompt}
    ]
    
    try:

        completion = getOpenAI().chat.completions.create(
            model=gpt_model , # Changed from gpt-4o-mini to gpt-4
            messages=messages,
        )
        return completion.choices[0].message.content

    except Exception as e:
        print(f"Error making OpenAI API call: {str(e)}")
        return f"An error occurred: {str(e)}"

def stream_gemini(user_prompt):
    loadSystemPrompts()
    prompts = [
                {"role": "system", "content": gemini_system_message},
                {"role": "user", "content": user_prompt}
            ]
    
    stream = getGemini().chat.completions.create(
        model=gemini_model,
        messages=prompts,
        stream=True
    )
    content=""
    for chunk in stream:
        if chunk.choices[0].delta.content is not None:
            content += chunk.choices[0].delta.content
            yield content
    

def message_claude(user_prompt):

    loadSystemPrompts()
    try:
        message = getAnthropic().messages.create(
                    model=claude_model,
                    max_tokens=200,
                    temperature=0.7,
                    system=claude_system_message,
                    messages=[
                        {"role": "user", "content": user_prompt},
                    ]   ,
        )
        return(message.content[0].text)
    except Exception as e:
        print(f"Error making Claude API call: {str(e)}")
        return f"An error occurred: {str(e)}"
    
def shout(text):
    print(f"Shout has been called with input {text}")
    return text.upper()

def stream_gpt(prompt):

    loadSystemPrompts()
    messages = [
        {"role": "system", "content": gpt_system_message},
        {"role": "user", "content": prompt}
      ]
    stream = getOpenAI().chat.completions.create(
        model=gpt_model,
        messages=messages,
        stream=True
    )
    result = ""
    for chunk in stream:
        result += chunk.choices[0].delta.content or ""
        yield result

def stream_claude(prompt):
    result = getAnthropic().messages.stream(
        model=claude_model,
        max_tokens=1000,
        temperature=0.7,
        system=claude_system_message,
        messages=[
            {"role": "user", "content": prompt},
        ],
    )
    response = ""
    with result as stream:
        for text in stream.text_stream:
            response += text or ""
            yield response

def stream_model(prompt, model):
    if model=="GPT":
        result = stream_gpt(prompt)
    elif model=="Claude":
        result = stream_claude(prompt)
    elif model=="Gemini":
        result = stream_gemini(prompt)
    else:
        raise ValueError("Unknown model")
    yield from result



def showUIGPTStream():
     view = gr.Interface(
            fn=stream_gpt,
            inputs=[gr.Textbox(label="Your message:")],
            outputs=[gr.Markdown(label="Response:")],
            flagging_mode="never"
            )
     view.launch(inbrowser=True)

def showUIClaudeStream():
     view = gr.Interface(
            fn=stream_claude,
            inputs=[gr.Textbox(label="Your message:")],
            outputs=[gr.Markdown(label="Response:")],
            flagging_mode="never"
            )
     view.launch(inbrowser=True)

def showUIWithModelSelection():
    view = gr.Interface(
                fn=stream_model,
                inputs=[gr.Textbox(label="Your message:"), gr.Dropdown(["GPT", "Claude","Gemini"], label="Select model", value="GPT")],
                outputs=[gr.Markdown(label="Response:")],
                flagging_mode="never"
    )   
    view.launch(inbrowser=True)   

def showUI():
    #gr.Interface(fn=shout, inputs="textbox", outputs="textbox", flagging_mode="never").launch(share=True)
    #gr.Interface(fn=message_gpt, inputs="textbox", outputs="textbox", flagging_mode="never").launch(inbrowser=True)
    # view = gr.Interface(
    #         fn=message_gemini,
    #         inputs=[gr.Textbox(label="Your message:")],
    #         outputs=[gr.Markdown(label="Response:")],
    #         flagging_mode="never"
    #         )
    # view.launch()

    # print(message_gemini("Tell me a joke !!!"))
    # print(stream_claude("Tell me a Joke"))
    
    showUIWithModelSelection()

if __name__ == "__main__":
    try:
       showUI()
    except Exception as e:
        print(f"Error occurred: {e}")