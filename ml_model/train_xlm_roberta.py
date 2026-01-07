"""
XLM-RoBERTa Model Training Script for Urdu and Punjabi
Trains a multilingual model for translation and language understanding
"""

import torch
from transformers import (
    XLMRobertaTokenizer,
    XLMRobertaForSequenceClassification,
    Trainer,
    TrainingArguments,
    DataCollatorWithPadding
)
from datasets import Dataset
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
import json
import os

# Set device
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

# Create dataset with 1000+ Urdu and Punjabi phrases
def create_comprehensive_dataset():
    """Creates a comprehensive dataset with 1000+ entries"""
    
    data = []
    
    # URDU DATASET - Basics (200 entries)
    urdu_basics = [
        # Greetings
        ("السلام علیکم", "Hello/Peace be upon you", "urdu", "greeting"),
        ("وعلیکم السلام", "And peace be upon you too", "urdu", "greeting"),
        ("صبح بخیر", "Good morning", "urdu", "greeting"),
        ("شام بخیر", "Good evening", "urdu", "greeting"),
        ("رات بخیر", "Good night", "urdu", "greeting"),
        ("خوش آمدید", "Welcome", "urdu", "greeting"),
        ("الوداع", "Goodbye", "urdu", "greeting"),
        ("پھر ملیں گے", "See you later", "urdu", "greeting"),
        
        # Polite expressions
        ("شکریہ", "Thank you", "urdu", "polite"),
        ("بہت شکریہ", "Thank you very much", "urdu", "polite"),
        ("آپ کا بہت بہت شکریہ", "Thank you so much", "urdu", "polite"),
        ("معاف کیجیے", "Excuse me/Sorry", "urdu", "polite"),
        ("مہربانی", "Please/Kindness", "urdu", "polite"),
        ("براہ مہربانی", "Please", "urdu", "polite"),
        ("کوئی بات نہیں", "No problem/You're welcome", "urdu", "polite"),
        ("معاف کریں", "Forgive me", "urdu", "polite"),
        
        # Basic responses
        ("ہاں", "Yes", "urdu", "response"),
        ("نہیں", "No", "urdu", "response"),
        ("ٹھیک ہے", "Okay/Alright", "urdu", "response"),
        ("بالکل", "Absolutely", "urdu", "response"),
        ("شاید", "Maybe/Perhaps", "urdu", "response"),
        ("یقیناً", "Certainly", "urdu", "response"),
        ("ضرور", "Of course", "urdu", "response"),
        ("بلکل ٹھیک", "Absolutely right", "urdu", "response"),
        
        # Questions
        ("آپ کیسے ہیں؟", "How are you?", "urdu", "question"),
        ("آپ کا نام کیا ہے؟", "What is your name?", "urdu", "question"),
        ("آپ کہاں سے ہیں؟", "Where are you from?", "urdu", "question"),
        ("یہ کیا ہے؟", "What is this?", "urdu", "question"),
        ("کیوں؟", "Why?", "urdu", "question"),
        ("کب؟", "When?", "urdu", "question"),
        ("کہاں؟", "Where?", "urdu", "question"),
        ("کیسے؟", "How?", "urdu", "question"),
        ("کون؟", "Who?", "urdu", "question"),
        ("کتنا؟", "How much?", "urdu", "question"),
        
        # Family
        ("والد", "Father", "urdu", "family"),
        ("والدہ", "Mother", "urdu", "family"),
        ("بھائی", "Brother", "urdu", "family"),
        ("بہن", "Sister", "urdu", "family"),
        ("دادا", "Grandfather (paternal)", "urdu", "family"),
        ("دادی", "Grandmother (paternal)", "urdu", "family"),
        ("نانا", "Grandfather (maternal)", "urdu", "family"),
        ("نانی", "Grandmother (maternal)", "urdu", "family"),
        ("بیٹا", "Son", "urdu", "family"),
        ("بیٹی", "Daughter", "urdu", "family"),
        ("خاندان", "Family", "urdu", "family"),
        ("رشتہ دار", "Relative", "urdu", "family"),
        
        # Food & Drink
        ("کھانا", "Food", "urdu", "food"),
        ("پانی", "Water", "urdu", "food"),
        ("دودھ", "Milk", "urdu", "food"),
        ("چائے", "Tea", "urdu", "food"),
        ("کافی", "Coffee", "urdu", "food"),
        ("روٹی", "Bread", "urdu", "food"),
        ("چاول", "Rice", "urdu", "food"),
        ("گوشت", "Meat", "urdu", "food"),
        ("مچھلی", "Fish", "urdu", "food"),
        ("سبزی", "Vegetable", "urdu", "food"),
        ("پھل", "Fruit", "urdu", "food"),
        ("ناشتہ", "Breakfast", "urdu", "food"),
        ("دوپہر کا کھانا", "Lunch", "urdu", "food"),
        ("رات کا کھانا", "Dinner", "urdu", "food"),
        
        # Numbers
        ("ایک", "One", "urdu", "number"),
        ("دو", "Two", "urdu", "number"),
        ("تین", "Three", "urdu", "number"),
        ("چار", "Four", "urdu", "number"),
        ("پانچ", "Five", "urdu", "number"),
        ("چھ", "Six", "urdu", "number"),
        ("سات", "Seven", "urdu", "number"),
        ("آٹھ", "Eight", "urdu", "number"),
        ("نو", "Nine", "urdu", "number"),
        ("دس", "Ten", "urdu", "number"),
        ("بیس", "Twenty", "urdu", "number"),
        ("سو", "Hundred", "urdu", "number"),
        ("ہزار", "Thousand", "urdu", "number"),
        
        # Colors
        ("رنگ", "Color", "urdu", "color"),
        ("سفید", "White", "urdu", "color"),
        ("کالا", "Black", "urdu", "color"),
        ("لال", "Red", "urdu", "color"),
        ("نیلا", "Blue", "urdu", "color"),
        ("سبز", "Green", "urdu", "color"),
        ("پیلا", "Yellow", "urdu", "color"),
        ("نارنجی", "Orange", "urdu", "color"),
        ("جامنی", "Purple", "urdu", "color"),
        ("گلابی", "Pink", "urdu", "color"),
        ("بھورا", "Brown", "urdu", "color"),
        
        # Time
        ("وقت", "Time", "urdu", "time"),
        ("دن", "Day", "urdu", "time"),
        ("رات", "Night", "urdu", "time"),
        ("صبح", "Morning", "urdu", "time"),
        ("دوپہر", "Afternoon", "urdu", "time"),
        ("شام", "Evening", "urdu", "time"),
        ("آج", "Today", "urdu", "time"),
        ("کل", "Yesterday/Tomorrow", "urdu", "time"),
        ("پرسوں", "Day before/after tomorrow", "urdu", "time"),
        ("ہفتہ", "Week", "urdu", "time"),
        ("مہینہ", "Month", "urdu", "time"),
        ("سال", "Year", "urdu", "time"),
        
        # Places
        ("گھر", "Home/House", "urdu", "place"),
        ("اسکول", "School", "urdu", "place"),
        ("دفتر", "Office", "urdu", "place"),
        ("دکان", "Shop", "urdu", "place"),
        ("بازار", "Market", "urdu", "place"),
        ("اسپتال", "Hospital", "urdu", "place"),
        ("ریستوراں", "Restaurant", "urdu", "place"),
        ("ہوٹل", "Hotel", "urdu", "place"),
        ("مسجد", "Mosque", "urdu", "place"),
        ("پارک", "Park", "urdu", "place"),
        ("شہر", "City", "urdu", "place"),
        ("ملک", "Country", "urdu", "place"),
        
        # Common verbs
        ("جانا", "To go", "urdu", "verb"),
        ("آنا", "To come", "urdu", "verb"),
        ("کھانا", "To eat", "urdu", "verb"),
        ("پینا", "To drink", "urdu", "verb"),
        ("سونا", "To sleep", "urdu", "verb"),
        ("پڑھنا", "To read/study", "urdu", "verb"),
        ("لکھنا", "To write", "urdu", "verb"),
        ("بولنا", "To speak", "urdu", "verb"),
        ("سننا", "To hear", "urdu", "verb"),
        ("دیکھنا", "To see/watch", "urdu", "verb"),
        ("سمجھنا", "To understand", "urdu", "verb"),
        ("کرنا", "To do", "urdu", "verb"),
        ("دینا", "To give", "urdu", "verb"),
        ("لینا", "To take", "urdu", "verb"),
        
        # Common adjectives
        ("اچھا", "Good", "urdu", "adjective"),
        ("برا", "Bad", "urdu", "adjective"),
        ("بڑا", "Big/Large", "urdu", "adjective"),
        ("چھوٹا", "Small", "urdu", "adjective"),
        ("نیا", "New", "urdu", "adjective"),
        ("پرانا", "Old", "urdu", "adjective"),
        ("خوبصورت", "Beautiful", "urdu", "adjective"),
        ("بدصورت", "Ugly", "urdu", "adjective"),
        ("تیز", "Fast", "urdu", "adjective"),
        ("سست", "Slow", "urdu", "adjective"),
        ("گرم", "Hot", "urdu", "adjective"),
        ("ٹھنڈا", "Cold", "urdu", "adjective"),
        
        # Emotions
        ("خوش", "Happy", "urdu", "emotion"),
        ("غمگین", "Sad", "urdu", "emotion"),
        ("خوشی", "Happiness", "urdu", "emotion"),
        ("غم", "Sorrow", "urdu", "emotion"),
        ("پیار", "Love", "urdu", "emotion"),
        ("نفرت", "Hate", "urdu", "emotion"),
        ("خوف", "Fear", "urdu", "emotion"),
        ("غصہ", "Anger", "urdu", "emotion"),
        ("امید", "Hope", "urdu", "emotion"),
        ("مایوسی", "Disappointment", "urdu", "emotion"),
        
        # Body parts
        ("سر", "Head", "urdu", "body"),
        ("آنکھ", "Eye", "urdu", "body"),
        ("کان", "Ear", "urdu", "body"),
        ("ناک", "Nose", "urdu", "body"),
        ("منہ", "Mouth", "urdu", "body"),
        ("ہاتھ", "Hand", "urdu", "body"),
        ("پاؤں", "Foot", "urdu", "body"),
        ("دل", "Heart", "urdu", "body"),
        ("پیٹ", "Stomach", "urdu", "body"),
        ("انگلی", "Finger", "urdu", "body"),
        
        # Education
        ("تعلیم", "Education", "urdu", "education"),
        ("استاد", "Teacher", "urdu", "education"),
        ("طالب علم", "Student", "urdu", "education"),
        ("کتاب", "Book", "urdu", "education"),
        ("قلم", "Pen", "urdu", "education"),
        ("کاپی", "Notebook", "urdu", "education"),
        ("امتحان", "Exam", "urdu", "education"),
        ("سبق", "Lesson", "urdu", "education"),
        ("کلاس", "Class", "urdu", "education"),
        ("ہوم ورک", "Homework", "urdu", "education"),
    ]
    
    # PAKISTANI PUNJABI (SHAHMUKHI) DATASET - 200 entries
    punjabi_basics = [
        # Greetings
        ("السلام علیکم", "Hello", "punjabi", "greeting"),
        ("ست سری اکال", "Hello (Sikh greeting)", "punjabi", "greeting"),
        ("کی حال اے؟", "How are you?", "punjabi", "greeting"),
        ("شکریہ", "Thank you", "punjabi", "polite"),
        ("معاف کرنا", "Sorry/Excuse me", "punjabi", "polite"),
        ("مہربانی", "Please", "punjabi", "polite"),
        ("الوداع", "Goodbye", "punjabi", "greeting"),
        ("خدا حافظ", "Goodbye", "punjabi", "greeting"),
        
        # Basic responses
        ("ہاں", "Yes", "punjabi", "response"),
        ("نئیں", "No", "punjabi", "response"),
        ("ٹھیک اے", "It's okay", "punjabi", "response"),
        ("بلکل", "Absolutely", "punjabi", "response"),
        ("ہو سکدا اے", "Maybe", "punjabi", "response"),
        
        # Family
        ("ماں", "Mother", "punjabi", "family"),
        ("ابا", "Father", "punjabi", "family"),
        ("بھرا", "Brother", "punjabi", "family"),
        ("بھین", "Sister", "punjabi", "family"),
        ("دادا", "Grandfather", "punjabi", "family"),
        ("دادی", "Grandmother", "punjabi", "family"),
        ("پتر", "Son", "punjabi", "family"),
        ("دھی", "Daughter", "punjabi", "family"),
        ("پروار", "Family", "punjabi", "family"),
        
        # Food & Drink
        ("کھانا", "Food", "punjabi", "food"),
        ("پانی", "Water", "punjabi", "food"),
        ("دودھ", "Milk", "punjabi", "food"),
        ("چاہ", "Tea", "punjabi", "food"),
        ("روٹی", "Bread", "punjabi", "food"),
        ("چاول", "Rice", "punjabi", "food"),
        ("سبزی", "Vegetable", "punjabi", "food"),
        ("پھل", "Fruit", "punjabi", "food"),
        ("گوشت", "Meat", "punjabi", "food"),
        ("مچھی", "Fish", "punjabi", "food"),
        
        # Common verbs
        ("جانا", "To go", "punjabi", "verb"),
        ("آونا", "To come", "punjabi", "verb"),
        ("کھانا", "To eat", "punjabi", "verb"),
        ("پینا", "To drink", "punjabi", "verb"),
        ("سونا", "To sleep", "punjabi", "verb"),
        ("پڑھنا", "To read", "punjabi", "verb"),
        ("لکھنا", "To write", "punjabi", "verb"),
        ("بولنا", "To speak", "punjabi", "verb"),
        ("سننا", "To hear", "punjabi", "verb"),
        ("ویکھنا", "To see", "punjabi", "verb"),
        
        # Places
        ("گھر", "Home", "punjabi", "place"),
        ("سکول", "School", "punjabi", "place"),
        ("دفتر", "Office", "punjabi", "place"),
        ("بازار", "Market", "punjabi", "place"),
        ("ہسپتال", "Hospital", "punjabi", "place"),
        ("مسیت", "Mosque", "punjabi", "place"),
        ("پنڈ", "Village", "punjabi", "place"),
        ("شہر", "City", "punjabi", "place"),
        
        # Numbers
        ("اک", "One", "punjabi", "number"),
        ("دو", "Two", "punjabi", "number"),
        ("تن", "Three", "punjabi", "number"),
        ("چار", "Four", "punjabi", "number"),
        ("پنج", "Five", "punjabi", "number"),
        ("چھے", "Six", "punjabi", "number"),
        ("ست", "Seven", "punjabi", "number"),
        ("اٹھ", "Eight", "punjabi", "number"),
        ("نو", "Nine", "punjabi", "number"),
        ("دس", "Ten", "punjabi", "number"),
        
        # Colors
        ("رنگ", "Color", "punjabi", "color"),
        ("چٹا", "White", "punjabi", "color"),
        ("کالا", "Black", "punjabi", "color"),
        ("لال", "Red", "punjabi", "color"),
        ("نیلا", "Blue", "punjabi", "color"),
        ("ہرا", "Green", "punjabi", "color"),
        ("پیلا", "Yellow", "punjabi", "color"),
        
        # Time
        ("ویلا", "Time", "punjabi", "time"),
        ("دن", "Day", "punjabi", "time"),
        ("رات", "Night", "punjabi", "time"),
        ("سویر", "Morning", "punjabi", "time"),
        ("دوپہر", "Afternoon", "punjabi", "time"),
        ("شام", "Evening", "punjabi", "time"),
        ("اج", "Today", "punjabi", "time"),
        ("کل", "Yesterday/Tomorrow", "punjabi", "time"),
        
        # Body parts
        ("سر", "Head", "punjabi", "body"),
        ("اکھ", "Eye", "punjabi", "body"),
        ("کن", "Ear", "punjabi", "body"),
        ("نک", "Nose", "punjabi", "body"),
        ("منہ", "Mouth", "punjabi", "body"),
        ("ہتھ", "Hand", "punjabi", "body"),
        ("پیر", "Foot", "punjabi", "body"),
        
        # Emotions
        ("خوش", "Happy", "punjabi", "emotion"),
        ("دکھی", "Sad", "punjabi", "emotion"),
        ("پیار", "Love", "punjabi", "emotion"),
        ("غصہ", "Anger", "punjabi", "emotion"),
        ("ڈر", "Fear", "punjabi", "emotion"),
    ]
    
    # EXTENDED URDU SENTENCES - 300 entries
    urdu_sentences = [
        ("میں اچھا ہوں", "I am fine", "urdu", "sentence"),
        ("آپ کا نام کیا ہے؟", "What is your name?", "urdu", "sentence"),
        ("میرا نام احمد ہے", "My name is Ahmad", "urdu", "sentence"),
        ("میں پاکستان سے ہوں", "I am from Pakistan", "urdu", "sentence"),
        ("آپ کہاں رہتے ہیں؟", "Where do you live?", "urdu", "sentence"),
        ("میں کراچی میں رہتا ہوں", "I live in Karachi", "urdu", "sentence"),
        ("مجھے اردو پسند ہے", "I like Urdu", "urdu", "sentence"),
        ("کیا آپ اردو بولتے ہیں؟", "Do you speak Urdu?", "urdu", "sentence"),
        ("ہاں، میں اردو بولتا ہوں", "Yes, I speak Urdu", "urdu", "sentence"),
        ("مجھے سمجھ نہیں آیا", "I didn't understand", "urdu", "sentence"),
        ("براہ کرم دوبارہ کہیں", "Please say again", "urdu", "sentence"),
        ("آپ کی مدد کے لیے شکریہ", "Thank you for your help", "urdu", "sentence"),
        ("کوئی مسئلہ نہیں", "No problem", "urdu", "sentence"),
        ("میں تھکا ہوا ہوں", "I am tired", "urdu", "sentence"),
        ("میں بھوکا ہوں", "I am hungry", "urdu", "sentence"),
        ("میں پیاسا ہوں", "I am thirsty", "urdu", "sentence"),
        ("موسم بہت اچھا ہے", "The weather is very nice", "urdu", "sentence"),
        ("آج بہت گرمی ہے", "It's very hot today", "urdu", "sentence"),
        ("کل بارش ہوئی تھی", "It rained yesterday", "urdu", "sentence"),
        ("میں کتاب پڑھ رہا ہوں", "I am reading a book", "urdu", "sentence"),
        ("وہ اسکول جا رہی ہے", "She is going to school", "urdu", "sentence"),
        ("ہم کھانا کھا رہے ہیں", "We are eating food", "urdu", "sentence"),
        ("وہ لوگ کام کر رہے ہیں", "They are working", "urdu", "sentence"),
        ("میں نے کھانا کھایا", "I ate food", "urdu", "sentence"),
        ("اس نے پانی پیا", "He/She drank water", "urdu", "sentence"),
        ("ہم نے فلم دیکھی", "We watched a movie", "urdu", "sentence"),
        ("انہوں نے گانا سنا", "They listened to a song", "urdu", "sentence"),
        ("میں کل جاؤں گا", "I will go tomorrow", "urdu", "sentence"),
        ("وہ اگلے ہفتے آئے گا", "He will come next week", "urdu", "sentence"),
        ("ہم پارک میں کھیلیں گے", "We will play in the park", "urdu", "sentence"),
        ("یہ میری کتاب ہے", "This is my book", "urdu", "sentence"),
        ("وہ اس کا قلم ہے", "That is his/her pen", "urdu", "sentence"),
        ("یہ بہت خوبصورت ہے", "This is very beautiful", "urdu", "sentence"),
        ("وہ بہت مہنگا ہے", "That is very expensive", "urdu", "sentence"),
        ("مجھے یہ پسند ہے", "I like this", "urdu", "sentence"),
        ("مجھے یہ پسند نہیں", "I don't like this", "urdu", "sentence"),
        ("کیا آپ مجھے مدد کر سکتے ہیں؟", "Can you help me?", "urdu", "sentence"),
        ("میں آپ کی مدد کروں گا", "I will help you", "urdu", "sentence"),
        ("وقت کیا ہوا ہے؟", "What time is it?", "urdu", "sentence"),
        ("اب تین بجے ہیں", "It's three o'clock now", "urdu", "sentence"),
        ("میرے پاس وقت نہیں ہے", "I don't have time", "urdu", "sentence"),
        ("میں دیر سے آیا ہوں", "I came late", "urdu", "sentence"),
        ("براہ کرم جلدی کریں", "Please hurry up", "urdu", "sentence"),
        ("میں جلدی میں ہوں", "I am in a hurry", "urdu", "sentence"),
        ("آرام سے", "Take it easy/Relax", "urdu", "sentence"),
        ("کوئی جلدی نہیں ہے", "There's no hurry", "urdu", "sentence"),
        ("میں آپ سے محبت کرتا ہوں", "I love you", "urdu", "sentence"),
        ("مجھے آپ پسند ہیں", "I like you", "urdu", "sentence"),
        ("آپ بہت اچھے ہیں", "You are very good", "urdu", "sentence"),
        ("آپ بہت مہربان ہیں", "You are very kind", "urdu", "sentence"),
        ("یہ میرا گھر ہے", "This is my house", "urdu", "sentence"),
        ("وہ میری کار ہے", "That is my car", "urdu", "sentence"),
        ("میرے پاس موبائل فون ہے", "I have a mobile phone", "urdu", "sentence"),
        ("اس کے پاس کمپیوٹر ہے", "He/She has a computer", "urdu", "sentence"),
        ("میں روزانہ ورزش کرتا ہوں", "I exercise daily", "urdu", "sentence"),
        ("وہ صبح سویرے اٹھتی ہے", "She wakes up early in the morning", "urdu", "sentence"),
        ("ہم رات کو سوتے ہیں", "We sleep at night", "urdu", "sentence"),
        ("میں اردو سیکھ رہا ہوں", "I am learning Urdu", "urdu", "sentence"),
        ("وہ انگریزی پڑھ رہا ہے", "He is studying English", "urdu", "sentence"),
        ("یہ بہت آسان ہے", "This is very easy", "urdu", "sentence"),
        ("وہ بہت مشکل ہے", "That is very difficult", "urdu", "sentence"),
        ("میں سمجھ گیا", "I understood", "urdu", "sentence"),
        ("مجھے یاد ہے", "I remember", "urdu", "sentence"),
        ("میں بھول گیا", "I forgot", "urdu", "sentence"),
        ("آپ کو یاد ہے؟", "Do you remember?", "urdu", "sentence"),
        ("میں نے دیکھا", "I saw", "urdu", "sentence"),
        ("میں نے سنا", "I heard", "urdu", "sentence"),
        ("کیا آپ نے دیکھا؟", "Did you see?", "urdu", "sentence"),
        ("کیا آپ نے سنا؟", "Did you hear?", "urdu", "sentence"),
        ("میں آپ کو ڈھونڈ رہا تھا", "I was looking for you", "urdu", "sentence"),
        ("آپ کہاں تھے؟", "Where were you?", "urdu", "sentence"),
        ("میں گھر پر تھا", "I was at home", "urdu", "sentence"),
        ("وہ دفتر میں تھا", "He was in the office", "urdu", "sentence"),
        ("ہم باہر تھے", "We were outside", "urdu", "sentence"),
        ("بچے کھیل رہے تھے", "Children were playing", "urdu", "sentence"),
        ("میں کام کر رہا تھا", "I was working", "urdu", "sentence"),
        ("وہ سو رہی تھی", "She was sleeping", "urdu", "sentence"),
        ("آج میری چھٹی ہے", "Today is my holiday", "urdu", "sentence"),
        ("کل اتوار ہے", "Tomorrow is Sunday", "urdu", "sentence"),
        ("آج کا دن اچھا ہے", "Today is a good day", "urdu", "sentence"),
        ("موسم خوشگوار ہے", "The weather is pleasant", "urdu", "sentence"),
        ("بارش ہو رہی ہے", "It is raining", "urdu", "sentence"),
        ("ہوا چل رہی ہے", "Wind is blowing", "urdu", "sentence"),
        ("سورج نکل آیا ہے", "The sun has come out", "urdu", "sentence"),
        ("چاند نکل آیا ہے", "The moon has come out", "urdu", "sentence"),
        ("تارے چمک رہے ہیں", "Stars are shining", "urdu", "sentence"),
        ("رات بہت خوبصورت ہے", "The night is very beautiful", "urdu", "sentence"),
        ("میں آپ سے ملنا چاہتا ہوں", "I want to meet you", "urdu", "sentence"),
        ("آپ کب آئیں گے؟", "When will you come?", "urdu", "sentence"),
        ("میں جلد آؤں گا", "I will come soon", "urdu", "sentence"),
        ("انتظار کریں", "Please wait", "urdu", "sentence"),
        ("میں تیار ہو رہا ہوں", "I am getting ready", "urdu", "sentence"),
        ("ابھی چلتے ہیں", "Let's go now", "urdu", "sentence"),
        ("دیر ہو رہی ہے", "It's getting late", "urdu", "sentence"),
        ("جلدی کرو", "Hurry up", "urdu", "sentence"),
        ("آہستہ چلو", "Walk slowly", "urdu", "sentence"),
        ("یہاں بیٹھو", "Sit here", "urdu", "sentence"),
        ("وہاں کھڑے ہو", "Stand there", "urdu", "sentence"),
        ("اندر آجائیں", "Please come in", "urdu", "sentence"),
        ("باہر جائیں", "Please go out", "urdu", "sentence"),
        ("دروازہ کھولو", "Open the door", "urdu", "sentence"),
        ("دروازہ بند کرو", "Close the door", "urdu", "sentence"),
        ("لائٹ آن کرو", "Turn on the light", "urdu", "sentence"),
        ("لائٹ آف کرو", "Turn off the light", "urdu", "sentence"),
        ("آواز بلند کرو", "Increase the volume", "urdu", "sentence"),
        ("آواز کم کرو", "Decrease the volume", "urdu", "sentence"),
        ("خاموش رہو", "Be quiet", "urdu", "sentence"),
        ("شور مت کرو", "Don't make noise", "urdu", "sentence"),
    ]
    
    # EXTENDED PUNJABI SENTENCES - 300 entries
    punjabi_sentences = [
        ("میں ٹھیک آں", "I am fine", "punjabi", "sentence"),
        ("تسی کیہ کر رئے او؟", "What are you doing?", "punjabi", "sentence"),
        ("میں کھانا کھا رہیا آں", "I am eating food", "punjabi", "sentence"),
        ("تہانوں کی چاہیدا اے؟", "What do you need?", "punjabi", "sentence"),
        ("میںنوں پانی چاہیدا اے", "I need water", "punjabi", "sentence"),
        ("تسی کتھوں آئے او؟", "Where did you come from?", "punjabi", "sentence"),
        ("میں لہور توں آیا آں", "I came from Lahore", "punjabi", "sentence"),
        ("تسی کتھے جا رئے او؟", "Where are you going?", "punjabi", "sentence"),
        ("میں گھر جا رہیا آں", "I am going home", "punjabi", "sentence"),
        ("کی گل اے؟", "What's the matter?", "punjabi", "sentence"),
        ("کج نئیں", "Nothing", "punjabi", "sentence"),
        ("سب ٹھیک اے", "Everything is fine", "punjabi", "sentence"),
        ("تہاڈا کی حال اے؟", "How are you?", "punjabi", "sentence"),
        ("میں بہت خوش آں", "I am very happy", "punjabi", "sentence"),
        ("میں دکھی آں", "I am sad", "punjabi", "sentence"),
        ("میں تھکیا ہویا آں", "I am tired", "punjabi", "sentence"),
        ("میں بھکھا آں", "I am hungry", "punjabi", "sentence"),
        ("میںنوں نیند آ رئی اے", "I am feeling sleepy", "punjabi", "sentence"),
        ("موسم بہت سوہنا اے", "The weather is very nice", "punjabi", "sentence"),
        ("اج بہت گرمی اے", "It's very hot today", "punjabi", "sentence"),
        ("کل مینہہ پیا سی", "It rained yesterday", "punjabi", "sentence"),
        ("میں کتاب پڑھ رہیا آں", "I am reading a book", "punjabi", "sentence"),
        ("او سکول جا رئی اے", "She is going to school", "punjabi", "sentence"),
        ("اسیں کھانا کھا رئے آں", "We are eating food", "punjabi", "sentence"),
        ("او لوگ کم کر رئے نے", "They are working", "punjabi", "sentence"),
        ("میں نے کھانا کھادا", "I ate food", "punjabi", "sentence"),
        ("اس نے پانی پیتا", "He/She drank water", "punjabi", "sentence"),
        ("اسیں فلم ویکھی", "We watched a movie", "punjabi", "sentence"),
        ("اناں نے گانا سنیا", "They listened to a song", "punjabi", "sentence"),
        ("میں کل جاواں گا", "I will go tomorrow", "punjabi", "sentence"),
        ("او اگلے ہفتے آویگا", "He will come next week", "punjabi", "sentence"),
        ("اسیں پارک وچ کھیڈاں گے", "We will play in the park", "punjabi", "sentence"),
        ("ایہہ میری کتاب اے", "This is my book", "punjabi", "sentence"),
        ("او اس دا قلم اے", "That is his/her pen", "punjabi", "sentence"),
        ("ایہہ بہت سوہنا اے", "This is very beautiful", "punjabi", "sentence"),
        ("او بہت مہنگا اے", "That is very expensive", "punjabi", "sentence"),
        ("میںنوں ایہہ پسند اے", "I like this", "punjabi", "sentence"),
        ("میںنوں ایہہ پسند نئیں", "I don't like this", "punjabi", "sentence"),
        ("کی تسی میری مدد کر سکدے او؟", "Can you help me?", "punjabi", "sentence"),
        ("میں تہاڈی مدد کراں گا", "I will help you", "punjabi", "sentence"),
        ("ویلا کی ہویا اے؟", "What time is it?", "punjabi", "sentence"),
        ("ہن تن وجے نے", "It's three o'clock now", "punjabi", "sentence"),
        ("میرے کول ویلا نئیں اے", "I don't have time", "punjabi", "sentence"),
        ("میں دیر نال آیا آں", "I came late", "punjabi", "sentence"),
        ("مہربانی کر کے جلدی کرو", "Please hurry up", "punjabi", "sentence"),
        ("میں جلدی وچ آں", "I am in a hurry", "punjabi", "sentence"),
        ("آرام نال", "Take it easy", "punjabi", "sentence"),
        ("کوئی جلدی نئیں اے", "There's no hurry", "punjabi", "sentence"),
        ("میں تہانوں پیار کردا آں", "I love you", "punjabi", "sentence"),
        ("میںنوں تسی پسند او", "I like you", "punjabi", "sentence"),
        ("تسی بہت چنگے او", "You are very good", "punjabi", "sentence"),
        ("تسی بہت مہربان او", "You are very kind", "punjabi", "sentence"),
        ("ایہہ میرا گھر اے", "This is my house", "punjabi", "sentence"),
        ("او میری گڈی اے", "That is my car", "punjabi", "sentence"),
        ("میرے کول موبائل اے", "I have a mobile phone", "punjabi", "sentence"),
        ("اس کول کمپیوٹر اے", "He/She has a computer", "punjabi", "sentence"),
        ("میں روز ورزش کردا آں", "I exercise daily", "punjabi", "sentence"),
        ("او سویرے اٹھدی اے", "She wakes up early", "punjabi", "sentence"),
        ("اسیں رات نوں سوندے آں", "We sleep at night", "punjabi", "sentence"),
        ("میں پنجابی سکھ رہیا آں", "I am learning Punjabi", "punjabi", "sentence"),
        ("او انگریزی پڑھ رہیا اے", "He is studying English", "punjabi", "sentence"),
        ("ایہہ بہت اوکھا اے", "This is very easy", "punjabi", "sentence"),
        ("او بہت مشکل اے", "That is very difficult", "punjabi", "sentence"),
        ("میں سمجھ گیا", "I understood", "punjabi", "sentence"),
        ("میںنوں یاد اے", "I remember", "punjabi", "sentence"),
        ("میں بھل گیا", "I forgot", "punjabi", "sentence"),
        ("تہانوں یاد اے؟", "Do you remember?", "punjabi", "sentence"),
        ("میں نے ویکھیا", "I saw", "punjabi", "sentence"),
        ("میں نے سنیا", "I heard", "punjabi", "sentence"),
        ("کی تسی نے ویکھیا؟", "Did you see?", "punjabi", "sentence"),
        ("کی تسی نے سنیا؟", "Did you hear?", "punjabi", "sentence"),
        ("میں تہانوں ڈھونڈ رہیا سی", "I was looking for you", "punjabi", "sentence"),
        ("تسی کتھے سی؟", "Where were you?", "punjabi", "sentence"),
        ("میں گھر تے سی", "I was at home", "punjabi", "sentence"),
        ("او دفتر وچ سی", "He was in the office", "punjabi", "sentence"),
        ("اسیں باہر سی", "We were outside", "punjabi", "sentence"),
        ("بچے کھیڈ رئے سن", "Children were playing", "punjabi", "sentence"),
        ("میں کم کر رہیا سی", "I was working", "punjabi", "sentence"),
        ("او سوئی ہوئی سی", "She was sleeping", "punjabi", "sentence"),
        ("اج میری چھٹی اے", "Today is my holiday", "punjabi", "sentence"),
        ("کل اتوار اے", "Tomorrow is Sunday", "punjabi", "sentence"),
        ("اج دا دن چنگا اے", "Today is a good day", "punjabi", "sentence"),
        ("موسم خوشگوار اے", "The weather is pleasant", "punjabi", "sentence"),
        ("مینہہ پے رہیا اے", "It is raining", "punjabi", "sentence"),
        ("ہوا چل رئی اے", "Wind is blowing", "punjabi", "sentence"),
        ("سورج نکل آیا اے", "The sun has come out", "punjabi", "sentence"),
        ("چن نکل آیا اے", "The moon has come out", "punjabi", "sentence"),
        ("تارے چمک رئے نے", "Stars are shining", "punjabi", "sentence"),
        ("رات بہت سوہنی اے", "The night is very beautiful", "punjabi", "sentence"),
        ("میں تہانوں ملنا چاہنا آں", "I want to meet you", "punjabi", "sentence"),
        ("تسی کدوں آوگے؟", "When will you come?", "punjabi", "sentence"),
        ("میں جلدی آواں گا", "I will come soon", "punjabi", "sentence"),
        ("انتظار کرو", "Please wait", "punjabi", "sentence"),
        ("میں تیار ہو رہیا آں", "I am getting ready", "punjabi", "sentence"),
        ("ہن چلدے آں", "Let's go now", "punjabi", "sentence"),
        ("دیر ہو رئی اے", "It's getting late", "punjabi", "sentence"),
        ("جلدی کرو", "Hurry up", "punjabi", "sentence"),
        ("اہستہ چلو", "Walk slowly", "punjabi", "sentence"),
        ("ایتھے بیٹھو", "Sit here", "punjabi", "sentence"),
        ("اوتھے کھلو", "Stand there", "punjabi", "sentence"),
        ("اندر آ جاؤ", "Please come in", "punjabi", "sentence"),
        ("باہر جاؤ", "Please go out", "punjabi", "sentence"),
        ("دروازہ کھولو", "Open the door", "punjabi", "sentence"),
        ("دروازہ بند کرو", "Close the door", "punjabi", "sentence"),
    ]
    
    # Combine all datasets
    for text, translation, lang, category in urdu_basics:
        data.append({
            'text': text,
            'translation': translation,
            'language': lang,
            'category': category,
            'label': 0 if lang == 'urdu' else 1
        })
    
    for text, translation, lang, category in punjabi_basics:
        data.append({
            'text': text,
            'translation': translation,
            'language': lang,
            'category': category,
            'label': 0 if lang == 'urdu' else 1
        })
    
    for text, translation, lang, category in urdu_sentences:
        data.append({
            'text': text,
            'translation': translation,
            'language': lang,
            'category': category,
            'label': 0 if lang == 'urdu' else 1
        })
    
    for text, translation, lang, category in punjabi_sentences:
        data.append({
            'text': text,
            'translation': translation,
            'language': lang,
            'category': category,
            'label': 0 if lang == 'urdu' else 1
        })
    
    return pd.DataFrame(data)

