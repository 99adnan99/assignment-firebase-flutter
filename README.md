# flutter_firebase

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Flutter Staff Firestore App

A simple Flutter application to:

- Add staff information (name, ID, age)
- Save staff to Firebase Cloud Firestore
- Display, edit, and delete staff

## 🔧 Features
- No photo or authentication
- Realtime Firestore updates
- Clean UI with Firestore integration

## 🚀 Setup

1. Clone this repo
2. Run `flutter pub get`
3. Add your `firebase_options.dart` (generated via FlutterFire CLI)
4. Update Firebase Firestore rules for development:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}

