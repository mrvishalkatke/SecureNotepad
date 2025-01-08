# Secure Notepad Android Application

## Project Overview

The **Secure Notepad** Android application is designed to provide users with a secure and user-friendly platform to store, manage, and share their important notes. The application uses Firebase as the backend for storing user notes and implements SHA-256 encryption to ensure that the notes are securely stored. The application allows users to share their notes with trusted contacts and also provides functionalities such as liking, commenting, and saving notes for easy access.

## Features

### 1. User Authentication
- **Login and Sign-Up**: Users can register and log in using their email address or via Google authentication.
- **Email Verification**: Upon signing up, users are required to verify their email address through a verification link sent to their email.

### 2. Home Page
- Displays a list of notes with titles, creation timestamps, and a share icon.
- Users can add new notes by providing a title and description, which are saved and displayed in real-time on the home page.

### 3. Note Management
- **Edit and Delete Notes**: Users can open, edit, or delete their existing notes.
- **Real-Time Updates**: Any changes made to the notes are updated immediately and reflected across the app.

### 4. Shared Notepad
- Users can share their notes with trusted contacts.
- Shared notes can be liked, commented on, and saved by other users.
- The shared notes section fosters collaboration, allowing users to interact with notes from other trusted users.

### 5. Saved Notes
- Users can save notes for later reference.
- The saved notes are displayed in a separate section, sorted by the time they were saved.

### 6. Security Features
- **SHA-256 Encryption**: Notes are encrypted using the SHA-256 algorithm before being stored in Firebase, ensuring that sensitive information is protected.
- **Firebase Authentication**: User login and account management are handled securely using Firebase Authentication.

## Penetration Testing

As part of the development process, the application underwent thorough penetration testing, including:
- **Black Box Testing**: External testing of the application to identify vulnerabilities without access to the source code.
- **White Box Testing**: Internal testing of the application to identify vulnerabilities within the code.
- **Page-wise Testing**: Each page of the app was carefully tested for security risks, ensuring that all user data and interactions were protected.
- **Dynamic and Static Analysis**: Both dynamic and static testing methods were applied to identify and fix vulnerabilities.

## Technology Stack
- **Frontend**: Flutter, Dart
- **Backend**: Firebase (Authentication, Firestore Database)
- **Encryption**: SHA-256
- **Authentication**: Firebase Authentication, Google Sign-In

## Future Improvements
- **Multi-Language Support**: Adding support for multiple languages to make the app accessible to a wider audience.
- **Advanced Sharing Features**: Introduce additional sharing functionalities such as sharing notes with groups.
- **Offline Mode**: Implement an offline mode to allow users to create, edit, and view notes without an internet connection.
- **Enhanced Security**: Adding more robust security features like two-factor authentication (2FA) and end-to-end encryption.
