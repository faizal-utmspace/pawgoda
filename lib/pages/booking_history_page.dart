import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawgoda/pages/appointment_activities_page.dart';
import 'package:pawgoda/pages/payment_page.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({Key? key}) : super(key: key);

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  String selectedFilter = 'All';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getPaymentStatusColor(String? paymentStatus) {
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

  String _getPaymentStatusLabel(String? paymentStatus) {
    if (paymentStatus == null) return 'Unpaid';
    
    switch (paymentStatus.toLowerCase()) {
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

  IconData _getPaymentStatusIcon(String? paymentStatus) {
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

  Future<String?> _getPaymentStatus(String bookingId) async {
    try {
      // Check in payment collection for this booking
      final paymentQuery = await FirebaseFirestore.instance
          .collection('payment')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (paymentQuery.docs.isNotEmpty) {
        final paymentStatus = paymentQuery.docs.first.data()['status'];
        return paymentStatus?.toString();
      }

      // Check in bookings document
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (bookingDoc.exists) {
        final bookingData = bookingDoc.data();
        return bookingData?['paymentStatus']?.toString();
      }

      return null;
    } catch (e) {
      debugPrint('Error getting payment status: $e');
      return null;
    }
  }

  bool _canAccessActivities(String? paymentStatus) {
    if (paymentStatus == null) return false;
    
    final status = paymentStatus.toLowerCase();
    return status == 'success' || status == 'paid' || status == 'completed';
  }

  void _showPaymentRequiredDialog(BuildContext context, String bookingId, 
      String serviceName, String petName, double amount, String? paymentStatus) {
    final statusLabel = _getPaymentStatusLabel(paymentStatus);
    
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
              color: _getPaymentStatusColor(paymentStatus),
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
                color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPaymentStatusColor(paymentStatus).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(paymentStatus),
                    color: _getPaymentStatusColor(paymentStatus),
                    size: 20,
                  ),
                  const Gap(10),
                  Text(
                    'Payment Status: $statusLabel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getPaymentStatusColor(paymentStatus),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              paymentStatus?.toLowerCase() == 'pending'
                  ? 'Your payment is being processed. You can view activity updates once payment is confirmed.'
                  : 'Payment is required to access activity updates and booking details.',
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
                        'Previous payment failed. Please try again.',
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
                    bookingId: bookingId,
                    serviceName: serviceName,
                    petName: petName,
                    amount: amount,
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking History'),
          backgroundColor: Styles.bgColor,
        ),
        body: const Center(
          child: Text('Please log in to view bookings'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const PetBackButton(),
                  const Gap(20),
                  Text(
                    'Booking History',
                    style: TextStyle(
                      color: Styles.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('uid', isEqualTo: user.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const Gap(16),
                          Text('Error loading bookings: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  final allBookings = snapshot.data?.docs ?? [];
                  
                  // Filter bookings based on selected filter
                  final filteredBookings = selectedFilter == 'All'
                      ? allBookings
                      : allBookings.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['status']?.toLowerCase() == selectedFilter.toLowerCase();
                        }).toList();

                  if (allBookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const Gap(20),
                          Text(
                            'No bookings yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            'Book a hotel stay for your pet',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Summary card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
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
                                Icons.calendar_month,
                                color: Styles.highlightColor,
                                size: 32,
                              ),
                              const Gap(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Bookings',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Styles.blackColor.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '${allBookings.length}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Styles.highlightColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            _buildFilterChip('All', allBookings.length),
                            const Gap(8),
                            _buildFilterChip(
                              'Active',
                              allBookings.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['status']?.toLowerCase() == 'active';
                              }).length,
                            ),
                            const Gap(8),
                            _buildFilterChip(
                              'Completed',
                              allBookings.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['status']?.toLowerCase() == 'completed';
                              }).length,
                            ),
                            const Gap(8),
                            _buildFilterChip(
                              'Cancelled',
                              allBookings.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['status']?.toLowerCase() == 'cancelled';
                              }).length,
                            ),
                          ],
                        ),
                      ),
                      const Gap(20),

                      // Bookings list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final bookingDoc = filteredBookings[index];
                            final bookingData = bookingDoc.data() as Map<String, dynamic>;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FutureBuilder<String?>(
                                future: _getPaymentStatus(bookingDoc.id),
                                builder: (context, paymentSnapshot) {
                                  final paymentStatus = paymentSnapshot.data;
                                  
                                  return _buildBookingCard(
                                    context: context,
                                    bookingId: bookingDoc.id,
                                    petName: bookingData['petName'] ?? 'Unknown',
                                    serviceName: bookingData['serviceName'] ?? 'Service',
                                    status: bookingData['status'] ?? 'Pending',
                                    totalAmount: (bookingData['totalAmount'] ?? 0).toDouble(),
                                    startDate: bookingData['startDate'],
                                    endDate: bookingData['endDate'],
                                    bookingData: bookingData,
                                    paymentStatus: paymentStatus,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const Gap(6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Styles.highlightColor 
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = label;
        });
      },
      selectedColor: Styles.highlightColor.withOpacity(0.2),
      checkmarkColor: Styles.highlightColor,
      labelStyle: TextStyle(
        color: isSelected ? Styles.highlightColor : Styles.blackColor.withOpacity(0.7),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Styles.highlightColor : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String bookingId,
    required String petName,
    required String serviceName,
    required String status,
    required double totalAmount,
    required Timestamp? startDate,
    required Timestamp? endDate,
    required Map<String, dynamic> bookingData,
    String? paymentStatus,
  }) {
    final statusColor = _getStatusColor(status);
    final canAccess = _canAccessActivities(paymentStatus);
    final paymentStatusColor = _getPaymentStatusColor(paymentStatus);
    final paymentStatusLabel = _getPaymentStatusLabel(paymentStatus);

    return InkWell(
      onTap: () {
        if (canAccess) {
          // Payment completed - allow access
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentActivitiesPage(
                petType: bookingData['petType'] ?? 'Pet',
                serviceName: serviceName,
                bookingDate: startDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(startDate.toDate())
                    : 'N/A',
                bookingTime: bookingData['checkInTime'] ?? 'N/A',
                bookingId: bookingId,
                petName: petName,
                breed: bookingData['breed'] ?? 'Unknown',
                specialNotes: bookingData['specialNotes'] ?? '',
                checkOutDate: endDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(endDate.toDate())
                    : null,
                selectedActivities: [],
                selectedPackage: bookingData['selectedPackage'],
              ),
            ),
          );
        } else {
          // Payment not completed - show payment dialog
          _showPaymentRequiredDialog(
            context,
            bookingId,
            serviceName,
            petName,
            totalAmount,
            paymentStatus,
          );
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: canAccess ? Colors.grey.shade300 : paymentStatusColor.withOpacity(0.5),
            width: canAccess ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Styles.highlightColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.hotel, color: Styles.highlightColor, size: 22),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              petName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Styles.blackColor,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              serviceName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Styles.blackColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  
                  // Payment Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: paymentStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: paymentStatusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentStatusIcon(paymentStatus),
                          size: 14,
                          color: paymentStatusColor,
                        ),
                        const Gap(6),
                        Text(
                          'Payment: $paymentStatusLabel',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: paymentStatusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Gap(12),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const Gap(12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Styles.blackColor.withOpacity(0.6)),
                      const Gap(6),
                      Text(
                        startDate != null
                            ? DateFormat('MMM d, yyyy').format(startDate.toDate())
                            : 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          color: Styles.blackColor.withOpacity(0.7),
                        ),
                      ),
                      if (endDate != null) ...[
                        const Gap(8),
                        Icon(Icons.arrow_forward, size: 12, color: Styles.blackColor.withOpacity(0.4)),
                        const Gap(8),
                        Text(
                          DateFormat('MMM d, yyyy').format(endDate.toDate()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        'RM ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Styles.highlightColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Lock overlay if payment not completed
            if (!canAccess)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: paymentStatusColor,
                        ),
                        const Gap(8),
                        Text(
                          'Payment ${paymentStatusLabel.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: paymentStatusColor,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Tap to pay',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}