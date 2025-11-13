import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/styles.dart';
import 'payment_page.dart';
import 'customer_activity_tracking_page.dart';

/// This version is compatible with activity_selection_page
/// It accepts selectedActivities and selectedPackage parameters
class AppointmentActivitiesPage extends StatelessWidget {
  final String petType;
  final String serviceName;
  final String bookingDate;
  final String bookingTime;
  final String bookingId;
  final String petName;
  final String breed;
  final String specialNotes;
  final String? checkOutDate;
  final List<String>? selectedActivities; // NEW - optional for backward compatibility
  final String? selectedPackage; // NEW - optional for backward compatibility

  const AppointmentActivitiesPage({
    Key? key,
    required this.petType,
    required this.serviceName,
    required this.bookingDate,
    required this.bookingTime,
    required this.bookingId,
    required this.petName,
    required this.breed,
    required this.specialNotes,
    this.checkOutDate,
    this.selectedActivities, // NEW
    this.selectedPackage, // NEW
  }) : super(key: key);

  double _calculateAmount() {
    double baseAmount = 0.0;
    
    if (serviceName.contains('Hotel')) {
      // Calculate based on package
      switch (selectedPackage) {
        case 'Normal':
          baseAmount = 80.0;
          break;
        case 'Deluxe':
          baseAmount = 150.0;
          break;
        case 'VIP':
          baseAmount = 250.0;
          break;
        default:
          baseAmount = 80.0;
      }
    } else if (serviceName.contains('Daycare')) {
      baseAmount = 60.0;
    }
    
    return baseAmount;
  }

  IconData _getActivityIcon(String activityName) {
    switch (activityName.toLowerCase()) {
      case 'feeding':
        return Icons.restaurant;
      case 'walking':
        return Icons.directions_walk;
      case 'playtime':
        return Icons.sports_esports;
      case 'medication':
        return Icons.medication;
      default:
        return Icons.check_circle;
    }
  }

  Color _getActivityColor(String activityName) {
    switch (activityName.toLowerCase()) {
      case 'feeding':
        return Colors.orange;
      case 'walking':
        return Colors.green;
      case 'playtime':
        return Colors.blue;
      case 'medication':
        return Colors.red;
      default:
        return Styles.highlightColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDaycare = serviceName.contains('Daycare');
    final totalAmount = _calculateAmount();
    final activities = selectedActivities ?? []; // Use empty list if null

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.highlightColor),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: Text(
          'Booking Confirmed',
          style: TextStyle(
            color: Styles.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Success Header
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
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Styles.highlightColor,
                      size: 50,
                    ),
                  ),
                  const Gap(15),
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Your ${isDaycare ? 'daycare' : 'hotel'} booking has been successfully created',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Gap(25),

            // Booking Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Styles.bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Styles.highlightColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Styles.highlightColor, size: 24),
                      const Gap(10),
                      Text(
                        'Booking Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Styles.blackColor,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const Gap(15),
                  _buildInfoRow('Booking ID', bookingId, Icons.confirmation_number),
                  const Gap(12),
                  _buildInfoRow('Pet Name', petName, Icons.pets),
                  const Gap(12),
                  _buildInfoRow('Pet Type', petType, Icons.category),
                  const Gap(12),
                  _buildInfoRow('Breed', breed, Icons.info_outline),
                  const Gap(12),
                  _buildInfoRow('Service', serviceName, Icons.room_service),
                  if (selectedPackage != null) ...[
                    const Gap(12),
                    _buildInfoRow('Package', '$selectedPackage Package', Icons.star),
                  ],
                  const Gap(12),
                  _buildInfoRow(
                    isDaycare ? 'Service Date' : 'Check-In', 
                    bookingDate, 
                    Icons.calendar_today,
                  ),
                  const Gap(12),
                  _buildInfoRow(
                    isDaycare ? 'Drop-off Time' : 'Time', 
                    bookingTime, 
                    Icons.access_time,
                  ),
                  if (checkOutDate != null) ...[
                    const Gap(12),
                    _buildInfoRow('Check-Out', checkOutDate!, Icons.event_available),
                  ],
                  if (specialNotes.isNotEmpty) ...[
                    const Gap(15),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const Gap(15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, color: Styles.highlightColor, size: 20),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Special Notes:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Styles.blackColor,
                                ),
                              ),
                              const Gap(5),
                              Text(
                                specialNotes,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Styles.blackColor.withOpacity(0.7),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Gap(25),

            // Selected Activities Section (only if activities are provided)
            if (activities.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Styles.bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Styles.highlightColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event_note, color: Styles.highlightColor, size: 24),
                        const Gap(10),
                        Text(
                          'Selected Activities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.blackColor,
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    Text(
                      'Staff will update these activities with photos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Styles.blackColor.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Gap(15),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const Gap(15),
                    ...activities.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activity = entry.value;
                      final color = _getActivityColor(activity);
                      final icon = _getActivityIcon(activity);
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < activities.length - 1 ? 12 : 0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  activity,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Styles.blackColor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: color,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const Gap(25),

              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Track Activity Updates',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'You can view real-time updates and photos from staff during your pet\'s stay',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(25),
            ],

            // Action buttons
            Row(
              children: [
                if (activities.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerActivityTrackingPage(
                              bookingId: bookingId,
                              petName: petName,
                              selectedActivities: activities,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Updates'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Styles.highlightColor,
                        side: BorderSide(color: Styles.highlightColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (activities.isNotEmpty) const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            bookingId: bookingId,
                            serviceName: serviceName,
                            petName: petName,
                            amount: totalAmount,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.highlightColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(15),

            // Back to home button
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: Text(
                'Back to Home',
                style: TextStyle(
                  color: Styles.highlightColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Styles.highlightColor),
        const Gap(10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Styles.blackColor.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Styles.blackColor,
            ),
          ),
        ),
      ],
    );
  }
}