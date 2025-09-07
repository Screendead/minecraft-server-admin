#!/bin/bash

# Clear Firebase emulator data
echo "🗑️  Clearing Firebase emulator data..."

# Remove emulator data directory
if [ -d "emulator-data" ]; then
    rm -rf emulator-data
    echo "✅ Emulator data cleared"
else
    echo "ℹ️  No emulator data found to clear"
fi

echo "💡 Use './start_emulators.sh' to start fresh emulators"
