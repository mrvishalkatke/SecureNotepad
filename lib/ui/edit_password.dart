import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class ChangePasswordPage extends StatefulWidget {
  final User user;

  const ChangePasswordPage({super.key, required this.user});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xff0056FF),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xff0056FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: !_isPasswordVisible,
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Change the color here
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: newPasswordController,
                obscureText: !_isPasswordVisible,
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Change the color here
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !_isPasswordVisible,
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Change the color here
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: const Color(0xff040E24),
                      ),
                      onPressed: _changePassword,
                      child: const Text('Change Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    try {
      // Validate current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: widget.user.email!,
        password: currentPasswordController.text,
      );
      print("Reauthenticating...");
      await widget.user.reauthenticateWithCredential(credential);

      // Check if the new password and confirm password match
      if (newPasswordController.text == confirmPasswordController.text) {
        // Change password
        print("Changing password...");
        await widget.user.updatePassword(newPasswordController.text);

        // Update password in Firestore collection
        print("Updating password in Firestore...");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .update({
          'password': newPasswordController.text, // Replace 'password' with your field name
        });

        // Clear password fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Show success message or navigate back
        // You can handle it based on your UI/UX
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Passwords do not match, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New Password and Confirm Password do not match'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Password changed successfully!");
    } catch (e) {
      print('Error changing password: $e');
      // Handle error (e.g., show error message to the user)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error changing password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
