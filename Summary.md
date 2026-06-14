# Sovann Souvenir — Complete Codebase Documentation

> **App purpose**: A Flutter e-commerce catalog app for browsing and ordering handmade Cambodian souvenir gifts. Features product browsing, gift-finder quiz, booking flow, map with artisan shop locator, chat simulation, and full 5-language localization.

---

## 1. Libraries & Dependencies — Full Inventory

### SDK / Framework
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `flutter` (SDK) | Every file | The UI framework itself |
| `flutter_localizations` (SDK) | `lib/app.dart` | Provides Material widget translations (Cut/Copy/Paste, date picker) in 80+ languages — wired via `AppLocalizations.localizationsDelegates` |

### State Management
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `flutter_riverpod` ^3.0.0 | `lib/state/*.dart`, every `ConsumerWidget`/`ConsumerStatefulWidget` screen | Reactive state management — providers notify widgets to rebuild when state changes. We use `NotifierProvider` for complex state (auth, theme, locale, booking, favorites) and `StateProvider` for simple flags (map search, filters) |
| `riverpod_annotation` ^4.0.0 | Listed but **not actively used** — all providers are handwritten | Code-generation annotations (reserved for future use with `riverpod_generator`) |

### Navigation
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `go_router` ^17.0.0 | `lib/router/app_router.dart`, every screen that calls `context.push()` / `context.go()` / `context.pop()` | Declarative routing with a `ShellRoute` for bottom-nav tabs. Detail pages route via the root navigator (full-screen push, no bottom bar) |

### Local Storage
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `shared_preferences` ^2.5.0 | `lib/state/locale_provider.dart`, `lib/state/favorites_provider.dart`, `lib/features/onboarding/onboarding_screen.dart` | Key-value disk storage — persists favorites set, selected locale, and onboarding "seen" flag across app restarts |

### Internationalization
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `intl` ^0.20.0 | `lib/l10n/generated/*.dart` (auto-generated), `lib/features/booking/booking_screen.dart` (via `table_calendar`) | ICU message formatting for plurals (`{count, plural, ...}`), date formatting, and number formatting. Used transitively by `flutter_localizations` and `table_calendar` |

### Maps & Location
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `flutter_map` ^8.3.0 | `lib/features/map/map_screen.dart` | OpenStreetMap-based interactive map (no API key needed). Uses `TileLayer` with CartoCDN tiles, `MarkerLayer` for branch pins |
| `latlong2` ^0.9.1 | `lib/features/map/map_screen.dart` | Geographic coordinate types (`LatLng`) for map markers and camera positioning |
| `geolocator` ^13.0.0 | `lib/features/map/map_screen.dart` | Device GPS — requests location permission, gets current position, shown as blue dot on map |
| `url_launcher` ^6.3.0 | `lib/features/map/map_screen.dart`, `lib/features/nearby/nearby_screen.dart` | Opens Google Maps directions URL in the device's browser/maps app |

### Images & Media
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `cached_network_image` ^3.4.0 | `lib/widgets/product_card.dart`, detail/artisan/collection/map/gallery/reviews screens | Caches remote images to disk — product photos, artisan avatars, hero carousel images. Reduces bandwidth and works offline for previously-loaded images |
| `photo_view` ^0.15.0 | `lib/features/gallery/gallery_screen.dart` | Pinch-to-zoom image viewer with `PhotoViewGallery` — swipe through product images, zoom into details |

### UI Helpers
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `shimmer` ^3.0.0 | `lib/widgets/shimmer_card.dart` | Skeleton loading placeholder — shimmer animation while images/data load |
| `smooth_page_indicator` ^2.0.0 | `lib/features/home/home_screen.dart`, `lib/features/onboarding/onboarding_screen.dart` | Dot indicators for PageView — hero carousel and onboarding flow |
| `flutter_animate` ^4.5.0 | `lib/features/home/home_screen.dart` | Declarative animations — `.fadeIn(duration: 600.ms)` on hero carousel |
| `table_calendar` ^3.2.0 | `lib/features/booking/booking_screen.dart` | Calendar date picker — booking Step 3 delivery date selection |
| `flutter_svg` ^2.2.0 | Listed, ready for SVG icons/assets |
| `lottie` ^3.3.0 | Listed, ready for Lottie animations |

### Backend
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `supabase_flutter` ^2.8.0 | `lib/main.dart`, `lib/state/auth_provider.dart`, `lib/features/auth/*.dart` | Backend-as-a-Service — email/password authentication, session persistence, user management. Currently used for auth only; mock data serves as product catalog |

### Fonts & Icons
| Library | Where Used | Purpose |
|---------|-----------|---------|
| `google_fonts` ^8.0.0 | `lib/theme/app_text_styles.dart` | Playfair Display (headings) + Lato (body) — loaded via `GoogleFonts` package for consistent cross-platform rendering |
| `cupertino_icons` ^1.0.8 | Not directly used — available for iOS-style icons |

### Dev Dependencies
| Library | Purpose |
|---------|---------|
| `build_runner` ^2.5.0 | Code generation runner (`dart run build_runner build`) |
| `riverpod_generator` ^4.0.0 | Generates Riverpod providers from annotations (not currently in use) |
| `flutter_launcher_icons` ^0.14.4 | Generates app icon from `assets/icons/app_icon.png` |

---

## 2. Architecture Overview

### Layer Map
```
lib/
├── main.dart                 ← Entry point
├── app.dart                  ← Root widget (auth gate + theme + locale + router)
├── models/                   ← Plain Dart data classes with fromJson factories
├── data/                     ← MockRepository (JSON loader) + ContentTranslations
├── state/                    ← Riverpod providers (auth, theme, locale, favorites, booking, map)
├── router/                   ← GoRouter config with ShellRoute
├── features/                 ← One subfolder per screen
│   ├── auth/                 ← Login, SignUp, VerifyEmail
│   ├── home/                 ← HomeScreen
│   ├── favorites/            ← FavoritesScreen
│   ├── map/                  ← MapScreen
│   ├── nearby/               ← NearbyScreen
│   ├── promotions/           ← PromotionsScreen
│   ├── settings/             ← SettingsScreen
│   ├── detail/               ← ProductDetailScreen
│   ├── artisan/              ← ArtisanProfileScreen
│   ├── collection/           ← CollectionDetailScreen
│   ├── booking/              ← BookingScreen (multi-step wizard)
│   ├── chat/                 ← ChatListScreen, ChatThreadScreen
│   ├── reviews/              ← ReviewsScreen
│   ├── gallery/              ← GalleryScreen (full-screen image viewer)
│   ├── quiz/                 ← QuizScreen (gift-finder)
│   └── onboarding/           ← OnboardingScreen (first-launch flow)
├── widgets/                  ← Reusable UI components
├── theme/                    ← AppColors, AppTextStyles, AppTheme (light + dark)
└── l10n/                     ← ARB translation files + generated code
```

