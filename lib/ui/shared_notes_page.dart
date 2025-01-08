import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:intl/intl.dart" show DateFormat;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_notepad/ui/bookmarked_notes_page.dart';
import 'package:secure_notepad/ui/new_shared_notes_page.dart';
import 'package:share_plus/share_plus.dart';

class SharedNotesIndexPage extends StatefulWidget {
  const SharedNotesIndexPage({super.key});

  @override
  __SharedNotesIndexPageState createState() => __SharedNotesIndexPageState();
}

class __SharedNotesIndexPageState extends State<SharedNotesIndexPage>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController textController;
  late TextEditingController commentController = TextEditingController();
  late String currentUserUid;
  late Map<String, TextEditingController> commentControllers;
  String currentSearchText = '';
  String? currentUserProfilePictureUrl;
  DocumentSnapshot? userInfo;
  DocumentSnapshot? userPicture;
  bool showBookmarkedOnly = false;
  bool isLoading = false;
  late bool isLiked;
  late bool isBookmarked;
  late Map<String, bool> isLikedMap = {};
  late Map<String, bool> isBookmarkedMap = {};
  String? get noteId => noteId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    commentController = TextEditingController();
    commentControllers = {};
    currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    _fetchCurrentUserProfilePicture();
    _fetchLikedStatusForNotes();
    _fetchBookmarkedStatusForNotes();
    _fetchUserInfo();
    isLiked = false;
    isBookmarked = false;
    isLikedMap = {};
    isBookmarkedMap = {};
    if (showBookmarkedOnly) {
      _fetchBookmarkedStatusForNotes();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is disposed
    commentControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  void submitComment(String noteId, String commentText) {
    addComment(context, noteId, commentText);
    commentController.clear();
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
                                color: const Color(0xff040E24), // Container color
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

  Future<void> _fetchLikedStatusForNotes() async {
    try {
      // Fetch all liked documents for each note
      final QuerySnapshot likedSnapshot =
      await FirebaseFirestore.instance.collection('shared_notes').get();

      // Initialize a new map to store liked status
      Map<String, bool> updatedLikedMap = {};

      // Iterate through the liked documents and update updatedLikedMap
      likedSnapshot.docs.forEach((noteDoc) async {
        final noteId = noteDoc.id;
        // Fetch the liked status for the current note
        DocumentSnapshot likeSnapshot = await FirebaseFirestore.instance
            .collection('shared_notes')
            .doc(noteId)
            .collection('likes')
            .doc(currentUserUid)
            .get();
        // Extract the liked status
        if (likeSnapshot.exists) {
          final bool isLiked = likeSnapshot['isLiked'];
          updatedLikedMap[noteId] = isLiked;
        } else {
          updatedLikedMap[noteId] = false;
        }
      });

      // Update the state with the new liked status map
      setState(() {
        isLikedMap = updatedLikedMap;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching liked status: $error');
      }
    }
  }

  Future<void> _fetchBookmarkedStatusForNotes() async {
    try {
      // Fetch all bookmarked documents for each note
      final QuerySnapshot bookmarkedSnapshot =
      await FirebaseFirestore.instance.collection('shared_notes').get();

      // Initialize a new map to store bookmarked status
      Map<String, bool> updatedBookmarkedMap = {};

      // Iterate through the bookmarked documents and update updatedLikedMap
      for (QueryDocumentSnapshot noteDoc in bookmarkedSnapshot.docs) {
        final String noteId = noteDoc.id;

        // Fetch the bookmarked status for the current note
        DocumentSnapshot bookmarkedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('bookmarked')
            .doc(noteId)
            .get();
        // Extract the bookmarked status
        if (bookmarkedSnapshot.exists) {
          final bool isBookmarked = bookmarkedSnapshot['isBookmarked'];
          updatedBookmarkedMap[noteId] = isBookmarked;
        } else {
          updatedBookmarkedMap[noteId] = false;
        }
      }
      // Update the state with the new liked status map
      setState(() {
        isBookmarkedMap = updatedBookmarkedMap;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching bookmarked status: $error');
      }
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      // Fetch the user's document from the 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userInfoSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .collection('accountDetails')
              .doc('info')
              .get();

      // Check if the document exists before accessing its fields
      if (userInfoSnapshot.exists) {
        setState(() {
          userInfo = userInfoSnapshot; // Store the document snapshot
        });
      } else {
        // Document doesn't exist, handle this case accordingly
        if (kDebugMode) {
          print('User info document does not exist');
        }
        return; // Exit the method if the document doesn't exist
      }

      // Fetch the user's picture document from the 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userPictureSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .collection('accountDetails')
              .doc('info')
              .get();

      // Check if the document exists before accessing its fields
      if (userPictureSnapshot.exists) {
        setState(() {
          userPicture = userPictureSnapshot; // Store the document snapshot
        });
      } else {
        // Document doesn't exist, handle this case accordingly
        if (kDebugMode) {
          print('User picture document does not exist');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user info: $error');
      }
    }
  }

  Future<void>toggleLikedStatus(String noteId,bool currentLikedStatus,
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

  Future<void>toggleBookmarkedStatus(String noteId,bool currentBookmarkedStatus,
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
          'noteId' : noteId,
          'userId' : userId,
        });
      } else {
        // If not Bookmark yet, add the Bookmark
        await bookmarkRef.set({
          'isBookmarked': true,
          'firstName': firstName,
          'lastName': lastName,
          'noteId' : noteId,
          'userId' : userId,
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

  Future<void> addComment(BuildContext context, String noteId,
      String commentText) async {
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

      if (commentText.isEmpty)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please input the comment'),
          ),
        );return;}
      else {
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
      }
      // Optionally, you can show a confirmation message
      // or update the UI to display the new comment.
    } catch (error) {
      if (kDebugMode) {
        print('Error adding comment: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20.0, top: 5),
            icon: Icon(
              showBookmarkedOnly ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarkedNotesPage(currentUserUid: currentUserUid),
                ),
              );
            },
          ),
        ],
        title: const Text(
          'Shared Notepad',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewSharedNotesPage(
                      currentUserUid: currentUserUid,
                    )),
          );
        },
        child: const Icon(
          FontAwesomeIcons.pencil,
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.1),
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      showBookmarkedOnly;
                    });
                  },
                  child: StatefulBuilder(
                      builder: (context, setState) {
                      return Card(
                        color: const Color(0xff0056FF),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: showBookmarkedOnly
                              ? FirebaseFirestore.instance
                                  .collection('bookmarked')
                                  .where('userId', isEqualTo: currentUserUid)
                                  .snapshots()
                                  .asyncMap((snapshot) async {
                                  final noteIds = snapshot.docs
                                      .map((doc) => doc['noteId'])
                                      .toList();
                                  return await FirebaseFirestore.instance
                                      .collection('shared_notes')
                                      .where(FieldPath.documentId, whereIn: noteIds)
                                      .orderBy('timestamp', descending: true)
                                      .get();
                                })
                              : FirebaseFirestore.instance
                                  .collection('shared_notes')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData && snapshot.data != null) {
                              final filteredNotes = snapshot.data!.docs.where((note) {
                                final title = note['title'].toString().toUpperCase();
                                return title.contains(textController.text.toUpperCase());
                              }).toList();

                              return Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: ListView.builder(
                                  itemCount: filteredNotes.length,
                                  itemBuilder: (context, index) {
                                    var note = filteredNotes[index];
                                    final title = note['title'].toString();
                                    final notes = capitalizeFirstLetter(note['notes'].toString());
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        }
                                        isLoading = false;

                                        final ownerFirstName = snapshot.data!.get('firstName').toString();
                                        final ownerLastName = snapshot.data!.get('lastName').toString();
                                        final ownerPicture = snapshot.data!.get('profilePictureUrl');

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
                                                          ? NetworkImage(
                                                              ownerPicture!)
                                                          : const AssetImage(
                                                                  'assets/profile.png')
                                                              as ImageProvider<
                                                                  Object>,
                                                      backgroundColor: Colors.white,
                                                    ),
                                                    if (ownerPicture == null)
                                                      const Positioned.fill(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.black,
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
                                                          padding:
                                                              const EdgeInsets.only(
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
                                                  if (note['userId'] ==
                                                      currentUserUid)
                                                    // Inside the ListView.builder itemBuilder method
                                                    IconButton(
                                                      onPressed: () {
                                                        if (note['userId'] ==
                                                            currentUserUid) {
                                                          // If the current user is the owner, show the delete confirmation dialog
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                  'Delete Note',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                content: const Text(
                                                                  'Are you sure you want to delete this note?',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
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
                                                                      deletePost(
                                                                          note.id);
                                                                      Navigator.pop(
                                                                          context); // Close dialog
                                                                    },
                                                                    child: const Text(
                                                                      'Delete',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
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
                                                        note['userId'] ==
                                                                currentUserUid
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
                                                              DateFormat(
                                                                      'EEEE, MMM d, y')
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.start,
                                                        children: [
                                                          IconButton(
                                                            icon: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Icon(
                                                                isLikedMap[note.id] ??
                                                                        false // Get the like status for this specific note
                                                                    ? Icons.favorite
                                                                    : Icons
                                                                        .favorite_border,
                                                                color: isLikedMap[note
                                                                            .id] ??
                                                                        false // Get the like status for this specific note
                                                                    ? Colors.red
                                                                    : Colors.white,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              toggleLikedStatus(
                                                                note.id,
                                                                isLikedMap[note.id] ?? false,
                                                                    (bool currentLikedStatus) {
                                                                  setState(() {
                                                                    isLikedMap[note.id] = currentLikedStatus;
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
                                                              padding:
                                                                  EdgeInsets.all(5),
                                                              child: Icon(
                                                                  Icons
                                                                      .comment_outlined,
                                                                  color:
                                                                      Colors.white),
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
                                                                subject:
                                                                    'Shared Note',
                                                                // Optionally specify the share position
                                                                sharePositionOrigin:
                                                                    const Rect
                                                                        .fromLTWH(0,
                                                                        0, 100, 100),
                                                              );
                                                            },
                                                            icon: const Padding(
                                                              padding:
                                                                  EdgeInsets.all(5),
                                                              child: Icon(Icons.send,
                                                                  color:
                                                                      Colors.white),
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
                                                                isBookmarkedMap[note.id] ?? false,
                                                                    (bool currentBookmarkedStatus) {
                                                                  setState(() {
                                                                    isBookmarkedMap[note.id] = currentBookmarkedStatus;
                                                                  });
                                                                },
                                                              );
                                                            },
                                                            icon: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Icon(
                                                                isBookmarkedMap[note.id] ?? false
                                                                    ? Icons.bookmark
                                                                    : Icons
                                                                        .bookmark_border,
                                                                color: isBookmarkedMap[note.id] ?? false
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
                            return const SizedBox();
                          },
                        ),
                      );
                    }
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 15, left: 10, right: 90),
              child: TextFormField(
                controller: textController,
                obscureText: false,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Search notes',
                  hintText: 'Search by title...',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.white),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
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
            ), //Search TextField
          ],
        ),
      ),
    );
  }
}
