import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:secure_notepad/ui/additional_info_page.dart';
import 'package:secure_notepad/ui/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  Future<UserCredential>? _authFuture;
  bool confirmPasswordError = false;

  bool _isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  Future<void> signUp(context) async {
    setState(() {
      _isLoading = true;
    });

    if (!_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email ID'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (emailController.text.trim().isEmpty &&
        passwordController.text.trim().isEmpty &&
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all the details'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        confirmPasswordError = true;
        _isLoading = false;
      });
      return;
    }

    try {
      if (kDebugMode) {
        print("Before Firestore Query");
      }
      // Check if the email already exists
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: emailController.text.toLowerCase())
          .get();
      if (kDebugMode) {
        print("Query Snapshot: ${snapshot.docs}");
      }

      if (snapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          print("Email already exists");
        }
        showExistingUserPopup(context);
        return;
      }

      if (kDebugMode) {
        print("Email does not exist, proceeding with user creation");
      }

      // Email doesn't exist, proceed with user creation
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      // Store additional user data in Firestore (customize based on your needs)
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'email': emailController.text,
        'password': passwordController.text,
        'timestamp': DateTime.now(),
        // Add more fields as needed
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('accountDetails')
          .doc('info')
          .set({
        'email': emailController.text,
        // Add more fields as needed
      });

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          if (kDebugMode) {
            print('User is currently signed out!');
          }
        } else {
          if (kDebugMode) {
            print('User is signed in!');
          }
        }
      });

      // Navigate to home page or another screen upon successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdditionalInfoPage(
            user: userCredential.user!,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showExistingUserPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Account Already Exists', style: TextStyle(color: Colors.white),),
          content: const Text(
              'The provided email is already associated with an account.', style: TextStyle(color: Colors.white),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK', style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: const Text('Login', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Center(child: Text('Sign Up Page', style: TextStyle(color: Colors.blue.shade600),)),
      // ),
      body: Stack(children: <Widget>[
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/login.png'), fit: BoxFit.cover)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              Colors.transparent,
              const Color(0xffFFFFFF).withOpacity(1.0),
              const Color(0xffFFFFFF),
              const Color(0xffFFFFFF),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    "Create Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    contentPadding: EdgeInsets.all(20.0),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.black),
                    contentPadding: const EdgeInsets.all(20.0),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: confirmPasswordController,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(
                        color:
                            confirmPasswordError ? Colors.red : Colors.black),
                    contentPadding: const EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                          color:
                              confirmPasswordError ? Colors.red : Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                          color:
                              confirmPasswordError ? Colors.red : Colors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (_authFuture != null)
                  FutureBuilder<UserCredential>(
                    future: _authFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                            backgroundColor: Colors.black,
                            valueColor:
                            AlwaysStoppedAnimation(Colors.blueAccent),
                            strokeWidth: 3);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                      strokeWidth: 3,
                    ),
                  ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                    onPressed: _isLoading ? null : () => signUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7b0323),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/email.png',
                            width: 30,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 18),
                          const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(pageBuilder: (BuildContext context,
                            Animation animation, Animation secondaryAnimation) {
                          return const LoginPage();
                        }, transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child) {
                          return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10.0,
                                    sigmaY: 10.0), // Adjust the blur intensity
                                child: ClipRect(
                                  child: child,
                                ),
                              ));
                        }),
                        result: (Route route) => false);
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
