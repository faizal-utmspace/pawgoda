import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/styles.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Mock user data (in real app, this would come from Firebase Auth)
  final Map<String, dynamic> userData = {
    'name': 'afi',
    'email': 'afi@gmail.com',
    'phone': '+60 12-345 6789',
    'profileImageUrl': null, // URL from Firebase Storage
    'role': 'customer', // customer, staff, admin
    'memberSince': '2024-01-15',
    'totalBookings': 12,
    'activePets': 2,
  };

  bool isLoading = false;

  // Mock Google Sign-In (in real app, use firebase_auth and google_sign_in packages)
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });

    // Simulate sign-in delay
    await Future.delayed(const Duration(seconds: 2));

    // In real app:
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );
    // await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed in successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    // In real app: await FirebaseAuth.instance.signOut();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Signed out successfully'),
                  backgroundColor: Styles.highlightColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.highlightColor),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Styles.highlightColor,
                ),
              )
            : ListView(
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
                          child: userData['profileImageUrl'] != null
                              ? ClipOval(
                                  child: Image.network(
                                    userData['profileImageUrl'],
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
                          userData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(5),
                        // Email
                        Text(
                          userData['email'],
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
                            userData['role'].toString().toUpperCase(),
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
                          userData['totalBookings'].toString(),
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                      const Gap(15),
                      Expanded(
                        child: _buildStatCard(
                          'Active Pets',
                          userData['activePets'].toString(),
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
                    value: userData['phone'],
                    onTap: () {},
                  ),
                  const Gap(12),

                  _buildInfoCard(
                    icon: Icons.cake,
                    title: 'Member Since',
                    value: userData['memberSince'],
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
                    onPressed: _handleSignOut,
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