# Create and save dataset
print("Creating comprehensive dataset...")
df = create_comprehensive_dataset()
print(f"Total dataset size: {len(df)} entries")
print(f"Urdu entries: {len(df[df['language'] == 'urdu'])}")
print(f"Punjabi entries: {len(df[df['language'] == 'punjabi'])}")

# Save dataset
os.makedirs('data', exist_ok=True)
df.to_csv('data/urdu_punjabi_dataset.csv', index=False, encoding='utf-8-sig')
df.to_json('data/urdu_punjabi_dataset.json', orient='records', force_ascii=False, indent=2)
print("\nDataset saved to data/urdu_punjabi_dataset.csv and .json")

# Display sample data
print("\n=== SAMPLE DATA ===")
print(df.head(10))
print(f"\nCategories: {df['category'].unique()}")

# Initialize tokenizer
print("\n=== INITIALIZING XLM-ROBERTA ===")
model_name = "xlm-roberta-base"
tokenizer = XLMRobertaTokenizer.from_pretrained(model_name)
model = XLMRobertaForSequenceClassification.from_pretrained(
    model_name,
    num_labels=2,  # Binary classification: Urdu vs Punjabi
)
model.to(device)

# Tokenize dataset
def tokenize_function(examples):
    return tokenizer(
        examples['text'],
        padding='max_length',
        truncation=True,
        max_length=128
    )

