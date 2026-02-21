# Vehicles-Logs-MotoLog

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

# MotoLog

A Flutter app to manage vehicles and track maintenance/service logs, costs, and reminders — with a simple dashboard and spending chart.

## Features

- **Multiple vehicles**: Add/edit/delete vehicles (name, license number, odometer, notes, etc.).
- **Service & expense logs**: Record maintenance entries with date, category, shop, odometer reading, cost, and notes.
- **Maintenance checklist**: Create checklist items per vehicle, set optional target dates, and mark items complete.
- **Spending chart**: Pie chart breakdown of spending by category for a selected vehicle.
- **Theme setting**: Light/Dark/System theme selection.

## Tech Stack

- **Flutter (Material 3)**
- **State management**: `provider`
- **Local storage**:
  - `sqflite` (SQLite) for vehicles/logs/checklist
  - `shared_preferences` for settings (theme)
- **Charts**: `fl_chart`

## Sample Screenshot
![Screenshot](https://github.com/kevin030-anto/To-Do-List/b0List.jpg)

## **Note:**

**The project has not been added to the repository yet (coming soon...).**

## Getting Started

### Prerequisites

- Flutter SDK installed
- A configured device/emulator (Android/iOS) or desktop target (Windows/macOS/Linux)

Verify your setup:

```bash
flutter doctor
```

### Run locally

```bash
flutter pub get
flutter run
```

### Run tests

```bash
flutter test
```

## Data Storage & Privacy

All data is stored **locally on the device** in a SQLite database (`vehicle_log.db`). Nothing is sent to a server by default.

## Project Structure

- `lib/main.dart` — App entry point + providers
- `lib/db/` — SQLite helper and schema
- `lib/models/` — Data models (Vehicle, LogEntry, ChecklistItem)
- `lib/providers/` — App state (vehicles, logs, checklist, settings)
- `lib/screens/` — UI pages (home, vehicle dashboard, logs, checklist, chart, settings)

## Build

Common build commands:

```bash
flutter build apk
flutter build appbundle
flutter build ios
flutter build windows
flutter build macos
flutter build linux
flutter build web
```

## Contributing

Issues and pull requests are welcome. If you’re making bigger changes, open an issue first to discuss what you want to add.

## License

Add a license for your repository (for example: MIT). If you don’t add one, GitHub defaults to “All rights reserved”.

## Author

GitHub: [@kevin030-anto](https://github.com/kevin030-anto)
