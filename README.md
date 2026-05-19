# 🚗 RuralRide — Flutter Ride-Hailing App for Rural Africa

A production-ready, offline-first, accessible ride-hailing app designed for rural communities in Ghana and across Africa.

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        # AppConstants (routes, keys, prices, statuses)
│   ├── di/               # GetIt dependency injection
│   ├── errors/           # Failure types (Network, Auth, Cache, etc.)
│   ├── router/           # GoRouter configuration
│   ├── services/         # LocationService, VoiceService, OfflineSyncService
│   ├── theme/            # AppTheme, AppColors, AppTextStyles, AppSpacing
│   ├── utils/            # NetworkInfo
│   └── widgets/          # AppButton, BigIconButton, OfflineBanner, RideStatusBadge
│
├── features/
│   ├── auth/             # Login, OTP, Onboarding, Splash
│   ├── ride/             # Home, RequestRide, Tracking, History
│   ├── driver/           # DriverHome, Navigation, Earnings
│   ├── admin/            # AdminDashboard (Rides, Drivers, Stats)
│   └── profile/          # ProfileScreen
│
└── main.dart
```

---

## 🏗️ Architecture

**Clean Architecture** with three layers per feature:
- `domain/` — Entities, Repositories (abstract), UseCases
- `data/` — Models, DataSources (local + remote), Repository implementations
- `presentation/` — BLoC, Screens, Widgets

**State Management:** flutter_bloc (BLoC pattern)
**DI:** get_it
**Navigation:** go_router
**Offline Storage:** shared_preferences + hive
**Functional:** dartz (Either<Failure, Success>)

---

## 🔑 Key Features

### User App
- ✅ Phone-based login with OTP
- ✅ Onboarding with large visuals (low-literacy friendly)
- ✅ Select vehicle: Taxi / Motorcycle / Tricycle
- ✅ GPS + manual location input
- ✅ Passenger count selector
- ✅ Fare estimate calculator
- ✅ Offline ride request (saved locally, syncs when online)
- ✅ Real-time ride status tracking (simulated)
- ✅ Ride history
- ✅ Voice instructions (TTS English + pre-recorded Twi)
- ✅ Driver call/message from tracking screen
- ✅ Star rating after trip

### Driver App
- ✅ Online/Offline toggle
- ✅ Incoming ride request overlay with countdown
- ✅ Accept / Reject ride
- ✅ Navigation screen (pickup → destination)
- ✅ Earnings dashboard
- ✅ Voice announcements for each step

### Admin
- ✅ Live ride request table
- ✅ Assign drivers to unassigned rides
- ✅ Driver list with status (online/busy/offline)
- ✅ Summary stats (rides, revenue, pending offline)

---

## 🚀 Setup

### 1. Prerequisites
- Flutter 3.16+
- Dart 3.0+
- Android Studio / VS Code

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Firebase Setup (optional for real OTP)
```bash
flutterfire configure
```
- Enable Firebase Auth → Phone Authentication
- Update `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 4. Google Maps Setup
In `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_API_KEY"/>
```

In `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

### 5. Run the app
```bash
flutter run
```

---

## 🌍 Offline Mode

When there's no internet:
- Ride requests are saved locally in `SharedPreferences`
- A yellow banner notifies the user
- Voice instruction confirms offline saving
- Auto-sync runs every 30 seconds when connectivity resumes
- Pending count is shown in the home screen header

---

## 🔊 Voice Instructions

- **English:** Uses `flutter_tts` (Text-to-Speech)
- **Twi:** Uses pre-recorded `.mp3` files in `assets/audio/twi/`
  - `ride_searching.mp3`
  - `ride_accepted.mp3`
  - `driver_arriving.mp3`
  - `ride_started.mp3`
  - `ride_completed.mp3`
  - `no_internet.mp3`
  - `request_saved.mp3`
  - `login_success.mp3`
  - `welcome.mp3`

Record these with a native Twi speaker and place them in the `assets/audio/twi/` folder.

---

## 🎨 Design Decisions

| Decision | Reasoning |
|---|---|
| **Large buttons (56–60px)** | Easy to tap for users unfamiliar with touchscreens |
| **Emoji + text labels** | Visual cues for low-literacy users |
| **Warm gold/green palette** | African sun + nature, culturally resonant |
| **Offline-first** | Rural areas often have poor connectivity |
| **OTP-only login** | No password to remember |
| **Voice in Twi** | Supports local language users |
| **Simple role select** | One app serves user/driver/admin |

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `go_router` | Navigation |
| `dartz` | Functional error handling |
| `geolocator` | GPS location |
| `google_maps_flutter` | Maps |
| `flutter_tts` | Text-to-speech |
| `shared_preferences` | Local storage |
| `connectivity_plus` | Network detection |
| `firebase_auth` | Phone OTP authentication |
| `intl_phone_field` | Phone number input |
| `pin_code_fields` | OTP input |
| `smooth_page_indicator` | Onboarding dots |
| `image_picker` | Profile photo |

---

## 🛣️ Roadmap

- [ ] Real-time WebSocket driver tracking
- [ ] Google Maps polyline routing
- [ ] Mobile money payment (MTN MoMo, Vodafone Cash)
- [ ] Push notifications (FCM)
- [ ] Driver vehicle document upload
- [ ] Multi-language support (Hausa, Ga, Ewe)
- [ ] Surge pricing
- [ ] SOS emergency button

---

## 📄 License

MIT License — Free for commercial and personal use.
