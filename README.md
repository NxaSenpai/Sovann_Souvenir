# 🏺 Sovann Souvenir

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-757575?style=for-the-badge&logo=material-design&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-C8960C?style=for-the-badge)

**A beautifully crafted Flutter app to browse and order handmade Cambodian gifts and souvenirs.**  
Festive · Cultural · Khmer Motifs · Warm Earth Tones & Gold

</div>

---

**Sovann Souvenir** is a frontend-only Flutter application built as part of a university group project. It allows users to explore handcrafted Cambodian products — silk kramas, silverware, wooden carvings, artisanal food, and jewelry — each accompanied by the story of the artisan who made it.

The app celebrates Cambodian cultural heritage through Khmer-inspired design motifs, a warm earth-tone and gold color palette, and a curated experience that connects buyers directly with artisans across Cambodia.

> **Scope:** Frontend-only · Static mock data · UI-ready demo  
> **Backend:** Not included in base version (bonus feature)

---

## ✨ Features

### 🛍️ Core Shopping Experience
- **Story-style hero carousel** — Instagram-style vertical banner with animated transitions
- **Category browsing** — Textile, Silver, Wood, Edible, Jewelry
- **Curated collections** — For Him, For Her, Wedding, Songkran Gift Set, Tourist Essentials
- **Product detail** — Image gallery with PageView, artisan info, materials, dimensions, and the story behind each item
- **Artisan profiles** — Photo, region, craft specialty, personal story, and their product lineup

### ❤️ Personalization
- **Favorites** — Save items and collections, persisted across sessions via `shared_preferences`
- **Gift Finder Quiz** — 4-question quiz that recommends products based on recipient, budget, type, and occasion
- **Multi-step booking flow** — Item → Gift Wrap → Personal Message → Delivery Date & Time → Confirmation

### 🗺️ Discovery
- **Interactive map** — `flutter_map` with cultural pin icons for all shop/atelier locations
- **Nearby shops** — Sorted by mock distance, filterable by Open Now and Rating
- **Promotions & Coupons** — Seasonal deals (Khmer New Year, Pchum Ben) with copy-to-clipboard coupon codes

### 💬 Communication
- **Chat** — Direct artisan messaging with auto-reply simulation, typing indicator, and attachment icon
- **Reviews** — Star rating summary, distribution bars, individual review cards with photos, and a write-a-review form

### 🎨 Galleries
- **Photos/Videos** — Masonry-style gallery with full-screen pinch-to-zoom viewer and making-of video thumbnails

### ⚙️ App Polish
- Light **and** dark mode with a custom Khmer-inspired theme
- Onboarding flow (3 slides) shown on first launch
- Empty states, loading shimmers, and error placeholder widgets
- Hero transitions, page transitions, and list animations
- Responsive layout (phone portrait + tablet)
- Custom app icon and native splash screen

---

## 📸 Screenshots

| Home | Product Detail | Artisan Profile |
|:----:|:--------------:|:---------------:|
| ![Home](screenshots/home.png) | ![Detail](screenshots/detail.png) | ![Artisan](screenshots/artisan.png) |

| Booking Flow | Map | Gift Quiz |
|:------------:|:---:|:---------:|
| ![Booking](screenshots/booking.png) | ![Map](screenshots/map.png) | ![Quiz](screenshots/quiz.png) |

| Chat | Gallery | Promotions |
|:----:|:-------:|:----------:|
| ![Chat](screenshots/chat.png) | ![Gallery](screenshots/gallery.png) | ![Promos](screenshots/promos.png) |

> *Add screenshots to a `/screenshots` folder in the repo root after building.*

---


## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x or later
- Dart 3.x (bundled with Flutter)
- Android Studio / VS Code with Flutter extension
- A connected device or emulator

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/khmer_gift.git
cd khmer_gift
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the app**
```bash
flutter run
```

**4. Run on a specific device**
```bash
flutter devices          # list available devices
flutter run -d <device>  # run on specific device
```

### Build APK (Android)

```bash
flutter build apk --release
```
The output APK is at: `build/app/outputs/flutter-apk/app-release.apk`

### Build for iOS

```bash
flutter build ios --release
```

---

### Typography

- **Display / Headings** — Playfair Display (serif, editorial)
- **Body / UI** — Lato (sans-serif, readable)
- **Khmer Script labels** — Hanuman (decorative accents)

---


## 👥 Team

| Name           | Role  |
|----------------|-------|
| Souery Sreyno  | Blank |
| Tang Nakry     | Blank |
| Soth Pichpanha | Blank |

---


## 📄 License

This project is for educational purposes as part of a university course.

---

<div align="center">
  Made with ❤️ and inspired by the artisans of Cambodia 🇰🇭
</div>