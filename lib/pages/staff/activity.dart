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

  // Fetch today activities from Firestore
  Future<void> _fetchActivities() async {
    try {


      final snapshot = await FirebaseFirestore.instance
        .collectionGroup('activities')
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .get();

      setState(() {
        activities.clear();
        activities.addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'bookingId': doc.reference.parent.parent?.id ?? '',
            'activityName': data['activityName'] ?? 'Unknown',
            'scheduledDate': data['date'] ?? 'Unknown',
            'scheduledTime': data['time'] ?? 'Unknown',
            'status': data['status'] ?? 'Pending',
            'note': data['note'] ?? '',
            // 'imageFile': data['imageFile'] != null ? File(data['imageFile']) : null,
          };
        }).toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  //final ImagePicker _picker = ImagePicker();
  String selectedFilter = 'Pending';
  final List<String> filters = ['All', 'Pending', 'Completed'];

  // Mock scheduled activities (in real app, this would come from Firebase)
  final List<Map<String, dynamic>> activities = [];

  List<Map<String, dynamic>> get filteredActivities {
    if (selectedFilter == 'All') {
      return activities;
    } else if (selectedFilter == 'Pending') {
      return activities
          .where((activity) => activity['status'] != 'Completed')
          .toList();
    }
    return activities
        .where((activity) => activity['status'] == selectedFilter)
        .toList();
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
          'Today Activities',
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