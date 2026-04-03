# Fleet Tracker Auto-Run Script

Write-Host "Syncing Firebase Auth & Core dependencies..." -ForegroundColor Cyan
flutter pub add firebase_auth
flutter pub add firebase_core
flutter pub get

Write-Host "Initializing Web Support..." -ForegroundColor Cyan
flutter create .

Write-Host "Launching Fleet Tracker on Chrome..." -ForegroundColor Yellow
flutter run -d chrome