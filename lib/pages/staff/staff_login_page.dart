import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pawgoda/pages/staff/home_staff.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/widgets/list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({Key? key}) : super(key: key);

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
        "980151251492-vegm8onmtimk2u6mljm55ef6ksh6o2s0.apps.googleusercontent.com",
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
    // If already navigated avoid double navigation.
    if (_navigated) return;

    final isSignedIn = user != null || name != null ||
        FirebaseAuth.instance.currentUser != null;
    if (!isSignedIn) return;

    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeStaffPage()),
      );
    });
  }

  Future<void> _saveToFirestore(User? firebaseUser) async {
    if (firebaseUser == null) return;
    final users = FirebaseFirestore.instance.collection('users');
    await users.doc(firebaseUser.uid).set({
      'uid': firebaseUser.uid,
      'name': firebaseUser.displayName,
      'email': firebaseUser.email,
      'photoURL': firebaseUser.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserCredential?> _signIn() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Ensure createdAt is set only on first creation and role is set to 'staff'.
      final uid = userCred.user?.uid;
      if (uid != null) {
        final users = FirebaseFirestore.instance.collection('users');
        final docRef = users.doc(uid);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'staff',
          }, SetOptions(merge: true));
        } else {
          await docRef.set({
        'role': 'staff',
          }, SetOptions(merge: true));
        }
      }

      await _saveToFirestore(userCred.user);

      setState(() {
        user = googleUser;
        name = userCred.user?.displayName;
        email = userCred.user?.email;
        photoURL = userCred.user?.photoURL;
      });


      // Navigate to Home after successful sign-in. Use pushReplacement so
      // the user cannot go back to the login page via the back button.
      if (!mounted) return userCred;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeStaffPage())
        );
      });

      return userCred;
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
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
                          MaterialPageRoute(builder: (context) => const StaffLoginPage()),
                        );
                      },
                      child: const Text(
                        'Continue as client',
                        style: const TextStyle(
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
