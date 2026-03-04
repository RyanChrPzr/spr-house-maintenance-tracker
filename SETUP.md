# Development Setup Guide

Run these steps **once** to get the project running locally.

## Prerequisites

- Flutter SDK (stable channel): https://docs.flutter.dev/get-started/install
- Supabase CLI: `brew install supabase/tap/supabase`
- Xcode (for iOS) + Android Studio (for Android)
- Firebase project with FCM enabled

## Step 1: Initialise the Flutter project

```bash
# From repo root — flutter create adds android/, ios/ alongside existing lib/ files
flutter create spr_house_maintenance_tracker --org com.spr --platforms ios,android
```

> The `lib/`, `pubspec.yaml`, `analysis_options.yaml`, and `main.dart` already exist
> in the repo. Flutter create will ask to overwrite — answer **yes** for the platform
> directories only. Keep the custom `lib/` and `pubspec.yaml` from the repo.

```bash
cd spr_house_maintenance_tracker
flutter pub get
flutter analyze    # should report zero issues
```

## Step 2: Firebase setup

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app (package: `com.spr.spr_house_maintenance_tracker`) → download `google-services.json` → place in `android/app/`
3. Add an iOS app (bundle ID: `com.spr.sprHouseMaintenanceTracker`) → download `GoogleService-Info.plist` → place in `ios/Runner/`
4. Enable Cloud Messaging in Firebase console
5. Note your FCM Sender ID from Project Settings → Cloud Messaging

## Step 3: Supabase project setup

1. Create a free project at https://supabase.com
2. Copy your **Project URL** and **anon public key** from Settings → API
3. Copy your `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
# Edit .env with real SUPABASE_URL, SUPABASE_ANON_KEY, FCM_SENDER_ID
```

## Step 4: Initialise Supabase CLI + apply migrations

```bash
# From repo root
supabase init         # creates supabase/config.toml
supabase start        # starts local Postgres + Studio (requires Docker)
supabase db push      # applies all migrations in supabase/migrations/

# Verify in Supabase Studio
open http://localhost:54323
# Check that 'profiles' table exists with RLS enabled
```

## Step 5: Run the app

```bash
cd spr_house_maintenance_tracker

# iOS
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
            --dart-define=FCM_SENDER_ID=$FCM_SENDER_ID \
            -d <ios-device-id>

# Android
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
            --dart-define=FCM_SENDER_ID=$FCM_SENDER_ID \
            -d <android-device-id>
```

The app should launch and display "Login — Story 1.3" (placeholder screen).

## VS Code launch.json (recommended)

Add to `.vscode/launch.json` to avoid typing --dart-define each time:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "SPR (dev)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=SUPABASE_URL=${env:SUPABASE_URL}",
        "--dart-define=SUPABASE_ANON_KEY=${env:SUPABASE_ANON_KEY}",
        "--dart-define=FCM_SENDER_ID=${env:FCM_SENDER_ID}"
      ]
    }
  ]
}
```

Load `.env` into your shell before launching VS Code: `export $(cat .env | xargs)`.

## Current Sprint

See `_bmad-output/implementation-artifacts/sprint-status.yaml` for story progress.
Implement stories in order using `/bmad-bmm-dev-story`.
