# 🌍 Travel Explorer - GDGC VNRVJIET App Development Assignment

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-23%20Passed-success.svg)]()

A complete, photography-first, production-style **Travel Explorer and Trip-Planning Application** designed and engineered from scratch for the **GDGC VNRVJIET App Development Assignment**.

---

## 🌟 Application Overview

**Travel Explorer** helps wanderers discover India’s most captivating travel destinations, plan day-by-day itineraries, track trip budgets and categorized expenses, view real-time destination weather, inspect interactive map directions, and receive rule-based destination recommendations based on their budget and interests.

The app features a **Material Design 3** aesthetic with custom design tokens, smooth page transitions, responsive layouts for phones and tablets, and 100% offline-first local persistence.

---

## ✨ Core Features & Capabilities

### 1. 🏖️ Destination Discovery (Home)
- **Personalized Header**: Greets the user dynamically by name or Guest title with time-relevant travel inspiration.
- **Hero Featured Destination Card**: Large photography hero card with instant save-to-wishlist and quick explore actions.
- **Discovery Sections**:
  - *Popular in India* (Goa, Manali, Jaipur, Andaman, etc.)
  - *Trending Right Now* (Rishikesh, Hampi, Leh Ladakh)
  - *Weekend Getaways* (Coorg, Ooty, Shimla, Alleppey)
  - *Recently Viewed* (Maintains persistent history of recently visited places)
- **14 Pre-seeded Destinations**: Structured with rich descriptions, coordinates, suggested durations, daily costs in INR (`₹`), seasons, highlights, attractions, travel tips, and local culinary delicacies.

### 2. 🔍 Explore, Search & Multi-Filter Engine
- **Instant Search**: Case-insensitive matching across destination name, city, state, description, and tags (e.g. *scuba*, *temples*, *snow*, *beaches*).
- **Category Filter Chips**: Quick switching between *All*, *Beaches*, *Mountains*, *Heritage*, and *Adventure*.
- **Filter & Sort Modal**:
  - Sort by *Popularity*, *Name (A to Z)*, *Budget: Low to High*, *Budget: High to Low*.
  - Daily Budget Slider: Filters from ₹1,500/day to ₹6,000/day.
  - Duration Chips: Filter by trip length (≤ 3 Days, ≤ 5 Days, ≤ 7 Days, Any).
- **Graceful Empty State**: Includes friendly reset button when no results match.

### 3. 🗺️ Rich Destination Details
- **Sliver Hero Header**: High-resolution photography banner with overlay gradient, rating chip, and favorite toggle.
- **Key Metrics Grid**: Estimated daily cost in INR, suggested trip duration, and best visiting season.
- **Live Open-Meteo Weather**:
  - Fetches real-time temperature, condition, humidity, and wind speed.
  - Includes a 5-day daily forecast with high/low temperatures.
  - In-memory cache with 30-minute validity and retry button on network failure.
  - Graceful fallback retaining full destination guide even if offline.
- **Top Attractions**: Visual cards with entry fees, opening hours, descriptions, and direct **"Directions"** action launching Google Maps.
- **Traveler Insights & Must-Try Local Foods**: Regional food chips and actionable travel advice.
- **Interactive Action Bar**: Add to Wishlist, Add to Trip, Open in Google Maps, and Share Destination.

### 4. ❤️ Persistent Wishlist
- Heart toggle accessible on cards, carousels, and detail screens.
- Instant reactive updates across all tabs via Provider.
- Prevents duplicates and persists across application restarts.
- Direct **"Add to Trip"** action from saved wishlist cards.
- Clear all confirmation dialog.

### 5. 🗓️ My Trips & Day-by-Day Itinerary Planner
- **Trips Dashboard**: Organizes journeys into **Upcoming**, **Ongoing**, and **Past** tabs.
- **Trip Creation & Editing**: Validates dates, destination name, travelers, travel style (*Leisure*, *Adventure*, *Solo*, *Family*, *Cultural*, *Romantic*), and budget.
- **Day-by-Day Itinerary**:
  - Automatically calculates and renders individual day tabs based on trip duration.
  - Add activities with time, location, title, and notes.
  - Interactive completion checkbox with strikethrough.
  - Direct **"Open in Maps"** button for each activity stop.
  - Delete and edit activities.

