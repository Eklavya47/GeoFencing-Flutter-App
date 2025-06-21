# 📍 GeoFence Flutter App
A location-based app built using Flutter with Firebase Authentication for secure login. The app allows users to fetch their current coordinates, set a custom geofence radius, and receive notifications when they step outside the defined boundary. It also integrates a map view to visualize the user’s location and geofence in real-time.

# ✨ Features
- 🔐 **User Authentication** – Secure login and signup functionality
- 📍 **Real-time Location Tracking** – Monitor current location
- 🗺️ **Maps Integration** – Visual location tracking with Google Maps
- 🛡️ **Geofencing** – Create a custom-radius geo-fence around your current location.
- 🔔 **Alert on Exit** – Receive an alert when you step outside the geofence boundary.
- 📱 **Cross-Platform** – Works on both Android and iOS

# ⚙️ Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **Authentication**: Firebase Auth
- **Maps**: Google Maps Flutter
- **Location Services**: Geolocator, Geocoding
- **Local Notifications**: Flutter Ringtone Player
- **Platform Support**: Android, iOS, Web

# 📂 Project Structure
- **lib/**
  - `main.dart`: Application entry point
  - `login.dart`: User authentication screen
  - `signup.dart`: New user registration
  - `forgot.dart`: Password recovery
  - `homepage.dart`: Main application screen
  - `maps.dart`: Maps integration
  - `location.dart`: Location tracking logic
  - `geolocator.dart`: Geolocation services
  - `wrapper.dart`: Authentication state management

# 🚀 Getting Started
Follow these steps to run the project locally:
1. Clone the repository
2. Open the project in VS Code or Android Studio
3. Ensure Flutter is installed on your system
4. Run `flutter pub get` to install dependencies
5. Configure your Firebase project and add necessary API keys
6. Run the app using `flutter run`

# 🔧 Requirements
- Flutter SDK (Latest version)
- Dart SDK
- Android Studio / VS Code with Flutter and Dart plugins
- Firebase project setup
- Google Maps API key
- Minimum SDK: Android 21, iOS 11

# 🤝 Contributing
Contributions are welcome! If you'd like to improve the app or add new features, feel free to fork the repository and submit a pull request.