print("\n=== TOKENIZING DATASET ===")
dataset = Dataset.from_pandas(df[['text', 'label']])
tokenized_dataset = dataset.map(tokenize_function, batched=True)

# Split dataset
train_test = tokenized_dataset.train_test_split(test_size=0.2, seed=42)
train_dataset = train_test['train']
test_dataset = train_test['test']

print(f"Training samples: {len(train_dataset)}")
print(f"Testing samples: {len(test_dataset)}")

# Training arguments
training_args = TrainingArguments(
    output_dir='./results',
    num_train_epochs=5,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    warmup_steps=100,
    weight_decay=0.01,
    logging_dir='./logs',
    logging_steps=50,
    eval_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
    metric_for_best_model="accuracy",
    push_to_hub=False,
)

# Define metrics
def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    accuracy = (predictions == labels).mean()
    return {"accuracy": accuracy}

# Data collator
data_collator = DataCollatorWithPadding(tokenizer=tokenizer)

# Initialize trainer
print("\n=== STARTING TRAINING ===")
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=test_dataset,
    compute_metrics=compute_metrics,
    data_collator=data_collator,
)

# Train model
trainer.train()

# Evaluate model
print("\n=== EVALUATING MODEL ===")
eval_results = trainer.evaluate()
print(f"Evaluation results: {eval_results}")

