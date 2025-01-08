import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secure_notepad/ui/notes_index_page.dart';

class NewNotesPage extends StatefulWidget {
  final String currentUserUid;

  NewNotesPage({required this.currentUserUid});

  @override
  _CreateNotePageState createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<NewNotesPage> {
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
        title: const Text('Create New Note',
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
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
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
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Change the color here
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
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // Change the color here
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            )
                        ),
                        minLines: null,
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
                      saveNote();
                      // Optionally, you can navigate back to the previous page or show a confirmation message
                    },
                    child: const Text('Save Note', style: TextStyle(color: Colors.white, fontSize: 20),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveNote() async {
    if (titleController.text.trim().isEmpty)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please input the title'),
        ),
      );return;}
      else {
        await FirebaseFirestore.instance.collection('notes').add({
      'userId': widget.currentUserUid,
      'title': titleController.text,
      'notes': notesController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });}

    // Clear the text controllers after saving the note
    titleController.clear();
    notesController.clear();

    // Optionally, you can navigate back to the previous page or show a confirmation message
    Navigator.pop(context); // This will close the current page and return to the previous page
  }
}
