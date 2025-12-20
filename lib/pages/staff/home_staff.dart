import 'package:pawgoda/pages/staff/activity.dart';
import 'package:pawgoda/pages/staff_activity_management_page.dart';
import 'package:pawgoda/pages/staff/booking.dart';
import 'package:pawgoda/pages/staff/staff_customer_list_page.dart'; 
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

class HomeStaffPage extends StatefulWidget {
  const HomeStaffPage({Key? key}) : super(key: key);

  @override
  State<HomeStaffPage> createState() => _HomeStaffPageState();
}

class _HomeStaffPageState extends State<HomeStaffPage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> navItems = [
        {
      'text': 'Activities', 
      'icon': 'assets/nav_icons/notification_list_icon.svg', 
      'page': const ActivityPage()
    },
    {
      'text': 'Bookings', 
      'icon': 'assets/nav_icons/booking.svg', 
      'page': const StaffCustomerListPage() // CHANGED: Now shows customer list first
    },

    {
      'text': 'Profile', 
      'icon': 'assets/nav_icons/profile_icon.svg', 
      'page': const UserProfilePage()
    }
  ];

  void _onNavItemTap(int index, Map<String, dynamic> item) {
    // Switch tab in place. We use IndexedStack in the body so each tab's
    // state is preserved when switching.
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) {
              return DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.4,
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
                          // small grabber
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
                          Expanded(
                            child: AIChatbotPage(),
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
        child: const Icon(Icons.smart_toy_outlined),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: navItems.map<Widget>((item) => item['page'] as Widget).toList(),
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