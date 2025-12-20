import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pawgoda/pages/staff/activity_details.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityPage extends StatefulWidget {

  const ActivityPage({
    super.key,
  });

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    try {
      final today = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(today);

      final snapshot = await FirebaseFirestore.instance
        .collectionGroup('activities')
        .get();

      // Fetch booking details for each activity
      List<Map<String, dynamic>> activitiesWithBookingDetails = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bookingId = doc.reference.parent.parent?.id ?? '';
        
        // Fetch booking details
        Map<String, dynamic> bookingData = {};
        if (bookingId.isNotEmpty) {
          try {
            final bookingDoc = await FirebaseFirestore.instance
                .collection('bookings')
                .doc(bookingId)
                .get();
            
            if (bookingDoc.exists) {
              bookingData = bookingDoc.data() ?? {};
            }
          } catch (e) {
            debugPrint('Error fetching booking details: $e');
          }
        }
        
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
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final activityDateOnly = DateTime(activityDate.year, activityDate.month, activityDate.day);
          
          if (activityDateOnly.isAfter(today)) {
            // Future date = Incoming (only if not completed)
            if (displayStatus != 'Completed') {
              displayStatus = 'Incoming';
            }
          }
          // For today or past dates, keep the original status from Firestore
        }
        
        activitiesWithBookingDetails.add({
          'id': doc.id,
          'bookingId': bookingId,
          'activityName': data['activityName'] ?? 'Unknown',
          'scheduledDate': activityDateString,
          'scheduledTime': data['time'] ?? 'Unknown',
          'status': displayStatus,
          'originalStatus': data['status'] ?? 'Pending',
          'note': data['note'] ?? '',
          'activityDate': activityDate,
          // Booking details
          'petName': bookingData['petName'] ?? 'Unknown Pet',
          'petType': bookingData['petType'] ?? '',
          'customerName': bookingData['customerName'] ?? 'Unknown Customer',
          'serviceType': bookingData['serviceType'] ?? '',
          'bookingStatus': bookingData['status'] ?? '',
        });
      }

      setState(() {
        activities.clear();
        activities.addAll(activitiesWithBookingDetails);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching activities: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  String selectedFilter = 'Pending';
  final List<String> filters = ['All', 'Incoming', 'Pending', 'In Progress', 'Completed'];


  final List<Map<String, dynamic>> activities = [];

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
        title: Text(
          'Activities List',
          style: TextStyle(
            color: Styles.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: Styles.highlightColor.withOpacity(0.2),
                    checkmarkColor: Styles.highlightColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Styles.highlightColor : Styles.blackColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
              child: filteredActivities.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredActivities.length,
                      separatorBuilder: (context, index) => const Gap(15),
                      itemBuilder: (context, index) {
                        final activity = filteredActivities[index];
                        return buildActivityCard(activity);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActivityCard(Map<String, dynamic> activity) {
    final status = activity['status'] as String;
    final isCompleted = status == 'Completed';
    final activityColor = _getActivityColor(activity['status']);
    final activityIcon = _getActivityIcon(activity['activityName']);

    return Container(
      decoration: BoxDecoration(
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
          onTap:() async {
            // Update to "In Progress" if currently "Pending"
            if (activity['status'] == 'Pending' || activity['originalStatus'] == 'Pending') {
              try {
                await FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(activity['bookingId'])
                    .collection('activities')
                    .doc(activity['id'])
                    .update({
                  'status': 'In Progress',
                  'startedAt': FieldValue.serverTimestamp(),
                  'lastUpdated': FieldValue.serverTimestamp(),
                });
                debugPrint('🔵 Activity marked as In Progress');
              } catch (e) {
                debugPrint('❌ Error marking activity in progress: $e');
              }
            }

            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ActivityDetailsPage(bookingId: activity['bookingId'], activityId: activity['id'], activityData: activity)
            );

            _fetchActivities();
          } ,
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
                          const Gap(4),
                          Row(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 12,
                                color: Styles.highlightColor,
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  '${activity['petName']} • ${activity['customerName']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Styles.blackColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                            : (status == 'In Progress' ? Colors.blue.withOpacity(0.2) : Colors.orange.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.green 
                          : (status == 'In Progress' ? Colors.blue : Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),

                // Booking details
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Styles.highlightColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Styles.highlightColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              fontWeight: FontWeight.w600,
                              color: Styles.blackColor,
                            ),
                          ),
                        ],
                      ),
                      if (activity['serviceType'] != null && activity['serviceType'].isNotEmpty) ...[
                        const Gap(6),
                        Row(
                          children: [
                            Icon(
                              Icons.room_service,
                              size: 14,
                              color: Styles.highlightColor,
                            ),
                            const Gap(6),
                            Expanded(
                              child: Text(
                                activity['serviceType'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Styles.blackColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Gap(6),
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 14,
                            color: Styles.highlightColor,
                          ),
                          const Gap(6),
                          Text(
                            activity['bookingId'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Styles.blackColor.withOpacity(0.5),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Show details if completed
                if (isCompleted) ...[
                  const Gap(12),
                  Divider(color: Colors.grey.shade300),
                  const Gap(12),
                  if (activity['note'] != null && activity['note'].isNotEmpty)
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
                          ),
                        ),
                      ],
                    ),
                  if (activity['imageFile'] != null) ...[
                    const Gap(8),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 16,
                          color: Colors.green,
                        ),
                        const Gap(8),
                        Text(
                          'Photo uploaded',
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  const Gap(12),
                  // Row(
                  //   children: [
                  //     Icon(
                  //       Icons.touch_app,
                  //       size: 16,
                  //       color: Styles.highlightColor,
                  //     ),
                  //     const Gap(8),
                  //     Text(
                  //       'Tap to update this activity',
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         color: Styles.highlightColor,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //     const Spacer(),
                  //     Icon(
                  //       Icons.arrow_forward_ios,
                  //       size: 14,
                  //       color: Styles.highlightColor,
                  //     ),
                  //   ],
                  // ),
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
}