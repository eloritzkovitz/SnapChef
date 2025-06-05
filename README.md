![SnapChef Banner](docs/images/banner.png)

# SnapChef - Your AI sous-chef

SnapChef is a mobile application designed to create customized recipes based on available products at home. The application will make use of AI to identify various ingredients (from a taken photo, a scanned receipt or a barcode), and then create cooking recipes based on the given data and other preferences. In addition, the application will provide guidance throughout the process and allow its users to save and rate their recipes, as well as share them with their friends.

## Table of Contents
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Documentation](#documentation)
- [Authors](#authors)

## Features

### **Ingredient Recognition**
- **Snap a Photo:** Take photos of ingredients to identify them.
- **Receipt Scanner:** Upload grocery receipts to extract ingredient lists automatically.
- **Barcode Scanner:** Quickly scan product barcodes to add items directly to your ingredient list.

### **Recipe Generation**
- **Tailored recipes:** Get recipes designed just for you, based on your preferences and available ingredients.
- **Dietary Preferences:** Save your dietary preferences, restrictions and allergies for future use.
- **Meal Options:** Choose from categories like breakfast, lunch, dinner, or snacks.
- **Time-Based Filters:** Filter recipes by preparation and cooking time.
- **Visual Appeal:** View high-quality images of your meal options for inspiration.

### **Cooking Assistance**
- **Voice Guidance:** Follow cooking steps with text and voice instructions for hands-free help.
- **Storage Tips:** Learn how to store meals and leftovers to maximize freshness.
- **Groceries:** Organize your groceries easily and keep them in sync.

### **Your Personal Cookbook**
- **Save Recipes:** Create a personal collection of your favorite recipes.
- **Personal Recipes:** Add your own personal recipes or ideas.
- **Share:** Share recipes and meal ideas with friends in-app.

### **Notifications and Updates**
- **Scheduled Reminders:** Set and receive alerts for expiring ingredients or grocery items.
- **Friend Activity:** Stay updated on friend requests and recipe sharing.
- **App Updates:** Receive news about new features and updates.

### **User Management**
  - **Account Security:** Create and manage your account with secure login and password recovery.
  - **Custom Profiles:** Customize your own profile and preferences.
  - **Social Connectivity:** Add friends to collaborate and share recipes!

## Technologies Used

### Backend
- **Node.js** (TypeScript) — Server-side logic
- **Express.js** — API routing
- **JWT** — Authentication and authorization
- **MongoDB** — Database
- **Jest** — Testing 
- **WebSockets** — Real-time updates and communication

### Frontend
- **Flutter** (Dart) — Cross-platform mobile app
- **Drift** — Local persistence (SQLite ORM)
- **Text-to-speech** — Cooking assistance

### Third-party Services
- **Google Cloud Vision & ML Kit** — Ingredient recognition
- **Google Generative AI** — Personalized recipe creation
- **Vertex AI & Stable Diffusion** — Recipe image generation
- **Firebase Cloud Messaging** — Push notifications

## Documentation
- [Architecture Overview](docs/architecture.md)
- [Data Models](docs/models.md)
- [API Reference](https://snapchef-app.vercel.app/api)

## Authors
- [Elor Itzkovitz](https://github.com/Elor-Itz)
- [Yuval Lavi](https://github.com/Yuvalya101)
- [Adi Cahal](https://github.com/Adica6)
- [Yonatan Cohen](https://github.com/yonatan62862)
