import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:share_plus/share_plus.dart';

class BookmarkedNotesPage extends StatefulWidget {
  final String currentUserUid;

  const BookmarkedNotesPage({super.key, required this.currentUserUid});

  @override
  _BookmarkedNotesPageState createState() => _BookmarkedNotesPageState();
}

class _BookmarkedNotesPageState extends State<BookmarkedNotesPage> {
  bool isLoading = false;
  late String currentUserUid;
  late bool isLiked;
  late bool isBookmarked;
  late Map<String, bool> isLikedMap = {};
  late Map<String, bool> isBookmarkedMap = {};
  String? currentUserProfilePictureUrl;
  late TextEditingController commentController = TextEditingController();
  String? get noteId => noteId;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    isLiked = false;
    isBookmarked = false;
    isLikedMap = {};
    isBookmarkedMap = {};
    commentController = TextEditingController();
    _fetchNoteStatuses();
    _fetchCurrentUserProfilePicture();
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<void> addComment(
      BuildContext context, String noteId, String commentText) async {
    try {
      // Get the current user's information
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('accountDetails')
          .doc('info')
          .get();

      String firstName =
          userSnapshot.exists ? userSnapshot.get('firstName') : '';
      String lastName = userSnapshot.exists ? userSnapshot.get('lastName') : '';

      // Add the comment to the 'comments' subcollection under the note
      await FirebaseFirestore.instance
          .collection('shared_notes')
          .doc(noteId)
          .collection('comments')
          .add({
        'userId': currentUserUid,
        'firstName': firstName,
        'lastName': lastName,
        'comment': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Optionally, you can show a confirmation message
      // or update the UI to display the new comment.
    } catch (error) {
      if (kDebugMode) {
        print('Error adding comment: $error');
      }
    }
  }

  void submitComment(String noteId, String commentText) {
    addComment(context, noteId, commentText);
    commentController.clear();
  }

  void _showFloatingCommentPage(BuildContext context, String noteId) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xff040E24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: currentUserProfilePictureUrl !=
                                    null
                                ? NetworkImage(currentUserProfilePictureUrl!)
                                : null,
                            child: currentUserProfilePictureUrl == null
                                ? const Icon(
                                    Icons.account_circle,
                                    size: 40,
                                  )
                                : null,
                          ),
                          TextField(
                            controller: commentController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: 'Add Comment...',
                              labelStyle:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              contentPadding: EdgeInsets.only(left: 60),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Adjust the value to change the roundness
                                color: Color(0xff040E24), // Container color
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // Get the text from the TextField
                                  String commentText = commentController.text;
                                  // Check if the comment is not empty
                                  if (commentText.isNotEmpty) {
                                    // Call the addComment function
                                    addComment(context, noteId, commentText);
                                    // Clear the TextField
                                    commentController.clear();
                                  }
                                },
                                icon: const Icon(Icons.send_sharp, color: Colors.white,),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('shared_notes')
                              .doc(noteId)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final comments = snapshot.data!.docs;

                            if (comments.isEmpty) {
                              return const Text(
                                'No comments',
                                style: TextStyle(color: Colors.white),
                              );
                            }
                            return ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                final commenterFirstName = comment['firstName'];
                                final commenterLastName = comment['lastName'];
                                final commentText = comment['comment'];

                                return ListTile(
                                  title: Text(
                                    '$commenterFirstName $commenterLastName',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    commentText,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection("shared_notes")
          .doc(postId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Note has been deleted!!',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.white,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting post: $error');
      }
    }
  }

  void _fetchCurrentUserProfilePicture() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('accountDetails')
          .doc('info')
          .get();

