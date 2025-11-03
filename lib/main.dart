import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'change_notifiers/notes_provider.dart';
import 'change_notifiers/registration_controller.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'models/note_model.dart';
import 'pages/main_page.dart';
import 'pages/registration_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('notesBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Awesome Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          useMaterial3: true,
          fontFamily: 'Fredoka',
        ),
        // ✅ Add these localizations to fix FlutterQuill error
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          quill.FlutterQuillLocalizations.delegate, // ✅ THIS IS THE FIX!
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('en', 'GB'),
          // Add more locales as needed
        ],
        home: const AuthWrapper(),
      ),
    );
  }
}

// ✅ This Widget listens to the Firebase auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ If user is logged in → go to MainPage
        if (snapshot.hasData && snapshot.data != null) {
          return const MainPage();
        }

        // ❌ Not logged in → show RegistrationPage
        return const RegistrationPage();
      },
    );
  }
}
