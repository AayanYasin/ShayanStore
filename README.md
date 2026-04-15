# Shayan Store - Full-Stack E-Commerce Application

A professional, full-stack E-Commerce prototype built for university presentation purposes. It features a completely custom-built Dart backend API and a highly interactive, modern Flutter frontend (compatible with Web and Android). 

## 🚀 Features
- **Modern Frontend Architecture:** Built with Flutter, utilizing an ultra-modern, responsive mobile-first UI that scales gracefully to desktop. Features a premium Material Design 3 (M3) Purple theme.
- **Dynamic Visuals:** Includes immersive product image carousels, expandable tiles, sleek glass-morphism effects, and flash-sale-oriented visual elements for high user engagement.
- **Robust Cart & Checkout:** Enhanced cart state management with interactive product quantity controls (+/-), and a streamlined checkout navigation flow.
- **Custom Backend API:** Built entirely in Dart using the `shelf` and `shelf_router` frameworks. Completely handles raw CORS and RESTful API endpoints.
- **Relational Database:** Stores user authentication parameters, shipping addresses, live product inventories, and dynamic order tracking using MySQL.
- **Authentication:** Live multi-state login and signup logic with phone and address capture.
- **Admin Dashboard:** A secure, password-protected backend panel to view raw user orders, shipping addresses, and mark physical orders as completed.

---

## 🛠️ Tech Stack
- **Frontend:** Flutter & Dart (Material Design 3)
- **Backend Server:** Dart (`shelf`, `mysql1`)
- **Database:** MySQL (XAMPP / PhpMyAdmin)
- **Networking:** HTTP REST API (Dynamic routing for `localhost`/`10.0.2.2`)

---

## 💻 Installation & Setup Guide

### 1. Database Setup
You must configure the MySQL database before running the server.
1. Download and open **XAMPP**.
2. Start the **Apache** and **MySQL** modules.
3. Open PhpMyAdmin in your browser (`http://localhost/phpmyadmin`).
4. Import or run the contents of the `database_v3_setup.sql` file provided in this repository. This will automatically generate the `ecom_db` database, necessary tables, and pre-fill the store with 10 dummy products.

### 2. Backend Server Setup
The Dart server handles all communication between the app and the database.
1. Open a terminal and navigate to the backend folder:
   ```bash
   cd backend_server
   ```
2. Install the necessary Dart dependencies:
   ```bash
   dart pub get
   ```
3. Run the API Server:
   ```bash
   dart run bin/server.dart
   ```
   *The server will start listening on port 8080. Leave this terminal open.*

### 3. Frontend App Setup
The user-facing application built in Flutter.
1. Open a **new** separate terminal and navigate into the app folder:
   ```bash
   cd ecom_app
   ```
2. Install frontend dependencies:
   ```bash
   flutter pub get
   ```
3. **To run on Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```
4. **To run on Android Emulator:**
   - Start your Android Emulator.
   - Run: `flutter run`

---

## 👨‍💻 Usage Flow
1. **User Sign Up:** Create an account with your Email, Phone Number, and Shipping Address.
2. **Shopping:** Browse the 10 products, expand image carousels, and interact with flash-sale items.
3. **Checkout:** Add items to your cart, manage quantities (+ / -), and smoothly navigate to finalize your order.
4. **Order History:** Use the sidebar drawer to view your pending orders.
5. **Admin Processing:** Click the `Shield` icon on the login page and use the dummy master password (`admin123`) to view all user orders and mark them as fully completed.
