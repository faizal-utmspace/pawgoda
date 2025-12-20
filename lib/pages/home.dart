import 'package:pawgoda/pages/grooming_page.dart';
import 'package:pawgoda/pages/user_profile_page.dart';
import 'package:pawgoda/pages/vet_page.dart';
import 'package:pawgoda/pages/my_pets_page.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/animated_title.dart';
import 'package:pawgoda/widgets/pet_card.dart';
import 'package:pawgoda/widgets/stories_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'text': 'My Pet', 'icon': 'assets/nav_icons/dog_icon.svg'},
    {'text': 'Booking', 'icon': Icons.list, 'page': const GroomingPage()},
    {'text': 'Vet', 'icon': Icons.hotel, 'page': const VetPage()},
    {'text': 'Profile', 'icon': Icons.person, 'page': const UserProfilePage()},
  ];

  final List<Widget> _pages = [
    const _AdoptPage(),
    const GroomingPage(),
    const VetPage(),
    const UserProfilePage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List navItems = [
      {
        'text': 'Adopt',
        'icon': 'assets/nav_icons/dog_icon.svg',
      },
      {
        'text': 'Grooming',
        'icon': 'assets/nav_icons/cut_icon.svg',
        'page': const GroomingPage()
      },
      {
        'text': 'Vet',
        'icon': 'assets/nav_icons/vet_icon.svg',
        'page': const VetPage()
      },
      {
        'text': 'Help',
        'icon': 'assets/nav_icons/ai_icon.svg',
      },
    ];
    final size = Layouts.getSize(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          color: Styles.bgColor,
        ),
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _navItems.asMap().entries.map((entry) {
            int idx = entry.key;
            var item = entry.value;

            bool isSelected = _selectedIndex == idx;

            return InkWell(
              onTap: () => _onTabSelected(idx),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  item['icon'] is String ? SvgPicture.asset(
                    item['icon'],
                    height: 20,
                    color: isSelected ? Styles.highlightColor : Styles.blackColor,
                  ) : Icon(item['icon']),
                  const Gap(5),
                  Text(
                    item['text'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Styles.highlightColor : Styles.blackColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AdoptPage extends StatelessWidget {
  const _AdoptPage();

  void _navigateToBooking(BuildContext context, String petId, Map<String, dynamic> petData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroomingPage(), // Pass petId and petData if needed
      ),
    );
  }

  void _navigateToAddPet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyPetsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: Colors.grey[400]),
            const Gap(20),
            Text(
              'Please log in to view your pets',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      children: [
        Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, value, _) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    height: value * 50,
                    width: value * 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Styles.bgColor),
                    child: Image.asset('assets/svg/sticker.png'),
                  ),
                );
              },
            ),
            const Gap(7),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(15),
                height: 50,
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Styles.bgColor,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/svg/Search.svg', height: 20, width: 20),
                    const Gap(10),
                    Text('Search', style: TextStyle(color: Styles.highlightColor)),
                    const Spacer(),
                    SvgPicture.asset('assets/svg/scanner.svg', height: 20, width: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(35),
        const AnimatedTitle(title: 'My Pets'),
        const Gap(10),
        
        // Pet List
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pets')
              .where('ownerId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
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

            if (pets.isEmpty) {
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
                      'Add your pet to start booking services',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(20),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddPet(context),
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

            return Column(
              children: [
                ...pets.map((doc) {
                  final petData = doc.data() as Map<String, dynamic>;
                  final petId = doc.id;
                  final name = petData['name'] ?? 'Unknown';
                  final breed = petData['breed'] ?? 'Unknown';
                  final type = petData['type'] ?? 'Unknown';
                  final imageUrl = petData['imageUrl'] as String?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Styles.bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Pet Image
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Styles.highlightColor.withOpacity(0.1),
                              image: imageUrl != null && imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageUrl == null || imageUrl.isEmpty
                                ? Icon(
                                    Icons.pets,
                                    size: 35,
                                    color: Styles.highlightColor,
                                  )
                                : null,
                          ),
                          const Gap(16),
                          
                          // Pet Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '$type • $breed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Book Now Button
                          ElevatedButton(
                            onPressed: () => _navigateToBooking(context, petId, petData),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.highlightColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                
                // Add Pet Button
                const Gap(10),
                OutlinedButton.icon(
                  onPressed: () => _navigateToAddPet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Pet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Styles.highlightColor,
                    side: BorderSide(color: Styles.highlightColor, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        const Gap(25),
        const AnimatedTitle(title: 'Community'),
        const Gap(10),
        const StoriesSection(),
      ],
    );
  }
}
