import 'dart:developer';

import 'package:pawgoda/pages/profile_page.dart';
import 'package:pawgoda/pages/staff_activity_management_page.dart';
import 'package:pawgoda/pages/staff_bookings_list_page.dart';
import 'package:pawgoda/pages/user_dashboard.dart';
import 'package:pawgoda/pages/user_profile_page.dart';
import 'package:pawgoda/pages/ai_chatbot_page.dart';
import 'package:pawgoda/pages/booking_page.dart';
import 'package:pawgoda/pages/my_pets_page.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/animated_title.dart';
import 'package:pawgoda/widgets/pet_card.dart';
import 'package:pawgoda/widgets/stories_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepet extends StatefulWidget {
  const Homepet({Key? key}) : super(key: key);

  @override
  State<Homepet> createState() => _HomepetState();
}

class _HomepetState extends State<Homepet> {
  int _currentIndex = 0;
  final Map<String, dynamic> userData = {
    'name': '',
    'email': '',
    'phone': '',
    'profileImageUrl': null,
    'memberSince': '',
    'totalBookings': 0,
    'activePets': 0,
    'role': '-'
  };
  
  final List<Map<String, dynamic>> navItems = [
    {
      'text': 'Hotel', 
      'icon': 'assets/nav_icons/hotel_icon.svg',
      'isActive': true
    },
    {
      'text': 'Dashboard', 
      'icon': 'assets/nav_icons/vet_icon.svg', 
      'page': const StaffBookingsListPage()
    },
    {
      'text': 'Profile', 
      'icon': 'assets/nav_icons/profile_icon.svg', 
      'page': const UserProfilePage()
    }
  ];

  void _onNavItemTap(int index, Map<String, dynamic> item) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCustomerAIChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Column(
                  children: [
                    // Grabber handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    
                    const Expanded(
                      child: AIChatbotPage(
                        isStaffMode: false, 
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
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
  onPressed: _openCustomerAIChatbot,
  backgroundColor: Styles.highlightColor,
  child: const Center(
    child: Icon(
      Icons.smart_toy,
      color: Colors.white,
    ),
  ),
),
      body: SafeArea(
        child: userData.isNotEmpty ? IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: main Homepet content
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // Header with profile and search
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: Styles.bgColor
                      ),
                      child: Image.asset(
                        'assets/svg/sticker.png',
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.pets, color: Styles.highlightColor);
                        },
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Styles.bgColor,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/Search.svg',
                              height: 20,
                              color: Styles.highlightColor,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                'Search rooms, services...',
                                style: TextStyle(
                                  color: Styles.highlightColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Gap(10),
                            SvgPicture.asset(
                              'assets/svg/scanner.svg', 
                              height: 20,
                              color: Styles.highlightColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Gap(30),
                
                // Welcome title
                const AnimatedTitle(title: 'Welcome to PawGoda Pet Hotel'),
                const Gap(15),
                
                // Dynamic Pet Type Cards from Firebase
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pets')
                      .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading pets',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final pets = snapshot.data?.docs ?? [];
                    
                    // Get unique pet types
                    final petTypes = <String>{};
                    for (var doc in pets) {
                      final data = doc.data() as Map<String, dynamic>;
                      final type = data['type'] as String?;
                      if (type != null) {
                        petTypes.add(type);
                      }
                    }

                    // Show pet type cards or "Add Pet" card
                    if (petTypes.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Styles.bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.pets, size: 60, color: Colors.grey[400]),
                            const Gap(15),
                            Text(
                              'No pets yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Add your first pet to start booking',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyPetsPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Pet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.highlightColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show available pet type cards
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.85,
                      children: petTypes.map((petType) {
                        // Configuration for each pet type
                        final Map<String, dynamic> config = {
                          'Dog': {
                            'icon': '🐶',
                            'color': const Color(0xFFFF6B6B),
                          },
                          'Cat': {
                            'icon': '🐱',
                            'color': const Color(0xFF4ECDC4),
                          },
                          'Rabbit': {
                            'icon': '🐰',
                            'color': const Color(0xFF95E1D3),
                          },
                        };

                        final petConfig = config[petType] ?? {
                          'icon': '🐾',
                          'color': Styles.highlightColor,
                        };

                        return _buildPetTypeCard(context, petType, petConfig);
                      }).toList(),
                    );
                  },
                ),
                
                const Gap(25),
                
                // Quick Booking Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Styles.highlightColor.withOpacity(0.1),
                        Styles.highlightColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Styles.highlightColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hotel,
                        size: 50,
                        color: Styles.highlightColor,
                      ),
                      const Gap(15),
                      const Text(
                        'Book Hotel Stay',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Select your pet type to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show pet type selector
                            FirebaseFirestore.instance
                                .collection('pets')
                                .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                .get()
                                .then((snapshot) {
                              final petTypes = <String>{};
                              for (var doc in snapshot.docs) {
                                final type = doc.data()['type'] as String?;
                                if (type != null) petTypes.add(type);
                              }

                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Select Pet Type',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Gap(20),
                                      ...petTypes.map((petType) {
                                        String getEmoji(String type) {
                                          switch (type.toLowerCase()) {
                                            case 'cat': return '🐱';
                                            case 'dog': return '🐶';
                                            case 'rabbit': return '🐰';
                                            case 'bird': return '🐦';
                                            case 'hamster': return '🐹';
                                            default: return '🐾';
                                          }
                                        }

                                        return ListTile(
                                          leading: Text(
                                            getEmoji(petType),
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                          title: Text(petType),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BookingPage(petType: petType),
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.bgWithOpacityColor,
                            foregroundColor: Styles.highlightColor,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 12
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Book Now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Gap(25),
                
                // Community Section
                const AnimatedTitle(title: 'Community'),
                const Gap(15),
                const StoriesSection(),
                
                const Gap(20),
              ],
            ),

            // Tab 1: Dashboard
            const UserDashboard(),

            // Tab 2: Profile
            const UserProfilePage()
          ],
        ) : Container(),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          color: Styles.bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: navItems.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == _currentIndex;
            
            return InkWell(
              onTap: () => _onNavItemTap(index, item),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      item['icon'],
                      height: 22,
                      color: isActive ? Styles.highlightColor : Colors.black54,
                    ),
                    const Gap(4),
                    Text(
                      item['text'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Styles.highlightColor : Styles.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPetTypeCard(BuildContext context, String petType, Map<String, dynamic> config) {
    final String emoji = config['icon'];
    final Color color = config['color'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingPage(petType: petType),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 50),
              ),
            ),
            const Gap(15),
            // Pet Type Name
            Text(
              '$petType Hotel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            // Book Now Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}