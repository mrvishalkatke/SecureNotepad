import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secure_notepad/ui/new_notes_page.dart';
import 'package:secure_notepad/ui/setting_page.dart';
import 'package:secure_notepad/ui/notes_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_notepad/ui/shared_notes_page.dart';

class NotesIndexPage extends StatelessWidget {
  const NotesIndexPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return _NotesIndexPage();
  }
}

class _NotesIndexPage extends StatefulWidget {
  @override
  __NotesIndexPageState createState() => __NotesIndexPageState();
}

class __NotesIndexPageState extends State<_NotesIndexPage> {
  late TextEditingController textController;
  late FocusNode focusNode;
  late TextEditingController nameInputController;
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;
  late String currentUserUid;
  var firestoreDb;
  String currentSearchText = '';

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    nameInputController = TextEditingController();
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();

    currentUserUid = '';
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUserUid = user.uid;
          firestoreDb = FirebaseFirestore.instance
              .collection("notes")
              .where('userId', isEqualTo: currentUserUid)
              .orderBy('timestamp', descending: true)
              .snapshots();
        });
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> filterNotesByTitle(
      List<DocumentSnapshot> notes,
      String searchText,
      ) {
    return notes.where((note) {
      final title = note['title'].toString().toLowerCase();
      return title.contains(searchText.toLowerCase());
    }).toList();
  }

  Future<void> shareNote(DocumentSnapshot note) async {
    try {
      // Get the current user's ID
      String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserUid != null) {
        // Get the reference to the "shared_notes" collection
        CollectionReference sharedNotesCollection =
        FirebaseFirestore.instance.collection('shared_notes');

        // Fetch the user's document from the 'users' collection
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('accountDetails')
            .doc('info')
            .get();

        // Extract the first name and last name from the user's document
        String firstName = userSnapshot.exists ? userSnapshot.get('firstName') : '';
        String lastName = userSnapshot.exists ? userSnapshot.get('lastName') : '';
        String profilePicture = userSnapshot.exists ? userSnapshot.get('profilePictureUrl') : '';

        // Create a duplicate note in the "shared_notes" collection
        await sharedNotesCollection.add({
          'title': note['title'],
          'notes': note['notes'],
          'userId': currentUserUid,
          'firstName': firstName,
          'lastName': lastName,
          'profilePictureUrl' : profilePicture,
          'timestamp': Timestamp.now(),
          'isBookmarked': false,
          // You may need to add other fields based on your requirements
        });
      } else {
        print('Current user not found');
      }
    } catch (e) {
      print('Error sharing note: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 20.0,
        title: const Text(
          'Secure Notepad',
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
            padding: const EdgeInsets.only(right: 20.0, top: 5),
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 20.0, top: 5),
            icon: const Icon(
              Icons.people_alt_outlined,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SharedNotesIndexPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xff0056FF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewNotesPage(currentUserUid: currentUserUid)));
        },
        child: const Icon(
          FontAwesomeIcons.pencil,
          color: Color(0xff0056FF),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
              child: TextFormField(
                controller: textController,
                focusNode: focusNode,
                obscureText: false,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Search notes',
                  hintText: 'Search by title...',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textController.clear();
                        setState(() {});
                      },
                      color: Colors.white,
                    ),
                  ),
                ),
                onChanged: (searchText) {
                  setState(() {
                    currentSearchText = searchText;
                  }); // Trigger a rebuild when the search text changes
                },
              ),
            ), //Search Box
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.1),
                child: Card(
                  color: const Color(0xff0056FF),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: textController.text.isEmpty
                          ? firestoreDb
                          : FirebaseFirestore.instance
                          .collection("notes")
                          .where('userId', isEqualTo: currentUserUid)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 1.3,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  backgroundColor: Colors.black,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.blueAccent),
                                  strokeWidth: 3),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          final filteredNotes = textController.text.isEmpty
                              ? snapshot.data!.docs
                              : filterNotesByTitle(snapshot.data!.docs, textController.text);

                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ListView.builder(
                              itemCount: filteredNotes.length,
                              itemBuilder: (context, int index) {
                                var timestamp = snapshot.data!.docs[index]['timestamp'];
                                // Add a null check for timestamp
                                if (timestamp == null || !(timestamp is Timestamp)) {
                                  return const SizedBox(); // or a placeholder widget
                                }
                                var timeToDate =
                                DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
                                var dateFormatted =
                                    DateFormat("EEEE, MMM d, y").format(timeToDate);
                                var timeFormatted =
                                    DateFormat("hh:mm:ss a").format(timeToDate);
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.blueAccent),
                                      strokeWidth: 3);
                                }
                                return Card(
                                  color: const Color(0xff040E24),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0, bottom: 8),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            filteredNotes[index]['title'].toString(),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              // Show confirmation dialog
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Share Note', style: TextStyle(color: Colors.white),),
                                                    content: const Text('Are you sure you want to share this note?', style: TextStyle(color: Colors.white),),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // Close dialog
                                                        },
                                                        child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          // Share note
                                                          shareNote(filteredNotes[index]);
                                                          Navigator.pop(context); // Close dialog
                                                        },
                                                        child: const Text('Share', style: TextStyle(color: Colors.white),),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.share_outlined, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              dateFormatted,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              timeFormatted,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          ]
                                      ),
                                      // Add your onTap logic for each note,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => NoteDetailPage(
                                                noteId:
                                                filteredNotes[index].id),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      }),
                ),
              ),
            ), //Notes List View
          ],
        ),
      ),
    );
  }
}
