# SnapChef

SnapChef is a Flutter application that allows users to capture images of food items, scan receipts, and scan barcodes to recognize ingredients and generate recipes.

## Getting Started

- **Flutter SDK:** [Install Flutter](https://docs.flutter.dev/get-started/install)- 
- **Environment variables:** Create a `.env` file with your IP and port to connect with the backend.

### Installation

1. **Clone the repository:**
```sh
   git clone https://github.com/Elor-Itz/SnapChef.git
   cd SnapChef/flutter_app
   ```

2. **Install dependencies:**
```dart
   flutter pub get
   ```

3. **Set up anvironmental variables:**
   In order to access the backend API from your mobile device, you will need to set:
```sh
   SERVER_IP=http://<YOUR_IP_ADDRESS:PORT>  
   ```
   to the value of your computer's IP address and the required port (3000).
   
   The file should be at the `/flutter_app` directory.

4. **Run the app:**
```sh
   flutter run     
   ``` 
   Make sure you are inside the `/flutter_app` folder.

## Usage

1. Open the SnapChef app on your device.

2. Use the floating action button to capture a photo, scan a receipt, or scan a barcode.

3. View the recognized ingredients and their categories.

4. Generate recipes based on the recognized ingredients.

## Project Structure

* `lib/:` Contains the main Flutter application code.
  * `main.dart:` Entry point of the application.
  * `services/:` Contains service classes for image processing and recognition.
    * `upload_photo.dart:` Handles image upload and recognition using Google Cloud Vision API.
* `assets/:` Contains static assets such as images and icons.
* `pubspec.yaml:` Defines the dependencies and assets for the Flutter project.
