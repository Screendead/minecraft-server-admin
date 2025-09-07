#!/bin/bash

# Start Firebase emulators from the root directory with data persistence
echo "Starting Firebase emulators with data persistence..."

# Create emulator data directory if it doesn't exist
mkdir -p emulator-data

# Check if we have existing data to import
if [ -d "emulator-data" ] && [ "$(ls -A emulator-data 2>/dev/null)" ]; then
    echo "📁 Found existing emulator data, importing..."
    firebase emulators:start --project=minecraft-server-automation --import=./emulator-data --export-on-exit=./emulator-data
else
    echo "🆕 No existing data found, starting fresh with persistence enabled..."
    firebase emulators:start --project=minecraft-server-automation --export-on-exit=./emulator-data
fi

# The emulators will run on:
# - Auth: http://localhost:9099
# - Firestore: http://localhost:8080
# - Storage: http://localhost:9199
# - UI: http://localhost:4000
# - Functions: http://localhost:5001
