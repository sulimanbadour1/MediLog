#!/usr/bin/env python3
"""
App Icon Generator for MediLog iOS App
This script generates all required iOS app icon sizes from a single 1024x1024 source image.
"""

import os
from PIL import Image

def generate_app_icons(source_image_path, output_dir):
    """
    Generate all required iOS app icon sizes from a source image.
    
    Args:
        source_image_path (str): Path to the source 1024x1024 image
        output_dir (str): Directory to save the generated icons
    """
    
    # Required iOS app icon sizes
    icon_sizes = [
        ("AppIcon-20@2x.png", 40, 40),      # 20pt @2x
        ("AppIcon-20@3x.png", 60, 60),      # 20pt @3x
        ("AppIcon-29@2x.png", 58, 58),      # 29pt @2x
        ("AppIcon-29@3x.png", 87, 87),      # 29pt @3x
        ("AppIcon-40@2x.png", 80, 80),      # 40pt @2x
        ("AppIcon-40@3x.png", 120, 120),    # 40pt @3x
        ("AppIcon-60@2x.png", 120, 120),    # 60pt @2x
        ("AppIcon-60@3x.png", 180, 180),    # 60pt @3x
        ("AppIcon-1024.png", 1024, 1024),   # App Store
    ]
    
    try:
        # Open the source image
        with Image.open(source_image_path) as source:
            # Ensure the source image is 1024x1024
            if source.size != (1024, 1024):
                print(f"Warning: Source image is {source.size}, expected (1024, 1024)")
                source = source.resize((1024, 1024), Image.Resampling.LANCZOS)
            
            # Create output directory if it doesn't exist
            os.makedirs(output_dir, exist_ok=True)
            
            # Generate each icon size
            for filename, width, height in icon_sizes:
                output_path = os.path.join(output_dir, filename)
                
                # Resize the image
                resized = source.resize((width, height), Image.Resampling.LANCZOS)
                
                # Save the icon
                resized.save(output_path, "PNG", optimize=True)
                print(f"Generated: {filename} ({width}x{height})")
            
            print(f"\n✅ All app icons generated successfully in: {output_dir}")
            print("\nNext steps:")
            print("1. Copy the generated PNG files to Assets.xcassets/AppIcon.appiconset/")
            print("2. Build and run your app to see the new icon on the home screen")
            
    except FileNotFoundError:
        print(f"❌ Error: Source image not found at {source_image_path}")
        print("Please provide a 1024x1024 PNG image as the source.")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    # Instructions for the user
    print("🏥 MediLog App Icon Generator")
    print("=" * 40)
    print()
    print("This script generates all required iOS app icon sizes.")
    print("You need a 1024x1024 PNG image as the source.")
    print()
    
    # Get source image path from user
    source_path = input("Enter path to your 1024x1024 source image: ").strip()
    
    if not source_path:
        print("❌ No source image path provided.")
        exit(1)
    
    # Set output directory
    output_directory = "generated_app_icons"
    
    # Generate the icons
    generate_app_icons(source_path, output_directory)