### Data Flow
```
assets/mock/*.json  ──load──▶  MockRepository (singleton, in-memory)
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                  ▼
              models/Product    models/Artisan     models/Review  ...
                    │                 │                  │
                    ▼                 ▼                  ▼
              Riverpod Providers ◀── Widgets read via ref.watch()
                    │
                    ▼
              Screens display translated content
                    │
                    ▼
              AppLocalizations.of(context) → ARB files → 5 languages
```

### State Flow for Language Switch
```
User taps Language in Settings
  → Bottom sheet appears with 5 languages
  → User taps "ភាសាខ្មែរ"
  → ref.read(localeProvider.notifier).setLocale(Locale('km'))
  → LocaleNotifier: state = Locale('km'), persists to SharedPreferences
  → MaterialApp rebuilds with new locale
  → MockRepository.setLocale('km') syncs content locale
  → All AppLocalizations.of(context).xxx return Khmer strings
  → Hanuman font auto-applied via MaterialApp.builder
  → productsTr returns translated product names/descriptions
```

---

## 3. File-by-File Documentation

---

### `lib/main.dart` — App Entry Point

**What is it?** The very first file Flutter runs.

**What does it do?** Initializes Supabase (auth backend), loads mock product data into memory, loads content translations for 5 languages, then launches the app wrapped in `ProviderScope` (Riverpod).

**Why we need it?** All initialization must happen before `runApp()`. Without this, the app has no data and no auth.

**Crucial code:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Required before any async work
  await Supabase.initialize(...);              // Auth backend
  await MockRepository.instance.init();        // Load JSON products into memory
  await ContentTranslations.init();            // Load 5-language content translations
  runApp(const ProviderScope(child: SovannSouvenirApp()));  // Launch
}
```

**Real-life analogy**: Like a store manager opening the shop — unlocks the door (Supabase), unpacks inventory from boxes (MockRepository), puts up translated signs (ContentTranslations), then opens for business (runApp).

**Connections**: `main.dart` → `app.dart` (launches it) → `MockRepository` (loads data) → `ContentTranslations` (loads translations)

---

### `lib/app.dart` — Root Widget (Authentication Gate)

**What is it?** The top-level `ConsumerWidget` that decides which screen to show based on auth state.

**What does it do?** Watches `authProvider` and displays one of 4 states:
- `loading` → spinner
- `unauthenticated` → Login/SignUp screens
- `emailNotVerified` → "Check your email" screen
- `authenticated` → Main app with GoRouter + dual theme + 5-language localization

**Why we need it?** Single entry point that gates the entire app behind authentication. All 4 branches share the same localization configuration.

**Crucial code — the authenticated branch:**
```dart
case AppAuthState.authenticated:
  return MaterialApp.router(
    theme: AppTheme.light,               // Gold seed color, cream background
    darkTheme: AppTheme.dark,            // Dark brown surface, gold accents
    themeMode: themeMode,                // system / light / dark (user toggle)
    locale: locale,                      // en / km / zh / ja / vi
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: appRouter,             // GoRouter shell + routes
    builder: (context, child) {          // Auto-apply Hanuman font for Khmer
      if (Localizations.localeOf(context).languageCode == 'km') {
        return DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: 'Hanuman'),
          child: child!,
        );
      }
      return child!;
    },
  );
```

**Real-life analogy**: A hotel lobby with a security guard. The guard checks your key card (auth state):
- No card → go to registration desk (login)
- Card not activated → go to verification desk
- Valid card → enter the main hotel (the app with all features)

**Connections**: `app.dart` reads from → `authProvider`, `themeModeProvider`, `localeProvider` | `app.dart` provides → `appRouter`, `AppTheme`, `AppLocalizations`

---

### `lib/router/app_router.dart` — Navigation Map

**What is it?** The GoRouter configuration defining every possible route in the app.

**What does it do?** Sets up a `ShellRoute` wrapping 5 tab destinations (Home, Favorites, Map, Promotions, Settings) inside a `MainShell` with a bottom `NavigationBar`. Full-screen detail pages (product, artisan, booking, etc.) use `parentNavigatorKey: _rootKey` to push over the tabs without the bottom bar.

**Why we need it?** Without a router, every screen navigation would need manual `Navigator.push` with duplicated boilerplate. GoRouter gives us named routes with path parameters (`/product/:id`), type-safe navigation, and deep-link support.

**Crucial code — ShellRoute pattern:**
```dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),  // Wraps tabs with nav bar
      routes: [
        GoRoute(path: '/',           builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/favorites',  builder: (c, s) => const FavoritesScreen()),
        GoRoute(path: '/map',        builder: (c, s) => const MapScreen()),
        GoRoute(path: '/promotions', builder: (c, s) => const PromotionsScreen()),
        GoRoute(path: '/settings',   builder: (c, s) => const SettingsScreen()),
      ],
    ),
    // Full-screen routes (no bottom nav bar):
    GoRoute(path: '/product/:id',    parentNavigatorKey: _rootKey, builder: ...),
    GoRoute(path: '/booking/:productId', parentNavigatorKey: _rootKey, builder: ...),
    // ... 8 more full-screen routes
  ],
);
```

**Real-life analogy**: A shopping mall directory map. The `ShellRoute` is the main concourse with 5 anchor stores always visible. The `_rootKey` routes are individual stores you enter fully, leaving the concourse behind. Path parameters like `:id` are like store numbers — "go to store #p5".

**Connections**: `app_router.dart` is consumed by → `app.dart` (via `routerConfig: appRouter`) | `app_router.dart` imports → every screen file, `MainShell`

---

### `lib/widgets/main_shell.dart` — Bottom Navigation Bar Wrapper

**What is it?** The persistent scaffold wrapping all 5 tab screens with a Material 3 `NavigationBar`.

**What does it do?** Reads the current URL from `GoRouterState` to determine which tab is active (highlighted). Tapping a tab calls `context.go()` to navigate.

**Why we need it?** Without `MainShell`, each tab would need its own `Scaffold` with duplicated navigation bar code. This centralizes the bottom bar in one place.

**Crucial code — tab index detection:**
```dart
int _currentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/favorites'))  return 1;  // Tab 1 = Saved
  if (location.startsWith('/map'))        return 2;  // Tab 2 = Map
  if (location.startsWith('/promotions')) return 3;  // Tab 3 = Promos
  if (location.startsWith('/settings'))   return 4;  // Tab 4 = Settings
  return 0;  // Default = Home
}
```

**Real-life analogy**: The navigation bar is like the tab bar in Instagram — Home, Search, Reels, Shop, Profile. Each tab remembers its state independently.

**Connections**: `main_shell.dart` wraps → all 5 tab screens | `main_shell.dart` provides → `NavigationBar` with 5 `NavigationDestination` widgets

---

### `lib/theme/app_theme.dart` — Light & Dark Theme Definitions

**What is it?** Two static `ThemeData` configurations (light + dark) using Material 3's `ColorScheme.fromSeed`.

**What does it do?** Defines colors for every Material component: AppBar, cards, chips, buttons, dividers, navigation bar, input fields. The seed color is gold (`#C8960C`), which generates a full harmonious palette automatically.

