import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';

class ViewUpdatesPage extends StatelessWidget {
  final String bookingId;
  final String activityId;
  final String activityName;

  const ViewUpdatesPage({
    Key? key,
    required this.bookingId,
    required this.activityId,
    required this.activityName,
  }) : super(key: key);

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
    print('🔍 ViewUpdatesPage build');
    print('   BookingId: $bookingId');
    print('   ActivityId: $activityId');
    print('   ActivityName: $activityName');
    
    final activityColor = _getActivityColor(activityName);
    final activityIcon = _getActivityIcon(activityName);
    
    return Scaffold(
      backgroundColor: Styles.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Styles.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                activityIcon,
                color: activityColor,
                size: 20,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activityName,
                    style: TextStyle(
                      color: Styles.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Activity Updates',
                    style: TextStyle(
                      color: Styles.blackColor.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .collection('activities')
            .doc(activityId)
            .snapshots(),
        builder: (context, snapshot) {
          print('📡 StreamBuilder state: ${snapshot.connectionState}');
          print('   Has data: ${snapshot.hasData}');
          print('   Has error: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('   Error: ${snapshot.error}');
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Styles.highlightColor),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print('   Document does not exist!');
            return _buildEmptyState();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final updates = data['updates'] as List<dynamic>? ?? [];
          final activityStatus = data['status'] as String? ?? 'Pending';
          final activityTime = data['time'] as String? ?? '';
          final activityDate = data['date'] as String? ?? '';
          
          print('   Updates count: ${updates.length}');
          print('   Activity Status: $activityStatus');
          if (updates.isNotEmpty) {
            print('   First update: ${updates[0]}');
          }

          if (updates.isEmpty) {
            return _buildEmptyState();
          }

          // Reverse to show newest first
          final reversedUpdates = updates.reversed.toList();

          return Column(
            children: [
              // Activity Info Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activityColor.withOpacity(0.1),
                      activityColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: activityColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: activityColor,
                              ),
                              const Gap(6),
                              Text(
                                activityTime,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Styles.blackColor.withOpacity(0.7),
                                ),
                              ),
                              const Gap(12),
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: activityColor,
                              ),
                              const Gap(6),
                              Text(
                                activityDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Styles.blackColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Icons.update,
                                size: 14,
                                color: Styles.blackColor.withOpacity(0.5),
                              ),
                              const Gap(6),
                              Text(
                                '${updates.length} update${updates.length != 1 ? 's' : ''} posted',
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
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: activityStatus == 'Completed'
                            ? Colors.green.withOpacity(0.2)
                            : activityStatus == 'In Progress'
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activityStatus == 'Completed'
                              ? Colors.green
                              : activityStatus == 'In Progress'
                                  ? Colors.blue
                                  : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        activityStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: activityStatus == 'Completed'
                              ? Colors.green
                              : activityStatus == 'In Progress'
                                  ? Colors.blue
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Updates List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: reversedUpdates.length,
                  itemBuilder: (context, index) {
                    final update = reversedUpdates[index] as Map<String, dynamic>;
                    return _buildUpdateCard(
                      context, 
                      update, 
                      index, 
                      reversedUpdates.length,
                      activityColor,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpdateCard(
    BuildContext context,
    Map<String, dynamic> update,
    int index,
    int totalUpdates,
    Color activityColor,
  ) {
    final remarks = update['remarks'] as String? ?? '';
    final mediaUrl = update['mediaUrl'] as String?;
    final isImage = update['isImage'] as bool? ?? false;
    final isVideo = update['isVideo'] as bool? ?? false;
    final createdAt = update['createdAt'] as Timestamp?;

    String formattedDate = 'Unknown date';
    String timeAgo = '';
    
    if (createdAt != null) {
      final dateTime = createdAt.toDate();
      formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty && mediaUrl != 'null';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
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
                    color: activityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.update,
                    size: 20,
                    color: activityColor,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update #${totalUpdates - index}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Styles.blackColor,
                        ),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Styles.blackColor.withOpacity(0.4),
                          ),
                          const Gap(4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: Styles.blackColor.withOpacity(0.5),
                            ),
                          ),
                          if (timeAgo.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: Styles.blackColor.withOpacity(0.5),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: activityColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                timeAgo,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: activityColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasMedia)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVideo ? Icons.videocam : Icons.image,
                          size: 14,
                          color: Colors.green,
                        ),
                        const Gap(4),
                        Text(
                          isVideo ? 'Video' : 'Photo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Media Section
          if (hasMedia) ...[
            GestureDetector(
              onTap: () => _showMediaFullScreen(context, mediaUrl, isVideo),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                    child: Image.network(
                      mediaUrl,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 280,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: activityColor,
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 280,
                          color: Colors.grey.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const Gap(12),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Video overlay
                  if (isVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 50,
                              color: activityColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Zoom indicator
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                          Gap(6),
                          Text(
                            'Tap to enlarge',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Remarks Section
          if (remarks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: activityColor,
                      ),
                      const Gap(8),
                      Text(
                        'Staff Notes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Styles.blackColor.withOpacity(0.7),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: activityColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: activityColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      remarks,
                      style: TextStyle(
                        fontSize: 14,
                        color: Styles.blackColor.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!hasMedia) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Styles.blackColor.withOpacity(0.3),
                  ),
                  const Gap(8),
                  Text(
                    'No notes provided for this update',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.blackColor.withOpacity(0.4),
                      fontStyle: FontStyle.italic,
                    ),
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
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.green.withOpacity(0.7),
                  ),
                  const Gap(8),
                  Text(
                    'Photo uploaded without notes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.blackColor.withOpacity(0.5),
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Styles.highlightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.update_disabled,
              size: 80,
              color: Styles.highlightColor.withOpacity(0.4),
            ),
          ),
          const Gap(24),
          Text(
            'No Updates Yet',
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
              'Staff updates for this activity will appear here',
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

  void _showMediaFullScreen(BuildContext context, String mediaUrl, bool isVideo) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  mediaUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const Gap(16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            if (isVideo)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        Gap(8),
                        Text(
                          'Video playback coming soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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