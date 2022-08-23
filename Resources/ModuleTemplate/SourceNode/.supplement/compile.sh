#!/bin/zsh

# this compiler script is designed to issue result to ./dist/index.js

set -e

cd "$(dirname "$0")"/../

echo "[*] starting build at $(pwd)..."

if [ ! -f .action ]; then
    echo "[E] malformed project architecture"
    exit 1
fi

echo "[*] cleaning build..."

rm -rf dist || true

echo "[*] install dependencies..."

npm i

echo "[*] compile..."

npm run build

echo "[+] completed compile"
