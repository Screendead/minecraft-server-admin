# Firebase Emulator Data Persistence

This project is configured to persist Firebase emulator data between restarts, ensuring that your test data, authentication users, and Firestore documents are preserved when you stop and restart the emulators.

## How It Works

The emulator data is automatically saved to the `emulator-data/` directory and restored when you restart the emulators. This includes:

- **Firestore documents and collections**
- **Authentication users and tokens**
- **Storage files and metadata**
- **Functions logs and state**

## Usage

### Starting Emulators with Persistence

```bash
./start_emulators.sh
```

This script will:
- Check for existing data in `emulator-data/`
- Import existing data if found
- Start emulators with automatic export on exit
- Create fresh data if none exists

### Manual Data Management

#### Export Current Data
```bash
./export_emulator_data.sh
```
Exports the current emulator state to `emulator-data/`

#### Clear All Data
```bash
./clear_emulator_data.sh
```
Removes all persisted emulator data and starts fresh

### Manual Commands

#### Start with Import
```bash
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

#### Start Fresh with Persistence
```bash
firebase emulators:start --export-on-exit=./emulator-data
```

#### Export Data Only
```bash
firebase emulators:export ./emulator-data
```

## Important Notes

### Graceful Shutdown
- Always stop emulators gracefully (Ctrl+C) to ensure data is exported
- Abrupt termination may result in data loss

### Data Location
- Emulator data is stored in `emulator-data/` directory
- This directory is gitignored to prevent committing test data
- Data persists across git operations and branch switches

### Development Workflow
1. Start emulators: `./start_emulators.sh`
2. Develop and test your application
3. Stop emulators gracefully (Ctrl+C)
4. Data is automatically saved
5. Restart emulators: `./start_emulators.sh`
6. Your data is restored!

## Troubleshooting

### Data Not Persisting
- Ensure you're stopping emulators gracefully (Ctrl+C)
- Check that `emulator-data/` directory exists and is writable
- Verify the export completed successfully in the terminal output

### Starting Fresh
- Use `./clear_emulator_data.sh` to remove all persisted data
- Or manually delete the `emulator-data/` directory

### Data Corruption
- If data seems corrupted, clear it with `./clear_emulator_data.sh`
- Start fresh and re-create your test data

## Emulator URLs

- **UI Dashboard**: http://localhost:4000
- **Auth Emulator**: http://localhost:9099
- **Firestore Emulator**: http://localhost:8080
- **Storage Emulator**: http://localhost:9199
- **Functions Emulator**: http://localhost:5001
