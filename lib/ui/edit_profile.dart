import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController additionalInfoController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    // Fetch user data for pre-populating fields
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('accountDetails')
          .doc('info')
          .get();

      if (snapshot.exists) {
        setState(() {
          firstNameController.text = snapshot.data()!['firstName'] ?? '';
          lastNameController.text = snapshot.data()!['lastName'] ?? '';
          additionalInfoController.text =
              snapshot.data()!['additionalInfo'] ?? '';
          if (snapshot.data()!['dateOfBirth'] != null) {
            Timestamp timestamp = snapshot.data()!['dateOfBirth'];
            selectedDateOfBirth = timestamp.toDate();
            dateOfBirthController.text =
                DateFormat('dd-MM-yyyy').format(selectedDateOfBirth!);
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
        dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _saveChanges() async {

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        additionalInfoController.text.isEmpty ||
        dateOfBirthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all the details'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('accountDetails')
          .doc('info')
          .update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'additionalInfo': additionalInfoController.text,
        'dateOfBirth': selectedDateOfBirth != null
            ? Timestamp.fromDate(selectedDateOfBirth!)
            : null,
      });

      // Navigate back after saving changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile edited successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error changing password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.left,
        ),
        backgroundColor: const Color(0xff0056FF),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xff0056FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: firstNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Change the color here
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                controller: lastNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Change the color here
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                controller: additionalInfoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Life Motivation',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Change the color here
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                readOnly: true,
                controller: dateOfBirthController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: const TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today,
                    color: Colors.white,),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Change the color here
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
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
                        onPressed: _saveChanges,
                        child: const Text('Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                          ),
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
}
