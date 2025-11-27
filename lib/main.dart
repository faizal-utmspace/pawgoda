import 'dart:developer';

import 'package:pawgoda/keys.dart';
import 'package:pawgoda/pages/get_started.dart';
import 'package:pawgoda/pages/home.dart';
import 'package:pawgoda/pages/homepet.dart';
import 'package:pawgoda/pages/staff/home_staff.dart';
import 'package:pawgoda/utils/helpers.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pawgoda/pages/payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Stripe key
  Stripe.publishableKey = StripePublisableKey;
  await Stripe.instance.applySettings();

  // Initialize for web
  if (Firebase.apps.isNotEmpty) {
    FirebaseAuth.instanceFor(app: Firebase.app());
  }


  try {
    final test = await FirebaseFirestore.instance.collection('test').get();
    print('Firestore connected! Found ${test.docs.length} docs.');
  } catch (e) {
    print('Firestore error: $e');
  }

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'PawGoda',
      theme: ThemeData(
          fontFamily: 'Poppins',
          primaryColor: Styles.blackColor,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(primary: Styles.blackColor)),
      // home: const GetStarted(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the currentUser synchronously; load SharedPreferences asynchronously
    // and decide the initial screen via FutureBuilder.
    final user = FirebaseAuth.instance.currentUser;
    final userData = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    return FutureBuilder<DocumentSnapshot>(
      future: userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (user != null && snapshot.hasData) {
            final data = snapshot.data!.data();
            final role = data is Map<String, dynamic> ? data['role'] as String? : null;

            log(  'User role: $role'  );
            if (role == 'staff') {
              return const HomeStaffPage();
            } else {
              return const Homepet();
            }
          } else {
            return const GetStarted();
          }
        }
      },
    );
  }
}
