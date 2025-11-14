import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/models/booking.dart';
import 'package:pawgoda/models/pet.dart';
import 'package:pawgoda/pages/login_page.dart';
import '../utils/styles.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawgoda/models/user.dart' as user_model;

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
        "980151251492-vegm8onmtimk2u6mljm55ef6ksh6o2s0.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );


  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final bookingsQuery = FirebaseFirestore.instance
        .collection('bookings')
        .where('uid', isEqualTo: uid)
        .get();

    final petsQuery = FirebaseFirestore.instance
        .collection('pets')
        .where('uid', isEqualTo: uid)
        .get();

    // Wait for all 3 to complete
    final results = await Future.wait([
      userDoc,
      bookingsQuery,
      petsQuery,
    ]);

    log('results: ${results[0].toString()}');

    return {
      'user': results[0],
      'bookings': results[1],
      'pets': results[2],
    };
  }


  Future<void> _logout() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed out successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {

    final userInstance = FirebaseAuth.instance.currentUser;
    log('Building UserProfilePage for user: ${userInstance?.uid}');
    
    // If no user is logged in, redirect to login page
    if (userInstance == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return FutureBuilder(
      future: getUserData(userInstance.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('No data found'));
        }

        final data = snapshot.data as Map<String, dynamic>;

        final userDoc = data['user'] as DocumentSnapshot<Map<String, dynamic>>;
        final bookings = data['bookings'] as QuerySnapshot<Map<String, dynamic>>;
        final pets = data['pets'] as QuerySnapshot<Map<String, dynamic>>;

        final user = user_model.User.fromJson(userDoc.data()!);
        final bookingList = bookings.docs.map((e) => Booking.fromJson(e.data())).toList();
        final petList = pets.docs.map((e) => Pet.fromJson(e.data())).toList();

        print(  'User data loaded: ${user.toString()}, Bookings: ${bookingList.length}, Pets: ${petList.length}'  );

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Edit profile feature coming soon!'),
                      backgroundColor: Styles.highlightColor,
                      behavior: SnackBarBehavior.floating,
                    ),
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
                      // Profile image
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: user.photoURL != null
                            ? ClipOval(
                                child: Image.network(
                                  user.photoURL ?? '',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 50,
                                color: Styles.highlightColor,
                              ),
                      ),
                      const Gap(15),
                      // Name
                      Text(
                        user.name ?? '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(5),
                      // Email
                      Text(
                        user.email ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const Gap(5),
                      // Role badge
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
                          user.role != null ? user.role!.toUpperCase() : '',
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
        
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Bookings',
                        bookingList.length.toString(),
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: _buildStatCard(
                        'Active Pets',
                        petList.length.toString(),
                        Icons.pets,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
        
                const Gap(25),
        
                // Account Information
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
                  icon: Icons.phone,
                  title: 'Phone Number',
                  value: user.phoneNumber ?? '-',
                  onTap: () {},
                ),
                const Gap(12),
        
                _buildInfoCard(
                  icon: Icons.cake,
                  title: 'Member Since',
                  value: user.createdAt ?? '-',
                  onTap: null,
                ),
        
                const Gap(25),
        
                // Settings Section
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Styles.blackColor,
                  ),
                ),
                const Gap(15),
        
                _buildSettingsOption(
                  icon: Icons.pets,
                  title: 'My Pets',
                  subtitle: 'Manage your pets',
                  onTap: () {
                    // Navigate to pets management page
                  },
                ),
                const Gap(12),
        
                _buildSettingsOption(
                  icon: Icons.history,
                  title: 'Booking History',
                  subtitle: 'View past bookings',
                  onTap: () {
                    // Navigate to booking history
                  },
                ),
                const Gap(12),
        
                _buildSettingsOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
                const Gap(12),
        
                _buildSettingsOption(
                  icon: Icons.lock,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                const Gap(12),
        
                _buildSettingsOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help or contact us',
                  onTap: () {
                    // Navigate to help page
                  },
                ),
        
                const Gap(30),
        
                // Sign out button
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        
                const Gap(15),
        
                // App version
                Center(
                  child: Text(
                    'PawGoda v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.blackColor.withOpacity(0.5),
                    ),
                  ),
                ),
        
                const Gap(20),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
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
        ],
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
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
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
                  child: Icon(
                    icon,
                    color: Styles.highlightColor,
                    size: 22,
                  ),
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

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
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
                  child: Icon(
                    icon,
                    color: Styles.highlightColor,
                    size: 22,
                  ),
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Styles.blackColor,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Styles.blackColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
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