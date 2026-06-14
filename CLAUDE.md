# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Run Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on a connected device/emulator
flutter build apk        # Build Android APK
flutter build ios        # Build iOS (macOS only)

flutter analyze          # Static analysis (lint + type checking)
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run a single test file
```

## Code generation

Dependencies use code generation via `build_runner`. After modifying any model or provider annotated for code generation, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Currently the generated providers (`riverpod_generator`) are not used — all providers are handwritten with `flutter_riverpod`.

## Architecture

This is a **read-only e-commerce catalog app** built with Flutter, displaying Cambodian souvenir products from hardcoded JSON. There is no backend — all data comes from `assets/mock/*.json`.

### Layer Map

```
lib/
├── main.dart            # Entry point: loads SharedPreferences, handles onboarding flag, wraps app in ProviderScope
├── app.dart             # MaterialApp.router with dual-theme support (light/dark via riverpod)
├── models/              # Plain Dart data classes with fromJson factories
├── data/                # Singleton MockRepository — loads JSON assets at startup into memory
├── state/               # Riverpod Notifier/StateProvider — theme, favorites, booking, map filters
├── router/              # Single GoRouter config with ShellRoute for bottom-nav tabs
├── features/            # One subfolder per screen, each file a full screen widget
├── widgets/             # Reusable UI components (ProductCard, RatingStars, MainShell, etc.)
├── theme/               # AppColors, AppTextStyles, AppTheme (light + dark ThemeData via Material 3)
```

### Key patterns

- **State management**: Riverpod (`flutter_riverpod ^3.0.0`). Providers are handwritten in `lib/state/` — no code generation is actually in use despite `riverpod_generator` being listed as a dev dependency.
- **Navigation**: Declarative `go_router` with a `ShellRoute` wrapping 5 tab destinations (Home, Favorites, Map, Promotions, Settings) inside a `MainShell` with a `NavigationBar`. Detail pages (`/product/:id`, `/artisan/:id`, etc.) route via the root navigator (full-screen push, no bottom bar).
- **Data access**: The `MockRepository` singleton pattern — call `MockRepository.instance` anywhere. It exposes getters like `.featured`, `.byCategory(id)`, `.reviewsForProduct(id)`. Data is parsed once at startup in `main()`.
- **Favorites persistence**: `FavoritesNotifier` reads/writes a `Set<String>` of product IDs to `shared_preferences`. Toggle logic is idempotent.
- **Theme**: `themeModeProvider` is a simple `Notifier<ThemeMode>` defaulting to `ThemeMode.system`. Both light/dark themes use Material 3 `ColorScheme.fromSeed` with gold as the seed color.
- **Booking**: Multi-step booking flow managed via `BookingNotifier` with an immutable `BookingState` and `copyWith` pattern — step, gift wrap, message, delivery date/time slot.

### Models

All in `lib/models/` — `Product`, `Artisan`, `GiftCollection`, `Branch`, `Review`, `Promotion`. Each has a `fromJson` factory. Product references artisans and collections by string ID (no ORM-style relations).

### Features overview

| Screen | Route | Notes |
|---|---|---|
| `HomeScreen` | `/` | Story carousel, categories, featured products, collections, artisans, quiz banner |
| `FavoritesScreen` | `/favorites` | Filterable grid of favorited products |
| `MapScreen` | `/map` | `flutter_map` with branch pins, search, open-now filter |
| `PromotionsScreen` | `/promotions` | Seasonal deals with copy-to-clipboard coupon codes |
| `SettingsScreen` | `/settings` | Theme toggle, about info |
| `ProductDetailScreen` | `/product/:id` | Gallery carousel, artisan link, reviews link, booking CTA |
| `ArtisanProfileScreen` | `/artisan/:id` | Artisan story, products list |
| `CollectionDetailScreen` | `/collection/:id` | Collection products grid |
| `NearbyScreen` | `/nearby` | Nearby shops sorted by distance |
| `BookingScreen` | `/booking/:productId` | Multi-step booking form |
| `ChatListScreen` | `/chat` | Artisan chat list |
| `ChatThreadScreen` | `/chat/:artisanId` | Mock auto-reply chat |
| `ReviewsScreen` | `/reviews/:productId` | Rating summary + review cards |
| `GalleryScreen` | `/gallery/:productId` | Masonry gallery with photo_view |
| `QuizScreen` | `/quiz` | Gift-finder quiz |
| `OnboardingScreen` | (initial flow) | Shown once based on SharedPreferences flag |
```
