import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pawgoda/pages/payment_page.dart';
import 'package:pawgoda/keys.dart';

import 'firebase_options.dart';
import 'pages/get_started.dart';
import 'pages/login_page.dart';
import 'pages/staff/staff_login_page.dart';
import 'pages/homepet.dart';
import 'pages/staff/home_staff.dart';
import 'models/user.dart' as user_model;
import 'utils/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
    
    
    if (dotenv.env['GROK_API_KEY'] != null && dotenv.env['GROK_API_KEY']!.isNotEmpty) {
      print('✅ Grok API key loaded');
    } else {
      print('⚠️ Grok API key not found in .env file');
    }
  } catch (e) {
    print('⚠️ Error loading .env file: $e');
    print('💡 Make sure .env file exists in project root');
    print('💡 Add GROK_API_KEY=your-key-here to .env file');
  }
  
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    Stripe.publishableKey = stripePublishableKey;
    await Stripe.instance.applySettings();
    print('✅ Stripe initialized successfully');
  } catch (e) {
    print('❌ Stripe initialization failed: $e');
    print('⚠️ Payment features will be disabled');

  }

  try {
    await FirebaseAuth.instance.signOut();
    print('✅ Firebase Auth signed out');
    
    final googleSignIn = GoogleSignIn();
    final isSignedIn = await googleSignIn.isSignedIn();
    
    if (isSignedIn) {
      await googleSignIn.signOut();
      print('✅ Google Sign-In signed out');
      
      try {
        await googleSignIn.disconnect();
        print('✅ Google Sign-In disconnected');
      } catch (e) {
        print('⚠️ Google disconnect failed: $e');
      }
    }
    
    print('🔴 LOGOUT COMPLETE');
  } catch (e) {
    print('⚠️ Logout error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawGoda',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Styles.blackColor,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: Styles.blackColor),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔍 AuthGate: Building...');
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        print('🔍 AuthGate: Has data = ${authSnapshot.hasData}');
        
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          print('✅ NO USER - Showing LoginPage');
          return const LoginPage();
        }

        final firebaseUser = authSnapshot.data!;
        print('✅ User logged in: ${firebaseUser.email}');
        
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError) {
              print('❌ Error: ${userSnapshot.error}');
              return const Homepet();
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final data = userSnapshot.data!.data() as Map<String, dynamic>?;
              final role = data?['role'] as String?;
              print('✅ User role: $role');

              if (role == 'staff') {
                print('➡️ HomeStaffPage');
                return const HomeStaffPage();
              } else {
                print('➡️ Homepet');
                return const Homepet();
              }
            } else {
              print('⚠️ No user document');
              return const Homepet();
            }
          },
        );
      },
    );
  }
}