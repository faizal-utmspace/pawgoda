import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawgoda/pages/homepet.dart';
import 'package:pawgoda/pages/booking_history_page.dart';
import 'package:pawgoda/pages/staff/staff_login_page.dart';
import 'package:pawgoda/widgets/list_card.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/models/user.dart' as user_model;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
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

  List<ListItem> get profileOptions => [
        ListItem(name: 'Biodata', description: '', icon: Icons.person, action: () {}),
        ListItem(
          name: 'Booking History',
          description: '',
          icon: Icons.list,
          action: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
          ),
        ),
        ListItem(name: 'Settings', description: '', icon: Icons.settings, action: () {}),
      ];

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
    _setupGoogleSignIn();
  }

  void _setupGoogleSignIn() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() => user = account);
      if (account != null) {
        _loadProfileOptions();
        _navigateToHomeIfNeeded();
      }
    });

    _googleSignIn.signInSilently().then((acct) {
      if (acct != null) {
        setState(() => user = acct);
        _loadProfileOptions();
        _navigateToHomeIfNeeded();
      }
    });
  }

  Future<void> _loadLocalUser() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _loadProfileOptions();
      _navigateToHomeIfNeeded();
    }
  }

  void _navigateToHomeIfNeeded() {
    if (_navigated) return;

    final isSignedIn =
        user != null || name != null || FirebaseAuth.instance.currentUser != null;
    if (!isSignedIn) return;

    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Homepet()),
      );
    });
  }

  Future<UserCredential?> _signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      // Save to Firestore
      await _saveToFirestore(userCred.user);

      // Navigate after saving
      _navigateToHomeIfNeeded();

      return userCred;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> _saveToFirestore(User? firebaseUser) async {
    if (firebaseUser == null) return;
    final users = FirebaseFirestore.instance.collection('users');
    await users.doc(firebaseUser.uid).set({
      'uid': firebaseUser.uid,
      'name': firebaseUser.displayName,
      'email': firebaseUser.email,
      'photoURL': firebaseUser.photoURL,
      'role': 'client',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _logout() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    setState(() {
      listItems.clear();
      user = null;
      name = null;
      email = null;
      photoURL = null;
    });
  }

  void _loadProfileOptions() {
    if (listItems.isNotEmpty) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      for (var i = 0; i < profileOptions.length; i++) {
        listKey.currentState?.insertItem(
          listItems.length,
          duration: Duration(milliseconds: 300 + i * 100),
        );
        listItems.add(profileOptions[i]);
      }

      final logoutOption = ListItem(
        name: 'Logout',
        description: '',
        icon: Icons.logout,
        color: Colors.redAccent,
        action: _logout,
      );
      listKey.currentState?.insertItem(listItems.length);
      listItems.add(logoutOption);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);
    final displayName = user?.displayName ?? name ?? '';

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
                    return user == null
                        ? Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/starter_header.svg',
                                  height: size.height * 0.7,
                                  width: size.width * value,
                                ),
                                if (displayName.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Container(
                            width: value * size.width,
                            height: size.height * 0.4,
                            decoration: BoxDecoration(
                              color: Styles.bgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(value * size.width / 2),
                                bottomRight: Radius.circular(value * size.width / 2),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/svg/cat1.svg'),
                                if (displayName.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                  },
                ),
              ],
            ),
            const Gap(15),
            if (user == null && name == null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _signIn,
                      icon: Image.asset('assets/png/google.png', width: 24, height: 24),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
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
                            MaterialPageRoute(builder: (_) => const StaffLoginPage()),
                          );
                        },
                        child: const Text(
                          'Continue as staff',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            else
              MediaQuery.removeViewPadding(
                context: context,
                removeTop: true,
                child: AnimatedList(
                  key: listKey,
                  initialItemCount: listItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index, animation) {
                    final item = listItems[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.5, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: ListCard(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
