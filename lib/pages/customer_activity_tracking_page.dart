import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_updates_page.dart'; // Import the view updates page

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
  final List<String> filters = ['All', 'Completed', 'Pending', 'In Progress'];
  List<Map<String, dynamic>> activityUpdates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      isLoading = true;
    });

    try {
      final activitiesSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .collection('activities')
          .orderBy('date', descending: false)
          .get();

      setState(() {
        activityUpdates = activitiesSnapshot.docs.map((doc) {
          final data = doc.data();
          
          // Parse timestamp
          DateTime? timestamp;
          try {
            final dateStr = data['date'] ?? '';
            if (dateStr.isNotEmpty) {
              timestamp = DateFormat('yyyy-MM-dd').parse(dateStr);
            }
          } catch (e) {
            timestamp = DateTime.now();
          }

          // Get updates array
          final updates = data['updates'] as List<dynamic>? ?? [];
          
          // Count updates with media
          int mediaCount = 0;
          for (var update in updates) {
            final mediaUrl = update['mediaUrl'] as String?;
            if (mediaUrl != null && mediaUrl.isNotEmpty && mediaUrl != 'null') {
              mediaCount++;
            }
          }

          return {
            'id': doc.id,
            'activityName': data['activityName'] ?? '',
            'date': data['date'] ?? '',
            'time': data['time'] ?? '',
            'status': data['status'] ?? 'Pending',
            'note': data['note'] ?? '',
            'imageUrl': data['imageUrl'] ?? '',
            'updatedBy': data['updatedBy'] ?? '',
            'timestamp': timestamp,
            'updates': updates,
            'updateCount': updates.length,
            'mediaCount': mediaCount,
          };
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
            content: Text('Error loading activities: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
              _loadActivities();
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Styles.highlightColor,
              ),
            )
          : SafeArea(
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
                                    'Booking ID: ${widget.bookingId.substring(0, 8)}...',
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
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Divider(color: Colors.grey.shade300),
                        const Gap(12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.event_note,
                              '${activityUpdates.length}',
                              'Activities',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey.shade300,
                            ),
                            _buildStatItem(
                              Icons.check_circle,
                              '${activityUpdates.where((a) => a['status'] == 'Completed').length}',
                              'Completed',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey.shade300,
                            ),
                            _buildStatItem(
                              Icons.photo_camera,
                              '${activityUpdates.fold<int>(0, (sum, a) => sum + (a['mediaCount'] as int? ?? 0))}',
                              'Photos',
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
                    child: filteredUpdates.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: Styles.highlightColor,
                            onRefresh: _loadActivities,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: filteredUpdates.length,
                              separatorBuilder: (context, index) => const Gap(15),
                              itemBuilder: (context, index) {
                                final update = filteredUpdates[index];
                                return _buildActivityCard(update);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Styles.highlightColor),
            const Gap(6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Styles.blackColor,
              ),
            ),
          ],
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Styles.blackColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> update) {
    final status = update['status'] as String;
    final isCompleted = status == 'Completed';
    final activityColor = _getActivityColor(update['activityName']);
    final activityIcon = _getActivityIcon(update['activityName']);
    final updates = update['updates'] as List<dynamic>? ?? [];
    final updateCount = update['updateCount'] as int? ?? 0;
    final mediaCount = update['mediaCount'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: updateCount > 0
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewUpdatesPage(
                        bookingId: widget.bookingId,
                        activityId: update['id'],
                        activityName: update['activityName'],
                      ),
                    ),
                  ).then((_) => _loadActivities());
                }
              : null,
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
                        color: activityColor.withOpacity(0.15),
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
                                Icons.calendar_today,
                                size: 12,
                                color: Styles.blackColor.withOpacity(0.6),
                              ),
                              const Gap(4),
                              Text(
                                update['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Styles.blackColor.withOpacity(0.6),
                                ),
                              ),
                              const Gap(8),
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Styles.blackColor.withOpacity(0.6),
                              ),
                              const Gap(4),
                              Text(
                                update['time'],
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
                            : status == 'In Progress'
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green
                              : status == 'In Progress'
                                  ? Colors.blue
                                  : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.green
                              : status == 'In Progress'
                                  ? Colors.blue
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),

                // Update info section
                if (updateCount > 0) ...[
                  const Gap(12),
                  Divider(color: Colors.grey.shade300),
                  const Gap(12),
                  Row(
                    children: [
                      // Update count
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 16,
                              color: activityColor,
                            ),
                            const Gap(6),
                            Text(
                              '$updateCount update${updateCount != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Styles.blackColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Media count
                      if (mediaCount > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 16,
                              color: Colors.green,
                            ),
                            const Gap(6),
                            Text(
                              '$mediaCount photo${mediaCount != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      const Gap(12),
                      // View button
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: activityColor,
                      ),
                    ],
                  ),
                  const Gap(8),
                  // Latest update preview
                  if (updates.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: activityColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: activityColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest Update',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: activityColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            _getLatestUpdatePreview(updates),
                            style: TextStyle(
                              fontSize: 12,
                              color: Styles.blackColor.withOpacity(0.7),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  const Gap(12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Scheduled - waiting for staff update',
                          style: TextStyle(
                            fontSize: 12,
                            color: Styles.blackColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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

  String _getLatestUpdatePreview(List<dynamic> updates) {
    if (updates.isEmpty) return 'No updates yet';
    
    final latest = updates.last as Map<String, dynamic>;
    final remarks = latest['remarks'] as String? ?? '';
    final mediaUrl = latest['mediaUrl'] as String?;
    final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty && mediaUrl != 'null';
    
    if (remarks.isNotEmpty) {
      return remarks;
    } else if (hasMedia) {
      final isVideo = latest['isVideo'] as bool? ?? false;
      return isVideo ? 'Video uploaded by staff' : 'Photo uploaded by staff';
    }
    
    return 'Update posted by staff';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Styles.highlightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 80,
              color: Styles.highlightColor.withOpacity(0.4),
            ),
          ),
          const Gap(24),
          Text(
            'No $selectedFilter Updates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor.withOpacity(0.6),
            ),
          ),
          const Gap(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Activity updates will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Styles.blackColor.withOpacity(0.4),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}