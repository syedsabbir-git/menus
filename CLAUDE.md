# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (requires a connected device or emulator)
flutter run

# Run on a specific device
flutter run -d <device_id>

# Build APK
flutter build apk

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze for lint/type errors
flutter analyze

# Format code
dart format lib/

# Get/upgrade dependencies
flutter pub get
flutter pub upgrade
```

## Environment Setup

The app requires a `.env` file at the project root with:
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

`flutter_dotenv` loads this at startup. Do not commit `.env`.

## Architecture

**Stack:** Flutter + GetX (state/DI/routing) + Supabase (PostgreSQL + Auth) + GetStorage (local persistence)

### Layer structure under `lib/app/`

| Layer | Path | Purpose |
|---|---|---|
| Routes | `routes/` | `app_routes.dart` (string constants) + `app_pages.dart` (route→page+binding map) |
| Modules | `modules/<role>/<feature>/` | Feature screens; each has `controllers/`, `views/`, and a `*_binding.dart` |
| Data | `data/` | `models/` (Supabase row ↔ Dart), `repositories/` (Supabase queries), `services/` (singletons) |
| Core | `core/` | `theme/`, `utils/` (ErrorHandler, Validators, Formatters, AppSnackBar), `widgets/` (shared UI), `constants/`, `enums/` |
| Bindings | `bindings/initial_binding.dart` | Registers global services (SupabaseService, StorageService, ThemeController) at app start |

### Module roles

- **auth** — login / register
- **splash** — checks `StorageService` for saved role, routes to the correct dashboard
- **customer** — shell (bottom nav), home, restaurant\_detail, cart, checkout, orders, profile
- **vendor** — dashboard, menu\_management, orders
- **admin** — dashboard, vendors, users

### State management pattern

Controllers extend `GetxController`. Views use `GetView<T>` for type-safe `controller` access. Reactive rebuilds use `GetBuilder<T>` (not `Obx`). Controllers mutate properties directly, then call `update()`. No `Rx` observables.

### Dependency injection

Each feature route has a `*Binding` that calls `Get.lazyPut(() => SomeController(), fenix: true)`. Global services use `Get.put()` in `InitialBinding`. Access singletons via `StorageService.to` / `SupabaseService.to`.

### Navigation & argument passing

Routes are named strings from `AppRoutes`. Navigation uses `Get.toNamed(Routes.X, arguments: someController)`. The receiving controller casts `Get.arguments` in `onInit()` — the type must match exactly what the caller passes.

### Data flow

Views → Controller → Repository → `SupabaseService.to.client` (Supabase Flutter client)

Repositories are plain Dart classes instantiated inside controllers (`final _repo = SomeRepo()`). All async calls are wrapped in `try/catch/finally` with `AppSnackBar.error(ErrorHandler.parse(e))` for user feedback.

### Models

All models implement `fromMap(Map)` (from Supabase row) and `toMap()` (for insert/update). Supabase table names are constants in `core/constants/` (`SupabaseTables`).

### Routing guard

Role-based routing is handled in `SplashController`: reads `StorageKeys.userRole` from GetStorage, then navigates to the appropriate dashboard with `Get.offAllNamed(...)`. There are no middleware-level route guards.

### Theme

`AppColors`, `AppTextStyles`, `AppDimensions` are used throughout. `ThemeController` wraps `ThemeMode` but is not yet wired to a UI toggle. Use `Theme.of(context)` for dynamic colors; use the `AppColors`/`AppTextStyles` constants for explicit values.
