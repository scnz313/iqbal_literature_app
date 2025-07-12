#!/bin/bash

# iOS App Icon Generator Script
# This script generates all required iOS app icon sizes from the main logo

# Source image
SOURCE_IMAGE="assets/icon/iqbalApp_logo.png"
ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image $SOURCE_IMAGE not found!"
    exit 1
fi

# Create icon directory if it doesn't exist
mkdir -p "$ICON_DIR"

echo "Generating iOS app icons from $SOURCE_IMAGE..."

# Array of icon sizes needed for iOS
declare -a sizes=(
    "20:Icon-App-20x20@1x.png"
    "40:Icon-App-20x20@2x.png"
    "60:Icon-App-20x20@3x.png"
    "29:Icon-App-29x29@1x.png"
    "58:Icon-App-29x29@2x.png"
    "87:Icon-App-29x29@3x.png"
    "40:Icon-App-40x40@1x.png"
    "80:Icon-App-40x40@2x.png"
    "120:Icon-App-40x40@3x.png"
    "50:Icon-App-50x50@1x.png"
    "100:Icon-App-50x50@2x.png"
    "57:Icon-App-57x57@1x.png"
    "114:Icon-App-57x57@2x.png"
    "120:Icon-App-60x60@2x.png"
    "180:Icon-App-60x60@3x.png"
    "72:Icon-App-72x72@1x.png"
    "144:Icon-App-72x72@2x.png"
    "76:Icon-App-76x76@1x.png"
    "152:Icon-App-76x76@2x.png"
    "167:Icon-App-83.5x83.5@2x.png"
    "1024:Icon-App-1024x1024@1x.png"
)

# Generate each icon size
for size_info in "${sizes[@]}"; do
    IFS=':' read -ra ADDR <<< "$size_info"
    size="${ADDR[0]}"
    filename="${ADDR[1]}"
    
    echo "Generating ${filename} (${size}x${size})"
    sips -z $size $size "$SOURCE_IMAGE" --out "$ICON_DIR/$filename" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✓ Created $filename"
    else
        echo "✗ Failed to create $filename"
    fi
done

# Create Contents.json file
cat > "$ICON_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "Icon-App-20x20@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-29x29@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-40x40@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-50x50@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "50x50"
    },
    {
      "filename" : "Icon-App-50x50@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "50x50"
    },
    {
      "filename" : "Icon-App-57x57@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "57x57"
    },
    {
      "filename" : "Icon-App-57x57@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "57x57"
    },
    {
      "filename" : "Icon-App-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-72x72@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "72x72"
    },
    {
      "filename" : "Icon-App-72x72@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "72x72"
    },
    {
      "filename" : "Icon-App-76x76@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-76x76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-App-1024x1024@1x.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✓ Created Contents.json"
echo ""
echo "iOS app icons generated successfully!"
echo "Total icons created: ${#sizes[@]}" 