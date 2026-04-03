# DrowsyDriver Flutter App

A real-time drowsiness monitoring dashboard built with Flutter and Firebase Realtime Database.

## Features

- 🔴 **Real-time DANGER Alert** — Screen flashes red and pulses when `driver_status` is `DANGER`
- 📋 **Alert History** — Firebase `alerts_history` node shown as a beautiful list with Cloudinary images
- 📸 **Cloudinary Images** — Expandable alert cards show the full captured image from Cloudinary
- ✨ **Dark UI** — Premium dark glassmorphism design with animated status cards

## Firebase RTDB Structure Expected

```
drowsydriver-eff03/
├── driver_status/
│   ├── status: "DANGER" | "WARNING" | "SAFE" | "NORMAL"
│   ├── confidence: 0.95
│   ├── driver_id: "driver_001"
│   └── last_updated: 1712345678000   ← milliseconds epoch
│
└── alerts_history/
    └── <alert_id>/
        ├── status: "DANGER"
        ├── image_url: "https://res.cloudinary.com/..."
        ├── timestamp: 1712345678000
        ├── location: "Sector 14, Delhi"
        └── confidence: 0.92
```

> **Note**: `driver_status` can also be just a plain string node — the app handles both cases.

## Setup & Run

1. Make sure Flutter SDK is installed and in your PATH
2. Open this folder in Android Studio or VS Code
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry + Firebase init
├── firebase_options.dart        # Firebase config (auto-generated)
├── models/
│   ├── driver_status.dart       # DriverStatus model
│   └── alert_record.dart        # AlertRecord model
├── services/
│   └── firebase_service.dart    # RTDB streams
├── screens/
│   ├── dashboard_screen.dart    # Main dashboard
│   └── alerts_history_screen.dart  # Alert list
└── widgets/
    ├── danger_overlay.dart      # Red flash overlay
    └── status_card.dart         # Stats card widget
```
