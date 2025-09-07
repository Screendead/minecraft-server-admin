# Minecraft Server Admin

A Flutter web application for managing Minecraft servers with Firebase integration.

## 🚀 Quick Start

1. **Setup Firebase:**
   ```bash
   cd app
   flutterfire configure
   ```

2. **Start Firebase Emulators:**
   ```bash
   ./start_emulators.sh
   ```

3. **Run the App:**
   ```bash
   cd app
   flutter run -d chrome
   ```

## 📊 Coverage

[![codecov](https://codecov.io/gh/Screendead/minecraft-server-admin/branch/master/graph/badge.svg)](https://codecov.io/gh/Screendead/minecraft-server-admin)

## 🛠️ Development

- **Flutter Version:** 3.27.0
- **Firebase Project:** minecraft-server-automation
- **Coverage Requirement:** 100% (enforced in CI)

## 📁 Project Structure

```
├── app/                    # Flutter application
│   ├── lib/               # Dart source code
│   ├── test/              # Test files
│   └── firebase.json      # Firebase configuration
├── .github/workflows/     # CI/CD pipelines
└── README.md             # This file
```

## 🔧 CI/CD

- **Master Branch:** Deploys to production Firebase Hosting
- **Pull Requests:** Creates preview deployments with coverage reports
- **Coverage:** 100% test coverage required for merging

## 📚 Documentation

- [CI/CD Setup Guide](CI_CD_README.md)
- [App Development Guide](app/README.md)
