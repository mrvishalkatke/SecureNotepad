import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_notepad/ui/contact_support.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Privacy Policy',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRIVACY POLICY',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Last updated March 03, 2024',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'This privacy notice for Cyfo-Tech Pvt. Ltd., describes how and why we might collect, store, use, and/or share ("process") your information when you use our services ("Services"), such as when you:\n\n'
              'Download and use our mobile application (Secure Notepad), or any other application of ours that links to this privacy notice\n'
              'Engage with us in other related ways, including any sales, marketing, or events\n'
              '\n'
              'Questions or concerns? Reading this privacy notice will help you understand your privacy rights and choices. If you do not agree with our policies and practices, please do not use our Services. If you still have any questions or concerns, please contact us at cyfotechcorp@gmail.com.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            _buildSection1('SUMMARY OF KEY POINTS', [
              'What personal information do we process? When you visit, use, or navigate our Services, we may process personal information depending on how you interact with us and the Services, the choices you make, and the products and features you use. Learn more about personal information you disclose to us.',
              'Do we process any sensitive personal information? We do not process sensitive personal information.',
              'Do we receive any information from third parties? We do not receive any information from third parties.',
              'How do we process your information? We process your information to provide, improve, and administer our Services, communicate with you, for security and fraud prevention, and to comply with law. We may also process your information for other purposes with your consent. We process your information only when we have a valid legal reason to do so. Learn more about how we process your information.',
              'In what situations and with which parties do we share personal information? We may share information in specific situations and with specific third parties. Learn more about when and with whom we share your personal information.',
              'How do we keep your information safe? We have organisational and technical processes and procedures in place to protect your personal information. However, no electronic transmission over the internet or information storage technology can be guaranteed to be 100% secure, so we cannot promise or guarantee that hackers, cybercriminals, or other unauthorised third parties will not be able to defeat our security and improperly collect, access, steal, or modify your information. Learn more about how we keep your information safe.',
              'What are your rights? Depending on where you are located geographically, the applicable privacy law may mean you have certain rights regarding your personal information. Learn more about your privacy rights.',
              'How do you exercise your rights? The easiest way to exercise your rights is by submitting a data subject access request, or by contacting us. We will consider and act upon any request in accordance with applicable data protection laws.',
            ]),
            const SizedBox(height: 16.0),
            _buildSection2('TABLE OF CONTENTS', [
              '1. WHAT INFORMATION DO WE COLLECT? - Personal information you disclose to us'
                  '\nIn Short: We collect personal information that you provide to us.'
                  '\nWe collect personal information that you voluntarily provide to us when you register on the Services, express an interest in obtaining information about us or our products and Services, when you participate in activities on the Services, or otherwise when you contact us.'
                  '\nPersonal Information Provided by You. The personal information that we collect depends on the context of your interactions with us and the Services, the choices you make, and the products and features you use. The personal information we collect may include the following:'
                  '\nnames\nphone numbers\nemail addresses\nusernames\npasswords\ncontact or authentication data\nSensitive Information. We do not process sensitive information.'
                  '\nSocial Media Login Data. We may provide you with the option to register with us using your existing social media account details, like your Facebook, Twitter, or other social media account. If you choose to register in this way, we will collect the information described in the section called "HOW DO WE HANDLE YOUR SOCIAL LOGINS?" below.'
                  '\nApplication Data. If you use our application(s), we also may collect the following information if you choose to provide us with access or permission:'
                  '\nMobile Device Access. We may request access or permission to certain features from your mobile device, including your mobile devices storage, and other features. If you wish to change our access or permissions, you may do so in your devices settings.'
                  '\nThis information is primarily needed to maintain the security and operation of our application(s), for troubleshooting, and for our internal analytics and reporting purposes.'
                  '\nAll personal information that you provide to us must be true, complete, and accurate, and you must notify us of any changes to such personal information.',

              '2. HOW DO WE PROCESS YOUR INFORMATION? - In Short: We process your information to provide, improve, and administer our Services, communicate with you, for security and fraud prevention, and to comply with law. We may also process your information for other purposes with your consent.'
                  '\nWe process your personal information for a variety of reasons, depending on how you interact with our Services, including:'
                  '\nTo facilitate account creation and authentication and otherwise manage user accounts. We may process your information so you can create and log in to your account, as well as keep your account in working order.',

              '3. WHEN AND WITH WHOM DO WE SHARE YOUR PERSONAL INFORMATION? - In Short: We may share information in specific situations described in this section and/or with the following third parties.'
                  '\nWe may need to share your personal information in the following situations:'
                  '\nBusiness Transfers. We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.',

              '4. HOW DO WE HANDLE YOUR SOCIAL LOGINS? - In Short: If you choose to register or log in to our Services using a social media account, we may have access to certain information about you.'
                  '\nOur Services offer you the ability to register and log in using your third-party social media account details (like your Facebook or Twitter logins). Where you choose to do this, we will receive certain profile information about you from your social media provider. The profile information we receive may vary depending on the social media provider concerned, but will often include your name, email address, friends list, and profile picture, as well as other information you choose to make public on such a social media platform.'
                  '\nWe will use the information we receive only for the purposes that are described in this privacy notice or that are otherwise made clear to you on the relevant Services. Please note that we do not control, and are not responsible for, other uses of your personal information by your third-party social media provider. We recommend that you review their privacy notice to understand how they collect, use, and share your personal information, and how you can set your privacy preferences on their sites and apps.',

              '5. HOW LONG DO WE KEEP YOUR INFORMATION? - In Short: We keep your information for as long as necessary to fulfil the purposes outlined in this privacy notice unless otherwise required by law.'
                  '\nWe will only keep your personal information for as long as it is necessary for the purposes set out in this privacy notice, unless a longer retention period is required or permitted by law (such as tax, accounting, or other legal requirements). No purpose in this notice will require us keeping your personal information for longer than the period of time in which users have an account with us.'
                  '\nWhen we have no ongoing legitimate business need to process your personal information, we will either delete or anonymise such information, or, if this is not possible (for example, because your personal information has been stored in backup archives), then we will securely store your personal information and isolate it from any further processing until deletion is possible.',

              '6. HOW DO WE KEEP YOUR INFORMATION SAFE? - In Short: We aim to protect your personal information through a system of organisational and technical security measures.'
                  '\nWe have implemented appropriate and reasonable technical and organisational security measures designed to protect the security of any personal information we process. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure, so we cannot promise or guarantee that hackers, cybercriminals, or other unauthorized third parties will not be able to defeat our security and improperly collect, access, steal, or modify your information. Although we will do our best to protect your personal information, transmission of personal information to and from our Services is at your own risk. You should only access the Services within a secure environment.',

              '7. WHAT ARE YOUR PRIVACY RIGHTS? - In Short:  You may review, change, or terminate your account at any time.'
                  '\nWithdrawing your consent: If we are relying on your consent to process your personal information, which may be express and/or implied consent depending on the applicable law, you have the right to withdraw your consent at any time. You can withdraw your consent at any time by contacting us by using the contact details provided in the section "HOW CAN YOU CONTACT US ABOUT THIS NOTICE?" below.'
                  '\nHowever, please note that this will not affect the lawfulness of the processing before its withdrawal nor, when applicable law allows, will it affect the processing of your personal information conducted in reliance on lawful processing grounds other than consent.'
                  '\nAccount Information'
                  '\nIf you would at any time like to review or change the information in your account or terminate your account, you can:'
                  '\nLog in to your account settings and update your user account.'
                  '\nContact us using the contact information provided.'
                  '\nUpon your request to terminate your account, we will deactivate or delete your account and information from our active databases. However, we may retain some information in our files to prevent fraud, troubleshoot problems, assist with any investigations, enforce our legal terms and/or comply with applicable legal requirements.'
                  '\nIf you have questions or comments about your privacy rights, you may email us at cyfotechcorp@gmail.com.',

              '8. CONTROLS FOR DO-NOT-TRACK FEATURES - Most web browsers and some mobile operating systems and mobile applications include a Do-Not-Track ("DNT") feature or setting you can activate to signal your privacy preference not to have data about your online browsing activities monitored and collected. At this stage no uniform technology standard for recognising and implementing DNT signals has been finalized. As such, we do not currently respond to DNT browser signals or any other mechanism that automatically communicates your choice not to be tracked online. If a standard for online tracking is adopted that we must follow in the future, we will inform you about that practice in a revised version of this privacy notice.',

              '9. DO WE MAKE UPDATES TO THIS NOTICE? - In Short: Yes, we will update this notice as necessary to stay compliant with relevant laws.'
                  '\nWe may update this privacy notice from time to time. The updated version will be indicated by an updated "Revised" date and the updated version will be effective as soon as it is accessible. If we make material changes to this privacy notice, we may notify you either by prominently posting a notice of such changes or by directly sending you a notification. We encourage you to review this privacy notice frequently to be informed of how we are protecting your information.',

              '10. HOW CAN YOU CONTACT US ABOUT THIS NOTICE? - If you have questions or comments about this notice, you may email us at cyfotechcorp@gmail.com or contact us by post at:'
                  '\n     Cyfo-Tech Pvt. Ltd.\n     Hari Om Apartment, Kalewadi\n     Pune, Maharashtra 411017\n     India',

              '11. HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU? - Based on the applicable laws of your country, you may have the right to request access to the personal information we collect from you, change that information, or delete it. To request to review, update, or delete your personal information, please fill out and submit a data subject access request.',
            ]),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactSupportPage()),
                      );
                    },
                    child: const Text(
                      'Contact Us',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection1(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: points
              .map(
                (point) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                point,
                textAlign: TextAlign.justify,
                style: const TextStyle(color: Colors.white), // Set your desired color here
              ),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }


  Widget _buildSection2(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20.0,
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: points.length,
          itemBuilder: (context, index) {
            return ExpansionTile(
              title: Text(
                points[index].split(' - ')[0],
                style: const TextStyle(color: Colors.lightBlueAccent,
                    decoration: TextDecoration.underline,),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(points[index].split(' - ')[1],
                    textAlign: TextAlign.justify,
                    style: const TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
