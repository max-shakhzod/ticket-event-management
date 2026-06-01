# Ticketio

Ticketio is a cross-platform Flutter app for offline event ticket validation. It allows event staff to scan QR codes, verify tickets against a local database, and track attendance without requiring an internet connection.

## Features

* QR code scanning with three outcomes:

  * Valid
  * Invalid
  * Already Scanned
* Role-based access (Super Admin, Event Manager, Scanner)
* Secure local authentication and session persistence
* Attendance dashboard and ticket category statistics
* Scan history and audit logging
* Fully offline operation

## Tech Stack

Flutter · SQLite (`sqflite`) · Provider · `flutter_secure_storage` · `crypto` · `mobile_scanner`

**Platforms:** Android, iOS, Windows, macOS, Linux

## Getting Started

```bash
flutter pub get
flutter run
```

## Structure

```text
lib/
├── db/
├── models/
├── providers/
├── screens/
├── widgets/
└── main.dart
```

## Roadmap

* ✅ Core scanning and validation
* 🟡 Authentication and role management
* ⏳ CSV import and offline sync
* ⏳ Search, pagination, and reporting
* ⏳ Testing, localization, and UI polish

## License

MIT