**Why we need it?** A centralized theme means changing one file updates the entire app's look. The `fromSeed` generator ensures all colors work together.

**Crucial code — dark theme surfaces:**
```dart
static ThemeData get dark => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.gold,           // Gold generates the palette
    brightness: Brightness.dark,
    primary: AppColors.goldLight,        // #E8B84B (lighter gold for dark bg)
    surface: AppColors.darkSurface,      // #2C1A0E (dark brown cards)
    onSurface: AppColors.cream,          // #FFF8E7 (light text on dark)
  ),
  scaffoldBackgroundColor: AppColors.darkBg,  // #1A0F07 (near-black)
  cardTheme: CardThemeData(color: AppColors.darkCard),  // #3D2614
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCard,       // Dark input fields
    focusedBorder: BorderSide(color: AppColors.goldLight),
  ),
);
```

**Real-life analogy**: A restaurant's brand guide — defines exactly what colors the walls, tables, menus, and staff uniforms should be. Light mode = daytime service, dark mode = evening ambiance.

**Connections**: `app_theme.dart` consumed by → `app.dart` (theme/darkTheme) | uses colors from → `app_colors.dart`

---

### `lib/theme/app_colors.dart` — Color Palette Constants

**What is it?** A class of static `Color` constants — the raw color values used throughout the app.

**What does it do?** Defines the brand palette: golds (primary), earth tones (secondary), neutrals (cream, charcoal, warm gray), semantic colors (success green, error red, warning orange), and dark-mode-specific surfaces.

**Why we need it?** Centralizing color constants prevents magic hex values scattered across 30+ files. Changing the brand color means changing one line.

**Crucial code:**
```dart
class AppColors {
  static const Color gold         = Color(0xFFC8960C);  // Primary brand gold
  static const Color goldLight    = Color(0xFFE8B84B);  // Lighter for dark mode
  static const Color cream        = Color(0xFFFFF8E7);  // Warm white background
  static const Color charcoal     = Color(0xFF2C1A0E);  // Dark brown text
  static const Color darkBg       = Color(0xFF1A0F07);  // Near-black scaffold
  static const Color darkCard     = Color(0xFF3D2614);  // Dark brown card surface
}
```

**Real-life analogy**: A paint store's color swatch book — every decorator (widget) picks from this book to ensure the whole building is color-coordinated.

**Connections**: Used by → every screen and widget file, `app_theme.dart`

---

### `lib/theme/app_text_styles.dart` — Typography

**What is it?** Centralized text style definitions using Google Fonts (Playfair Display for headings, Lato for body).

**What does it do?** Provides consistent typography — all headings use the same font family and weight, all body text uses the same line height.

**Why we need it?** Without this, each `Text` widget would need its own `TextStyle` with font family specified. This ensures typographic consistency.

**Connections**: Used by screens that want custom text styles beyond the Material theme defaults

---

### `lib/models/product.dart` — Product Data Model

**What is it?** A Dart data class representing a single product in the catalog.

**What does it do?** Holds all product fields (name, price, rating, description, materials, dimensions, story, images, tags, etc.). Has a `fromJson` factory to parse JSON, and a `translated(locale)` method that returns a copy with fields overridden by the translation for that language.

**Why we need it?** Dart is strongly typed — we can't just pass raw `Map<String, dynamic>` around. The model gives us autocomplete, type safety, and compile-time error checking.

**Crucial code — the translated() method:**
```dart
Product translated(String locale) {
  final t = ContentTranslations.instance.get(locale, 'products', id);
  if (t == null) return this;  // No translation → return English original
  return Product(
    id: id,                              // Structural — never translated
    name: t['name'] as String? ?? name,  // Override with translation if exists
    description: t['description'] as String? ?? description,
    story: t['story'] as String? ?? story,
    tags: (t['tags'] as List?)?.cast<String>() ?? tags,
    // Structural fields pass through unchanged:
    artisanId: artisanId, price: price, rating: rating, images: images, ...
  );
}
```

**Real-life analogy**: A product catalog card in a store's inventory system. The card has fixed fields (SKU, price, barcode) and translatable fields (product name, description). When a Japanese customer scans it, the name/description switch to Japanese, but the barcode stays the same.

**Connections**: `product.dart` is created by → `MockRepository` (from JSON) | consumed by → `ProductCard`, `ProductDetailScreen`, `HomeScreen`, `FavoritesScreen`, `CollectionDetailScreen`, `ArtisanProfileScreen`, `QuizScreen`, `BookingScreen`

### `lib/models/artisan.dart` — Artisan Data Model

**What is it?** Data class for a craftsperson (name, region, craft type, avatar, cover image, biography, years of experience).

**Crucial code — same pattern as Product:**
```dart
Artisan translated(String locale) {
  final t = ContentTranslations.instance.get(locale, 'artisans', id);
  if (t == null) return this;
  return Artisan(
    id: id,
    name: t['name'] as String? ?? name,      // "Sophea Meas" → "សោភា មាស"
    region: t['region'] as String? ?? region, // "Takeo Province" → "ខេត្តតាកែវ"
    story: t['story'] as String? ?? story,
    // Non-translatable: id, coverImage, avatar, yearsOfExperience, productIds
  );
}
```