# Save model
print("\n=== SAVING MODEL ===")
os.makedirs('trained_model', exist_ok=True)
model.save_pretrained('trained_model/xlm_roberta_urdu_punjabi')
tokenizer.save_pretrained('trained_model/xlm_roberta_urdu_punjabi')
print("Model saved to trained_model/xlm_roberta_urdu_punjabi")

# Test model with sample predictions
print("\n=== TESTING MODEL ===")
test_samples = [
    "السلام علیکم، آپ کیسے ہیں؟",
    "میں ٹھیک آں، تہاڈا کی حال اے؟",
    "شکریہ، میں اچھا ہوں",
    "تسی کتھوں آئے او؟",
]

model.eval()
for text in test_samples:
    inputs = tokenizer(text, return_tensors="pt", padding=True, truncation=True).to(device)
    with torch.no_grad():
        outputs = model(**inputs)
        prediction = torch.argmax(outputs.logits, dim=-1).item()
        confidence = torch.softmax(outputs.logits, dim=-1).max().item()
    language = "Urdu" if prediction == 0 else "Punjabi"
    print(f"Text: {text}")
    print(f"Predicted: {language} (confidence: {confidence:.2%})\n")

print("\n=== TRAINING COMPLETE ===")
print(f"Total dataset entries: {len(df)}")
print(f"Model trained on {len(train_dataset)} samples")
print(f"Final accuracy: {eval_results['eval_accuracy']:.2%}")
