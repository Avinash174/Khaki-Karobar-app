# Khaki Karobari — Mobile Application

> **Company:** KHAKI | KrypTech™  
> **Legal Name:** Khaki KrypTech (India) Pvt. Ltd.  
> **Brand Identity:** White + Red + Black

Enterprise mobile business management application for billing, inventory, accounting, GST, customers, suppliers, payments, expenses, and POS operations.

---

## Features

- **Point-of-Sale (POS) & GST Invoicing:** Rapid tax billing with automated CGST/SGST/IGST calculations.
- **WhatsApp Cloud Integration:** Instant one-click dispatch of bills and receipts to customer WhatsApp numbers.
- **Live Inventory & Stock Audit:** Real-time atomic stock reduction across all sales counters.
- **Customer CRM:** Comprehensive client directory with outstanding due balance tracking.
- **Unified Light + Dark + System Theme:** Full Material 3 theming system with persistent state using Riverpod and SharedPreferences.
- **Centralized REST API Architecture:** Seamlessly connected to the PostgreSQL backend API on port 5001.

---

## Tech Stack

- **Flutter 3.47+ (Dart 3.7+)**
- **State Management:** Flutter Riverpod (`flutter_riverpod: ^2.6.1`)
- **Navigation:** GoRouter (`go_router: ^14.8.1`)
- **HTTP Client:** Dio (`dio: ^5.8.0+1`)
- **Storage:** `shared_preferences: ^2.5.2` & `flutter_secure_storage: ^9.2.4`
- **Typography:** Google Fonts (`google_fonts: ^6.2.1`)

---

## Getting Started

1. Ensure Flutter SDK is installed and configured (`flutter doctor`).
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run code analysis and tests:
   ```bash
   flutter analyze
   flutter test
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

© 2026 Khaki KrypTech (India) Pvt. Ltd. All rights reserved.