      setState(() {
        currentUserProfilePictureUrl = userSnapshot.get('profilePictureUrl');
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching profile picture: $error');
      }
    }
  }

  Future<void> _fetchNoteStatuses() async {
    try {
      // Fetch all liked documents for each note
      final likedSnapshot =
          await FirebaseFirestore.instance.collection('shared_notes').get();

      // Fetch all bookmarked documents for each note
      final bookmarkedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('bookmarked')
          .get();

      // Initialize maps to store liked and bookmarked statuses
      Map<String, bool> updatedLikedMap = {};
      Map<String, bool> updatedBookmarkedMap = {};

      // Fetch liked status for each note
      for (final noteDoc in likedSnapshot.docs) {
        final noteId = noteDoc.id;
        final likeSnapshot = await FirebaseFirestore.instance
            .collection('shared_notes')
            .doc(noteId)
            .collection('likes')
            .doc(currentUserUid)
            .get();
        final isLiked = likeSnapshot.exists ? likeSnapshot['isLiked'] : false;
        updatedLikedMap[noteId] = isLiked;
      }

      // Fetch bookmarked status for each note
      for (final noteDoc in bookmarkedSnapshot.docs) {
        final noteId = noteDoc.id;
        final bookmarkedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('bookmarked')
            .doc(noteId)
            .get();
        final isBookmarked = bookmarkedSnapshot.exists
            ? bookmarkedSnapshot['isBookmarked']
            : false;
        updatedBookmarkedMap[noteId] = isBookmarked;
      }

      // Update the state with the new liked and bookmarked status maps
      setState(() {
        isLikedMap = updatedLikedMap;
        isBookmarkedMap = updatedBookmarkedMap;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching note statuses: $error');
      }
    }
  }

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getBookmarkedNotesStream(
      String currentUserUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('bookmarked')
        .where('isBookmarked', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<String> noteIds = snapshot.docs.map((doc) => doc.id).toList();
      final List<DocumentSnapshot<Map<String, dynamic>>> bookmarkedNotes = [];

      for (final noteId in noteIds) {
        try {
          final noteSnapshot = await FirebaseFirestore.instance
              .collection('shared_notes')
              .doc(noteId)
              .get();
          if (noteSnapshot.exists) {
            bookmarkedNotes.add(noteSnapshot);
          }
        } catch (error) {
          if (kDebugMode) {
            print('Error fetching note: $error');
          }
        }
      }

      return bookmarkedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Saved Notes',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0.1),
          child: StatefulBuilder(builder: (context, setState) {
            return Card(
              color: const Color(0xff0056FF),
              child:
                  StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                stream: getBookmarkedNotesStream(currentUserUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No bookmarked notes found.'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(1),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var note = snapshot.data![index];
                          final title = note['title'].toString();
                          final notes =
                              capitalizeFirstLetter(note['notes'].toString());
                          note.data();

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(note['userId'])
                                .collection('accountDetails')
                                .doc('info')
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                isLoading = true;
                                return const Center(
                                  child: LinearProgressIndicator(
                                    minHeight: 1,
                                    backgroundColor: Colors.black,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              isLoading = false;

                              final ownerFirstName =
                                  snapshot.data!.get('firstName').toString();
                              final ownerLastName =
                                  snapshot.data!.get('lastName').toString();
                              final ownerPicture =
                                  snapshot.data!.get('profilePictureUrl');

                              return Card(
                                color: const Color(0xff040E24),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6.0, top: 6.0),
                                    child: Row(
                                      children: [
                                        Stack(children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: ownerPicture !=
                                                    null
                                                ? NetworkImage(ownerPicture!)
                                                : const AssetImage(
                                                        'assets/profile.png')
                                                    as ImageProvider<Object>,
                                            backgroundColor: Colors.white,
                                          ),
                                          if (ownerPicture == null)
                                            const Positioned.fill(
                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.black,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                                strokeWidth: 3,
                                              ),
                                            ),
                                        ]),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$ownerFirstName $ownerLastName'
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 1.0),
                                                child: Text(
                                                  title, // Display uppercase title
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (note['userId'] == currentUserUid)
                                          // Inside the ListView.builder itemBuilder method
                                          IconButton(
                                            onPressed: () {
                                              if (note['userId'] ==
                                                  currentUserUid) {
                                                // If the current user is the owner, show the delete confirmation dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Delete Note',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to delete this note?',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context); // Close dialog
                                                          },
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            // Delete the post
                                                            deletePost(note.id);
                                                            Navigator.pop(
                                                                context); // Close dialog
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            icon: Icon(
                                              note['userId'] == currentUserUid
                                                  ? Icons
                                                      .delete_outline // If owner, show delete icon
                                                  : isLiked
                                                      ? Icons.favorite
                                                      : Icons
                                                          .favorite_border, // If not owner, show like icon
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Divider(color: Colors.white),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, bottom: 10.0),
                                          child: Text(
                                            notes,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    DateFormat('hh:mm:ss a')
                                                        .format(
                                                      (note['timestamp']
                                                              as Timestamp)
                                                          .toDate(),
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('EEEE, MMM d, y')
                                                        .format(
                                                      (note['timestamp']
                                                              as Timestamp)
                                                          .toDate(),
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(color: Colors.white),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                IconButton(
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Icon(
                                                      isLikedMap[note.id] ??
                                                              false // Get the like status for this specific note
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: isLikedMap[
                                                                  note.id] ??
                                                              false // Get the like status for this specific note
                                                          ? Colors.red
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    toggleLikedStatus(
                                                      note.id,
                                                      isLikedMap[note.id] ??
                                                          false,
                                                      (bool
                                                          currentLikedStatus) {
                                                        setState(() {
                                                          isLikedMap[note.id] =
                                                              currentLikedStatus;
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    _showFloatingCommentPage(
                                                        context, note.id);
                                                  },
                                                  icon: const Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                        Icons.comment_outlined,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    // Generate the text content of the note to be shared
                                                    String noteContent =
                                                        "$ownerFirstName $ownerLastName\n"
                                                        "Title: $title\nNote: $notes";
                                                    // Share the note content using the share package
                                                    Share.share(
                                                      noteContent,
                                                      subject: 'Shared Note',
                                                      // Optionally specify the share position
                                                      sharePositionOrigin:
                                                          const Rect.fromLTWH(
                                                              0, 0, 100, 100),
                                                    );
                                                  },
                                                  icon: const Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(Icons.send,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    toggleBookmarkedStatus(
                                                      note.id,
                                                      isBookmarkedMap[
                                                              note.id] ??
                                                          false,
                                                      (bool
                                                          currentBookmarkedStatus) {
                                                        setState(() {
                                                          isBookmarkedMap[
                                                                  note.id] =
                                                              currentBookmarkedStatus;
                                                        });
                                                      },
                                                    );
                                                  },
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Icon(
                                                      isBookmarkedMap[
                                                                  note.id] ??
                                                              false
                                                          ? Icons.bookmark
                                                          : Icons
                                                              .bookmark_border,
                                                      color: isBookmarkedMap[
                                                                  note.id] ??
                                                              false
                                                          ? Colors.white
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> toggleLikedStatus(String noteId, bool currentLikedStatus,
      Function(bool) updateLikedStatus) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('accountDetails')
          .doc('info')
          .get();

      String firstName =
          userSnapshot.exists ? userSnapshot.get('firstName') : '';
      String lastName = userSnapshot.exists ? userSnapshot.get('lastName') : '';

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Check if the user has already liked the note
      DocumentReference likeRef = FirebaseFirestore.instance
          .collection('shared_notes')
          .doc(noteId)
          .collection('likes')
          .doc(userId);

      // Toggle the like status
      if (currentLikedStatus) {
        // If already liked, remove the like
        await likeRef.set({
          'isLiked': false,
          'firstName': firstName,
          'lastName': lastName,
        });
      } else {
        // If not liked yet, add the like
        await likeRef.set({
          'isLiked': true,
          'firstName': firstName,
          'lastName': lastName,
        });
      }

      // Call the callback function to update the liked status
      updateLikedStatus(!currentLikedStatus);

      // Show a snack-bar with the appropriate message
      final message = !currentLikedStatus ? 'Like Added' : 'Like Removed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.white,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error toggling Like: $error');
      }
    }
  }

  Future<void> toggleBookmarkedStatus(
      String noteId,
      bool currentBookmarkedStatus,
      Function(bool) updateBookmarkedStatus) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('accountDetails')
          .doc('info')
          .get();

      String firstName =
          userSnapshot.exists ? userSnapshot.get('firstName') : '';
      String lastName = userSnapshot.exists ? userSnapshot.get('lastName') : '';

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Check if the user has already liked the note
      DocumentReference bookmarkRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bookmarked')
          .doc(noteId);

      // Toggle the Bookmark status
      if (currentBookmarkedStatus) {
        // If already Bookmark, remove the Bookmark
        await bookmarkRef.set({
          'isBookmarked': false,
          'firstName': firstName,
          'lastName': lastName,
          'noteId': noteId,
          'userId': userId,
        });
      } else {
        // If not Bookmark yet, add the Bookmark
        await bookmarkRef.set({
          'isBookmarked': true,
          'firstName': firstName,
          'lastName': lastName,
          'noteId': noteId,
          'userId': userId,
        });
      }

      // Call the callback function to update the bookmarked status
      updateBookmarkedStatus(!currentBookmarkedStatus);

      // Show a snack-bar with the appropriate message
      final message =
          !currentBookmarkedStatus ? 'Bookmark Added' : 'Bookmark Removed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.white,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error toggling Bookmark: $error');
      }
    }
  }
}
