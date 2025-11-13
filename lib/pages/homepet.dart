import 'package:pawgoda/pages/staff_activity_management_page.dart';
import 'package:pawgoda/pages/staff_bookings_list_page.dart';
import 'package:pawgoda/pages/user_profile_page.dart';
import 'package:pawgoda/pages/ai_chatbot_page.dart';
import 'package:pawgoda/pages/booking_page.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/animated_title.dart';
import 'package:pawgoda/widgets/pet_card.dart';
import 'package:pawgoda/widgets/stories_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class Homepet extends StatefulWidget {
  const Homepet({Key? key}) : super(key: key);

  @override
  State<Homepet> createState() => _HomepetState();
}

class _HomepetState extends State<Homepet> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> navItems = [
    {
      'text': 'Hotel', 
      'icon': 'assets/nav_icons/hotel_icon.svg',
      'isActive': true
    },
    {
      'text': 'Staff', 
      'icon': 'assets/nav_icons/vet_icon.svg', 
      'page': const StaffBookingsListPage()
    },
    {
      'text': 'Profile', 
      'icon': 'assets/nav_icons/profile_icon.svg', 
      'page': const UserProfilePage()
    },
    {
      'text': 'Chatbot', 
      'icon': 'assets/nav_icons/ai_icon.svg',
      'page': const AIChatbotPage()
    },
  ];

  void _onNavItemTap(int index, Map<String, dynamic> item) {
    setState(() {
      _currentIndex = index;
    });
    
    if (item['page'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['page']),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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
            
            // Pet cards row - RESPONSIVE APPROACH
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
        aspectRatio: 0.9, // Adjust this value as needed
        child: PetCard(
          petPath: 'assets/svg/cat1.svg',
          petName: 'Cat Hotel',
          petType: 'Cat',
          isBooking: true,
        ),
      ),
    ),
                const Gap(15),
                Expanded(
                  child: AspectRatio(
        aspectRatio: 0.9, // Adjust this value as needed
        child: PetCard(
          petPath: 'assets/svg/dog1.svg',
          petName: 'Dog Hotel',
          petType: 'Dog',
          isBooking: true,
        ),
      ),
    ),
  ],
            ),
            
            const Gap(25),
            
            // Special Services
            const AnimatedTitle(title: 'Special Services'),
            const Gap(15),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Styles.bgColor,
                borderRadius: BorderRadius.circular(27),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Luxury Cat Suites 🐾",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Styles.blackColor,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    "Air-conditioned rooms, 24/7 monitoring, and cozy beds for your furry friend.",
                    style: TextStyle(
                      fontSize: 13, 
                      color: Styles.blackColor.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const Gap(15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show dialog to select pet type
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Pet Type'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Text('🐱', style: TextStyle(fontSize: 24)),
                                  title: const Text('Cat'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BookingPage(petType: 'Cat')
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Text('🐶', style: TextStyle(fontSize: 24)),
                                  title: const Text('Dog'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BookingPage(petType: 'Dog')
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Text('🐰', style: TextStyle(fontSize: 24)),
                                  title: const Text('Rabbit'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const BookingPage(petType: 'Rabbit')
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
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
}