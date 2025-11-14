import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pawgoda/pages/booking_history_page.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/list_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "980151251492-vegm8onmtimk2u6mljm55ef6ksh6o2s0.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final List<ListItem> _items = [];

  String? cachedName;
  String? cachedEmail;
  String? cachedPhotoURL;

  List<ListItem> get profileList => [
        ListItem(
          name: 'Biodata',
          description: '',
          icon: Icons.person,
          action: () {},
        ),
        ListItem(
          name: 'Booking History',
          description: '',
          icon: Icons.list,
          action: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingHistoryPage(),
              ),
            );
          },
        ),
        ListItem(
          name: 'Settings',
          description: '',
          icon: Icons.settings,
          action: () {},
        ),
      ];

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() => _currentUser = account);
      if (account != null) _loadProfileList();
    });
    _googleSignIn.signInSilently();
  }

  /// Save user data to Firestore
  Future<void> saveUserToFirestore(User? user) async {
    if (user == null) return;
    final usersRef = FirebaseFirestore.instance.collection('users');

    await usersRef.doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Handle Google Sign-In
  Future<UserCredential?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await saveUserToFirestore(userCredential.user);

      debugPrint('Google Sign-In successful: ${userCredential.user?.email}');
      setState(() {
        _currentUser = googleUser;
        cachedName = userCredential.user?.displayName;
        cachedEmail = userCredential.user?.email;
        cachedPhotoURL = userCredential.user?.photoURL;
      });
      _loadProfileList();
      return userCredential;
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> _handleLogout() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    setState(() {
      _items.clear();
      _currentUser = null;
      cachedName = null;
      cachedEmail = null;
      cachedPhotoURL = null;
    });
  }

  void _loadProfileList() {
    Future.delayed(const Duration(milliseconds: 300), () {
      for (var i = 0; i < profileList.length; i++) {
        listKey.currentState?.insertItem(
          _items.length,
          duration: Duration(milliseconds: 400 + i * 100),
        );
        _items.add(profileList[i]);
      }

      final logoutItem = ListItem(
        name: 'Logout',
        description: '',
        icon: Icons.logout,
        color: Colors.redAccent,
        action: _handleLogout,
      );
      listKey.currentState?.insertItem(_items.length);
      _items.add(logoutItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);

    final displayName = _currentUser?.displayName ?? cachedName ?? '';
    final displayPhoto = _currentUser?.photoUrl ?? cachedPhotoURL;

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
                      width: value * size.width,
                      height: value * size.width * (2 / 3),
                      decoration: BoxDecoration(
                        color: Styles.bgColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(value * size.width / 2),
                          bottomRight:
                              Radius.circular(value * size.width / 2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (displayPhoto != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(displayPhoto),
                            )
                          else
                            SvgPicture.asset(
                              'assets/svg/person2.svg',
                              height: value * 180,
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
                    );
                  },
                ),
              ],
            ),
            const Gap(15),

            if (_currentUser == null && cachedName == null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: _handleSignIn,
                  icon:
                      Image.asset('assets/png/google.png', width: 24, height: 24),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              MediaQuery.removeViewPadding(
                context: context,
                removeTop: true,
                child: AnimatedList(
                  key: listKey,
                  initialItemCount: _items.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index, animation) {
                    final item = _items[index];
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
