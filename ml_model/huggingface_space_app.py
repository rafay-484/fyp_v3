"""
Gradio app for Hugging Face Spaces
Copy this to your Hugging Face Space as 'app.py'
"""

import gradio as gr
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# Load model - replace with your model ID
MODEL_NAME = "YOUR_USERNAME/urdu-punjabi-classifier"

print(f"Loading model: {MODEL_NAME}")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
model.eval()
print("Model loaded successfully!")

def detect_language(text):
    """
    Detect if text is Urdu or Punjabi
    """
    if not text or not text.strip():
        return {
            "error": "Please enter some text",
            "language": None,
            "confidence": 0
        }
    
    # Tokenize and predict
    inputs = tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        max_length=128,
        padding=True
    )
    
    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.softmax(outputs.logits, dim=1)
        predicted_class = torch.argmax(probs, dim=1).item()
        confidence = probs[0][predicted_class].item()
    
    # Map prediction to language
    language = "urdu" if predicted_class == 0 else "punjabi"
    
    return {
        "language": language,
        "confidence": round(confidence, 4),
        "urdu_probability": round(probs[0][0].item(), 4),
        "punjabi_probability": round(probs[0][1].item(), 4)
    }

# Create Gradio interface
demo = gr.Interface(
    fn=detect_language,
    inputs=gr.Textbox(
        label="Enter Text",
        placeholder="Type Urdu or Punjabi text here...",
        lines=3
    ),
    outputs=gr.JSON(label="Detection Result"),
    title="🤖 Urdu/Punjabi Language Detector",
    description="""
    AI-powered language detection using XLM-RoBERTa.
    
    Enter text in Urdu or Punjabi and get instant classification with confidence scores!
    """,
    examples=[
        ["السلام علیکم"],
        ["آپ کیسے ہیں؟"],
        ["میں ٹھیک ہوں شکریہ"],
        ["ਸਤ ਸ੍ਰੀ ਅਕਾਲ"],
        ["ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"],
        ["میں ٹھیک آں شکریہ"],
    ],
    theme=gr.themes.Soft(),
    allow_flagging="never"
)

if __name__ == "__main__":
    demo.launch()
