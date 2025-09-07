#!/bin/bash

# Export Firebase emulator data
echo "📤 Exporting Firebase emulator data..."

# Create emulator data directory if it doesn't exist
mkdir -p emulator-data

# Export current emulator data
firebase emulators:export ./emulator-data --project=minecraft-server-automation

echo "✅ Emulator data exported to ./emulator-data/"
echo "💡 Use './start_emulators.sh' to start emulators with this data"
