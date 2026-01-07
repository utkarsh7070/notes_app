# Notes App

A professional notes application built with **Flutter** and **Firebase**, featuring real-time synchronization, secure authentication, and clean architecture implementation.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

- 🔐 **Secure Authentication** - Email/Password authentication with Firebase Auth
- 📝 **CRUD Operations** - Create, Read, Update, and Delete notes
- 🔄 **Real-time Sync** - Instant updates across devices using Firestore streams
- 🔍 **Smart Search** - Search notes by title or content with real-time filtering
- 🏗️ **Clean Architecture** - MVVM pattern with separation of concerns
- 🎯 **State Management** - Riverpod for dependency injection and reactive state
- 🔒 **Data Isolation** - Each user can only access their own notes
- 📱 **Responsive UI** - Modern, clean interface with Material Design

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **MVVM pattern**:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, ViewModels, States, Providers)   │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│  (Entities, UseCases, Repositories)     │
│         [Business Logic]                │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│            Data Layer                   │
│  (Models, DataSources, Repositories)    │
└─────────────────────────────────────────┘
```

**Key Benefits:**
- ✅ Testable and maintainable code
- ✅ Loose coupling between layers
- ✅ Easy to scale and extend
- ✅ Independent business logic

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Firebase account
- Android device or emulator

### 1. Clone the Repository

```bash
git clone https://github.com/utkarsh7070/notes_app.git
cd flutter-notes-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and create a new project
3. Register your Android app with package name: `com.example.flutter_notes_app`

#### B. Download Configuration

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

#### C. Enable Services

**Firebase Authentication:**
1. Go to Firebase Console → Authentication
2. Click "Get Started"
3. Enable "Email/Password" sign-in method

**Cloud Firestore:**
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in production mode
4. Choose your preferred location

#### D. Configure Security Rules

In Firebase Console → Firestore Database → Rules, add:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // This rule allows anyone with your Firestore database reference to view, edit,
    // and delete all data in your Firestore database. It is useful for getting
    // started, but it is configured to expire after 30 days because it
    // leaves your app open to attackers. At that time, all client
    // requests to your Firestore database will be denied.
    //
    // Make sure to write security rules for your app before that time, or else
    // all client requests to your Firestore database will be denied until you Update
    // your rules
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2027, 2, 1);
    }
  }
}
```

#### E. Add SHA-1 Certificate (Required)

1. Get your SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy the SHA1 value from the output
3. In Firebase Console → Project Settings → Your apps
4. Click "Add fingerprint" and paste SHA-1
5. Download new `google-services.json` and replace the old one

### 4. Run the App

```bash
flutter run
```

---

## 📊 Database Schema

### Firestore Structure

```
firestore
└── users (collection)
    └── {userId} (document)
        ├── email: string
        ├── uid: string
        └── notes (subcollection)
            └── {noteId} (document)
                ├── id: string (auto-generated)
                ├── title: string
                ├── content: string
                ├── userId: string
                ├── createdAt: timestamp
                └── updatedAt: timestamp
```

### Data Model

**NoteEntity:**
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique note identifier |
| title | String | Note title |
| content | String | Note content/body |
| userId | String | Owner's user ID |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

**UserEntity:**
| Field | Type | Description |
|-------|------|-------------|
| uid | String | User unique identifier |
| email | String | User email address |

---

## 🔐 Authentication Approach

### Firebase Authentication

**Implementation:**
- **Sign Up:** Email/Password registration with Firebase Auth
- **Sign In:** Email/Password authentication
- **Session Persistence:** Automatic session management via Firebase
- **Sign Out:** Secure logout functionality

**Security Features:**
- ✅ Password minimum length validation (6+ characters)
- ✅ Email format validation
- ✅ Secure token-based authentication
- ✅ Automatic session refresh
- ✅ User-specific data isolation

**Flow:**
```
User enters credentials
    ↓
Firebase Auth validates
    ↓
Token generated & stored
    ↓
User can access protected resources
    ↓
Auto-refresh on app restart
```

---

## 🎯 Technical Decisions

### State Management
**Choice:** Riverpod  
**Reason:** 
- Compile-time safety
- Better testing support
- Dependency injection
- No BuildContext required

### Architecture Pattern
**Choice:** Clean Architecture + MVVM  
**Reason:**
- Clear separation of concerns
- Highly testable
- Scalable for large teams
- Independent business logic

### Database
**Choice:** Cloud Firestore  
**Reason:**
- Real-time synchronization
- Offline support
- Scalable NoSQL database
- Built-in security rules

---

## 📋 Assumptions & Trade-offs

### Assumptions

1. **Internet Connectivity**: App requires active internet connection for authentication and data sync
2. **Single Device Login**: Users can be logged in on multiple devices simultaneously
3. **Data Persistence**: Notes are stored only in Firestore (no local database for offline access)
4. **User Base**: Designed for individual users, not collaborative note-taking

### Trade-offs

| Decision | Trade-off | Justification |
|----------|-----------|---------------|
| **Client-side Search** | Limited to loaded notes | Simpler implementation, sufficient for MVP |
| **Subcollection Structure** | Cannot query across all users | Better data isolation and security |
| **No Offline Mode** | Requires internet | Reduces complexity, real-time sync priority |
| **Email/Password Only** | No social login | Faster implementation, can be extended later |
| **No Note Sharing** | Single-user notes | Focuses on core functionality |

### Future Enhancements

- 🔄 Offline support with local caching
- 🏷️ Tags and categories for notes
- 🎨 Rich text editor with formatting
- 📎 File attachments
- 🔗 Note sharing with other users
- 🌐 Social authentication (Google, Apple)
- 🔔 Push notifications
- 🗂️ Folders and organization
- 🌙 Dark mode theme

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── error/              # Error handling
│   └── usecases/          # Base use case
|   └── routes/            # routes
├── domain/                # Business logic
│   ├── entities/          # Business models
│   ├── repositories/      # Repository interfaces
│   └── usecases/         # Business operations
├── data/                  # Data layer
│   ├── models/           # Data models
│   ├── datasources/      # Firebase integration
│   └── repositories/     # Repository implementations
├── presentation/          # UI layer
│   ├── providers/        # Riverpod providers
│   ├── viewmodels/       # UI business logic
│   ├── views/           # Screens
│   └── widgets/         # Reusable components
└── main.dart            # App entry point
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Real-time NoSQL database |
| **Riverpod** | State management & DI |
| **Dartz** | Functional programming (Either) |
| **Equatable** | Value equality |
| **Intl** | Date formatting |
| **Searchable ListView** | Enhanced search functionality |

---

## 🔨 Building APK

### Debug Build

```bash
flutter build apk --debug
```

### Release Build

```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🐛 Troubleshooting

### Common Issues

**1. Google Play Services Error**
```
Solution: Add SHA-1 fingerprint to Firebase Console
```

**2. Permission Denied Error**
```
Solution: Check Firestore security rules are properly configured
```

**3. Notes Not Updating**
```
Solution: Ensure internet connection and Firestore rules allow access
```

**4. Build Fails**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
flutter run
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Utkarsh Singh**
- GitHub: [utkarsh7070](https://github.com/utkarsh7070)
- Email: singhpariahrutkarsh@gmail.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Riverpod community for state management
- Clean Architecture principles by Robert C. Martin

---

## 📞 Support

For issues, questions, or contributions:
- 📧 Email: singhpariharutkarsh@gmail.com

---

**Made with ❤️ using Flutter**
