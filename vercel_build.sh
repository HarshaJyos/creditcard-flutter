#!/bin/bash

# Exit on error
set -e

# Install Flutter
echo "🚀 Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Check Flutter version
flutter --version

# Get dependencies
flutter pub get

# Build for web
flutter build web

echo "✅ Build complete!"
