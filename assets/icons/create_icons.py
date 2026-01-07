"""
Simple script to create placeholder app icons using PIL
Run: python create_icons.py
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    """Create a simple language learning app icon"""
    # Create 1024x1024 icon
    size = 1024
    img = Image.new('RGB', (size, size), color='#4CAF50')
    draw = ImageDraw.Draw(img)
    
    # Draw a book/language symbol
    # White rounded rectangle for book
    book_padding = 200
    book_rect = [book_padding, book_padding, size-book_padding, size-book_padding]
    draw.rounded_rectangle(book_rect, radius=80, fill='white')
    
    # Draw text "L" for Language
    try:
        # Try to use a nice font
        font = ImageFont.truetype("arial.ttf", 400)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Center the text
    text = "لغ"  # Arabic/Urdu letter for language
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 50
    
    draw.text((x, y), text, fill='#4CAF50', font=font)
    
    # Save
    img.save('assets/icons/app_icon.png')
    print("✓ Created app_icon.png")

def create_foreground_icon():
    """Create adaptive icon foreground (transparent background)"""
    size = 1024
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw the same letter but larger for adaptive icon
    try:
        font = ImageFont.truetype("arial.ttf", 500)
    except:
        font = ImageFont.load_default()
    
    text = "لغ"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 50
    
    draw.text((x, y), text, fill='white', font=font)
    
    img.save('assets/icons/app_icon_foreground.png')
    print("✓ Created app_icon_foreground.png")

def create_splash_logo():
    """Create splash screen logo"""
    size = 512
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw circular background
    circle_padding = 50
    draw.ellipse([circle_padding, circle_padding, size-circle_padding, size-circle_padding], 
                 fill='white')
    
    # Draw text
    try:
        font = ImageFont.truetype("arial.ttf", 250)
    except:
        font = ImageFont.load_default()
    
    text = "لغ"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 25
    
    draw.text((x, y), text, fill='#4CAF50', font=font)
    
    # Create images directory if needed
    os.makedirs('assets/images', exist_ok=True)
    img.save('assets/images/splash_logo.png')
    print("✓ Created splash_logo.png")

if __name__ == '__main__':
    print("Creating app icons...")
    os.makedirs('assets/icons', exist_ok=True)
    create_app_icon()
    create_foreground_icon()
    create_splash_logo()
    print("\n✓ All icons created successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: flutter pub run flutter_launcher_icons")
    print("3. Run: flutter pub run flutter_native_splash:create")
