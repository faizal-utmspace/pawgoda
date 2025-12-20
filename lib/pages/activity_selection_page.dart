import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import 'appointment_activities_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // Activity templates loaded from Firebase
  List<Map<String, dynamic>> activityTemplates = [];
  bool isLoadingActivities = true;

  @override
  void initState() {
    super.initState();
    _loadActivityTemplates();
  }

  Future<void> _loadActivityTemplates() async {
    try {
      final settingsDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('NesWMZ7U8uIlMoJo1WC9')
          .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data();
        final activities = data?['values'] as List<dynamic>? ?? [];

        setState(() {
          activityTemplates = activities.map((activityName) {
            return _createActivityTemplate(activityName.toString());
          }).toList();
          isLoadingActivities = false;
        });
      } else {
        // Fallback to default activities if settings not found
        _loadDefaultActivities();
      }
    } catch (e) {
      print('Error loading activities: $e');
      _loadDefaultActivities();
    }
  }

  Map<String, dynamic> _createActivityTemplate(String name) {
    // Map activity names to icons, colors, and descriptions
    IconData icon;
    Color color;
    String description;

    switch (name.toLowerCase()) {
      case 'feeding':
        icon = Icons.restaurant;
        color = Colors.orange;
        description = 'Regular feeding according to schedule';
        break;
      case 'walking':
        icon = Icons.directions_walk;
        color = Colors.green;
        description = 'Daily walking and outdoor exercise';
        break;
      case 'playtime':
        icon = Icons.sports_esports;
        color = Colors.blue;
        description = 'Interactive play sessions';
        break;
      case 'medication':
        icon = Icons.medication;
        color = Colors.red;
        description = 'Medication administration if needed';
        break;
      case 'grooming':
        icon = Icons.shower;
        color = Colors.purple;
        description = 'Grooming and hygiene care';
        break;
      case 'bathing':
        icon = Icons.bathtub;
        color = Colors.cyan;
        description = 'Bath and cleaning service';
        break;
      default:
        icon = Icons.pets;
        color = Colors.grey;
        description = name;
    }

    return {
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
      'isSelected': false,
    };
  }

  void _loadDefaultActivities() {
    setState(() {
      activityTemplates = [
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
      ];
      isLoadingActivities = false;
    });
  }

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

  String _calculateTotalPrice() {
    double totalAmount = 0;
    
    if (widget.selectedPackage != null) {
      switch (widget.selectedPackage!.toLowerCase()) {
        case 'normal':
          totalAmount = 80.0;
          break;
        case 'deluxe':
          totalAmount = 150.0;
          break;
        case 'vip':
          totalAmount = 250.0;
          break;
        default:
          totalAmount = 80.0;
      }
    } else {
      totalAmount = 50.0; // Daycare default
    }

    // Calculate days
    if (widget.checkOutDate != null) {
      final days = widget.checkOutDate!.difference(widget.checkInDate).inDays;
      if (days > 0) {
        totalAmount *= days;
      }
    }

    return 'RM ${totalAmount.toStringAsFixed(2)}';
  }

  void _confirmActivities() async {
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

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();
      final customerName = userData?['name'] ?? 'Unknown';

      // Get pet data to find petId
      final petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('ownerId', isEqualTo: user.uid)
          .where('name', isEqualTo: widget.petName)
          .limit(1)
          .get();

      String? petId;
      if (petsSnapshot.docs.isNotEmpty) {
        petId = petsSnapshot.docs.first.id;
      }

      // Calculate total amount based on package
      double totalAmount = 0;
      if (widget.selectedPackage != null) {
        switch (widget.selectedPackage!.toLowerCase()) {
          case 'normal':
            totalAmount = 80.0;
            break;
          case 'deluxe':
            totalAmount = 150.0;
            break;
          case 'vip':
            totalAmount = 250.0;
            break;
          default:
            totalAmount = 80.0;
        }
      } else {
        // Daycare default price
        totalAmount = 50.0;
      }

      // If it's multi-day hotel, multiply by number of days
      if (widget.checkOutDate != null) {
        final days = widget.checkOutDate!.difference(widget.checkInDate).inDays;
        if (days > 0) {
          totalAmount *= days;
        }
      }

      final now = Timestamp.now();
      
      // Create booking document
      final bookingData = {
        'createdAt': now,
        'customerId': user.uid,
        'customerName': customerName,
        'endDate': widget.checkOutDate != null 
            ? Timestamp.fromDate(widget.checkOutDate!)
            : Timestamp.fromDate(widget.checkInDate),
        'petId': petId ?? '',
        'petName': widget.petName,
        'petType': widget.petType,
        'startDate': Timestamp.fromDate(widget.checkInDate),
        'status': 'Active',
        'totalAmount': totalAmount,
        'uid': user.uid,
        'updatedAt': now,
        'serviceName': widget.serviceName,
        'breed': widget.breed,
        'specialNotes': widget.specialNotes,
        'checkInTime': widget.checkInTime.format(context),
        'selectedPackage': widget.selectedPackage ?? 'Daycare',
      };

      // Save booking to Firestore
      final bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(bookingData);

      final actualBookingId = bookingRef.id;

      // Create activities subcollection
      final batch = FirebaseFirestore.instance.batch();

      for (String activityName in selectedActivities) {
        final activityRef = FirebaseFirestore.instance
            .collection('bookings')
            .doc(actualBookingId)
            .collection('activities')
            .doc();

        final activityData = {
          'activityName': activityName,
          'bookingId': actualBookingId,
          'date': DateFormat('yyyy-MM-dd').format(widget.checkInDate),
          'imageUrl': '',
          'lastUpdated': now,
          'note': '',
          'status': 'Pending',
          'time': widget.checkInTime.format(context),
          'updatedAt': now,
          'updatedBy': '',
          'updates': [],
        };

        batch.set(activityRef, activityData);
      }

      // Commit all activities at once
      await batch.commit();

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Navigate to appointment details page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentActivitiesPage(
              petType: widget.petType,
              serviceName: widget.serviceName,
              bookingDate: DateFormat('EEEE, MMMM d, yyyy').format(widget.checkInDate),
              bookingTime: widget.checkInTime.format(context),
              bookingId: actualBookingId,
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

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDaycare = widget.serviceName.contains('Daycare');
    
    // Show loading while fetching activities
    if (isLoadingActivities) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Select Activities"),
          backgroundColor: Styles.bgColor,
          foregroundColor: Styles.blackColor,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Gap(16),
              Text('Loading activities...'),
            ],
          ),
        ),
      );
    }
    
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
                    'Check-in: ${DateFormat('MMM d, yyyy').format(widget.checkInDate)}',
                  ),
                  if (!isDaycare && widget.checkOutDate != null) ...[
                    const Gap(8),
                    _buildSummaryRow(
                      Icons.event_available,
                      'Check-out: ${DateFormat('MMM d, yyyy').format(widget.checkOutDate!)}',
                    ),
                    const Gap(8),
                    _buildSummaryRow(
                      Icons.hotel,
                      '${widget.checkOutDate!.difference(widget.checkInDate).inDays} days',
                    ),
                  ],
                  const Gap(12),
                  Divider(color: Colors.grey.shade300),
                  const Gap(8),
                  // Total Price
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 20, color: Styles.highlightColor),
                      const Gap(8),
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Styles.blackColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _calculateTotalPrice(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Styles.highlightColor,
                        ),
                      ),
                    ],
                  ),
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