# AWESOME NOTES
**A Flutter-Based Smart Notes and To-Do Application**

## 📋 Project Overview
Awesome Notes is a Flutter-based mobile application designed to help users manage their tasks and notes efficiently. It provides multiple note-taking options such as text, voice, and image-based notes, along with category management and Firebase synchronization. The app also supports offline storage using Hive, ensuring access to notes even without an internet connection.

## 🎯 Objective
The main objective of this project is to design and develop a smart notes and to-do application that:

- Simplifies daily note-taking and task organization
- Works both online (Firebase sync) and offline (Hive storage)
- Provides multiple input types including text, voice, and image
- Offers a user-friendly interface with formatting tools such as bold and italic text

## 🔍 Scope of the Project
This project aims to assist students and professionals in managing their tasks and notes efficiently. The application can be extended for:

- Personal task management
- Academic note organization
- Office or team collaboration (future enhancement)
- Reminders and notifications for important events

## 🛠️ Tools & Technologies Used

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform mobile development |
| Dart | Programming language for Flutter |
| Firebase | Cloud data storage and synchronization |
| Hive | Local offline data storage |
| Provider | State management |
| Speech-to-Text | For recording voice notes |
| Image Picker | For capturing and selecting images |
| Android Studio / VS Code | Development environment |

## 💻 System Requirements

- **Operating System:** Windows / macOS / Linux
- **RAM:** Minimum 4 GB
- **Software:** Flutter SDK, Android Studio / VS Code
- **Device:** Android Emulator or Physical Device (Android 8.0 or higher)
- **Internet:** Required for Firebase Sync

## 🚀 Setup Instructions

Follow these steps to set up and run the project on your system:

### Step 1 — Clone the Repository
```bash
git clone https://github.com/YOUR-USERNAME/Awesome_Notes
```

### Step 2 — Navigate to the Project Folder
```bash
cd awesome-notes
```

### Step 3 — Install Dependencies
```bash
flutter pub get
```

### Step 4 — Configure Firebase
1. Create a new Firebase project in [Firebase Console](https://console.firebase.google.com/)
2. Enable Cloud Firestore and Authentication
3. Download the `google-services.json` file
4. Place it inside: `android/app/`

### Step 5 — Run the Application
```bash
flutter run
```

## 📦 Dependencies List

The project uses the following main dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.0.5
  image_picker: ^1.0.0
  speech_to_text: ^6.1.0
  flutter_tts: ^3.6.3
  path_provider: ^2.1.2
```

## ✨ Major Features

- **Firebase Integration** – Securely stores user signup and login credentials using Firebase Authentication
- **Offline Mode (Hive)** – Access notes without an internet connection
- **Task Categories** – Group notes and to-do items by category
- **Text Formatting** – Supports bold and italic text
- **Voice Notes** – Record and save spoken notes
- **Image Notes** – Add images directly from camera or gallery
- **Responsive UI** – Works on all device sizes
- **Clean Architecture** – Easy to maintain and extend

## 🔄 Working Principle

1. **User Registration & Access:** Once a user registers with an email and password, they can start creating and managing their personal notes.

2. **Local Storage with Hive:** All notes are securely and efficiently stored locally using the Hive database, ensuring fast performance even without internet connectivity.

3. **Complete Note Management:** Users can view, edit, delete, and organize their notes into different categories for better productivity and structure.

4. **Voice & Image Support:** The app supports rich note types — users can create voice and image notes, which are saved as linked files within each note entry.

## 📸 Screenshots

### Authentication Screens

<table>
  <tr>
    <td><img src="screenshots/Register.png" alt="Register" width="200"/><br><center>Register</center></td>
    <td><img src="screenshots/Register2.png" alt="Register Alt" width="200"/><br><center>Register (Alt)</center></td>
    <td><img src="screenshots/Sign in.png" alt="Sign In" width="200"/><br><center>Sign In</center></td>
    <td><img src="screenshots/Reg with Google.png" alt="Google Registration" width="200"/><br><center>Google Registration</center></td>
  </tr>
  <tr>
    <td colspan="2"><img src="screenshots/Reg with google 2.png" alt="Google Registration Alt" width="400"/><br><center>Google Registration (Alt)</center></td>
    <td colspan="2"><img src="screenshots/Firebase console.png" alt="Firebase Console" width="400"/><br><center>Firebase Console</center></td>
  </tr>
</table>

### Main Screens

<table>
  <tr>
    <td><img src="screenshots/Main.png" alt="Main Screen" width="200"/><br><center>Main Screen</center></td>
    <td><img src="screenshots/Saved Notes.png" alt="Saved Notes" width="200"/><br><center>Saved Notes</center></td>
    <td><img src="screenshots/Sort Notes.png" alt="Sort Notes" width="200"/><br><center>Sort Notes</center></td>
    <td><img src="screenshots/Tag.png" alt="Tag View" width="200"/><br><center>Tag View</center></td>
  </tr>
</table>

### Note Management

<table>
  <tr>
    <td><img src="screenshots/New Note 1.png" alt="New Note 1" width="200"/><br><center>New Note 1</center></td>
    <td><img src="screenshots/New Note 2.png" alt="New Note 2" width="200"/><br><center>New Note 2</center></td>
    <td><img src="screenshots/New Note 3.png" alt="New Note 3" width="200"/><br><center>New Note 3</center></td>
    <td><img src="screenshots/Update Note.png" alt="Update Note" width="200"/><br><center>Update Note</center></td>
  </tr>
</table>

### Image Input

<p align="center">
  <img src="screenshots/Image Input.png" alt="Image Input" width="300"/>
  <br>
  <em>Image Input</em>
</p>

## 🚀 Future Enhancements

- Add reminders and push notifications
- Implement note locking (PIN or biometrics)
- Add calendar integration
- Support for PDF or text export

## 🎓 Conclusion

The Awesome Notes app successfully integrates multiple functionalities such as voice, image, and text-based note-taking, combined with cloud synchronization and offline access. It demonstrates efficient use of Flutter, Firebase, and Hive, providing a robust and scalable notes management solution suitable for both personal and professional use.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Your Name**
- GitHub: [@YOUR-USERNAME](https://github.com/YOUR-USERNAME)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/YOUR-USERNAME/Awesome_Notes/issues).

## ⭐ Show your support

Give a ⭐️ if this project helped you!