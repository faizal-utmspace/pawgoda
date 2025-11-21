# 🐾 PawGoda - Pet Hotel Activity Management System

<div align="center">
  <img src="assets/svg/starter_header.svg" alt="PawGoda Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.35.7-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📖 About

**PawGoda** is an innovative pet hotel management solution that bridges the gap between pet owners and pet hotel services. It provides real-time activity tracking and management, ensuring pet owners stay connected with their beloved pets even when they're away from home.

### 🎯 The Problem

Pet owners who utilize pet hotel services face several challenges:
- **Limited Visibility**: Unable to track their pets' activities during the hotel stay
- **Anxiety & Stress**: Uncertainty about their pets' wellbeing creates worry
- **Communication Gap**: Difficulty maintaining consistent care routines with the hotel
- **Trust Issues**: Lack of transparency between pet owners and hotel staff

### 💡 Our Solution

PawGoda offers an interactive platform that enables:
- **Pre-Booking Customization**: Pet owners can arrange and customize their pets' daily activities before check-in
- **Real-Time Updates**: Pet hotel staff can update performed activities instantly
- **Live Activity Tracking**: Pet owners can monitor their pets' status anytime, anywhere
- **AI-Powered Support**: Integrated chatbot for quick assistance
- **Media Sharing**: Staff can share photos and videos of pets during activities

### 🌟 Key Benefits

- ✅ **Reduced Anxiety**: Peace of mind through constant connectivity and updates
- ✅ **Enhanced Trust**: Transparent communication strengthens pet owner-hotel relationships
- ✅ **Customized Care**: Maintain consistent routines tailored to each pet's needs
- ✅ **Improved Experience**: Seamless booking and activity management process

### 🏆 Competitive Advantages

What sets PawGoda apart:
- 🎨 **Customizable Activities**: Tailor daily care routines for each pet
- ⚡ **Real-Time Updates**: Instant activity status with photo/video evidence
- 🤖 **AI & Human Support**: Dual support system for comprehensive assistance
- 📱 **Modern UX**: Intuitive, user-friendly interface with smooth navigation
- 🔔 **Smart Notifications**: Keep owners informed of important updates

---

## 🚀 Features

### For Pet Owners
- 📅 **Activity Planning**: Schedule and customize pet activities before check-in
- 📊 **Activity Dashboard**: View real-time status of all scheduled activities
- 🖼️ **Media Gallery**: Access photos and videos shared by hotel staff
- 📖 **Booking History**: Track past and current bookings
- 💬 **AI Chatbot**: Get instant answers to common questions
- 🔐 **Secure Login**: Google Sign-In authentication

### For Pet Hotel Staff
- 📋 **Booking Management**: View and manage all active bookings
- ✅ **Activity Tracking**: Mark activities as complete with notes
- 📸 **Media Upload**: Share photos and videos with pet owners
- 📝 **Real-Time Updates**: Post activity updates instantly
- 📊 **Activity Analytics**: Monitor completion rates and pending tasks

---

## 🛠️ Technology Stack

### Frontend
- **Framework**: Flutter 3.35.7
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **UI Components**: Material Design 3

### Backend & Services
- **Authentication**: Firebase Auth + Google Sign-In
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage (for media files)
- **Hosting**: Firebase Hosting (Web)

### Key Dependencies
```yaml
firebase_core: ^3.5.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.4
google_sign_in: ^6.2.1
image_picker: ^1.1.2
video_player: ^2.9.2
shared_preferences: ^2.3.3
flutter_svg: ^2.2.1
gap: ^3.0.1
intl: ^0.17.0
```

---

## 📱 Screenshots

<div align="center">
  <img src="sreenshots/1.png" width="200" alt="Home Screen"/>
  <img src="sreenshots/2.png" width="200" alt="Booking"/>
  <img src="sreenshots/3.png" width="200" alt="Activities"/>
  <img src="sreenshots/4.png" width="200" alt="Profile"/>
</div>

---

## 🏃 Getting Started

### Prerequisites

- Flutter SDK (3.35.7 or higher)
- Dart SDK (^3.9.2)
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/faizal-utmspace/pawgoda.git
   cd pawgoda
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Google Sign-In)
   - Create Firestore Database
   - Enable Firebase Storage
   - Download and add configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
     - `lib/firebase_options.dart`

4. **Run the app**
   ```bash
   # Development mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

### Build APK

```bash
# Build release APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user.dart
│   ├── booking.dart
│   ├── pet.dart
│   └── package.dart
├── pages/                    # UI screens
│   ├── get_started.dart
│   ├── login_page.dart
│   ├── homepet.dart
│   ├── user_profile_page.dart
│   ├── booking_page.dart
│   ├── ai_chatbot_page.dart
│   └── staff/
│       ├── home_staff.dart
│       ├── booking.dart
│       ├── activity.dart
│       └── activity_details.dart
├── services/                 # Business logic
│   └── auth.dart
├── utils/                    # Utilities
│   ├── styles.dart
│   ├── storage.dart
│   └── helpers.dart
└── widgets/                  # Reusable components
    ├── pet_card.dart
    ├── list_card.dart
    └── animated_title.dart
```

---

## 🎨 Design System

### Color Palette
- **Primary**: `#09D4D9` (Turquoise)
- **Background**: `#C0F7F8` (Light Cyan)
- **Secondary BG**: `#E6FEFF` (Very Light Cyan)
- **Text**: `#2C3131` (Dark Gray)

### Typography
- **Font Family**: Poppins
- **Weights**: Regular, Medium, Bold, ExtraBold, Black

---

## 🔐 Firebase Collections Structure

### users
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "photoURL": "string",
  "role": "customer | staff"
}
```

### bookings
```json
{
  "bookingId": "string",
  "uid": "string",
  "petName": "string",
  "petType": "string",
  "customerName": "string",
  "serviceType": "string",
  "package": "object",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "status": "Active | Completed",
  "selectedActivities": ["string"],
  "pendingActivities": "number",
  "completedActivities": "number"
}
```

### activity
```json
{
  "activityId": "string",
  "title": "string",
  "description": "string",
  "updates": [
    {
      "text": "string",
      "mediaUrl": "string",
      "isVideo": "boolean",
      "timestamp": "timestamp"
    }
  ],
  "lastUpdated": "timestamp"
}
```

---

## 👥 User Roles

### Customer Role
- Browse and book pet hotel services
- Customize pet activity schedules
- Track activities in real-time
- View media updates
- Manage bookings and profile

### Staff Role
- View all active bookings
- Update activity status
- Upload photos/videos
- Manage pet care routines
- Communicate with pet owners

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Faizal Razak**
- GitHub: [@faizal-utmspace](https://github.com/faizal-utmspace)
- Branch: `dev/faizal`

---

## 📞 Support

For support, please contact:
- Email: support@pawgoda.com
- GitHub Issues: [Create an issue](https://github.com/faizal-utmspace/pawgoda/issues)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

---

<div align="center">
  <p>Made with ❤️ for pets and their owners</p>
  <p>© 2025 PawGoda. All rights reserved.</p>
</div>
