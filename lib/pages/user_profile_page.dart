import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/pages/login_page.dart';
import 'package:pawgoda/pages/staff/staff_login_page.dart';
import 'package:pawgoda/pages/my_pets_page.dart';
import 'package:pawgoda/pages/booking_history_page.dart';
import 'package:pawgoda/pages/edit_profile_page.dart'; // Import the edit profile page
import '../utils/styles.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pawgoda/models/user.dart' as user_model;

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userRole = data?['role'] as String?;
        });
      }
    }
  }

  Future<void> _navigateToEditProfile(String currentName, String? currentPhotoURL) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentName: currentName,
          currentPhotoURL: currentPhotoURL,
        ),
      ),
    );

    // Refresh the profile if changes were made
    if (result == true && mounted) {
      setState(() {
        // The StreamBuilder will automatically refresh
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Disconnect Google account to clear cached account
      await googleSignIn.disconnect();
      // Sign out from Google
      await googleSignIn.signOut();
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Signed out successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to appropriate login page based on role
        final loginPage = userRole == 'staff' 
            ? const StaffLoginPage() 
            : const LoginPage();
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => loginPage),
        );
      }
    } catch (e) {
      log("Logout error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInstance = FirebaseAuth.instance.currentUser;

    if (userInstance == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userInstance.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Styles.highlightColor,
              ),
            ),
          );
        }

        if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text('Error loading profile: ${userSnapshot.error}')),
          );
        }

        final user = user_model.User.fromJson(userSnapshot.data!.data() as Map<String, dynamic>);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pets')
              .where('ownerId', isEqualTo: userInstance.uid)
              .snapshots(),
          builder: (context, petsSnapshot) {
            final petCount = petsSnapshot.hasData ? petsSnapshot.data!.docs.length : 0;
            
            log('🐾 Pet count for ${userInstance.uid}: $petCount');

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('uid', isEqualTo: userInstance.uid)
                  .snapshots(),
              builder: (context, bookingsSnapshot) {
                final bookingCount = bookingsSnapshot.hasData ? bookingsSnapshot.data!.docs.length : 0;

                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      'Profile',
                      style: TextStyle(
                        color: Styles.blackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Styles.highlightColor),
                        onPressed: () {
                          _navigateToEditProfile(
                            user.name ?? 'User',
                            user.photoURL,
                          );
                        },
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Profile header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Styles.highlightColor,
                                Styles.highlightColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Styles.highlightColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: user.photoURL != null && user.photoURL!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              user.photoURL!,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    color: Styles.highlightColor,
                                                    strokeWidth: 2,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Styles.highlightColor,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Styles.highlightColor,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _navigateToEditProfile(
                                          user.name ?? 'User',
                                          user.photoURL,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Styles.highlightColor.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Styles.highlightColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(15),
                              Text(
                                user.name ?? '-',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Gap(5),
                              Text(
                                user.email ?? '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const Gap(5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.role?.toUpperCase() ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Gap(25),

                        // Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Bookings',
                                bookingCount.toString(),
                                Icons.calendar_today,
                                Colors.blue,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BookingHistoryPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Gap(15),
                            Expanded(
                              child: _buildStatCard(
                                'My Pets',
                                petCount.toString(),
                                Icons.pets,
                                Colors.orange,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyPetsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const Gap(25),

                        // Account Info
                        Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.blackColor,
                          ),
                        ),
                        const Gap(15),
                        _buildInfoCard(
                          icon: Icons.pets,
                          title: 'My Pets',
                          value: '$petCount pet${petCount != 1 ? 's' : ''}',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyPetsPage(),
                              ),
                            );
                          },
                        ),
                        const Gap(12),
                        _buildInfoCard(
                          icon: Icons.phone,
                          title: 'Phone Number',
                          value: user.phoneNumber ?? '-',
                          onTap: () {},
                        ),
                        const Gap(12),
                        _buildInfoCard(
                          icon: Icons.cake,
                          title: 'Member Since',
                          value: user.createdAt != null
                              ? DateFormat('dd MMM yyyy').format(user.createdAt!)
                              : '-',
                          onTap: null,
                        ),
                        
                        const Gap(25),

                        // Sign out button
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const Gap(8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Styles.blackColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onTap != null) ...[
              const Gap(4),
              Icon(Icons.arrow_forward_ios, size: 12, color: color.withOpacity(0.5)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Styles.highlightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Styles.highlightColor, size: 22),
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Styles.blackColor.withOpacity(0.6),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Styles.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}