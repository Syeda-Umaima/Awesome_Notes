# Awesome Notes

<div align="center">

![Awesome Notes Banner](assets/screenshots/feature_banner.png)

**A powerful, AI-enhanced notes application with voice input, rich text editing, and smart organization**

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Hive](https://img.shields.io/badge/Hive-Local_DB-orange?style=for-the-badge)](https://docs.hivedb.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture)

</div>

---

## Overview

**Awesome Notes** is a feature-rich Flutter application that combines traditional note-taking with modern AI capabilities. Create notes using text, voice, or images, organize them with smart tags, and let AI help you summarize and categorize your thoughts.

### Perfect for:
- Students organizing lecture notes
- Professionals managing meeting notes
- Anyone tracking tasks and ideas
- Creative writers capturing inspiration

---

## Features

### Core Features
| Feature | Description |
|---------|-------------|
| **Rich Text Editor** | Full formatting with Flutter Quill (bold, italic, lists, etc.) |
| **Voice Input** | Speech-to-text for hands-free note creation with real-time transcription |
| **Image Notes** | Attach images from camera or gallery |
| **Smart Tags** | Organize notes with custom tags |
| **Powerful Search** | Find notes instantly by title or content |
| **Grid/List View** | Choose your preferred layout |

### AI-Powered Features
| Feature | Description |
|---------|-------------|
| **AI Summarization** | Auto-generate note summaries from content |
| **Smart Tag Suggestions** | AI suggests relevant tags based on note content |
| **Key Point Extraction** | Identify important points automatically |
| **Sentiment Analysis** | Understand the tone of your notes |
| **Title Suggestion** | AI recommends titles based on note content |

### Security & Storage
| Feature | Description |
|---------|-------------|
| **Firebase Auth** | Secure email/password & Google Sign-In |
| **User Isolation** | Each user only sees their own notes |
| **Offline Storage** | Hive local database for offline access |
| **Cloud Ready** | Architecture supports cloud sync |

### Organization
| Feature | Description |
|---------|-------------|
| **Pin Notes** | Keep important notes at the top |
| **Favorites** | Mark frequently accessed notes |
| **Color Coding** | Visual organization with 10 colors |
| **Reminders** | Set notification reminders for notes |
| **Trash & Archive** | Soft delete with recovery option |

---

## Screenshots

<div align="center">

### Splash & Authentication

<table>
  <tr>
    <td align="center"><b>Splash Screen</b></td>
    <td align="center"><b>Register</b></td>
    <td align="center"><b>Sign In</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/splash.png" width="200"/></td>
    <td><img src="assets/screenshots/Register.png" width="200"/></td>
    <td><img src="assets/screenshots/Sign%20in.png" width="200"/></td>
  </tr>
</table>

<table>
  <tr>
    <td align="center"><b>Register Step 2</b></td>
    <td align="center"><b>Google Sign-In</b></td>
    <td align="center"><b>Google Auth Step 2</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/Register2.png" width="200"/></td>
    <td><img src="assets/screenshots/Reg%20with%20Google.png" width="200"/></td>
    <td><img src="assets/screenshots/Reg%20with%20google%202.png" width="200"/></td>
  </tr>
</table>

### Main Interface

<table>
  <tr>
    <td align="center"><b>Home Screen</b></td>
    <td align="center"><b>Saved Notes</b></td>
    <td align="center"><b>Sort Options</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/Main.png" width="200"/></td>
    <td><img src="assets/screenshots/Saved%20Notes.png" width="200"/></td>
    <td><img src="assets/screenshots/Sort%20Notes.png" width="200"/></td>
  </tr>
</table>

### Note Creation & Features

<table>
  <tr>
    <td align="center"><b>New Note</b></td>
    <td align="center"><b>Rich Editor</b></td>
    <td align="center"><b>Note with Content</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/New%20Note%201.png" width="200"/></td>
    <td><img src="assets/screenshots/New%20Note%202.png" width="200"/></td>
    <td><img src="assets/screenshots/New%20Note%203.png" width="200"/></td>
  </tr>
</table>

<table>
  <tr>
    <td align="center"><b>Image Attachment</b></td>
    <td align="center"><b>Update Note</b></td>
    <td align="center"><b>Set Reminder</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/Image%20Input.png" width="200"/></td>
    <td><img src="assets/screenshots/Update%20Note.png" width="200"/></td>
    <td><img src="assets/screenshots/Remainder.png" width="200"/></td>
  </tr>
</table>

### Voice & AI Features

<table>
  <tr>
    <td align="center"><b>Voice Input</b></td>
    <td align="center"><b>AI Features</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/voice%20input.png" width="200"/></td>
    <td><img src="assets/screenshots/AI%20Features.png" width="200"/></td>
  </tr>
</table>

### Firebase Console

<table>
  <tr>
    <td align="center"><b>Firebase Authentication</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/Firebase%20console.png" width="400"/></td>
  </tr>
</table>

</div>

---

## Architecture

```
lib/
├── main.dart                    # App entry point with Firebase & Hive init
├── firebase_options.dart        # Firebase configuration
├── change_notifiers/            # State management (Provider)
│   ├── new_note_controller.dart # Note editing state
│   ├── notes_provider.dart      # Notes list with search & sorting
│   └── registration_controller.dart
├── core/                        # Utilities & constants
│   ├── constants.dart           # App-wide constants & colors
│   ├── dialogs.dart             # Dialog helpers
│   ├── extensions.dart          # Dart extensions
│   ├── utils.dart               # Utility functions
│   └── validator.dart           # Form validation
├── enums/
│   └── order_option.dart        # Sort options enum
├── models/
│   ├── note.dart                # Note entity
│   ├── note_model.dart          # Hive model with user isolation
│   └── note_model.g.dart        # Hive adapter (generated)
├── pages/
│   ├── main_page.dart           # Home screen with notes grid/list
│   ├── new_or_edit_note_page.dart # Note editor with all features
│   ├── recover_password_page.dart
│   ├── registration_page.dart   # Auth screen
│   ├── splash_screen.dart       # Animated splash
│   └── view_notes_screen.dart
├── services/
│   ├── ai_service.dart          # AI summarization & tag suggestions
│   ├── auth_service.dart        # Firebase authentication
│   ├── note_storage_service.dart
│   └── notification_service.dart # Reminder notifications
└── widgets/                     # Reusable components
    ├── ai_features_sheet.dart   # AI features bottom sheet
    ├── confirmation_dialog.dart
    ├── note_card.dart
    ├── note_color_picker.dart   # Color selection
    ├── note_fab.dart
    ├── note_grid.dart
    ├── note_toolbar.dart        # Rich text formatting toolbar
    ├── notes_list.dart
    ├── search_field.dart
    ├── voice_input_dialog.dart  # Voice recognition UI
    └── ... (more widgets)
```

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.19+ |
| **Language** | Dart 3.0+ |
| **Auth** | Firebase Authentication |
| **Database** | Hive (Local), Firestore Ready |
| **State** | Provider |
| **Rich Text** | Flutter Quill |
| **Voice** | speech_to_text |
| **Images** | image_picker |
| **Permissions** | permission_handler |
| **Fonts** | Google Fonts (Poppins, Fredoka) |

---

## Installation

### Prerequisites
- Flutter SDK 3.19+
- Firebase project with Authentication enabled
- Android Studio / VS Code

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/Syeda-Umaima/awesome_notes.git
cd awesome_notes

# 2. Install dependencies
flutter pub get

# 3. Generate Hive adapters
flutter packages pub run build_runner build

# 4. Configure Firebase (see below)

# 5. Run the app
flutter run
```

### Firebase Configuration

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password** and **Google Sign-In** authentication
3. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure` (recommended)

**Security Note**: Firebase config files are gitignored. Each developer needs their own Firebase project.

---

## Security

This app follows security best practices:

| Item | Status |
|------|--------|
| Firebase config files | Gitignored |
| API keys | Not in source code |
| User passwords | Firebase managed |
| Local data | Encrypted with Hive |
| User isolation | Each user sees only their notes |

---

## Dependencies

```yaml
dependencies:
  # Core
  flutter_quill: ^11.5.0      # Rich text editor
  provider: ^6.1.2            # State management

  # Firebase
  firebase_core: ^4.2.0
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  google_sign_in: ^5.4.0

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Features
  speech_to_text: ^7.0.0      # Voice input
  image_picker: ^1.1.2        # Image capture
  permission_handler: ^11.0.0 # Runtime permissions
  path_provider: ^2.1.5       # File paths
  url_launcher: ^6.3.0        # External links
  intl: ^0.20.2               # Date formatting
```

---

## Roadmap

- [x] Rich text editing
- [x] Voice input with speech recognition
- [x] Image attachments
- [x] Firebase authentication
- [x] Local storage with Hive
- [x] AI summarization
- [x] Smart tag suggestions
- [x] Sentiment analysis
- [x] Note reminders
- [x] Color coding
- [x] User note isolation
- [ ] Cloud sync with Firestore
- [ ] Push notifications for reminders
- [ ] Note sharing & collaboration
- [ ] PDF export
- [ ] Biometric lock
- [ ] Widget for home screen

---

## Contributing

Contributions are welcome! Please:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Syeda Umaima**

[![GitHub](https://img.shields.io/badge/GitHub-@Syeda--Umaima-181717?style=flat&logo=github)](https://github.com/Syeda-Umaima)

---

<div align="center">

**Star this repo if you found it helpful!**

Made with Flutter

</div>
