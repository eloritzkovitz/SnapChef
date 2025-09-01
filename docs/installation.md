# SnapChef App Installation Manual

This guide covers all methods for installing and running the SnapChef app on Android and iOS devices.

## Installing the Application

### Android: Installing the APK from GitHub

1. **Download the APK**
   - Go to the [GitHub Releases](https://github.com/eloritzkovitz/SnapChef/releases) page.
   - Download the latest `snapchef_vx.x.x.apk` file.

2. **Transfer the APK to Your Android Device**
   - Connect your device via USB, or upload the APK to Google Drive/Dropbox and download it on your device.

3. **Install the APK**
   - On your device, locate the APK file and tap to install.
   - If prompted, allow installation from unknown sources.

---

### iOS: Installing from the App Store (Email Approval Required)

1. **Request Access**
   - Send an email to `adicahal@gmail.com` requesting access to SnapChef on the App Store/TestFlight.

2. **Receive Invitation**
   - You will receive an email invitation with instructions to download the app via the App Store (iOS) or Google Play (Android).

3. **Install the App**
   - Follow the link in the email and install the app as instructed.

## Running the Application Locally

### Setup and Configuration

1. **Clone the Repository**
   ```sh
   git clone https://github.com/eloritzkovitz/SnapChef.git
   cd SnapChef
   ```

2. **Configure Environmental Variables:**  
   Add an .env file in the project root:
   ```
   SERVER_IP=https://snapchef.cs.colman.ac.il
   ```

   If you're running the backend server locally, you will need to replace the address with your own IP and the correct port.

3. **Add Firebase to your project:**
   * You will need to register the application in the Firebase Console as explained in the [Firebase Documentation](https://firebase.google.com/docs/android/setup).
   * For Android, you should place `google-services.json` in the `/android/app` folder.
   * For iOS, you should place `GoogleService-Info.plist` in the `/ios/Runner` folder.
   * For more information and instructions on obtaining the files, you can read [this support article](https://support.google.com/firebase/answer/7015592).

---

### Running on an Android Device via Android Studio

4. **Open in Android Studio**
   - Launch Android Studio and open the project folder.

5. **Connect Your Android Device**
   - Enable Developer Mode and USB Debugging on your device.
   - Connect your device via USB (or via wireless).

6. **Run the App**
   - Click the "Run" button in Android Studio.
   - Select your device from the list.

---

### Running on an iOS Device via Xcode

4. **Open in Xcode**
   - Open the `ios` folder in Xcode.

5. **Configure Signing**
   - Set your Apple Developer account for code signing in Xcode.

6. **Connect Your iOS Device**
   - Plug in your device and trust the computer if prompted.

7. **Run the App**
   - Select your device in Xcode.
   - Click the "Run" button to build and install the app.

## Notes

- For Android APK installation, you may need to enable "Install from unknown sources" in device settings.
- For iOS source builds, an Apple Developer account is required.
- For App Store/TestFlight access, approval via email is required.
