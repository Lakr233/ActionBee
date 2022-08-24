#!/bin/zsh

# this compiler script is designed to issue result to ./dist/index.js

export PATH=$PATH:/opt/homebrew/bin:/usr/local/bin

if ! [ -x "$(command -v npm)" ]; then
  echo '[E] npm is not installed.' >&2
  exit 1
fi

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
