#!/usr/bin/env python3
"""
App Icon Generator for MediLog
Creates all required app icon sizes from a base 1024x1024 image
"""

import os
from PIL import Image, ImageDraw
import math

def create_medilog_icon(size):
    """Create a MediLog app icon at the specified size"""
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Calculate dimensions based on size
    center = size // 2
    radius = int(size * 0.4)
    cross_width = int(size * 0.08)
    cross_length = int(size * 0.3)
    
    # Create gradient background (simplified - solid blue)
    draw.ellipse([center - radius, center - radius, center + radius, center + radius], 
                fill=(0, 122, 255, 255))  # iOS Blue
    
    # Draw medical cross
    # Vertical line
    draw.rectangle([center - cross_width//2, center - cross_length//2, 
                    center + cross_width//2, center + cross_length//2], 
                   fill=(255, 255, 255, 255))
    
    # Horizontal line
    draw.rectangle([center - cross_length//2, center - cross_width//2, 
                    center + cross_length//2, center + cross_width//2], 
                   fill=(255, 255, 255, 255))
    
    # Add small decorative dots
    dot_size = max(2, size // 30)
    dot_positions = [
        (center - radius//2, center - radius//2),
        (center + radius//2, center - radius//2),
        (center - radius//2, center + radius//2),
        (center + radius//2, center + radius//2)
    ]
    
    for pos in dot_positions:
        draw.ellipse([pos[0] - dot_size//2, pos[1] - dot_size//2, 
                     pos[0] + dot_size//2, pos[1] + dot_size//2], 
                    fill=(255, 255, 255, 100))
    
    return img

def generate_app_icons():
    """Generate all required app icon sizes"""
    # Required sizes for iOS app icons
    sizes = [
        (20, 2),   # 20@2x
        (20, 3),   # 20@3x
        (29, 2),   # 29@2x
        (29, 3),   # 29@3x
        (40, 2),   # 40@2x
        (40, 3),   # 40@3x
        (60, 2),   # 60@2x
        (60, 3),   # 60@3x
        (1024, 1)  # 1024@1x
    ]
    
    # Create output directory
    output_dir = "Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate icons
    for base_size, scale in sizes:
        actual_size = base_size * scale
        icon = create_medilog_icon(actual_size)
        
        # Determine filename
        if base_size == 20 and scale == 2:
            filename = "AppIcon-20@2x.png"
        elif base_size == 20 and scale == 3:
            filename = "AppIcon-20@3x.png"
        elif base_size == 29 and scale == 2:
            filename = "AppIcon-29@2x.png"
        elif base_size == 29 and scale == 3:
            filename = "AppIcon-29@3x.png"
        elif base_size == 40 and scale == 2:
            filename = "AppIcon-40@2x.png"
        elif base_size == 40 and scale == 3:
            filename = "AppIcon-40@3x.png"
        elif base_size == 60 and scale == 2:
            filename = "AppIcon-60@2x.png"
        elif base_size == 60 and scale == 3:
            filename = "AppIcon-60@3x.png"
        elif base_size == 1024 and scale == 1:
            filename = "AppIcon-1024.png"
        
        # Save icon
        icon.save(os.path.join(output_dir, filename), "PNG")
        print(f"Generated {filename} ({actual_size}x{actual_size})")

if __name__ == "__main__":
    print("Generating MediLog app icons...")
    generate_app_icons()
    print("✅ All app icons generated successfully!")
    print("\nTo use these icons:")
    print("1. Open your project in Xcode")
    print("2. Navigate to Assets.xcassets > AppIcon")
    print("3. Drag the generated PNG files to their respective slots")
    print("4. Build and run your app!")