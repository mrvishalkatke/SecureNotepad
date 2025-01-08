import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0056FF),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text('FAQ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.left,
        ),
        backgroundColor: Color(0xff0056FF),
        elevation: 0,
      ),
      body: ListView(
        children: _buildFAQList(),
      ),
    );
  }

  List<Widget> _buildFAQList() {
    return [
      _buildExpansionTile(
        'What is Secure Notepad?',
        'Secure Notepad is a versatile [brief description of your app\'s main purpose or features].',
      ),
      _buildExpansionTile(
        'How do I download and install the app?',
        'To download and install Secure Notepad, follow these steps:\n- For iOS: [Provide instructions for iOS users]\n- For Android: [Provide instructions for Android users]',
      ),
      _buildExpansionTile(
        'How do I create an account?',
        'Follow these simple steps to create an account on [Your App Name]:\n- [Step 1]\n- [Step 2]\n- [Step 3]',
      ),
      _buildExpansionTile(
        'I forgot my password. How can I reset it?',
        'If you\'ve forgotten your password, you can reset it easily by following these steps:\n- [Include password reset process]',
      ),
      _buildExpansionTile(
        'Can I use Secure Notepad on multiple devices?',
        'Yes, [Your App Name] supports usage on multiple devices simultaneously. [Specify any restrictions if applicable]',
      ),
      _buildExpansionTile(
        'How do I change my profile information?',
        'To update your profile information:\n- [Step 1]\n- [Step 2]\n- [Step 3]',
      ),
      _buildExpansionTile(
        'Is Secure Notepad available in multiple languages?',
        '[Your App Name] currently supports [List of supported languages]. We are actively working to add more languages in the future.',
      ),
      _buildExpansionTile(
        'What should I do if I encounter a bug or issue?',
        'If you come across any bugs or issues, please report them to our support team through [Specify the reporting channel].',
      ),
      _buildExpansionTile(
        'How can I contact customer support?',
        'For customer support, you can reach out to us via:\n- Email: [Your support email]\n- Phone: [Your support phone number]\n- [Include any other relevant contact information]',
      ),
      _buildExpansionTile(
        'What security measures does [Your App Name] have in place?',
        'Secure Notepad prioritizes the security of your data. We implement [Briefly describe security features].',
      ),
      _buildExpansionTile(
        'Can I use Secure Notepad offline?',
        'Yes, Secure Notepad supports offline usage. However, some features may be limited in offline mode.',
      ),
      _buildExpansionTile(
        'How are updates handled in [Your App Name]?',
        'We regularly release updates to enhance user experience. You can receive updates through [Specify update mechanism].',
      ),
      _buildExpansionTile(
        'Are there any subscription plans or in-app purchases?',
        'Secure Notepad offers [Specify subscription plans or in-app purchases if applicable]. Check our pricing page for details.',
      ),
      _buildExpansionTile(
        'How can I delete my account?',
        'To delete your account:\n- [Include account deletion process]\n- Note: [Specify any consequences of account deletion]',
      ),
      _buildExpansionTile(
        'Where can I find the app\'s terms of service and privacy policy?',
        'You can find our terms of service [here](link) and privacy policy [here](link). Please review them as they are crucial for using [Your App Name].',
      ),
    ];
  }

  Widget _buildExpansionTile(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
