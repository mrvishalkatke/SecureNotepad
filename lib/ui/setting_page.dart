import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_notepad/ui/contact_support.dart';
import 'package:secure_notepad/ui/edit_password.dart';
import 'package:secure_notepad/ui/edit_profile.dart';
import 'package:secure_notepad/ui/faq_page.dart';
import 'package:secure_notepad/ui/login_page.dart';
import 'package:secure_notepad/ui/privacy_policy_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  __SettingsPageState createState() => __SettingsPageState();
}

class __SettingsPageState extends State<SettingsPage> {
  late User? _user;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late Stream<QuerySnapshot>? firestoreDb;
  late FirebaseFirestore firebaseDb;
  late File _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    firebaseDb = FirebaseFirestore.instance;
    usernameController = TextEditingController();
    emailController = TextEditingController();

    if (_user != null) {
      firestoreDb = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('accountDetails')
          .snapshots();
    }
    _fetchUserData();
    _loadProfilePicture();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        // Fetch additional user details from Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_user!.uid)
                .collection('accountDetails')
                .doc('info') // Specify the document ID based on your structure
                .get();

        if (snapshot.exists) {
          setState(() {
            usernameController.text = snapshot.data()!['username'] ?? '';
            emailController.text = snapshot.data()!['email'] ?? '';
            _imageUrl = snapshot.data()!['profilePictureUrl'];
            _saveProfilePictureUrl(_imageUrl);
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching user data: $e');
        }
      }
    }
  }

  Future<void> _loadProfilePicture() async {
    // Load profile picture URL from local storage
    _imageUrl = await _getProfilePictureUrl();
    setState(() {});
  }

  Future<void> _saveProfilePictureUrl(String? url) async {
    // Save profile picture URL locally
    // Example: You can use shared preferences or another local storage solution
    // Here, let's assume you have a method named _saveImageUrl
    await _saveImageUrl(url);
  }

  Future<String?> _getProfilePictureUrl() async {
    // Retrieve profile picture URL from local storage
    // Example: You can use shared preferences or another local storage solution
    // Here, let's assume you have a method named _getImageUrl
    return await _getImageUrl();
  }

  Future<void> _saveImageUrl(String? url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture_url', url ?? '');
  }

  Future<String?> _getImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_picture_url');
  }

  Future<void> _uploadProfilePicture() async {
    // Upload profile picture to Firebase Storage
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile =
            File(pickedFile.path); // Assign picked file path to _imageFile
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(user.uid);
        UploadTask uploadTask =
            storageRef.putFile(_imageFile); // Use _imageFile here

        await uploadTask.whenComplete(() async {
          String downloadUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('accountDetails')
              .doc('info')
              .set({'profilePictureUrl': downloadUrl}, SetOptions(merge: true));
          setState(() {
            _imageUrl = downloadUrl;
            _saveProfilePictureUrl(
                downloadUrl); // Save profile picture URL locally
          });
        });
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.left,
        ),
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20.0, top: 5),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (BuildContext context, Animation animation,
                      Animation secondaryAnimation) {
                    return const LoginPage();
                  },
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        backgroundColor: const Color(0xff0056FF),
      ),
      backgroundColor: const Color(0xff0056FF),
      body: _user != null
          ? StreamBuilder<QuerySnapshot>(
              stream: firestoreDb,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                          valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                          strokeWidth: 3));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  if (kDebugMode) {
                    print('No data found in snapshot: ${snapshot.data}');
                  }
                  return const Text(
                    'No data found.',
                    style: TextStyle(color: Colors.white),
                  );
                } else {
                  var userData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;

                  return Container(
                    color: const Color(0xff0056FF),
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        const SizedBox(height: 25.0),
                        Column(
                          children: [
                            const SizedBox(height: 10.0),
                            _buildProfilePictureSection(),
                            const SizedBox(height: 10.0),
                            Text(
                              '${userData['firstName']} ${userData['lastName']}'
                                  .toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 25.0, color: Colors.white),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              '${userData['additionalInfo']}',
                              style: const TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30.0),
                        _buildSectionHeader('Account Details'),
                        TextButton(
                          onPressed: () async {
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(user: user),
                                ),
                              );
                            }
                          },
                          child: _buildTappableButton('Edit Profile', () {
                            // Handle onTap for 'Edit Profile'
                          }),
                        ),
                        TextButton(
                          onPressed: () async {
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangePasswordPage(user: user),
                                ),
                              );
                            }
                          },
                          child: _buildTappableButton('Change Password', () {
                            // Handle onTap for 'Edit Profile'
                          }),
                        ),
                        const SizedBox(height: 16.0),
                        _buildSectionHeader('Privacy Policy'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyPage()),
                            );
                          },
                          child: _buildTappableButton('Privacy & Security', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyPage()),
                            );
                          }),
                        ),
                        const SizedBox(height: 16.0),
                        _buildSectionHeader('Help'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FAQPage()),
                            );
                          },
                          child: _buildTappableButton('FAQ', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FAQPage()),
                            );
                          }),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactSupportPage()),
                            );
                          },
                          child: _buildTappableButton('Contact Support', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactSupportPage()),
                            );
                          }),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  );
                }
              },
            )
          : const Text('User not logged in'),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 110,
              backgroundColor: Colors.white,
              backgroundImage: _imageUrl != null
                  ? NetworkImage(_imageUrl!)
                  : const AssetImage('assets/profile.png')
                      as ImageProvider<Object>,
            ),
            if (_imageUrl == null)
              const Positioned.fill(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 7,
                ),
              ),
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff040E24),
                    border: Border(
                        top: BorderSide(),
                        left: BorderSide(),
                        bottom: BorderSide(),
                        right: BorderSide())),
                child: IconButton(
                  onPressed: _uploadProfilePicture,
                  icon: const Icon(
                    Icons.edit,
                    size: 35,
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTappableButton(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.normal),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
