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

### Requirement

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x or later
- Dart 3.x (bundled with Flutter)
- Android Studio / VS Code with Flutter extension
- A connected device or emulator

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/NxaSenpai/Sovann_Souvenir.git
cd Sovann_Souvenir
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the app**
```bash
flutter run
```

---

### Typography

- **Display / Headings** — Playfair Display (serif, editorial)
- **Body / UI** — Lato (sans-serif, readable)
- **Khmer Script labels** — Hanuman (decorative accents)

---


## 👥 Team Members

### Soeury Sreyno

- Designed the app icon and branding assets
- Created the onboarding screen flow and UI
- Implemented the artisan profile screen and gallery views
- Designed the promotions and coupon card components
- Contributed to UI/UX design across the application
- Assisted with localization data for Khmer language

### Tang Nakry

- Architected the Supabase backend integration and database schema
- Implemented user authentication (sign-up, login, sign-out)
- Built the AI Gift Assistant chatbot with OpenRouter integration
- Developed the shopping cart, checkout, and order tracking system
- Created the map screen with branch locations and nearby shops
- Implemented real-time favorites sync with Supabase
- Set up Supabase Storage for profile avatars and review photos
- Configured environment variables with flutter_dotenv

### Soth Pichpanha

- Developed the home screen with hero carousel and category browsing
- Built the product card component with animations and responsive layout
- Implemented the product detail screen with image gallery and specs
- Created the review system with star ratings, comments, and photo uploads
- Built the search bar with live dropdown results
- Developed the profile screen with avatar upload and password change
- Implemented multi-language support across all screens
- Built the dark/light theme system with Material 3

---


<div align="center">

## 📄 License

This project is for educational purposes as part of a Introduction of Mobile Application course.

</div>