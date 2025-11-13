import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import 'appointment_activities_page.dart';

class ActivitySelectionPage extends StatefulWidget {
  final String petType;
  final String serviceName;
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final TimeOfDay checkInTime;
  final String bookingId;
  final String petName;
  final String breed;
  final String specialNotes;
  final String? selectedPackage;

  const ActivitySelectionPage({
    Key? key,
    required this.petType,
    required this.serviceName,
    required this.checkInDate,
    this.checkOutDate,
    required this.checkInTime,
    required this.bookingId,
    required this.petName,
    required this.breed,
    required this.specialNotes,
    this.selectedPackage,
  }) : super(key: key);

  @override
  State<ActivitySelectionPage> createState() => _ActivitySelectionPageState();
}

class _ActivitySelectionPageState extends State<ActivitySelectionPage> {
  // Available activity templates
  final List<Map<String, dynamic>> activityTemplates = [
    {
      'name': 'Feeding',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'description': 'Regular feeding according to schedule',
      'isSelected': false,
    },
    {
      'name': 'Walking',
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'description': 'Daily walking and outdoor exercise',
      'isSelected': false,
    },
    {
      'name': 'Playtime',
      'icon': Icons.sports_esports,
      'color': Colors.blue,
      'description': 'Interactive play sessions',
      'isSelected': false,
    },
    {
      'name': 'Medication',
      'icon': Icons.medication,
      'color': Colors.red,
      'description': 'Medication administration if needed',
      'isSelected': false,
    },
  ];

  List<String> get selectedActivities {
    return activityTemplates
        .where((activity) => activity['isSelected'] == true)
        .map((activity) => activity['name'] as String)
        .toList();
  }

  void _toggleActivity(int index) {
    setState(() {
      activityTemplates[index]['isSelected'] = 
          !(activityTemplates[index]['isSelected'] as bool);
    });
  }

  void _confirmActivities() {
    if (selectedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select at least one activity"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Navigate to appointment details page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentActivitiesPage(
          petType: widget.petType,
          serviceName: widget.serviceName,
          bookingDate: DateFormat('EEEE, MMMM d, yyyy').format(widget.checkInDate),
          bookingTime: widget.checkInTime.format(context),
          bookingId: widget.bookingId,
          petName: widget.petName,
          breed: widget.breed,
          specialNotes: widget.specialNotes,
          checkOutDate: widget.checkOutDate != null 
              ? DateFormat('EEEE, MMMM d, yyyy').format(widget.checkOutDate!)
              : null,
          selectedActivities: selectedActivities,
          selectedPackage: widget.selectedPackage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDaycare = widget.serviceName.contains('Daycare');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Activities"),
        backgroundColor: Styles.bgColor,
        foregroundColor: Styles.blackColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Styles.highlightColor.withOpacity(0.1),
                    Styles.highlightColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Styles.highlightColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Styles.highlightColor,
                    size: 28,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'Select activities you want our staff to perform and update with photos during your pet\'s stay',
                      style: TextStyle(
                        fontSize: 13,
                        color: Styles.blackColor.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Gap(25),
            
            // Booking summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Styles.bgColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Styles.blackColor,
                    ),
                  ),
                  const Gap(12),
                  _buildSummaryRow(Icons.pets, widget.petName),
                  const Gap(8),
                  _buildSummaryRow(
                    Icons.room_service, 
                    widget.serviceName,
                  ),
                  if (widget.selectedPackage != null) ...[
                    const Gap(8),
                    _buildSummaryRow(
                      Icons.star, 
                      '${widget.selectedPackage} Package',
                    ),
                  ],
                  const Gap(8),
                  _buildSummaryRow(
                    Icons.calendar_today,
                    DateFormat('MMM d, yyyy').format(widget.checkInDate),
                  ),
                  if (!isDaycare && widget.checkOutDate != null) ...[
                    const Gap(8),
                    _buildSummaryRow(
                      Icons.event_available,
                      DateFormat('MMM d, yyyy').format(widget.checkOutDate!),
                    ),
                  ],
                ],
              ),
            ),
            
            const Gap(25),
            
            // Activities header
            Text(
              'Select Care Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Styles.blackColor,
              ),
            ),
            const Gap(5),
            Text(
              'Choose activities our staff should track',
              style: TextStyle(
                fontSize: 13,
                color: Styles.blackColor.withOpacity(0.6),
              ),
            ),
            
            const Gap(20),
            
            // Activity templates
            Expanded(
              child: ListView.separated(
                itemCount: activityTemplates.length,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) {
                  final activity = activityTemplates[index];
                  final isSelected = activity['isSelected'] as bool;
                  
                  return InkWell(
                    onTap: () => _toggleActivity(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? (activity['color'] as Color).withOpacity(0.1)
                            : Styles.bgColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected 
                              ? activity['color'] as Color
                              : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (activity['color'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              activity['icon'] as IconData,
                              color: activity['color'] as Color,
                              size: 28,
                            ),
                          ),
                          const Gap(15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.blackColor,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  activity['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Styles.blackColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? activity['color'] as Color
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: isSelected 
                                  ? activity['color'] as Color
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const Gap(20),
            
            // Selected count
            if (selectedActivities.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Styles.highlightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Styles.highlightColor,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      '${selectedActivities.length} ${selectedActivities.length == 1 ? 'activity' : 'activities'} selected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Styles.highlightColor,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Gap(15),
            
            // Confirm button
            ElevatedButton(
              onPressed: _confirmActivities,
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.highlightColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Confirm Booking",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          
        ),
      ),
    );
  }

  

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Styles.highlightColor),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Styles.blackColor.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}