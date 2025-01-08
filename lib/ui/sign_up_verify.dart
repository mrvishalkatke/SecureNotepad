import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:email_validator/email_validator.dart';

class SignUpVerify extends StatefulWidget {
  final String email;

  const SignUpVerify({Key? key, required this.email}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<SignUpVerify> {
  final TextEditingController pinController = TextEditingController();
  bool _isValidEmail(String email) {return EmailValidator.validate(email);}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A 6-digit verification code\nhas been sent to ${widget.email}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter 6-digit code',
                counterText: '',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.email.isNotEmpty && _isValidEmail(widget.email)) {
                  verifyEmail();
                } else {
                  showErrorMessage('Please enter the\ncorrect 6-digit code',);
                }
              },
              child: Text('Verify', style: TextStyle(
                fontSize: 18
              ),),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: widget.email,
          password: pinController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Email verification successful
        // You can navigate to the next screen or perform any action here

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verification successful!'),
          ),
        );
      } else {
        // Handle the case where the user is not signed in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not signed in!'),
          ),
        );
      }
    } catch (e) {
      // Handle verification failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email verification failed!'),
        ),
      );
      print('Error verifying email: $e');
    }
  }
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 290,
            height: 65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)
                  ),
                )
              ]
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK', style: TextStyle(
                    fontSize: 18
                  ),),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
