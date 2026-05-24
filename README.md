<div align="center">

# Sovann Souvenir - Souvenir Market

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)


![cover](/assets/images/cover_image.png)

**Sovann Souvenir** is an application that enables users to purchase unique souvenirs from Cambodia with just a few clicks.
</div>


---

## ✨ Features

### 🛍️ Core Shopping Experience
- **Story-style hero carousel** — Instagram-style vertical banner with animated transitions
- **Category browsing** — Textile, Silver, Wood, Edible, Jewelry
- **Curated collections** — For Him, For Her, Wedding, Songkran Gift Set, Tourist Essentials
- **Product detail** — Image gallery with PageView, artisan info, materials, dimensions, and the story behind each item

### ❤️ Personalization
- **Favorites** — Save items and collections, persisted across sessions via `shared_preferences`

### 🗺️ Discovery
- **Interactive map** — `flutter_map` with cultural pin icons for all shop/atelier locations
- **Nearby shops** — Sorted by mock distance, filterable by Open Now and Rating
- **Promotions & Coupons** — Seasonal deals (Khmer New Year, Pchum Ben) with copy-to-clipboard coupon codes

### 💬 Communication
- **Chat** — Direct artisan messaging with auto-reply simulation, typing indicator, and attachment icon
- **Reviews** — Star rating summary, distribution bars, individual review cards with photos, and a write-a-review form

### 🎨 Galleries
- **Photos/Videos** — Masonry-style gallery with full-screen pinch-to-zoom viewer and making-of video thumbnails

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


## 👥 Team Members

| Name           | Role  |
|----------------|-------|
| Soeury Sreyno  | Blank |
| Tang Nakry     | Blank |
| Soth Pichpanha | Blank |

---


<div align="center">

## 📄 License

This project is for educational purposes as part of a Introduction of Mobile Application course.


  Made with ❤️ and inspired by the artisans of Cambodia 🇰🇭
</div>