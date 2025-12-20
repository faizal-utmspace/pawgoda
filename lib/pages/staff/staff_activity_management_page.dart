import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/pages/staff/activity_details.dart';

class StaffActivityManagementPage extends StatefulWidget {
  final String bookingId;
  final String petName;
  final List<String> selectedActivities;

  const StaffActivityManagementPage({
    Key? key,
    required this.bookingId,
    required this.petName,
    required this.selectedActivities,
  }) : super(key: key);

  @override
  State<StaffActivityManagementPage> createState() =>
      _StaffActivityManagementPageState();
}

class _StaffActivityManagementPageState
    extends State<StaffActivityManagementPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Incoming', 'Pending', 'In Progress', 'Completed'];
  
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;
  String? paymentStatus;
  bool canManageActivities = false;

  @override
  void initState() {
    super.initState();
    _fetchPaymentStatus();
    _fetchActivities();
  }

  // Fetch payment status from payment collection
  Future<void> _fetchPaymentStatus() async {
    try {
      // Check in payment collection for this booking
      final paymentQuery = await FirebaseFirestore.instance
          .collection('payment')
          .where('bookingId', isEqualTo: widget.bookingId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (paymentQuery.docs.isNotEmpty) {
        final status = paymentQuery.docs.first.data()['status']?.toString();
        setState(() {
          paymentStatus = status;
          canManageActivities = _canManageActivities(status);
        });
        return;
      }

      // Check in bookings document as fallback
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingDoc.exists) {
        final status = bookingDoc.data()?['paymentStatus']?.toString();
        setState(() {
          paymentStatus = status;
          canManageActivities = _canManageActivities(status);
        });
      }
    } catch (e) {
      debugPrint('Error fetching payment status: $e');
      setState(() {
        paymentStatus = null;
        canManageActivities = false;
      });
    }
  }

  bool _canManageActivities(String? status) {
    if (status == null) return false;
    final statusLower = status.toLowerCase();
    return statusLower == 'success' || 
           statusLower == 'paid' || 
           statusLower == 'completed';
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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

  String _getPaymentStatusLabel(String? status) {
    if (status == null) return 'Unpaid';
    
    switch (status.toLowerCase()) {
      case 'success':
      case 'paid':
      case 'completed':
        return 'Paid';
      case 'pending':
        return 'Pending Payment';
      case 'failed':
        return 'Payment Failed';
      default:
        return 'Unpaid';
    }
  }

  Future<void> _fetchActivities() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .collection('activities')
          .get();

      setState(() {
        activities.clear();
        activities.addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          final activityDateString = data['date'] ?? '';

          DateTime? activityDate;
          try {
            activityDate = DateFormat('yyyy-MM-dd').parse(activityDateString);
          } catch (e) {
            debugPrint('Error parsing date: $activityDateString');
          }

          // Determine display status
          String displayStatus = data['status'] ?? 'Pending';

          // Only override status for future dates
          if (activityDate != null) {
            final today = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final activityDateOnly = DateTime(
                activityDate.year, activityDate.month, activityDate.day);

            if (activityDateOnly.isAfter(today)) {
              // Future date = Incoming (only if not completed)
              if (displayStatus != 'Completed') {
                displayStatus = 'Incoming';
              }
            }
            // For today or past dates, keep the original status from Firestore
          }

          return {
            'id': doc.id,
            'bookingId': widget.bookingId,
            'activityName': data['activityName'] ?? 'Unknown',
            'scheduledDate': activityDateString,
            'scheduledTime': data['time'] ?? 'Unknown',
            'status': displayStatus,
            'originalStatus': data['status'] ?? 'Pending',
            'note': data['note'] ?? '',
            'activityDate': activityDate,
          };
        }).toList());

        // Sort by date and time
        activities.sort((a, b) {
          if (a['activityDate'] == null && b['activityDate'] == null) return 0;
          if (a['activityDate'] == null) return 1;
          if (b['activityDate'] == null) return -1;
          return (a['activityDate'] as DateTime)
              .compareTo(b['activityDate'] as DateTime);
        });

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching activities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredActivities {
    if (selectedFilter == 'All') {
      return activities;
    } else if (selectedFilter == 'Incoming') {
      return activities
          .where((activity) => activity['status'] == 'Incoming')
          .toList();
    } else if (selectedFilter == 'Pending') {
      return activities
          .where((activity) =>
              activity['status'] == 'Pending' ||
              activity['originalStatus'] == 'Pending')
          .toList();
    } else if (selectedFilter == 'In Progress') {
      return activities
          .where((activity) =>
              activity['status'] == 'In Progress' ||
              activity['originalStatus'] == 'In Progress')
          .toList();
    } else if (selectedFilter == 'Completed') {
      return activities
          .where((activity) => activity['status'] == 'Completed')
          .toList();
    }
    return activities;
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

  Color _getActivityColor(String status) {
    switch (status.toLowerCase()) {
      case 'incoming':
        return Colors.purple;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'due':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.petName,
              style: TextStyle(
                color: Styles.blackColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Activities',
              style: TextStyle(
                color: Styles.blackColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Styles.highlightColor),
            onPressed: _fetchActivities,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Payment status warning banner (if not paid)
            if (!canManageActivities) ...[
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _getPaymentStatusColor(paymentStatus),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: _getPaymentStatusColor(paymentStatus),
                      size: 28,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Status: ${_getPaymentStatusLabel(paymentStatus)}\nActivities cannot be updated until payment is completed.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Styles.blackColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Pet info card
            Container(
              margin: const EdgeInsets.all(20),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Styles.highlightColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets,
                      color: Styles.highlightColor,
                      size: 28,
                    ),
                  ),
                  const Gap(15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activities.length} Total Activities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Styles.blackColor,
                          ),
                        ),
                        Text(
                          'Booking ID: ${widget.bookingId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (context, index) => const Gap(10),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;

                  // Calculate count for each filter
                  int count;
                  if (filter == 'All') {
                    count = activities.length;
                  } else if (filter == 'Incoming') {
                    count = activities
                        .where((a) => a['status'] == 'Incoming')
                        .length;
                  } else if (filter == 'Pending') {
                    count = activities
                        .where((a) =>
                            a['status'] == 'Pending' ||
                            a['originalStatus'] == 'Pending')
                        .length;
                  } else if (filter == 'In Progress') {
                    count = activities
                        .where((a) =>
                            a['status'] == 'In Progress' ||
                            a['originalStatus'] == 'In Progress')
                        .length;
                  } else {
                    count = activities
                        .where((a) => a['status'] == filter)
                        .length;
                  }

                  return FilterChip(
                    label: Text('$filter ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: Styles.highlightColor.withOpacity(0.2),
                    checkmarkColor: Styles.highlightColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Styles.highlightColor
                          : Styles.blackColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Styles.highlightColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  );
                },
              ),
            ),

            const Gap(10),

            // Activities list
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Styles.highlightColor,
                      ),
                    )
                  : filteredActivities.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredActivities.length,
                          separatorBuilder: (context, index) => const Gap(15),
                          itemBuilder: (context, index) {
                            final activity = filteredActivities[index];
                            return _buildActivityCard(activity);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final status = activity['status'] as String;
    final isCompleted = status == 'Completed';
    final activityColor = _getActivityColor(activity['status']);
    final activityIcon = _getActivityIcon(activity['activityName']);

    return Container(
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? activityColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            // Check payment status first
            if (!canManageActivities) {
              _showPaymentRequiredDialog();
              return;
            }

            // Check if activity is incoming
            if (status == 'Incoming') {
              _showIncomingActivityDialog(activity);
              return;
            }

            // Update to "In Progress" if currently "Pending"
            if (status == 'Pending' || activity['originalStatus'] == 'Pending') {
              await _markActivityInProgress(activity['id']);
            }

            // Allow access to activity details
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ActivityDetailsPage(
                bookingId: activity['bookingId'],
                activityId: activity['id'],
                activityData: activity,
              ),
            );

            // Refresh activities after modal closes
            await _fetchActivities();
            
            // Check if all activities are completed and update booking status
            await _checkAndUpdateBookingStatus();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: activityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activityIcon,
                        color: activityColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['activityName'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                          const Gap(2),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: Styles.blackColor.withOpacity(0.6),
                              ),
                              const Gap(4),
                              Text(
                                activity['scheduledTime'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Styles.blackColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.2)
                            : (status == 'In Progress'
                                ? Colors.blue.withOpacity(0.2)
                                : (status == 'Incoming'
                                    ? Colors.purple.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2))),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.green
                              : (status == 'In Progress'
                                  ? Colors.blue
                                  : (status == 'Incoming'
                                      ? Colors.purple
                                      : Colors.orange)),
                        ),
                      ),
                    ),
                  ],
                ),

                // Show date info
                const Gap(12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Styles.highlightColor,
                    ),
                    const Gap(6),
                    Text(
                      activity['scheduledDate'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Styles.blackColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),

                // Show note if completed
                if (isCompleted && activity['note'] != null && activity['note'].isNotEmpty) ...[
                  const Gap(12),
                  Divider(color: Colors.grey.shade300),
                  const Gap(12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          activity['note'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Action hint for non-completed activities
                if (!isCompleted) ...[
                  const Gap(12),
                  Row(
                    children: [
                      Icon(
                        !canManageActivities 
                            ? Icons.lock_outline
                            : (status == 'Incoming' 
                                ? Icons.visibility 
                                : Icons.touch_app),
                        size: 16,
                        color: !canManageActivities 
                            ? Colors.red 
                            : (status == 'Incoming' 
                                ? Colors.purple 
                                : Styles.highlightColor),
                      ),
                      const Gap(8),
                      Text(
                        !canManageActivities
                            ? 'Payment required to update'
                            : (status == 'Incoming'
                                ? 'Tap to view (scheduled for future)'
                                : 'Tap to update this activity'),
                        style: TextStyle(
                          fontSize: 12,
                          color: !canManageActivities 
                              ? Colors.red 
                              : (status == 'Incoming' 
                                  ? Colors.purple 
                                  : Styles.highlightColor),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: !canManageActivities 
                            ? Colors.red 
                            : (status == 'Incoming' 
                                ? Colors.purple 
                                : Styles.highlightColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Styles.highlightColor.withOpacity(0.3),
          ),
          const Gap(20),
          Text(
            'No $selectedFilter Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor,
            ),
          ),
          const Gap(10),
          Text(
            'Activities will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Styles.blackColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
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
            Text(
              'Payment Status: ${_getPaymentStatusLabel(paymentStatus)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Styles.blackColor,
              ),
            ),
            const Gap(12),
            Text(
              'Activities cannot be updated until the booking payment is completed.',
              style: TextStyle(
                fontSize: 14,
                color: Styles.blackColor.withOpacity(0.7),
              ),
            ),
            const Gap(8),
            Text(
              'Please contact the customer to complete the payment.',
              style: TextStyle(
                fontSize: 14,
                color: Styles.blackColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: Styles.highlightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncomingActivityDialog(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Colors.purple,
              size: 28,
            ),
            const Gap(12),
            const Expanded(
              child: Text(
                'Upcoming Activity',
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
            Text(
              activity['activityName'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Styles.blackColor,
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.purple),
                const Gap(6),
                Text(
                  'Scheduled: ${activity['scheduledDate']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Styles.blackColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const Gap(6),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.purple),
                const Gap(6),
                Text(
                  'Time: ${activity['scheduledTime']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Styles.blackColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple, size: 20),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'This activity is scheduled for a future date. You can view details but cannot update until the scheduled date arrives.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Styles.blackColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: Styles.highlightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mark activity as "In Progress" when staff opens it
  Future<void> _markActivityInProgress(String activityId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .collection('activities')
          .doc(activityId)
          .update({
        'status': 'In Progress',
        'startedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      debugPrint('🔵 Activity marked as In Progress');
    } catch (e) {
      debugPrint('❌ Error marking activity in progress: $e');
      // Don't show error to user, this is a background operation
    }
  }

  // Check if all activities are completed and update booking status
  Future<void> _checkAndUpdateBookingStatus() async {
    try {
      debugPrint('🔍 Checking if all activities are completed...');
      
      // Use the activities already fetched in state
      if (activities.isEmpty) {
        debugPrint('⚠️ No activities found for this booking');
        return;
      }

      // Check if all activities are completed
      bool allCompleted = true;
      int totalActivities = activities.length;
      int completedCount = 0;

      for (var activity in activities) {
        // Use originalStatus to check actual completion, not display status
        final status = activity['originalStatus'] ?? activity['status'];
        if (status == 'Completed') {
          completedCount++;
        } else {
          allCompleted = false;
        }
      }

      debugPrint('📊 Activity Status: $completedCount/$totalActivities completed');

      // If all activities are completed, update booking status
      if (allCompleted && totalActivities > 0) {
        debugPrint('✅ All activities completed! Updating booking status...');
        
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
          'status': 'Completed',
          'completedAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Booking status updated to Completed!');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.white),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      '🎉 All activities completed! Booking marked as complete.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        debugPrint('⏳ Still have pending activities: ${totalActivities - completedCount} remaining');
      }
    } catch (e) {
      debugPrint('❌ Error checking booking status: $e');
      // Don't show error to user as this is a background operation
    }
  }
}