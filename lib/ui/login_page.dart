import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_notepad/ui/notes_index_page.dart';
import 'package:secure_notepad/ui/sign_up_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secure_notepad/ui/additional_info_page.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<UserCredential>? _authFuture;

  @override
  void initState() {
    super.initState();
    // Initialize _authFuture here if needed
  }

  Future<void> login(context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Successfully signed in with email and password
      if (kDebugMode) {
        print('Login successful! User ID: ${userCredential.user?.uid}');
      }
      storeAdditionalUserInfo(userCredential.user!);
      // Navigate to home page or another screen upon successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotesIndexPage()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging in: $e');
      }
      // Display a pop-up message for authentication failure
      showErrorMessage(context, 'Invalid email or password. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuthentication.canCheckBiometrics;
      if (isAvailable) {
        final didAuthenticate = await _localAuthentication.authenticate(
          localizedReason: 'Authenticate to access your secure notes',
        );

        if (didAuthenticate) {
          // Authentication successful, navigate to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NotesIndexPage()),
          );
        }
      } else {
        // Biometrics not available on the device
        // Handle accordingly, e.g., show a fallback authentication method
      }
    } catch (e) {
      print('Error during biometric authentication: $e');
    }
  }

  Future<void> signInWithGoogle(context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final OAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(googleAuthCredential);

        // Check if the user exists in Firestore
        bool userExists = await checkUserExists(userCredential.user!.uid);

        GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

        // Store additional user info including display name
        storeAdditionalUserInfo(userCredential.user!);

        if (userExists) {
          // User already exists, navigate to the home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NotesIndexPage()),
          );
        } else {
          // User is signing in for the first time, navigate to additional info page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdditionalInfoPage(
                user: userCredential.user!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> storeAdditionalUserInfo(User user) async {
    GoogleSignInAccount? googleSignInAccount = googleSignIn.currentUser;

    if (googleSignInAccount != null) {
      // User is signed in with Google
      String? displayName = googleSignInAccount.displayName;
      String? email = googleSignInAccount.email;

      // Store user info in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'username': displayName,
        'timestamp': DateTime.now(),
        // Add more fields as needed
      });

    } else {
      // User is not signed in with Google
      if (kDebugMode) {
        print('User is not signed in with Google');
      }
    }
  }

  Future<bool> checkUserExists(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userId)
          .get();

      return snapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user existence: $e');
      }
      return false;
    }
  }

  Future<void> signUp(context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Successfully signed up with email and password
      storeAdditionalUserInfo(userCredential.user!);

      // Navigate to home page or another screen upon successful sign up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotesIndexPage()),
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

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
        backgroundColor: Colors.red, // Customize the background color
        duration: const Duration(seconds: 3), // Adjust the duration as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Center(child: Text('Login Page', style: TextStyle(color: Colors.blue.shade600),)),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Welcome Back,\nYou've been missed!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
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
                          borderSide: BorderSide(color: Colors.black)),
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
                          // Toggle the password visibility
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                    onPressed: _isLoading ? null : () => login(context),
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
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => signInWithGoogle(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7b0323),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google.png',
                              width: 35, // Adjust the width as needed
                              height: 35, // Adjust the height as needed
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 18),
                            const Text(
                              'Login with Google',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
                              Animation animation,
                              Animation secondaryAnimation) {
                            return const SignUpPage();
                          }, transitionsBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation,
                              Widget child) {
                            return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0,
                                      sigmaY:
                                          10.0), // Adjust the blur intensity
                                  child: ClipRect(
                                    child: child,
                                  ),
                                ));
                          }),
                          result: (Route route) => false);
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
