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

if __name__ == "__main__":
    try:
        print(message_gpt("What is the capital of France."))
    except Exception as e:
        print(f"Error occurred: {e}")