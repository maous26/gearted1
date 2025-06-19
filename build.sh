#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Log the start of the build process.
echo "Starting Gearted Flutter Web Build..."

# STEP 1: Create the publish directory at the very beginning to avoid Render's pre-flight check failure.
echo "Creating publish directory to satisfy Render's check..."
mkdir -p flutter-build

# STEP 2: Install Flutter SDK
echo "Installing Flutter SDK..."
apt-get update && apt-get install -y --no-install-recommends git unzip xz-utils zip libglu1-mesa
git clone https://github.com/flutter/flutter.git --depth 1 --branch 3.22.2 /opt/flutter
export PATH="$PATH:/opt/flutter/bin"

# Verify Flutter installation
flutter doctor -v

# STEP 3: Build the Flutter application
echo "Building the Flutter application..."
cd gearted-mobile
flutter pub get
flutter build web --release --web-renderer canvaskit

# STEP 4: Move the built application to the publish directory
echo "Moving build artifacts to the publish directory..."
mv build/web/* ../flutter-build/

# Log the successful completion of the build process.
echo "Build finished successfully. The contents of flutter-build are:"
ls -la flutter-build
