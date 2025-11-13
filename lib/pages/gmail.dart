import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'get_started.dart'; // your existing GetStarted page

import 'homepet.dart'; // your existing Home page


class GmailLogin extends StatelessWidget {
  const GmailLogin({Key? key}) : super(key: key);

  void _goBackToGetStarted(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GetStarted()),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Homepet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _goBackToGetStarted(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.lock, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "accounts.google.com",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _goBackToGetStarted(context),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Gap(12),

            // 🔹 Google Sign-in Header
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/svg/google_logo.svg', height: 24),
                  const Gap(8),
                  const Text(
                    "Sign in with Google",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // 🔹 Account Selection Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    "Choose an account",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  const Text(
                    "to continue to PawGoda",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  ),
                  const Gap(20),

                  // 🔹 Email accounts
                  GestureDetector(
                    onTap: () => _goToHome(context), // Go to Home when tapped
                    child: _accountTile("P", "Personal Account",
                        "personal@email.com",
                        signedOut: false),
                  ),
                  _accountTile("W", "Work Account", "work@email.com",
                      signedOut: true),

                  const ListTile(
                    leading: Icon(Icons.person_add_outlined),
                    title: Text("Use another account"),
                  ),
                  const Divider(),
                  const Gap(10),

                  // 🔹 Info text
                  const Text(
                    "To continue, Google shares your name, email address, language preference, and profile picture with PawGoda. Before using this app, you can review PawGoda’s privacy policy and terms of service.",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(10),
                  const Text("English (United States)",
                      style:
                          TextStyle(fontSize: 13, color: Colors.black54)),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Help  •  Privacy  •  Terms",
                          style: TextStyle(
                              fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountTile(String initial, String name, String email,
      {bool signedOut = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(
            initial,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: signedOut
            ? const Text("Signed out", style: TextStyle(color: Colors.black45))
            : null,
      ),
    );
  }
}
