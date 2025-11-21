import 'package:pawgoda/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ActivityCard extends StatelessWidget {
  final dynamic activity;
  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
