#!/bin/bash

# this compiler script is designed to issue binary to ./.build/cli

set -e

cd "$(dirname "$0")"/../

echo "[*] starting build at $(pwd)..."

if [ ! -f .action ]; then
    exit 1
fi

echo "[*] cleaning build..."

rm -rf .build || true
mkdir .build

echo "[*] looking for target binary..."

BUILT_PRODUCTS_DIR=$(
    xcodebuild \
        clean build \
        -configuration Release \
        -workspace ./App.xcworkspace \
        -scheme CommandLineBridge \
        -showBuildSettings \
        CODE_SIGNING_ALLOWED="NO" \
        2>/dev/null | grep -m 1 "BUILT_PRODUCTS_DIR" | grep -oEi "\/.*"
)

BINARY_LOCATION="$BUILT_PRODUCTS_DIR/CommandLineBridge"

# remove the binary
rm -f "$BINARY_LOCATION" || true

echo "[*] building binary to $BUILT_PRODUCTS_DIR..."

xcodebuild \
    clean build \
    -configuration Release \
    -workspace ./App.xcworkspace \
    -scheme CommandLineBridge \
    CODE_SIGNING_ALLOWED="NO" \
    1>/dev/null 2>/dev/null

# check if the binary exists
if [ ! -f "$BINARY_LOCATION" ]; then
    echo "[E] failed to emit binary at $BINARY_LOCATION"
    exit 1
fi

echo "[*] copying binary..."

cp "$BINARY_LOCATION" .build/cli

echo "[*] signing binary..."
chmod +x .build/cli
codesign -s - --deep --force .build/cli 1>/dev/null 2>/dev/null

echo "[+] completed compile"
