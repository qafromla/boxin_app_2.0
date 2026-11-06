# Boxing Timer

A simple boxing round timer with **Training History** — every workout is saved with
the real number of completed rounds and the real time trained.

## Features
- Round / rest / rounds setup, remembered between launches
- Presets: Pro Fight 12×3:00, Amateur 3×3:00, Sparring, Heavy Bag, Quick HIIT
- 5-second "get ready" countdown, bells and last-5-seconds beeps
- Pause, restart round, −30s / +30s
- Training History with weekly count, total rounds and day streak
- Light and dark mode

## Project structure
- `lib/logic/workout_engine.dart` — timer logic (no UI, fully tested)
- `lib/services/` — settings, training history storage, sounds
- `lib/screens/` — Home, Workout Settings, Workout, Training History
- `lib/widgets/app_widgets.dart` — shared buttons, cards, round segments
- `lib/theme/app_theme.dart` — colors and light/dark themes

## Run checks
```
flutter analyze
flutter test
```
The same checks run automatically on GitHub for every pull request.
