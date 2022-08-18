#!/bin/bash

set -ex

cd "$(dirname "$0")"/../ModuleTemplate
SOURCE_DIR="$(pwd)"

TARGET_DIR="../../App/Action/Action/Backend/Action/ActionTemplates"
cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"

FLAG_FILE=".templates"
PATH_EXTENSION="ActionTemplatePackage"

if [ ! -f "$SOURCE_DIR/$FLAG_FILE" ]; then
    echo "malformed project structure"
    exit 1
fi

if [ ! -f "$TARGET_DIR/$FLAG_FILE" ]; then
    echo "malformed project structure"
    exit 1
fi

echo "[*] Cleaning up old templates..."
cd "$TARGET_DIR"
rm -rf ./*

echo "[*] Cleaning up dirty templates..."
cd "$SOURCE_DIR"
find "$SOURCE_DIR" -name ".DS_Store" -delete
find "$SOURCE_DIR" -name "._*" -delete
git clean -fdx

echo "[*] Packaging templates..."
cd "$SOURCE_DIR"
for TEMPLATE_ITEM in *
do
    echo "[*] Packaging $TEMPLATE_ITEM..."
    cd "$SOURCE_DIR/$TEMPLATE_ITEM" || continue
    tar -cvf "$TARGET_DIR/$TEMPLATE_ITEM.$PATH_EXTENSION" .
done

echo "[*] Done"