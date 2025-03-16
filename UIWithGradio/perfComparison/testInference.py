from huggingface_hub import InferenceClient
import json
import gradio as gr


# parsed_data = json.loads(completion.choices[0].message)
# content = parsed_data[0]["content"]
# print(completion.choices[0].message["content"])

def askInferenceModel(question):
    client = InferenceClient(
        provider="hyperbolic",
        api_key="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",
    )
    messages = [
        {
            "role": "user",
            "content": question
        }
    ]
    completion = client.chat.completions.create(
        model="Qwen/QwQ-32B", 
        messages=messages, 
        temperature=0.1,
        max_tokens=5000,
        stream=True  
    )
    reply = ""

    for chunk in completion:
        fragment = chunk.choices[0].delta.content or ""
        reply += fragment
        yield reply

custom_css = """
/* Target the button directly with more specific selectors */
.gradio-container .gr-button, 
.gradio-container button.gr-button,
.gradio-container button {
    background-color: #04AA6D !important; /* Green */
    border: none !important;
    color: white !important;
    padding: 15px 32px !important;
    text-align: center !important;
    text-decoration: none !important;
    display: inline-block !important;
    font-size: 16px !important;
}

.footer {
    display: none !important;
}

/* Alternative approach if the above doesn't work */
.gradio-footer {
    display: none !important;
}


/* If the buttons are in a specific container */
.gradio-container .footer-links,
.gradio-container .footer-buttons {
    display: none !important;
}

/* Specifically targeting "Use with API" and other buttons */
.footer-links a,
.footer-buttons button {
    display: none !important;
}

/* Most specific approach - if you know the exact classes */
.footer-button, 
.api-button, 
.share-button, 
.duplicate-button {
    display: none !important;
}

.settings-svelte-1byz9vf {
    display: none !important;
}

"""

def showGradioUI(css=custom_css):
    with gr.Blocks(css=css) as ui:  # Pass the css parameter here
        gr.Markdown("## Ask a Question to Qwen")
        with gr.Row():
            question = gr.Textbox(label="Your Question:", value="", lines=10)
            answer = gr.Markdown(label="Answer:")
        with gr.Row():
            with gr.Column(scale=2):
                pass
            # Create small button in center column
            with gr.Column(scale=1):
                btnClick = gr.Button("Ask Question")
            
            # Add an empty column for spacing on the right
            with gr.Column(scale=2):
                pass
        btnClick.click(askInferenceModel, inputs=[question], outputs=[answer])
    ui.launch(inbrowser=True, 
                show_api=False,
                show_error=False,
                share=False)
        
if __name__ == '__main__':
    showGradioUI()