**Real-life analogy**: A craftsperson's business card — name and bio in multiple languages on the back, but their photo and phone number stay the same.

**Connections**: Created by → `MockRepository` | consumed by → `HomeScreen`, `ArtisanProfileScreen`, `ProductDetailScreen`, `ChatListScreen`, `ChatThreadScreen`

### `lib/models/collection.dart` — Gift Collection Model
### `lib/models/branch.dart` — Store Branch Model
### `lib/models/review.dart` — Product Review Model
### `lib/models/promotion.dart` — Promotion/Coupon Model

All follow the same pattern: `fromJson` factory + `translated(locale)` method. Structural fields (id, price, rating, coordinates, image URLs) stay in English; display fields (name, description, address, story, comment) get translated via the overlay.

---

### `lib/data/mock_repository.dart` — Data Layer (Singleton)

**What is it?** The single source of truth for all product/artisan/branch/review/promotion data. Loaded once at startup from `assets/mock/*.json` files.

**What does it do?** Loads 6 JSON files into typed lists. Provides raw getters (`products`, `artisans`) and translated getters (`productsTr`, `artisansTr`). Also provides query methods: `featured`, `byCategory(id)`, `byCollection(id)`, `artisanById(id)`, `reviewsForProduct(pid)`.

**Why we need it?** Instead of every screen loading JSON independently (slow, duplicated), the singleton loads once into memory. When the locale changes, `setLocale()` is called and all translated getters return data in the new language.

**Crucial code — the two-tier getter pattern:**
```dart
// English originals (structural queries use these)
List<Product> get products => _products ?? [];
Artisan? artisanById(String id) => artisans.where((a) => a.id == id).firstOrNull;

// Translated versions (display queries use these)
List<Product> get productsTr => products.map((p) => p.translated(_locale)).toList();
Artisan? artisanByIdTr(String id) =>
    artisansTr.where((a) => a.id == id).firstOrNull;

// Locale sync called from app.dart when user switches language
void setLocale(String code) { _locale = code; }
```

**Real-life analogy**: A warehouse inventory database. The warehouse has boxes of products with English labels. When a customer switches to Khmer, the system doesn't repack the boxes — it just prints Khmer labels to overlay on the English ones. The `productsTr` getter is like the label printer.

**Connections**: `mock_repository.dart` loads from → `assets/mock/*.json` | consumed by → every screen file | synced from → `app.dart` (watches `localeProvider`)

---

### `lib/data/content_translations.dart` — Translation Overlay Loader

**What is it?** A singleton that loads `assets/i18n/content.json` — a single JSON file containing product names, artisan bios, collection names, and branch names in all 5 languages.

**What does it do?** Parses the JSON into a nested map: `_data[locale][entityType][entityId][field]`. The `get(locale, type, id)` method returns the translation overlay for a specific entity, or `null` if no translation exists (falls back to English).

**Why we need it?** Without this, we'd need 5 copies of every mock JSON file (30 files total). The overlay approach keeps structural data (prices, image URLs) in one set of English files and only stores translated display fields in one flat JSON.

**Crucial code — the nested map structure:**
```dart
// _data['km']['products']['p1'] → {'name': 'ក្រមាសូត្រ', 'description': '...'}

Map<String, dynamic>? get(String locale, String entityType, String id) {
  return _data[locale]?[entityType]?[id];
}

// Graceful degradation: if content.json doesn't exist or has missing entries,
// translated() returns the English original — the app never crashes.
```

**Real-life analogy**: A multilingual restaurant menu. The base menu has dish codes and prices. A separate translation sheet maps each dish code to its name in 5 languages. When a Vietnamese customer sits down, the server overlays the Vietnamese sheet — dish codes and prices stay the same.

**Connections**: `content_translations.dart` is initialized in → `main.dart` | consumed by → every model's `translated()` method

---

### `lib/state/auth_provider.dart` — Authentication State

**What is it?** A Riverpod `Notifier` managing the Supabase authentication lifecycle.

**What does it do?** Tracks 4 states: `loading → unauthenticated | emailNotVerified | authenticated`. Listens to Supabase's `onAuthStateChange` stream and automatically transitions when the user signs in/out or verifies email. Provides `signIn()`, `signUp()`, `signOut()`, `resendVerificationEmail()` methods.

**Why we need it?** Auth state is global — every screen potentially needs to know if the user is logged in. Riverpod makes this reactive: when auth state changes, all watching widgets rebuild automatically.

**Crucial code — the auth state machine:**
```dart
enum AppAuthState { loading, unauthenticated, emailNotVerified, authenticated }

class AuthNotifier extends Notifier<AppAuthState> {
  @override
  AppAuthState build() {
    // Listen to Supabase auth changes
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        state = AppAuthState.unauthenticated;
      } else if (session.user.emailConfirmedAt == null) {
        state = AppAuthState.emailNotVerified;
      } else {
        state = AppAuthState.authenticated;
      }
    });
    return AppAuthState.loading;  // Initial state while checking
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email, password: password,
      );
      return null;  // Success — auth state stream handles the transition
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
```

**Real-life analogy**: A building's security system. States: system booting (loading), no badge (unauthenticated), badge needs activation (emailNotVerified), access granted (authenticated). The `onAuthStateChange` listener is like a motion sensor — it detects changes and alerts the system automatically.

**Connections**: `auth_provider.dart` watched by → `app.dart` (decides which branch to show) | used by → `LoginScreen`, `SignUpScreen`, `VerifyEmailScreen`

---

### `lib/state/theme_provider.dart` — Theme Mode State

**What is it?** A simple Riverpod `Notifier<ThemeMode>` that toggles between light, dark, and system themes.

**What does it do?** Defaults to `ThemeMode.system` (follows device setting). `setThemeMode(mode)` updates the state, triggering a rebuild of `MaterialApp`.

**Why we need it?** User preference that affects the entire app. Simple enough to not need persistence (follows system).

**Connections**: Watched by → `app.dart` (themeMode parameter) | toggled by → `SettingsScreen` (Dark Mode switch)

---

### `lib/state/locale_provider.dart` — Language/Locale State

**What is it?** A Riverpod `Notifier<Locale>` managing the active display language with `SharedPreferences` persistence.

