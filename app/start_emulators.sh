#!/bin/bash

# Start Firebase emulators
echo "Starting Firebase emulators..."
firebase emulators:start --project=minecraft-server-automation

# The emulators will run on:
# - Auth: http://localhost:9099
# - Firestore: http://localhost:8080
# - Storage: http://localhost:9199
# - UI: http://localhost:4000
