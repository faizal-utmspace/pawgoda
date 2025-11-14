import 'package:pawgoda/pages/grooming_page.dart';
import 'package:pawgoda/pages/vet_page.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/animated_title.dart';
import 'package:pawgoda/widgets/pet_card.dart';
import 'package:pawgoda/widgets/stories_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/pages/grooming_page.dart';
import 'package:pawgoda/pages/login-old.dart';
import 'package:pawgoda/pages/profile_page.dart';
import 'package:pawgoda/pages/vet_page.dart';
import 'package:pawgoda/utils/layouts.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/animated_title.dart';
import 'package:pawgoda/widgets/pet_card.dart';
import 'package:pawgoda/widgets/stories_section.dart';

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
    {'text': 'Profile', 'icon': Icons.person, 'page': const ProfilePage()},
  ];

  final List<Widget> _pages = [
    const _AdoptPage(),
    const GroomingPage(),
    const VetPage(),
    const ProfilePage(),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 500),
                  curve: Curves.bounceOut,
                  builder: (context, value, _) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: value*50,
                        width: value*50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Styles.bgColor),
                        child: Image.asset(
                          'assets/svg/sticker.png',
                        ),
                      ),
                    );
                  }
              ),
              const Gap(7),
              Flexible(
                child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, _) {
                    return Container(
                      padding: const EdgeInsets.all(15),
                      height: 50,
                      width: value*size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Styles.bgColor),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/Search.svg',
                            height: value*20,
                            width: value*20,
                          ),
                          const Gap(10),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: value,
                            child: Text(
                              value<0.5 ? '' : 'Search',
                              style: TextStyle(color: Styles.highlightColor),
                            ),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            'assets/svg/scanner.svg',
                            height: 20,
                            width: 20,
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
          const Gap(35),
          const AnimatedTitle(title: 'Who are you looking for?'),
          const Gap(10),
          Row(
            children: const [
              PetCard(petPath: 'assets/svg/cat1.svg', petName: 'Cat Adoption'),
              Gap(28),
              PetCard(
                petPath: 'assets/svg/dog1.svg',
                petName: 'Dog Adoption',
                //height: 68,
              ),
            ],
          ),
          const Gap(25),
          const AnimatedTitle(title: 'Community'),
          const Gap(10),
          TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, _) {
              return Stack(
                children: [
                  Container(
                    height: 150,
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      children: [
                        Container(
                          height: 135,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Styles.bgColor,
                              borderRadius: BorderRadius.circular(27)),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              right: 12,
                              left: Layouts.getSize(context).width * 0.37,
                              top: 15,
                              bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Join our\ncommunity',
                                style: TextStyle(
                                    fontSize: value*27,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.blackColor,
                                    height: 1),
                              ),
                              const Gap(12),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 1500),
                                opacity: value,
                                child: Text(
                                  'Share your pet moments with other pet parents.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Styles.blackColor,
                                      fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          right: value*12,
                          top: value*12,
                          child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Styles.bgWithOpacityColor,
                              child: SvgPicture.asset(
                                'assets/svg/arrow_right.svg',
                                height: value*14,
                                width: value*14,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 0,
                    child: SvgPicture.asset(
                      'assets/svg/person.svg',
                      height: value*150,
                    ),
                  ),
                ],
              );
            }
          ),
          const Gap(25),
          const AnimatedTitle(title: 'Stories'),
          const Gap(10),
          const StoriesSection()
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final size = Layouts.getSize(context);
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
        const AnimatedTitle(title: 'Who are you looking for?'),
        const Gap(10),
        Row(
          children: const [
            PetCard(petPath: 'assets/svg/cat1.svg', petName: 'Cat Adoption'),
            Gap(28),
            PetCard(petPath: 'assets/svg/dog1.svg', petName: 'Dog Adoption'),
          ],
        ),
        const Gap(25),
        const AnimatedTitle(title: 'Community'),
        const Gap(10),
        const StoriesSection(),
      ],
    );
  }
}