**What does it do?** Defaults to English. On creation, loads saved locale from disk. `setLocale(locale)` updates state + saves to disk. Exports `supportedLocales` (5 languages) and `languageNames` (native script display names).

**Why we need it?** Language preference must survive app restarts. Without persistence, the user would need to re-select their language every time they open the app.

**Crucial code:**
```dart
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadFromPrefs();  // Async — loads saved locale from disk
    return const Locale('en');  // Default while loading
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);  // Persist
  }
}
```

**Real-life analogy**: A smartphone's language setting — when you switch to Japanese, every app that supports it switches too. The setting survives reboots because it's saved to storage.

**Connections**: Watched by → `app.dart` (locale parameter + MockRepository sync) | toggled by → `SettingsScreen` (language picker bottom sheet)

---

### `lib/state/favorites_provider.dart` — Saved/Favorited Products

**What is it?** A Riverpod `Notifier<Set<String>>` storing favorited product IDs, persisted via `SharedPreferences`.

**What does it do?** Loads saved IDs from disk on creation. `toggle(id)` adds or removes the ID (idempotent). The set is serialized as a comma-separated string.

**Why we need it?** Users expect their favorites to survive app restarts. Using a `Set<String>` ensures no duplicates and O(1) lookup.

**Crucial code:**
```dart
void toggle(String productId) {
  final updated = {...state};  // Copy the set
  if (updated.contains(productId)) {
    updated.remove(productId);  // Unlike
  } else {
    updated.add(productId);     // Like
  }
  state = updated;
  _save();  // Persist to SharedPreferences
}
```

**Real-life analogy**: A wishlist on Amazon — tap the heart to save, tap again to remove. The wishlist is still there when you come back tomorrow.

**Connections**: Watched by → `ProductCard`, `ProductDetailScreen`, `FavoritesScreen` | toggled by → heart icon taps

---

### `lib/state/booking_provider.dart` — Multi-Step Booking Wizard State

**What is it?** A Riverpod `Notifier<BookingState>` managing the 5-step booking flow form state.

**What does it do?** `BookingState` is an immutable data class with copyWith pattern: `step`, `product`, `giftWrap`, `personalMessage`, `deliveryDate`, `timeSlot`. Methods: `setProduct()`, `setGiftWrap()`, `setMessage()`, `setDeliveryDate()`, `setTimeSlot()`, `nextStep()`, `prevStep()`, `reset()`.

**Why we need it?** Multi-step forms need persistent state across steps. Without this, navigating between steps would lose the user's selections.

**Crucial code — the state class:**
```dart
class BookingState {
  final int step;           // 0-4 (Item → Gift Wrap → Message → Date → Confirm)
  final Product? product;
  final bool giftWrap;
  final String personalMessage;
  final DateTime? deliveryDate;
  final String timeSlot;

  BookingState copyWith({int? step, Product? product, bool? giftWrap, ...}) {
    return BookingState(
      step: step ?? this.step,
      product: product ?? this.product,
      giftWrap: giftWrap ?? this.giftWrap,
      // ... each field only overrides if provided
    );
  }
}
```

**Real-life analogy**: A restaurant online ordering wizard — Step 1: pick dish, Step 2: add sides, Step 3: special instructions, Step 4: delivery time, Step 5: confirm. You can go back and change your mind without losing your previous selections.

**Connections**: Watched and modified by → `BookingScreen`

---

### `lib/state/map_providers.dart` — Map UI State

**What is it?** Three simple `StateProvider`s for the map screen's UI state: selected branch, search query string, and "open only" filter boolean.

**Why we need it?** These are local UI state values that multiple widgets within the map screen need to react to. `StateProvider` is the simplest Riverpod provider for single-value state.

**Connections**: Used exclusively by → `MapScreen`

---

### `lib/l10n/` — ARB Translation Files & Generated Code

**What is it?** 5 ARB files (`app_en.arb`, `app_km.arb`, `app_zh.arb`, `app_ja.arb`, `app_vi.arb`) containing ~145 UI string translations. The `generated/` folder contains auto-generated Dart code produced by `flutter gen-l10n`.

**What does it do?** Each ARB file maps a key (e.g., `"signIn"`) to a translated string (e.g., `"ចូលគណនី"`). The code generator produces an abstract `AppLocalizations` class with a method for each key, plus concrete implementations per language. Access via `AppLocalizations.of(context).signIn` — returns the correct language automatically.

**Why we need it?** ARB is Flutter's standard localization format. It supports ICU plurals (`{count, plural, ...}`), placeholders (`{name}`), and has IDE plugin support for translators. Without it, every string would be hardcoded in English.

**Crucial code — how screens access translations:**
```dart
// In any screen's build() method:
final l10n = AppLocalizations.of(context);
// Now use:  l10n.signIn  → "Sign In" (en) / "ចូលគណនី" (km) / "登录" (zh) / etc.
```

**Real-life analogy**: A UN interpreter's phrasebook — for every concept ("Sign In"), there's a translation in 5 languages. The interpreter (`AppLocalizations.of(context)`) picks the right phrasebook based on who they're talking to (the current locale).

**Connections**: Generated by → `flutter gen-l10n` | consumed by → every screen file (via `AppLocalizations.of(context)`)

---

### `lib/features/home/home_screen.dart` — Main Landing Page

**What is it?** The home tab — a `CustomScrollView` with `SliverAppBar`, hero image carousel, search bar, category chips, featured products, curated collections, artisan highlights, and a quiz banner.

**What does it do?** Fetches featured products, collections, and artisans from `MockRepository`. Hero carousel auto-advances with dot indicators. Search bar accepts text input (currently decorative). Tapping any card navigates to its detail page.

**Why we need it?** This is the first screen users see — it must showcase the brand, surface popular items immediately, and provide clear navigation paths to deeper content.

**Crucial code — hero carousel with PageView + indicator:**
```dart
SizedBox(
  height: 220,
  child: Stack(children: [
    PageView.builder(
      controller: _heroController,
      itemCount: _heroItems.length,
      itemBuilder: (context, i) {
        final item = _heroItems[i];
        return Stack(fit: StackFit.expand, children: [
          CachedNetworkImage(imageUrl: item['image']!, fit: BoxFit.cover),
          // Dark gradient overlay for text readability
          Container(decoration: BoxDecoration(gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ))),
          // Title + subtitle positioned at bottom
          Positioned(bottom: 30, left: 20, child: Column(
            children: [
              Text(item['title']!, style: white headline),
              Text(item['sub']!, style: white subtitle),
            ],
          )),
        ]);
      },
    ),
    Positioned(bottom: 10, right: 20, child: SmoothPageIndicator(...)),
  ]),
).animate().fadeIn(duration: 600.ms),  // flutter_animate fade-in
```

