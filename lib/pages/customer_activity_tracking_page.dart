import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';

class CustomerActivityTrackingPage extends StatefulWidget {
  final String bookingId;
  final String petName;
  final List<String> selectedActivities;

  const CustomerActivityTrackingPage({
    Key? key,
    required this.bookingId,
    required this.petName,
    required this.selectedActivities,
  }) : super(key: key);

  @override
  State<CustomerActivityTrackingPage> createState() => _CustomerActivityTrackingPageState();
}

class _CustomerActivityTrackingPageState extends State<CustomerActivityTrackingPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Completed', 'Pending'];

  // Mock activity updates (in real app, this would come from Firebase)
  final List<Map<String, dynamic>> activityUpdates = [
    {
      'activityName': 'Feeding',
      'date': '2025-11-09',
      'time': '08:30 AM',
      'status': 'Completed',
      'note': 'Max enjoyed breakfast! Ate all the kibbles and drank water.',
      'imageUrl': 'https://example.com/feeding1.jpg', // In real app, Firebase Storage URL
      'staffName': 'Ewan',
      'timestamp': DateTime(2025, 11, 9, 8, 30),
    },
    {
      'activityName': 'Walking',
      'date': '2025-11-09',
      'time': '10:00 AM',
      'status': 'Completed',
      'note': '30 minutes walk in the park. Max was very energetic and playful!',
      'imageUrl': 'https://example.com/walking1.jpg',
      'staffName': 'Ewan',
      'timestamp': DateTime(2025, 11, 9, 10, 0),
    },
    {
      'activityName': 'Playtime',
      'date': '2025-11-09',
      'time': '02:00 PM',
      'status': 'Completed',
      'note': 'Had fun playing fetch and with other pets in the play area.',
      'imageUrl': 'https://example.com/playtime1.jpg',
      'staffName': 'Hadi',
      'timestamp': DateTime(2025, 11, 9, 14, 0),
    },
    {
      'activityName': 'Feeding',
      'date': '2025-11-09',
      'time': '06:00 PM',
      'status': 'Pending',
      'note': null,
      'imageUrl': null,
      'staffName': null,
      'timestamp': DateTime(2025, 11, 9, 18, 0),
    },
  ];

  List<Map<String, dynamic>> get filteredUpdates {
    if (selectedFilter == 'All') {
      return activityUpdates;
    }
    return activityUpdates
        .where((update) => update['status'] == selectedFilter)
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.highlightColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity Updates',
          style: TextStyle(
            color: Styles.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Styles.highlightColor),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Updates refreshed'),
                  backgroundColor: Styles.highlightColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header card
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: Styles.highlightColor, size: 24),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.petName,
                              style: TextStyle(
                                fontSize: 18,
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
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(6),
                            const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    backgroundColor: Styles.bgColor,
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

            // Activity timeline
            Expanded(
              child: filteredUpdates.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredUpdates.length,
                      separatorBuilder: (context, index) => const Gap(15),
                      itemBuilder: (context, index) {
                        final update = filteredUpdates[index];
                        return _buildActivityUpdateCard(update);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityUpdateCard(Map<String, dynamic> update) {
    final status = update['status'] as String;
    final isCompleted = status == 'Completed';
    final activityColor = _getActivityColor(update['activityName']);
    final activityIcon = _getActivityIcon(update['activityName']);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                        update['activityName'],
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
                            Icons.access_time,
                            size: 12,
                            color: Styles.blackColor.withOpacity(0.6),
                          ),
                          const Gap(4),
                          Text(
                            '${update['date']} at ${update['time']}',
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
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content (only for completed activities)
          if (isCompleted) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.grey.shade300),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Note
                  if (update['note'] != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notes,
                          size: 16,
                          color: Styles.highlightColor,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            update['note'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Styles.blackColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                  ],

                  // Photo placeholder (in real app, display actual image)
                  if (update['imageUrl'] != null) ...[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const Gap(8),
                            Text(
                              'Photo uploaded by staff',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              '(Image would be displayed here)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                  ],

                  // Staff info
                  if (update['staffName'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Styles.highlightColor,
                        ),
                        const Gap(8),
                        Text(
                          'Updated by ${update['staffName']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const Gap(8),
                  Text(
                    'Scheduled - waiting for staff update',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.blackColor.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
            'No $selectedFilter Updates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor,
            ),
          ),
          const Gap(10),
          Text(
            'Activity updates will appear here',
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