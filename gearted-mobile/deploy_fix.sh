#!/bin/bash

echo "🚀 DEPLOYING GEARTED FLUTTER WEB APP WITH GREY SCREEN FIX"
echo "=================================================="

# Set working directory
cd "$(dirname "$0")"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Verify our fix is in place
echo "🔍 Verifying grey screen fix..."
if grep -q "#1A1A1A" web/index.html; then
    echo "✅ Grey screen fix confirmed (#1A1A1A background)"
else
    echo "❌ Grey screen fix not found!"
    exit 1
fi

# Build for web
echo "🏗️ Building Flutter web with fix..."
flutter build web --release

# Verify fix is in built version
echo "🔍 Verifying fix in built version..."
if grep -q "#1A1A1A" build/web/index.html; then
    echo "✅ Fix successfully applied to build"
else
    echo "❌ Fix not found in build!"
    exit 1
fi

# Commit and push (trigger deployment)
echo "📤 Pushing to trigger deployment..."
git add .
git commit -m "deploy: Grey screen fix ready for production deployment" || echo "No changes to commit"
git push origin main

echo ""
echo "🎯 DEPLOYMENT SUMMARY"
echo "===================="
echo "✅ Grey screen fix applied (#1A1A1A instead of #1F2937)"
echo "✅ Flutter build completed successfully"
echo "✅ Changes pushed to trigger deployment"
echo ""
echo "🌐 Check deployment at: https://gearted.eu"
echo "⏱️ Allow 2-5 minutes for deployment to complete"

# Wait and check
echo "⏳ Waiting 60 seconds before checking deployment..."
sleep 60

echo "🔍 Checking if deployment is live..."
if curl -s -L "https://gearted.eu" | grep -q "#1A1A1A"; then
    echo "🎉 SUCCESS! Grey screen fix is now live!"
else
    echo "⏳ Deployment still in progress or needs manual trigger"
    echo "💡 Check Render dashboard or contact deployment admin"
fi