**Real-life analogy**: The homepage of an online store like Etsy — hero banner, category navigation, featured items, and curated collections all above the fold.

**Connections**: Reads from → `MockRepository` (featured, collections, artisans) | navigates to → `ProductDetailScreen`, `CollectionDetailScreen`, `ArtisanProfileScreen`, `QuizScreen`, `ChatListScreen`

---

### `lib/features/detail/product_detail_screen.dart` — Product Detail Page

**What is it?** Full-screen product view with image carousel, product info, artisan link, materials/dimensions, story, tags, and gallery button.

**What does it do?** Receives `productId` from the route parameter. Looks up the product (translated) and its artisan. Shows an image carousel with favorite and back buttons overlaid. Scrollable content below with all product details.

**Why we need it?** This is the conversion page — where users decide to book/order. Must present all relevant information clearly.

**Crucial code — image carousel with floating action buttons:**
```dart
Widget _imageCarousel(Product product, bool isFav) {
  return SizedBox(height: 340, child: Stack(children: [
    PageView.builder(
      controller: _pageController,
      itemCount: product.images.length,
      onPageChanged: (i) => setState(() => _currentImage = i),
      itemBuilder: (context, i) => CachedNetworkImage(
        imageUrl: product.images[i], fit: BoxFit.cover,
      ),
    ),
    // Back button — floating circle over the image
    Positioned(top: 52, left: 16,
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
    ),
    // Favorite button — floating circle over the image
    Positioned(top: 52, right: 16,
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: IconButton(
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : AppColors.charcoal),
          onPressed: () => ref.read(favoritesProvider.notifier).toggle(product.id),
        ),
      ),
    ),
    // Dot indicators at bottom of carousel
    if (product.images.length > 1)
      Positioned(bottom: 16, left: 0, right: 0,
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(product.images.length, (i) =>
            AnimatedContainer(
              width: _currentImage == i ? 20 : 6,  // Active dot is wider
              decoration: BoxDecoration(
                color: _currentImage == i ? AppColors.gold : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
  ]));
}
```

**Real-life analogy**: A product page on Amazon — image gallery at top, price + rating, description, specifications table, "Meet the maker" section, tags, and a prominent CTA button.

**Connections**: Reads from → `MockRepository` (product + artisan), `favoritesProvider` | navigates to → `ReviewsScreen`, `ArtisanProfileScreen`, `GalleryScreen`, `BookingScreen`

---

### `lib/features/booking/booking_screen.dart` — Multi-Step Booking Wizard

**What is it?** A 5-step form: Item → Gift Wrap → Message → Date → Confirm.

**What does it do?** Each step is a separate widget method (`_buildStep0` through `_buildStep4`). A progress indicator at top tracks position. "Continue" button advances with validation. Back button goes to previous step or pops the screen.

