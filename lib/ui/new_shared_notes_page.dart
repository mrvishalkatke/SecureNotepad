import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewSharedNotesPage extends StatefulWidget {
  final String currentUserUid;

  const NewSharedNotesPage({super.key, required this.currentUserUid});

  @override
  __CreateNotePageState createState() => __CreateNotePageState();
}

class __CreateNotePageState extends State<NewSharedNotesPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // This is true by default
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color here
        ),
        centerTitle: false,
        titleSpacing: 20.0,
        title: const Text(
          'Create New Note',
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
      backgroundColor: const Color(0xff0056FF),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight : Radius.circular(10),
              topLeft : Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Color(0xff0056FF),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: TextField(
                      controller: titleController,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.white), // Change the color here
                        ),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)
                          )
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                      child: TextField(
                        controller: notesController,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                        maxLines: null, // Allow multiple lines
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white), // Change the color here
                          ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            )
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight : Radius.circular(10),
                      topLeft : Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Color(0xff040E24),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xff040E24),
                    ),
                    onPressed: () {
                      // Save the note to Firestore
                      shareNote(context);
                      // Optionally, you can navigate back to the previous page or show a confirmation message
                    },
                    child: const Text(
                      'Share Note',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> shareNote(BuildContext context) async {
    // Get the current user's UID
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the user's document from the 'users' collection
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('accountDetails')
        .doc('info')
        .get();

    // Extract the user's first name and last name
    String firstName = userSnapshot.exists ? userSnapshot.get('firstName') : '';
    String lastName = userSnapshot.exists ? userSnapshot.get('lastName') : '';
    String profilePicture =
    userSnapshot.exists ? userSnapshot.get('profilePictureUrl') : '';

    // Add the note to the 'shared_notes' collection with user information
    await FirebaseFirestore.instance.collection('shared_notes').add({
      'userId': currentUserUid,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePicture,
      'title': titleController.text,
      'notes': notesController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Clear the text controllers after saving the note
    titleController.clear();
    notesController.clear();

    // Optionally, you can navigate back to the previous page or show a confirmation message
    Navigator.pop(
        context); // This will close the current page and return to the previous page
  }
}
