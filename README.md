# BeaconScanner

## Overview

  The Bluetooth Beacon Scanner is a Flutter application that allows users to scan, display, and view details of nearby   
  Bluetooth devices. This application demonstrates the use of Flutter for cross-platform mobile development and incorporates   Bluetooth functionalities using the [flutter_blue_plus] package.


## Features

  - Scan for nearby Bluetooth devices
  - Display a list of scanned devices with relevant information.
  - View detailed information about each device when tapped.
  - User-friendly interface with vibrant colors and gradients.

## Screenshots

  ![Sample Output](https://github.com/Praveen5102/BeaconScanner/blob/main/lib/assets/android%20output.jpeg)


## Installation

**Prerequisites**

  - Flutter SDK installed on your machine.
  - An IDE such as Android Studio, VS Code, or IntelliJ IDEA.
  - An Android device or emulator, and/or an iOS device or simulator.

**Setup Instructions**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/praveen5102/BeaconScanner.git
   ```
2. **Navigate to the project directory:**
   ```bash
   cd BeaconScanner
   ```
3. **Install dependencies:** Run the following command to install the required packages:
   ```bash
   flutter pub get
   ```
4. **Configure permissions:**
  - For **Android**, ensure that your [AndroidManifest.xml] has the necessary Bluetooth and location permissions:
    ```bash
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    ```
  - For **iOS**, update your Info.plist with the following entries:
    ```bash
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app requires Bluetooth access to scan for devices.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app requires location access to scan for Bluetooth devices.</string>
    ```
5. **Run the app:**
   - For **Android**, use:
     ```bash
     flutter run
     ```
   - For **iOS**, make sure you have a device connected or a simulator running, then use:
     ```bash
     flutter run
     ```

## Usage
  - Upon launching the app, you will see a button to start scanning for Bluetooth devices.
  - The app will display a list of found devices, along with their RSSI (signal strength) and other details.
  - Tapping on any device will show a dialog with more detailed information.

## Future Improvements
  - Implement filtering options for device types.
  - Add the ability to connect to devices and exchange data.
  - Improve UI/UX for a better user experience.

## Conclusion

  This app serves as a foundational project for understanding Bluetooth scanning capabilities in mobile applications. It       showcases the integration of Flutter with native device functionalities and can be further enhanced with additional       
  features and improvements.

## Acknowledgments

  - [Flutter] - The framework used for building the app.
  - [flutter_blue_plus] - Package used for Bluetooth functionalities.

## Contact

  For any questions or feedback, feel free to reach out:
  
  - **Email:**praveenkumargone229@gmail.com
  - **GitHub:** https://github.com/praveen5102

## 

  Thank you for checking out the BeaconScanner Application! We hope you enjoy using it as much as we enjoyed building it. 😊