**Why we need it?** Breaking a complex booking into steps reduces cognitive load (Hick's Law in UX). Each step has one clear decision.

**Crucial code — the step routing pattern:**
```dart
Expanded(child: [
  _buildStep0(context, booking),  // Step 0: Show item + info
  _buildStep1(context, booking),  // Step 1: Gift wrap yes/no
  _buildStep2(context, booking),  // Step 2: Personal message
  _buildStep3(context, booking),  // Step 3: Calendar + time slots
  _buildStep4(context, booking),  // Step 4: Confirmation summary
][booking.step]),  // Array index = current step — O(1) switching

// Validation before advancing
void _handleContinue(BookingState booking) {
  if (booking.step == 3) {
    if (booking.deliveryDate == null) {
      _showValidationToast(l10n.chooseDeliveryDate);
      return;
    }
    if (booking.timeSlot.isEmpty) {
      _showValidationToast(l10n.selectTimeSlot);
      return;
    }
  }
  ref.read(bookingProvider.notifier).nextStep();
}
```

**Real-life analogy**: An airline check-in kiosk — Step 1: scan boarding pass, Step 2: confirm baggage, Step 3: select seat, Step 4: print boarding pass. You can go back, but you can't skip ahead without completing each step.

**Connections**: Reads/writes → `bookingProvider` | reads from → `MockRepository` (product data)

---

### `lib/features/map/map_screen.dart` — Interactive Store Locator Map

**What is it?** An OpenStreetMap with branch marker pins, a search bar, an "Open Now" filter, current-location button, and a slide-up branch detail sheet.

**What does it do?** Uses `flutter_map` with CartoCDN tiles. Branch pins are green (open) or red (closed). Tapping a pin shows `_BranchSheet` — a bottom card with branch photo, name, rating, distance, address, phone, hours, and Center/Directions buttons. Device GPS shows a blue dot.

**Why we need it?** Physical stores need a store locator. Customers want to know which shops are nearby, open now, and how to get there.

**Crucial code — FlutterMap setup with markers:**
```dart
FlutterMap(
  mapController: mapController,
  options: MapOptions(
    initialCenter: _currentPosition ?? const LatLng(12.0, 104.5),  // Cambodia center
    initialZoom: _currentPosition != null ? 12 : 7,
    onTap: (_, __) => ref.read(selectedBranchProvider.notifier).state = null,  // Deselect
  ),
  children: [
    TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'),
    MarkerLayer(markers: [
      if (_currentPosition != null)
        Marker(point: _currentPosition!, child: Icon(Icons.my_location, color: Colors.blue)),  // You
      ...filteredBranches.map((b) => Marker(  // Branch pins
        point: LatLng(b.lat, b.lng),
        child: GestureDetector(
          onTap: () {
            ref.read(selectedBranchProvider.notifier).state = b;
            mapController.move(LatLng(b.lat, b.lng), 15);  // Zoom to branch
          },
          child: Column(children: [
            Container(/* branch name label */),
            Container(/* colored circle — green=open, red=closed */),
          ]),
        ),
      )),
    ]),
  ],
);
```

**Real-life analogy**: Google Maps store locator — search for "coffee near me", see pins on a map, tap one for details, get directions.

**Connections**: Reads from → `MockRepository` (branches), `map_providers` (search/filter/selected), device GPS via `geolocator` | navigates to → `NearbyScreen` (list view)

---

### `lib/features/quiz/quiz_screen.dart` — Gift Finder Quiz

**What is it?** A 5-question quiz that recommends products based on answers.

**What does it do?** Each question is a `_QuizQuestion` (question, subtitle, 4 options). User taps an option → answer saved, advances to next question. After Q5, maps answers to a category and shows recommended products.

**Why we need it?** Decision paralysis — a catalog with 12+ products is overwhelming. The quiz narrows choices to a personalized shortlist.

**Crucial code — answer-to-category mapping:**
```dart
String _categoryFromAnswers() {
  final giftType = _answers.length > 2 ? _answers[2] : 0;      // Q3: gift type
  final experience = _answers.length > 3 ? _answers[3] : 0;    // Q4: experience
  // Map gift type answer to category
  final base = switch (giftType) {
    0 => _answers[0] == 0 ? 'textile' : 'silver',  // Wearable → textile/silver
    1 => 'wood',     // Decorative → wood
    2 => 'edible',   // Edible
    3 => 'jewelry',  // Collectible → jewelry
    _ => 'textile',
  };
  if (experience >= 2 && base == 'edible') return 'textile';  // Expert + edible → upgrade to textile
  return base;
}
```

**Real-life analogy**: A wine shop's "Find Your Wine" quiz — "Red or white? Light or full-bodied? What's your budget?" → recommends 3 bottles.

**Connections**: Reads from → `MockRepository` (byCategory) | navigates to → `ProductDetailScreen` (tap result)

---

### `lib/features/settings/settings_screen.dart` — Settings Page

**What is it?** Settings tab with notification toggle, dark mode switch, language picker, and about info.

**What does it do?** Dark mode switch toggles `themeModeProvider`. Language picker shows a `ModalBottomSheet` with all 5 languages — tapping one calls `localeProvider.notifier.setLocale(locale)`.

**Why we need it?** Central place for user preferences. The language picker is the entry point for the 5-language localization system.

**Crucial code — the language picker bottom sheet:**
```dart
void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final locale in supportedLocales)
            ListTile(
              title: Text(languageNames[locale.languageCode]!),  // ភាសាខ្មែរ / English / 中文 / 日本語 / Tiếng Việt
              trailing: ref.watch(localeProvider).languageCode == locale.languageCode
                  ? const Icon(Icons.check, color: AppColors.gold)  // Checkmark on active
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    ),
  );
}
```

**Real-life analogy**: Your phone's Settings app — toggles, language selector, about info.

**Connections**: Reads/writes → `themeModeProvider`, `localeProvider`

---

### `lib/features/onboarding/onboarding_screen.dart` — First-Launch Tutorial

**What is it?** A 3-page onboarding carousel shown only on first app launch.

**What does it do?** PageView with 3 slides (emoji + title + subtitle). "Skip" button at top right. "Next" button advances pages; "Get Started" on the last page sets `seen_onboarding = true` in `SharedPreferences` and navigates to Home. On subsequent launches, this screen is skipped.

**Why we need it?** Introduces the app's 3 core value props (handmade gifts, personalization, store locator) in 10 seconds. Sets expectations before the user enters the main UI.

**Crucial code — the persistence check (in main.dart or app.dart):**
```dart
final prefs = await SharedPreferences.getInstance();
final seen = prefs.getBool('seen_onboarding') ?? false;
if (!seen) { show OnboardingScreen; } else { show Home; }
```

**Real-life analogy**: The tutorial screens when you first install Instagram — "Share photos," "Connect with friends," "Explore content" — seen once, never again.

**Connections**: Persists flag to → `SharedPreferences` | navigates to → Home (`context.go('/')`)

---

### `lib/widgets/product_card.dart` — Reusable Product Card

**What is it?** A card widget displaying product image, name, rating stars, and price. Used in grids and horizontal lists across 4+ screens.

**What does it do?** `CachedNetworkImage` for the product photo. Overlaid favorite heart button (tappable, toggles via `favoritesProvider`). Tapping the card navigates to `ProductDetailScreen`.

**Why we need it?** Reused in HomeScreen (horizontal list), FavoritesScreen (grid), CollectionDetailScreen (grid), and ArtisanProfileScreen (horizontal list). A single widget ensures visual consistency.

**Crucial code — layout structure:**
```dart
Container(
  width: width,
  clipBehavior: Clip.antiAlias,  // Prevents overflow at rounded corners
  decoration: BoxDecoration(
    color: Theme.of(context).cardTheme.color,  // Adapts to light/dark
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(mainAxisSize: MainAxisSize.min, children: [
    // Image (140px) with favorite button overlay
    Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(imageUrl: product.images.first, height: 140, fit: BoxFit.cover),
      ),
      Positioned(top: 8, right: 8, child: /* heart button */),
    ]),
    // Info section
    Padding(
      padding: EdgeInsets.all(10),
      child: Column(children: [
        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        RatingStars(rating: product.rating, size: 12),
        Text('\$${product.price.toStringAsFixed(2)}', style: gold bold),
      ]),
    ),
  ]),
);
```

**Real-life analogy**: The product tile in an online store's grid view — image, name, stars, price. Same component reused on homepage, search results, and category pages.

**Connections**: Reads from → `favoritesProvider` | navigates to → `ProductDetailScreen` | used by → `HomeScreen`, `FavoritesScreen`, `CollectionDetailScreen`, `ArtisanProfileScreen`

---

### `lib/widgets/rating_stars.dart` — Star Rating Display

**What is it?** A row of 5 gold stars showing a product's rating (supports half-stars).

**What does it do?** Given a `rating` value (0.0–5.0), renders filled stars (`Icons.star`), half stars (`Icons.star_half`), and outlined stars (`Icons.star_border`).

**Crucial code:**
```dart
Row(children: List.generate(5, (i) {
  if (i < rating.floor())      return Icon(Icons.star, color: AppColors.gold);
  if (i < rating)              return Icon(Icons.star_half, color: AppColors.gold);  // 4.5 → 4 full + 1 half
  return Icon(Icons.star_border, color: AppColors.gold);
}));
```

**Real-life analogy**: The star rating under every Amazon product — immediately communicates quality.

**Connections**: Used by → `ProductCard`, `ProductDetailScreen`, `ReviewsScreen`, `MapScreen` `_BranchSheet`, `NearbyScreen`

---

### `lib/widgets/empty_state.dart` — Empty State Placeholder

**What is it?** A centered icon + title + subtitle shown when a list has no items.

**What does it do?** Displays a greyed-out icon, a title, and a subtitle. Adapts colors for dark mode.

**Why we need it?** Empty states prevent the "dead screen" problem — instead of a blank white page, the user sees a helpful message like "No saved gifts yet — tap the heart to save."

**Connections**: Used by → `FavoritesScreen`

### `lib/widgets/coupon_card.dart` — Promotion Coupon Card
### `lib/widgets/khmer_pattern_divider.dart` — Ornamental Divider
### `lib/widgets/shimmer_card.dart` — Loading Skeleton Card

All are reusable UI atoms used across multiple screens. `CouponCard` displays promotion code + discount with copy-to-clipboard. `KhmerPatternDivider` is a decorative gold `✦` divider. `ShimmerCard` is a loading placeholder with shimmer animation.

---

### `lib/features/auth/login_screen.dart` — Login Form
### `lib/features/auth/signup_screen.dart` — Registration Form
### `lib/features/auth/verify_email_screen.dart` — Email Verification Prompt

Standard Supabase auth flow screens. Login has email + password fields with validation. SignUp adds name + confirm password. VerifyEmail polls for email confirmation and offers resend/sign-out.

**Connections**: Call → `authProvider.notifier.signIn()` / `.signUp()` / `.signOut()` | Navigate between each other via `Navigator.pushReplacementNamed`

---

### `lib/features/favorites/favorites_screen.dart` — Saved Items Grid
### `lib/features/promotions/promotions_screen.dart` — Coupons List
### `lib/features/reviews/reviews_screen.dart` — Product Reviews
### `lib/features/gallery/gallery_screen.dart` — Full-Screen Image Gallery
### `lib/features/nearby/nearby_screen.dart` — Nearby Shops List
### `lib/features/chat/chat_list_screen.dart` — Chat List
### `lib/features/chat/chat_thread_screen.dart` — Chat Conversation
### `lib/features/artisan/artisan_profile_screen.dart` — Artisan Profile
### `lib/features/collection/collection_detail_screen.dart` — Collection Detail

These are the remaining feature screens. Each follows the same pattern:
1. Import `AppLocalizations` for translated UI strings
2. Import `MockRepository` for data access
3. Build a `Scaffold` with content fetched from the repository
4. Use `context.push()` for navigation to related screens
5. Use `Theme.of(context)` for light/dark adaptive colors

---

## 4. Key Patterns & How Things Connect

### Pattern 1: Getting Data + Translations in Any Screen
```dart
// 1. Get localized UI strings
final l10n = AppLocalizations.of(context);

// 2. Get translated data from the repository
final repo = MockRepository.instance;
final products = repo.productsTr;           // Products with translated names/descriptions
final artisan = repo.artisanByIdTr(id);     // Single artisan with translated bio
final featured = repo.featuredTr;           // Featured products, translated
```

### Pattern 2: Navigation
```dart
// Tab navigation (stays within ShellRoute):
context.go('/');              // Go to Home tab
context.go('/favorites');     // Go to Favorites tab

// Full-screen push (over the tabs, no bottom bar):
context.push('/product/${product.id}');     // Product detail
context.push('/booking/${product.id}');     // Booking flow

// Go back:
context.pop();                // Return to previous screen
context.go('/');              // Go all the way home
```

### Pattern 3: State Management with Riverpod
```dart
// Read state (rebuilds when state changes):
final isFav = ref.watch(favoritesProvider).contains(product.id);
final themeMode = ref.watch(themeModeProvider);

// Write state:
ref.read(favoritesProvider.notifier).toggle(product.id);
ref.read(localeProvider.notifier).setLocale(Locale('km'));
```

### Pattern 4: Authentication Flow
```
App Launch
  → authProvider = loading
  → Supabase checks session
  → If no session → unauthenticated → LoginScreen
  → If session + unverified email → emailNotVerified → VerifyEmailScreen
  → If session + verified email → authenticated → Main App
```

### Pattern 5: Language Switching Flow
```
Settings → Tap Language → Bottom Sheet → Tap "ភាសាខ្មែរ"
  → localeProvider.setLocale(Locale('km'))
  → MaterialApp rebuilds with locale='km'
  → MockRepository.setLocale('km')
  → All AppLocalizations.of(context).xxx → Khmer
  → All productsTr/artisansTr/etc. → Khmer names/bios
  → Hanuman font auto-applied
```

### Pattern 6: Dark Mode Adaptation (Widget-Level)
```dart
// Any widget that needs manual dark mode handling:
final isDark = Theme.of(context).brightness == Brightness.dark;
// Then branch:
color: isDark ? AppColors.darkCard : AppColors.ivory,
textColor: isDark ? AppColors.cream : AppColors.charcoal,
```

---

## 5. File Count Summary

| Directory | Files | Purpose |
|-----------|-------|---------|
| `lib/` | 3 | Entry point, root widget |
| `lib/models/` | 6 | Data classes |
| `lib/data/` | 2 | Repository + translations loader |
| `lib/state/` | 5 | Riverpod providers |
| `lib/router/` | 1 | GoRouter config |
| `lib/theme/` | 3 | Colors, text styles, theme data |
| `lib/widgets/` | 6 | Reusable UI components |
| `lib/features/auth/` | 3 | Login, signup, email verification |
| `lib/features/home/` | 1 | Home screen |
| `lib/features/detail/` | 1 | Product detail |
| `lib/features/booking/` | 1 | Booking wizard |
| `lib/features/map/` | 1 | Map + store locator |
| `lib/features/nearby/` | 1 | Nearby shops list |
| `lib/features/favorites/` | 1 | Saved items grid |
| `lib/features/promotions/` | 1 | Coupons list |
| `lib/features/settings/` | 1 | Settings + language picker |
| `lib/features/quiz/` | 1 | Gift finder quiz |
| `lib/features/chat/` | 2 | Chat list + thread |
| `lib/features/reviews/` | 1 | Product reviews |
| `lib/features/gallery/` | 1 | Image gallery |
| `lib/features/artisan/` | 1 | Artisan profile |
| `lib/features/collection/` | 1 | Collection detail |
| `lib/features/onboarding/` | 1 | First-launch tutorial |
| `lib/l10n/` | 11 | 5 ARB files + 6 generated |
| **Total** | **~55** | |
