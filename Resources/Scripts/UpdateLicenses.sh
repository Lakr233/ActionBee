#!/bin/bash

set -ex

cd "$(dirname "$0")"
CURR_DIR="$(pwd)"
cd ../../
SOURCE_DIR="$(pwd)"

if [ ! -f "$SOURCE_DIR/App/Action/Action/Application/License.txt" ]; then
    echo "License.txt not found in App/Action/Action/Application"
    exit 1
fi

cat "$SOURCE_DIR/LICENSE" > "$SOURCE_DIR/App/Action/Action/Application/License.txt"

# for every LICENSE inside External
for dir in "$SOURCE_DIR"/External/*; do
    if [ -d "$dir" ]; then
        if [ -f "$dir/LICENSE" ]; then
            echo "" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
            echo "==========" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
            echo "" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
            echo "$(basename "$dir")" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
            cat "$dir/LICENSE" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
            echo "" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
        fi
    fi
done

echo "" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
echo "" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
echo "==========" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
echo "" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"
TIME=$(date +%Y-%m-%d)
echo "Updated: $TIME" >> "$SOURCE_DIR/App/Action/Action/Application/License.txt"

swift "$CURR_DIR/NewlineDeduplicate.swift" "$SOURCE_DIR/App/Action/Action/Application/License.txt"

echo "Done"