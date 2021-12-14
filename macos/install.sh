#!/usr/bin/env bash

# set -e
echo "EDMS Installer"

FIRMWARE=${1:-$HOME/Downloads/firmware.elf}

which avrdude > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "ℹ️  Installing avrdude if not already installed..."
    /bin/bash -c "$(curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install avrdude
fi

avrdude > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "✅ avrdude found in $(which avrdude)"
    echo "✅ avrdude OK"
else
    echo "❌ avrdude NOT OK"
    exit 1
fi

if [[ $FIRMWARE ]]; then
    echo "ℹ️  Working on $FIRMWARE"
else
    echo "❌ You MUST pass a firmware"
    exit 1
fi

if [[ $2 ]]; then
    export RAVEDUDE_PORT=$2
    echo "ℹ️  Working on port '$RAVEDUDE_PORT'"
else
    echo "ℹ️  Working on DEFAULT port"
fi

if test -f $FIRMWARE; then
    echo "✅ Found $FIRMWARE"
else
    echo "❌ File $FIRMWARE NOT found"
    exit 1
fi

RAVEDUDE_URL=https://github.com/ED-MS/avr-hal/releases/download/v0.1.3/ravedude-macos-latest.zip
ZIP_TARGET=/tmp/avrdude.zip

wget -q $RAVEDUDE_URL -O $ZIP_TARGET

# ls -alh $ZIP_TARGET
unzip -o $ZIP_TARGET
chmod a+x ravedude

ravedude --version
if [[ $? -eq 0 ]]; then
    echo "✅ ravedude OK"
else
    echo "❌ ravedude NOT OK"
    exit 1
fi

echo "⚠️ You are about to upload a new firmware from $FIRMWARE"
read -p "You may abort NOW with CTRL+C. Press ENTER to continue"

echo "Updating firmware, please wait..."

ravedude mega2560 $FIRMWARE

if [[ $? -eq 0 ]]; then
    echo "✅ Upload SUCCESSFUL"
else
    echo "❌ The update failed with code $?"
    exit 1
fi
