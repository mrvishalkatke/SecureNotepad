import 'package:flutter/material.dart';
import 'package:secure_notepad/ui/login_page.dart';

class SecureNotepad extends StatelessWidget {
  const SecureNotepad({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Notepad',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}


