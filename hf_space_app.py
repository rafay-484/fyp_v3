import gradio as gr
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

MODEL_NAME = "RAFAY-484/Urdu-Punjabi"

print(f"Loading model: {MODEL_NAME}")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
model.eval()
print("Model loaded successfully!")

def detect_language(text):
    """Detect if text is Urdu or Punjabi"""
    if not text or not text.strip():
        return {
            "error": "Please enter some text",
            "language": None,
            "confidence": 0
        }
    
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
    
    language = "urdu" if predicted_class == 0 else "punjabi"
    
    return {
        "language": language,
        "confidence": round(confidence, 4),
        "urdu_probability": round(probs[0][0].item(), 4),
        "punjabi_probability": round(probs[0][1].item(), 4)
    }

demo = gr.Interface(
    fn=detect_language,
    inputs=gr.Textbox(
        label="Enter Urdu or Punjabi text",
        placeholder="مثال: السلام علیکم یا ਸਤ ਸ੍ਰੀ ਅਕਾਲ",
        lines=3
    ),
    outputs=gr.JSON(label="Detection Result"),
    title="🌍 Urdu/Punjabi Language Detector by RAFAY-484",
    description="AI-powered language detection for Urdu (اردو) and Punjabi (پنجابی)",
    examples=[
        ["السلام علیکم، آپ کیسے ہیں؟"],
        ["ਸਤ ਸ੍ਰੀ ਅਕਾਲ، ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"],
        ["میں آج بہت خوش ہوں"],
        ["ਮੈਂ ਅੱਜ ਬਹੁਤ ਖੁਸ਼ ਹਾਂ"],
        ["پاکستان ایک خوبصورت ملک ہے"],
        ["ਪੰਜਾਬ ਇੱਕ ਸੁੰਦਰ ਥਾਂ ਹੈ"]
    ],
    theme=gr.themes.Soft(),
    analytics_enabled=False
)

if __name__ == "__main__":
    demo.launch()
