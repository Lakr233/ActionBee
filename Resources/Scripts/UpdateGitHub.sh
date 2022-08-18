#!/bin/bash

set -e

cd "$(dirname "$0")"
cd ../../

# check if .root file exists
if [ ! -f .root ]; then
    echo "malformed project structure, missing .root file"
    exit 1
fi

ORIG_DIR=$(pwd)
TARGET_DIR="/Users/qaq/Bootstrap/GitHub/ActionBee"

# check if ORIG_DIR has prefix 
if [[ $ORIG_DIR != "/Users/qaq/Bootstrap/"* ]]; then
    echo "this script is used to sync commit on @Lakr233 device, do not run it!"
    exit 1
fi

# check if target exists
if [ ! -d $TARGET_DIR ]; then
    echo "target directory $TARGET_DIR does not exist"
    exit 1
fi
# check if file target/.root exists
if [ ! -f $TARGET_DIR/.root ]; then
    echo "target directory $TARGET_DIR is not target project"
    exit 1
fi

echo "Syncing from $ORIG_DIR to $TARGET_DIR"

# check if git repo at ORIG_DIR has uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "git repo at $ORIG_DIR has uncommitted changes"
    exit 1
fi

# clean our project first
git clean -fdx

# remove everything at target
rm -rf $TARGET_DIR/* # not .file at root

# copy over
cp -r $ORIG_DIR/* $TARGET_DIR

PROHIBIT_FILE_LIST=(
    "Resources/Design"
)

# remove prohibited files
for file in "${PROHIBIT_FILE_LIST[@]}"; do
    echo "removing $TARGET_DIR/$file"
    rm -rf "${TARGET_DIR:?}/$file"
done

find $TARGET_DIR/External -name ".git" -delete

# get current commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)

cd $TARGET_DIR
git add .
git commit -m "Sync Update - $COMMIT_HASH"

echo ""
echo "======= Sync Update - $COMMIT_HASH ======="
echo "To push to remote, run following command:"
echo ""
echo "  cd $TARGET_DIR && git push origin master"
echo ""
echo "=========================================="
echo ""

# done
