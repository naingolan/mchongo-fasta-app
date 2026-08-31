# MchongoFasta Mobile

Flutter app for workers and employers on the Tanzanian daily-work marketplace.

## Design

Blue fintech visual system (splash, onboarding, soft cards, pill CTAs) with MchongoFasta product context: jobs, verification, wallet, and hiring.

Reusable UI lives in `lib/widgets/mf_components.dart` (buttons, inputs, radios, toggles, checklist rows, balance cards, success dialog). Auth/setup screens in `lib/screens/auth_flow.dart` use those components.

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```
