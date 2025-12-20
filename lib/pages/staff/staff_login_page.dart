import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pawgoda/pages/staff/home_staff.dart';
import 'package:pawgoda/pages/login_page.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/widgets/list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawgoda/main.dart';

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({Key? key}) : super(key: key);

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? user;

  bool _navigated = false;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final List<ListItem> listItems = [];

  String? name;
  String? email;
  String? photoURL;

 @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() => user = account);
      if (account != null) {
        _navigateToHomeIfNeeded();
      }
    });
    // Try silent sign-in and navigate if successful.
    googleSignIn.signInSilently().then((acct) {
      if (acct != null) {
        setState(() => user = acct);
        _navigateToHomeIfNeeded();
      }
    });
  }

  void _navigateToHomeIfNeeded() {
    // Auth state changes will be detected by AuthGate in main.dart
    // No need to manually navigate here
    debugPrint('✅ User signed in, AuthGate will handle navigation');
  }

  Future<UserCredential?> _signIn() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ User cancelled Google sign-in');
        return null;
      }

      debugPrint('✅ Google user: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔐 Signing in to Firebase...');
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      
      debugPrint('✅ Firebase user: ${userCred.user?.email}');

      // Set user as staff in Firestore
      final uid = userCred.user?.uid;
      if (uid != null) {
        debugPrint('💾 Saving to Firestore...');
        final users = FirebaseFirestore.instance.collection('users');
        final docRef = users.doc(uid);
        
        try {
          final doc = await docRef.get();
          
          if (!doc.exists) {
            // New user - create as staff
            debugPrint('📝 Creating new staff user');
            await docRef.set({
              'uid': uid,
              'name': userCred.user?.displayName,
              'email': userCred.user?.email,
              'photoURL': userCred.user?.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
              'role': 'staff',
              'lastLogin': FieldValue.serverTimestamp(),
            });
            debugPrint('✅ New staff user created');
          } else {
            // Existing user - update to staff role
            debugPrint('🔄 Updating existing user to staff');
            await docRef.update({
              'role': 'staff',
              'lastLogin': FieldValue.serverTimestamp(),
            });
            debugPrint('✅ User updated to staff');
          }
        } catch (e) {
          debugPrint('❌ Firestore error: $e');
          // Continue anyway - Firebase auth succeeded
        }
      }

      debugPrint('🎉 Sign-in successful, Firestore updated');

      // Pop back to root so AuthGate can detect auth state and navigate
      if (!mounted) return userCred;
      
      // Use Navigator.pushAndRemoveUntil to go back to root
      // This will trigger AuthGate to rebuild and navigate to HomeStaffPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
      
      return userCred;
    } catch (error) {
      debugPrint('❌ Google Sign-In Error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) {
                    return Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/person2.svg',
                            height: size.height * 0.6,
                            width: size.width * value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const Gap(15),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _signIn,
                    icon: Image.asset(
                      'assets/png/google.png',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Continue as client',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}