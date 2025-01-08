import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:secure_notepad/ui/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:secure_notepad/ui/notes_index_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBwvBgy0j8x4gDFsMrAcZaefaMrq-07mc0',
        authDomain: 'notepad-1de92.firebaseapp.com',
        projectId: 'notepad-1de92',
        storageBucket: 'notepad-1de92.appspot.com',
        messagingSenderId: '254110063014',
        appId: '1:254110063014:android:e836d845447bb6500e9767',
      ),
    );
    await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(
            '6LdW2IEpAAAAAP4ehLyKQ4WSZiYzkJTvkuENAkh9'
        )
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
  // await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  // await FirebaseAppCheck.instance.getToken(true);

  // Check if the user is already authenticated
  User? user = FirebaseAuth.instance.currentUser;

  runApp(
      MaterialApp(
        theme: ThemeData(
          dialogBackgroundColor: Colors.black,
        ),
        home: user != null ? const NotesIndexPage() : const LoginPage(),
      )
  );
}


// flutter build apk --split-per-abi.
//run this to get .aab file