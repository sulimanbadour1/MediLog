#!/usr/bin/env python3
"""
Create a sample app icon for MediLog
This script creates a simple medical-themed app icon that you can use as a starting point.
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_sample_app_icon():
    """Create a simple medical-themed app icon"""
    
    # Create a 1024x1024 image with a blue gradient background
    size = (1024, 1024)
    image = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Create gradient background (blue to purple)
    for y in range(size[1]):
        # Calculate gradient color
        ratio = y / size[1]
        r = int(59 + (128 - 59) * ratio)  # Blue to purple
        g = int(130 + (43 - 130) * ratio)
        b = int(246 + (128 - 246) * ratio)
        
        draw.line([(0, y), (size[0], y)], fill=(r, g, b, 255))
    
    # Add a white circle in the center
    circle_center = (size[0] // 2, size[1] // 2)
    circle_radius = 300
    
    # Draw white circle with shadow
    shadow_offset = 10
    draw.ellipse([
        circle_center[0] - circle_radius + shadow_offset,
        circle_center[1] - circle_radius + shadow_offset,
        circle_center[0] + circle_radius + shadow_offset,
        circle_center[1] + circle_radius + shadow_offset
    ], fill=(0, 0, 0, 100))
    
    # Draw main white circle
    draw.ellipse([
        circle_center[0] - circle_radius,
        circle_center[1] - circle_radius,
        circle_center[0] + circle_radius,
        circle_center[1] + circle_radius
    ], fill=(255, 255, 255, 255))
    
    # Draw medical cross
    cross_size = 200
    cross_thickness = 40
    
    # Horizontal line
    draw.rectangle([
        circle_center[0] - cross_size // 2,
        circle_center[1] - cross_thickness // 2,
        circle_center[0] + cross_size // 2,
        circle_center[1] + cross_thickness // 2
    ], fill=(59, 130, 246, 255))
    
    # Vertical line
    draw.rectangle([
        circle_center[0] - cross_thickness // 2,
        circle_center[1] - cross_size // 2,
        circle_center[0] + cross_thickness // 2,
        circle_center[1] + cross_size // 2
    ], fill=(59, 130, 246, 255))
    
    # Save the image
    output_path = "sample_app_icon_1024x1024.png"
    image.save(output_path, "PNG")
    
    print(f"✅ Sample app icon created: {output_path}")
    print("This is a basic medical cross icon with a blue gradient background.")
    print("You can now use this as your source image for the icon generator!")
    
    return output_path

if __name__ == "__main__":
    print("🏥 Creating sample MediLog app icon...")
    print("=" * 40)
    
    try:
        icon_path = create_sample_app_icon()
        print(f"\n📱 Next steps:")
        print(f"1. Use this image: {icon_path}")
        print("2. Run: python3 generate_app_icons.py")
        print("3. Enter the path to your new icon when prompted")
        print("4. Add the generated icons to Xcode")
        
    except Exception as e:
        print(f"❌ Error creating sample icon: {e}")
        print("Make sure you have Pillow installed: pip install Pillow")
