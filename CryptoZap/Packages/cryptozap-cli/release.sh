#!/bin/bash

set -e

echo "🔢 Enter the version (e.g., 1.0.3):"
read VERSION

echo "🧹 Cleaning previous build..."
swift package clean

echo "🏗 Building cryptozap-cli..."
swift build -c release --arch arm64 --arch x86_64 --product cryptozap-cli

RELEASE_DIR=".build/apple/Products/Release"
if [[ ! -f "$RELEASE_DIR/cryptozap-cli" || ! -d "$RELEASE_DIR/CryptoEngine_CryptoEngine.bundle" ]]; then
  echo "❌ Build output not found in $RELEASE_DIR"
  exit 1
fi

OUTPUT_DIR="cryptozap-cli-v$VERSION"
mkdir -p "$OUTPUT_DIR"

echo "📄 Copying files..."
cp "$RELEASE_DIR/cryptozap-cli" "$OUTPUT_DIR/"
cp -R "$RELEASE_DIR/CryptoEngine_CryptoEngine.bundle" "$OUTPUT_DIR/"

echo "📖 Compressing man page..."
if [[ -f "cryptozap-cli.1" ]]; then
  cp "cryptozap-cli.1" "$OUTPUT_DIR/"
  gzip -f "$OUTPUT_DIR/cryptozap-cli.1"
else
  echo "⚠️ cryptozap-cli.1 not found in script directory."
  exit 1
fi

echo "🗜 Creating archive..."
tar -czf "cryptozap-cli-app-v$VERSION.tar.gz" -C "$OUTPUT_DIR" .

echo "🔍 Calculating SHA256..."
shasum -a 256 "cryptozap-cli-app-v$VERSION.tar.gz"

echo "✅ Archive created: cryptozap-cli-app-v$VERSION.tar.gz"
