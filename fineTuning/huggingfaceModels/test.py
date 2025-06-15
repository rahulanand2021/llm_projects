import torch
from transformers import AutoModelForCausalLM

try:
    model = AutoModelForCausalLM.from_pretrained(
        "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
        torch_dtype=torch.float16,
        device_map={"": "cpu"},
        low_cpu_mem_usage=True
    )
    print("✅ Success: torch.float16 worked on CPU")
except Exception as e:
    print("❌ Failed: torch.float16 is not usable on your CPU")
    print("Error:", e)
