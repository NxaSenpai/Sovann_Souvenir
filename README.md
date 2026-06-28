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

### Tang Nakry

- Login / Sign In
- Chatbot (AI Gift Assistant)
- Saved Products (Favorites sync with Supabase)
- Orders Tracking
- Cart System (Cart, Checkout)
- Multiple Language Support (5 languages)
- Supabase backend integration and database schema
- Environment configuration (.env, API keys)
- Navigation & routing (GoRouter)
- Dark/Light theme system

### Soth Pichpanha

- Product Card (responsive layout, animations)
- Product Details (image gallery, specs, artisan info)
- Review Screen (star ratings, photo upload, full-screen gallery)
- Map Screen (interactive map, branch locations, nearby shops)
- Home Screen (hero carousel, categories, collections)
- Featured Products (See All page)
- Category screen

### Soeury Sreyno

- Profile Screen (avatar upload, edit profile, settings)
- Collection Card (curated collections UI)
- Artisan Profile (artisan stories and products)
- Onboarding Screen (welcome flow)
- App Icon (branding and launcher icon)
- Suggestion Search Bar (live dropdown search)
- Promotions & coupon card components
- Gallery screen (masonry layout, photo viewer)

---


<div align="center">

## 📄 License

This project is for educational purposes as part of a Introduction of Mobile Application course.

</div>