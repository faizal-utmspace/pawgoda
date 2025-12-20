import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/styles.dart';
import 'payment_page.dart';
import 'customer_activity_tracking_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This version is compatible with activity_selection_page
/// It accepts selectedActivities and selectedPackage parameters
class AppointmentActivitiesPage extends StatefulWidget {
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

  @override
  State<AppointmentActivitiesPage> createState() => _AppointmentActivitiesPageState();
}

class _AppointmentActivitiesPageState extends State<AppointmentActivitiesPage> {
  Map<String, dynamic>? bookingData;
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;
  String? paymentStatus;

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    try {
      // Load booking data
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingDoc.exists) {
        bookingData = bookingDoc.data();
      }

      // Load payment status
      await _loadPaymentStatus();

      // Load activities
      final activitiesSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .collection('activities')
          .get();

      setState(() {
        activities = activitiesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading booking data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPaymentStatus() async {
    try {
      // Check in payment collection
      final paymentQuery = await FirebaseFirestore.instance
          .collection('payment')
          .where('bookingId', isEqualTo: widget.bookingId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (paymentQuery.docs.isNotEmpty) {
        setState(() {
          paymentStatus = paymentQuery.docs.first.data()['status']?.toString();
        });
        return;
      }

      // Check in bookings document
      if (bookingData != null) {
        setState(() {
          paymentStatus = bookingData!['paymentStatus']?.toString();
        });
      }
    } catch (e) {
      debugPrint('Error loading payment status: $e');
    }
  }

  bool _canViewActivities() {
    if (paymentStatus == null) return false;
    
    final status = paymentStatus!.toLowerCase();
    return status == 'success' || status == 'paid' || status == 'completed';
  }

  Color _getPaymentStatusColor() {
    switch (paymentStatus?.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusLabel() {
    if (paymentStatus == null) return 'Unpaid';
    
    switch (paymentStatus!.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'completed':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return 'Unpaid';
    }
  }

  IconData _getPaymentStatusIcon() {
    switch (paymentStatus?.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      default:
        return Icons.payment;
    }
  }

  void _showPaymentRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: _getPaymentStatusColor(),
              size: 28,
            ),
            const Gap(12),
            const Expanded(
              child: Text(
                'Payment Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPaymentStatusColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(),
                    color: _getPaymentStatusColor(),
                    size: 20,
                  ),
                  const Gap(10),
                  Text(
                    'Payment Status: ${_getPaymentStatusLabel()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getPaymentStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              paymentStatus?.toLowerCase() == 'pending'
                  ? 'Your payment is being processed. Activity updates will be available once payment is confirmed.'
                  : 'Complete payment to unlock activity updates and photos from our staff.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            if (paymentStatus?.toLowerCase() == 'failed') ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Previous payment attempt failed. Please retry payment.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentPage(
                    bookingId: widget.bookingId,
                    serviceName: widget.serviceName,
                    petName: widget.petName,
                    amount: _calculateAmount(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.payment),
            label: Text(paymentStatus?.toLowerCase() == 'failed' ? 'Retry Payment' : 'Pay Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Styles.highlightColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAmount() {
    // Use Firebase data if available, otherwise use widget data
    final totalAmount = bookingData?['totalAmount'];
    if (totalAmount != null) {
      return totalAmount is int ? totalAmount.toDouble() : totalAmount;
    }

    // Fallback calculation
    double baseAmount = 0.0;
    
    if (widget.serviceName.contains('Hotel')) {
      // Calculate based on package
      switch (widget.selectedPackage) {
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
    } else if (widget.serviceName.contains('Daycare')) {
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          backgroundColor: Styles.bgColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDaycare = widget.serviceName.contains('Daycare');
    final totalAmount = _calculateAmount();
    // Use activities from Firebase
    final activityList = activities.isNotEmpty 
        ? activities.map((a) => a['activityName'] as String).toList()
        : (widget.selectedActivities ?? []);
    
    final canViewActivities = _canViewActivities();

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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${widget.bookingId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(25),

            // Payment Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _getPaymentStatusColor().withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getPaymentStatusIcon(),
                      color: _getPaymentStatusColor(),
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.6),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          _getPaymentStatusLabel(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getPaymentStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!canViewActivities)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: Colors.red.shade700),
                          const Gap(6),
                          Text(
                            'Locked',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
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
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: Styles.highlightColor),
                      const Gap(10),
                      Text(
                        'Booking Details',
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
                  _buildInfoRow('Pet Name', widget.petName, Icons.pets),
                  const Gap(12),
                  _buildInfoRow('Breed', widget.breed, Icons.category),
                  const Gap(12),
                  _buildInfoRow('Service', widget.serviceName, Icons.room_service),
                  const Gap(12),
                  _buildInfoRow('Date', widget.bookingDate, Icons.calendar_today),
                  const Gap(12),
                  _buildInfoRow('Time', widget.bookingTime, Icons.access_time),
                  if (widget.checkOutDate != null) ...[
                    const Gap(12),
                    _buildInfoRow('Check-out', widget.checkOutDate!, Icons.exit_to_app),
                  ],
                  if (widget.specialNotes.isNotEmpty) ...[
                    const Gap(15),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const Gap(15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 18, color: Styles.highlightColor),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Special Notes',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Styles.blackColor.withOpacity(0.6),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                widget.specialNotes,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Styles.blackColor,
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

            if (activityList.isNotEmpty) ...[
              const Gap(25),

              // Activities Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Styles.bgColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_activity, color: Styles.highlightColor),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            'Selected Activities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                        ),
                        if (!canViewActivities)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline, size: 12, color: Colors.orange.shade700),
                                const Gap(4),
                                Text(
                                  'Locked',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Gap(5),
                    Text(
                      canViewActivities 
                          ? 'Staff will update these activities with photos'
                          : 'Complete payment to unlock activity updates',
                      style: TextStyle(
                        fontSize: 12,
                        color: Styles.blackColor.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Gap(15),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const Gap(15),
                    ...activityList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activityName = entry.value;
                      final color = _getActivityColor(activityName);
                      final icon = _getActivityIcon(activityName);
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < activityList.length - 1 ? 12 : 0,
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
                                  activityName,
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
                    colors: canViewActivities
                        ? [
                            Colors.blue.shade50,
                            Colors.blue.shade100.withOpacity(0.5),
                          ]
                        : [
                            Colors.orange.shade50,
                            Colors.orange.shade100.withOpacity(0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: canViewActivities ? Colors.blue.shade200 : Colors.orange.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      canViewActivities ? Icons.info_outline : Icons.lock_clock,
                      color: canViewActivities ? Colors.blue.shade700 : Colors.orange.shade700,
                      size: 28,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            canViewActivities 
                                ? 'Track Activity Updates'
                                : 'Payment Required',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canViewActivities 
                                  ? Colors.blue.shade900
                                  : Colors.orange.shade900,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            canViewActivities
                                ? 'You can view real-time updates and photos from staff during your pet\'s stay'
                                : 'Complete payment to unlock activity updates and view photos from our staff',
                            style: TextStyle(
                              fontSize: 12,
                              color: canViewActivities 
                                  ? Colors.blue.shade800
                                  : Colors.orange.shade800,
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
                if (activityList.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canViewActivities
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerActivityTrackingPage(
                                    bookingId: widget.bookingId,
                                    petName: widget.petName,
                                    selectedActivities: activityList,
                                  ),
                                ),
                              );
                            }
                          : _showPaymentRequiredDialog,
                      icon: Icon(canViewActivities ? Icons.visibility : Icons.lock_outline),
                      label: const Text('View Updates'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: canViewActivities 
                            ? Styles.highlightColor 
                            : Colors.grey.shade500,
                        side: BorderSide(
                          color: canViewActivities 
                              ? Styles.highlightColor 
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (activityList.isNotEmpty) const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            bookingId: widget.bookingId,
                            serviceName: widget.serviceName,
                            petName: widget.petName,
                            amount: totalAmount,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: Text(canViewActivities ? 'View Payment' : 'Pay Now'),
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