#!/bin/bash
set -e

echo "🔥 Starting Flutter Web Build for Gearted"
echo "Current directory: $(pwd)"

# Ensure Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Installing..."
    # This would need to be handled by Render's build environment
    exit 1
fi

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🏗️ Building Flutter web app..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Built files are in: build/web/"

# List the contents to verify
ls -la build/web/

echo "🎯 Ready for deployment!"