### 6. 💰 Travel Budget & Expense Tracker
- **Budget Setup**: Defines total trip budget in Indian Rupees (INR ₹).
- **Dynamic Progress Bar**: Color-coded linear indicator visualizing percentage of budget consumed.
- **Overspend Warning**: Highlights in red when spending exceeds the planned budget and shows exact deficit amount.
- **Category Spending Grid**: Visual breakdown across:
  - 🏨 *Accommodation*
  - 🍽️ *Food*
  - 🚗 *Transport*
  - 🎟️ *Activities*
  - 🛍️ *Shopping*
  - 🧾 *Miscellaneous*
- **Expense Log**: Add, edit, and delete expense entries with amounts, dates, and notes.

### 7. 🎯 Smart Destination Matcher (Recommendation Engine)
- Transparent, local rule-based scoring engine (no paid cloud AI required).
- User selects preferences:
  1. *Category*: Beaches, Mountains, Heritage, Adventure, or Any.
  2. *Daily Budget*: Slider up to ₹5,500/day.
  3. *Duration*: 3, 4, 5, or 7 days.
  4. *Vibes & Interests*: Nature & Wildlife, Trekking, Palaces, Water Sports, Temples, etc.
- Scores destinations from 0 to 100% and displays transparent reasons:
  - *"Perfect match for your Mountains preference"*
  - *"Very affordable: ₹2,800/day fits well inside budget"*
  - *"Ideal for a 5-day itinerary"*

### 8. 🔐 Authentication & User Profiles
- **Clean Architecture Abstraction**: `AuthService` interface with `LocalAuthService` (persistent local storage + password hashing) and ready-to-plug `FirebaseAuthService`.
- **Email & Password Authentication**: Full Sign Up, Sign In, Forgot Password, and Form Validation (valid email format, 6+ character passwords).
- **Password Visibility Toggle**: Show/hide eye icon for secure input.
- **Dual Account Modes**:
  - **Guest Mode**: Allows instant offline exploration without creating an account; clearly labelled with a yellow warning badge.
  - **Authenticated Mode**: Shows verified account badge with user avatar and profile details.
- **Profile Editing**: Update display name, bio, and travel interests.
- **Firebase Setup Guide**: Built-in instructions viewer explaining how to register an Android app on Google Firebase console and download `google-services.json`.

---

## 🏗️ Architecture & Project Structure

```text
lib/
├── main.dart                          # Application bootstrap & dependency injection
├── app.dart                           # MultiProvider and MaterialApp.router setup
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Categories, seasons, expense types, sort options
│   ├── routing/
│   │   └── app_router.dart            # GoRouter configuration & ShellRoute navigation
│   ├── theme/
│   │   └── app_theme.dart             # Custom Material 3 Light & Dark design tokens
│   └── utils/
│       └── formatters.dart            # INR currency (₹), date ranges, and time formatting
├── data/
│   └── local/
│       ├── destination_seed_data.dart # 14 rich Indian destination datasets
│       └── local_storage_service.dart # SharedPreferences JSON persistence layer
├── models/
│   ├── attraction.dart                # Attraction coordinates, hours, fees
│   ├── destination.dart               # Complete destination model
│   ├── expense.dart                   # Trip expense model
│   ├── itinerary_activity.dart        # Day-by-day activity model
│   ├── trip.dart                      # Trip dates, budget, travelers
│   ├── user_profile.dart              # User profile & guest state
│   └── weather.dart                   # Open-Meteo weather & forecast model
├── providers/
│   ├── auth_provider.dart             # Authentication state & error handling
│   ├── destination_provider.dart      # Filtering, search, sort, and recent views
│   ├── theme_provider.dart            # Light / Dark theme switching & persistence
│   ├── trip_provider.dart             # Trips, itineraries, expenses & budget math
│   └── wishlist_provider.dart         # Reactive wishlist state & persistence
├── services/
│   ├── auth_service.dart              # Abstract AuthService + LocalAuthService
│   ├── maps_service.dart              # Google Maps deep links & intent launching
│   ├── recommendation_service.dart    # Transparent scoring algorithm
│   └── weather_service.dart           # Open-Meteo REST API client & cache
├── widgets/
│   ├── app_network_image.dart         # Progressive loading & error fallback
│   ├── category_chip.dart             # Category filter pill
│   ├── destination_card.dart          # Responsive destination card
│   ├── destination_carousel_card.dart # Large photography hero card
│   ├── empty_state_view.dart          # Generic illustrated empty state
│   └── rating_badge.dart              # Golden rating chip
└── features/
    ├── auth/                          # Login, Sign Up, Forgot Password
    ├── destination_details/           # Full destination guide & live weather
    ├── explore/                       # Search, category chips, filter modal
    ├── home/                          # Hero card, carousels, greetings
    ├── matcher/                       # Smart Destination Matcher wizard
    ├── navigation/                    # MainScaffold with 5-tab bottom navigation
    ├── profile/                       # User profile, travel stats, mode indicator
    ├── settings/                      # Dark mode toggle, Firebase guide, credits
    └── trips/                         # Dashboard, Itinerary, Expense dialogs
```

