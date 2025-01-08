import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController titleController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    notesController = TextEditingController();
    loadNoteDetails();
  }

  Future<void> loadNoteDetails() async {
    try {
      // Fetch the existing note from Firestore using the provided noteId
      DocumentSnapshot<Map<String, dynamic>> noteSnapshot =
          await FirebaseFirestore.instance
              .collection('notes')
              .doc(widget.noteId)
              .get();

      // Update the text controllers with the existing note details
      titleController.text = noteSnapshot['title'];
      notesController.text = noteSnapshot['notes'];
    } catch (e) {
      // Handle any errors, e.g., note not found
      if (kDebugMode) {
        print('Error loading note: $e');
      }
    }
  }

  Future<void> deleteNote() async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white),),
          content: const Text('Are you sure you want to delete this note?', style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () {
                // User clicked 'Cancel'
                Navigator.pop(context, false);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              onPressed: () {
                // User clicked 'Delete'
                Navigator.pop(context, true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
    // Check the result of the confirmation dialog
    if (confirmDelete == true) {
      try {
        // Delete the note from Firestore using the provided noteId
        await FirebaseFirestore.instance.collection('notes').doc(widget.noteId).delete();

        // Optionally, you can navigate back to the previous page or show a confirmation message
        Navigator.pop(context); // This will close the current page and return to the previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting the note'),
            backgroundColor: Colors.red,
          ),
        );
        // Handle any errors
        if (kDebugMode) {
          print('Error deleting note: $e');
        }
      }
    }
  }


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
          'Note Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.left,
        ),
        backgroundColor: const Color(0xff0056FF),
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20.0,),
            icon: const Icon(Icons.delete,
            color: Colors.white,
            size: 30,),
            onPressed: () {
              // Add the logic to delete the note
              deleteNote();
            },
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: const Color(0xff0056FF),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
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
            padding: const EdgeInsets.all(10.0),
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
                      saveNote();
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
    // Get the existing note ID based on the title
    String? existingNoteId = await getNoteId(titleController.text);
    if (existingNoteId != null) {
      // Update the existing note
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(existingNoteId)
          .update({
        'title': titleController.text,
        'notes': notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the text controllers after saving/updating the note
      titleController.clear();
      notesController.clear();

      // Optionally, you can navigate back to the previous page or show a confirmation message
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving the note'),
          backgroundColor: Colors.red,
        ),
      );
      if (kDebugMode) {
        print('Note not found');
      }
    }
  }

  Future<String?> getNoteId(String titleToFind) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('notes').get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      if (doc['title'] == titleToFind) {
        return doc.id;
      }
    }
    return null; // Return null if the note with the specified title is not found
  }
}
