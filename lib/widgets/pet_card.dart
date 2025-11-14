import 'package:pawgoda/pages/booking_page.dart';
import 'package:pawgoda/pages/grooming_page.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class PetCard extends StatefulWidget {
  final String petPath;
  final String petName;
  final String? petType;
  final bool isBooking;

  const PetCard({
    Key? key,
    required this.petPath,
    required this.petName,
    this.petType,
    this.isBooking = false,
  }) : super(key: key);

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  void _navigate() {
    if (widget.isBooking) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingPage(petType: widget.petType ?? 'Cat'),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GroomingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _navigate,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(seconds: 1),
        builder: (context, value, _) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Styles.bgColor,
              borderRadius: BorderRadius.circular(27),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced vertical padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section - reduced height
                SizedBox(
                  height: 70, // Reduced from 80
                  child: SvgPicture.asset(
                    widget.petPath,
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 8), // Reduced from 12
                
                // Text section
                Text(
                  widget.petName,
                  style: TextStyle(
                    color: Styles.highlightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                
                if (widget.petType != null) ...[
                  const SizedBox(height: 2), // Reduced from 4
                  Text(
                    widget.petType!,
                    style: TextStyle(
                      color: Styles.blackColor.withOpacity(0.6),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 8), // Reduced from 12
              ],
            ),
          );
        },
      ),
    );
  }
}