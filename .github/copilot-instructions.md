<!-- .github/copilot-instructions.md - guidance for AI coding agents -->
# Qejani Hub — Copilot Instructions

Purpose: quick, actionable guidance so an AI coding agent is immediately productive in this Flutter + Firebase repo.

- Project type: Flutter app (mobile + desktop folders present). Key entry: `lib/main.dart`.
- Primary architecture: UI screens in `lib/screens/`, reusable UI in `lib/widgets/`, business logic in `lib/services/`, data models in `lib/models/`, routes in `lib/routes/app_routes.dart`.

Core design notes (important for code changes):
- Firebase-first data layer: `lib/services/*` uses `cloud_firestore` and `firebase_auth`.
  - `AuthService` (`lib/services/auth_service.dart`) handles authentication and stores lightweight user docs under `users` (auth UID -> user meta).
  - `DatabaseService` (`lib/services/database_service.dart`) organizes Firestore under a root `artifacts` document keyed by app id `qejani-hub`.
    - Public collections path pattern: `artifacts/<appId>/public/data/<collection>` (e.g. apartments, users, bookings).
    - User-private collections path: `artifacts/<appId>/users/<userId>/bookings` for per-user bookings.

Models & mapping conventions:
- Models live in `lib/models/` and include factory constructors that accept `(Map<String, dynamic> data, String id)` or `DocumentSnapshot`.
  - Examples: `Apartment`, `Booking`, `Review`, `UserModel`.
- When reading/writing Firestore timestamps, prefer explicit conversions (e.g., `Timestamp?.toDate()`), and include the document ID when constructing model instances.

Service patterns and conventions:
- Methods in services tend to `print(...)` for basic telemetry and often `rethrow` on Firebase exceptions — preserve that style when adding new service logic.
- `AuthService` includes alias methods (e.g., `signInWithEmail`) — maintain these aliases for backward compatibility when refactoring.
- `DatabaseService` provides both per-user and public writes for some actions (e.g., creating a booking writes to the renter's private bookings and also to a public bookings collection); follow this pattern for features that need cross-user visibility.

Routing & UI:
- Routes are defined in `lib/routes/app_routes.dart` and use `go_router` navigation patterns; use `context.go('/path')` in widgets.
- Role-based flows: screens like `lib/screens/role_selection_screen.dart` route users to `/login/renter` or `/login/landlord` — preserve the role strings `'renter'` and `'landlord'` when changing auth logic.

Build, run, and test commands (PowerShell examples):
```
flutter pub get
flutter run -d <device-id>
flutter build apk
flutter build ios   # macOS only
flutter test
```

Firebase and platform setup:
- Android: `android/app/google-services.json` exists in the repo — when updating Firebase projects, replace this file and re-run `flutter pub get`.
- Dart: `lib/firebase_options.dart` holds generated Firebase options; if Firebase config changes, regenerate with `flutterfire configure` (FlutterFire CLI) and commit the updated file.

Testing & quick checks:
- Basic widget test: `test/widget_test.dart` — run `flutter test` to validate UI smoke tests.
- When adding Firestore-backed tests, mock `FirebaseFirestore` or use the Firebase emulator for integration tests.

What to look for in PRs and edits:
- Keep Firestore pathing consistent with `DatabaseService` (don't introduce ad-hoc top-level collections without reason).
- Preserve model `fromMap/fromFirestore` factories and include the document ID in returned objects.
- Maintain existing logging (`print`) style for quick local debugging; larger changes can introduce structured logging only with agreement.

Files to inspect for context when editing code:
- `lib/services/auth_service.dart`
- `lib/services/database_service.dart`
- `lib/models/*` (all model definitions)
- `lib/screens/*` (UI flows and role-based navigation)
- `lib/widgets/*` (reusable UI components)
- `pubspec.yaml` (dependencies)

If anything is unclear or you need additional conventions (naming, linting, CI), ask for the preferred style and I'll update this file.

— End of guidance —
