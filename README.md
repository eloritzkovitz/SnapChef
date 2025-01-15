# SnapChef - AI Powered Recipe App

## Overview
SnapChef is a mobile application designed to create customized recipes based on available products at home. The application will make use of AI to identify various ingredients (from a taken photo, a scanned receipt or a barcode), and then create cooking recipes based on the given data and other preferences. In addition, the application will provide guidance throughout the process and allow its users to save and rate their recipes, as well as share them with their friends.

---

## Features

### Core Functionalities
- **Ingredient Recognition**: Identify ingredients using:
  - Photos of ingredients.
  - Grocery receipt scanning (OCR).
  - Barcode scanning for grocery products.
- **Recipe Generation**: Create recipes based on:
  - Available ingredients.
  - Dietary preferences, restrictions, and cuisine types.
  - Meal types, difficulty levels, preparation and cooking times.
- **Cooking Assistance**:
  - Step-by-step text and voice guidance.
  - Illustrative photos and helpful cooking tips.
- **Storage Tips**:
  - Recommendations for storing cooked meals.

### User Engagement
- Save, review, and rate recipes in a personal cookbook.
- Share recipes and meal photos with friends.
- Add friends and view their shared content.

### Notifications and Analytics
- Recipe reminders and friend activity updates.
- In-app notifications for updates and new features.
- Activity tracking for app usage and performance optimization.

---

## Technology Stack

### Backend
- **Node.js** with **TypeScript** for server-side logic.
- **Express.js** for API routing.
- **MongoDB** for database management.

### Frontend
- **Flutter** for building a cross-platform mobile application.

### AI Features
- **Computer Vision** for ingredient recognition.
- **OCR** for receipt text extraction.
- **AI Recipe Generator** for personalized recipe creation.