---

## 🚀 Setup & Installation Instructions

### Prerequisites
- **Flutter SDK**: `>= 3.13.5` (Tested on Flutter 3.47.7 stable)
- **Dart SDK**: `>= 3.13.5`
- **Android Studio** or **VS Code** with Flutter extensions installed.

### Step 1: Clone or Navigate to the Workspace
```bash
cd gdgc_assignment
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run the Application on Android
Ensure an Android emulator is running or an Android phone is connected via USB debugging:
```bash
flutter run
```

### Step 4: Run the Application on Web (Optional)
```bash
flutter run -d chrome
```

---

## 🧪 Automated Testing

The project includes **23 automated tests** covering unit logic, data serialization, budget mathematics, recommendation scoring, and widget rendering.

To execute the test suite:
```bash
flutter test
```

### Test Coverage Highlights:
- **`destination_filter_test.dart`**: Verifies category chips, case-insensitive keyword search, budget filters, low-to-high sorting, and filter resets.
- **`recommendation_service_test.dart`**: Tests transparent matching logic for mountain vs beach preferences and handles empty criteria gracefully.
- **`trip_budget_calculator_test.dart`**: Tests inclusive `totalDays` calculations, upcoming/ongoing/past status, total spending derivation, remaining balance, and overspend detection.
- **`data_model_serialization_test.dart`**: Verifies `toJson` and `fromJson` round-trip parsing for all domain models.
- **`weather_model_test.dart`**: Tests WMO code mapping to friendly weather conditions (e.g. 0 -> Clear sky, 71 -> Snowfall).
- **`widget_test.dart`**: Verifies home screen launch, greetings, bottom navigation destinations, and category chip taps.

---

## ☁️ Firebase Authentication Configuration

By default, the app runs in **Local Storage Mode with Guest Access** so anyone can clone and run it immediately without missing credentials.

To connect your own Firebase project:
1. Open the [Firebase Console](https://console.firebase.google.com/) and create a project named `travel-explorer`.
2. Navigate to **Authentication > Sign-in method** and enable **Email/Password**.
3. Register an Android app with package name:
   ```text
   com.gdgc.travelexplorer
   ```
4. Download `google-services.json` and place it in:
   ```text
   android/app/google-services.json
   ```
5. In `lib/services/auth_service.dart`, attach `firebase_auth` credentials to `FirebaseAuthService`.

---

## 🌤️ Live Weather API Details

- **Provider**: [Open-Meteo](https://open-meteo.com/) (Open-source free weather API for non-commercial educational use).
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Parameters**: `latitude`, `longitude`, `current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m`, and `daily=weather_code,temperature_2m_max,temperature_2m_min`.
- **Caching**: 30-minute in-memory caching to avoid redundant HTTP requests.

---

## 🗺️ Google Maps Deep Link Integration

The app generates standards-compliant Google Maps universal URLs:
```text
https://www.google.com/maps/search/?api=1&query={destination_name},{latitude},{longitude}
```
When clicked on Android, the system automatically prompts to open in the native Google Maps app or default browser, requiring zero proprietary API keys or paid mapping SDK licenses.

---

## Acknowledgments
- **Platform**: Flutter & Dart
