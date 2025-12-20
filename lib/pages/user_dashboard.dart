import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/pages/my_pets_page.dart';
import 'package:pawgoda/pages/booking_page.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Month selection
  DateTime selectedMonth = DateTime.now();
  
  // Get month name
  String get monthName => DateFormat('MMMM yyyy').format(selectedMonth);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser?.uid)
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                    final userName = userData?['name'] ?? 'Guest';
                    final photoURL = userData?['photoURL'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                                child: photoURL == null ? const Icon(Icons.person, size: 28) : null,
                              ),
                            ],
                          ),
                        ),

                        // Stats Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('bookings')
                                .where('customerId', isEqualTo: currentUser?.uid)
                                .snapshots(),
                            builder: (context, bookingSnapshot) {
                              if (!bookingSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final bookings = bookingSnapshot.data!.docs;
                              final totalBookings = bookings.length;
                              
                              // Count Active bookings
                              final activeBookings = bookings
                                  .where((doc) => 
                                      (doc.data() as Map<String, dynamic>)['status'] == 'Active')
                                  .length;
                              
                              // Count Completed bookings
                              final completedBookings = bookings
                                  .where((doc) => 
                                      (doc.data() as Map<String, dynamic>)['status'] == 'Completed')
                                  .length;

                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total',
                                      totalBookings.toString(),
                                      Icons.bookmark,
                                      Styles.highlightColor,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Active',
                                      activeBookings.toString(),
                                      Icons.pending_actions,
                                      Colors.orange,
                                    ),
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Complete',
                                      completedBookings.toString(),
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const Gap(25),

                        // Monthly Statistics Section with Pie Chart
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fixed header row - using IntrinsicHeight for proper sizing
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Title
                                    Expanded(
                                      child: Text(
                                        'Monthly Overview',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Gap(8),
                                    // Month navigation - compact version
                                    Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Left arrow
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.chevron_left, size: 16),
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                setState(() {
                                                  selectedMonth = DateTime(
                                                    selectedMonth.year,
                                                    selectedMonth.month - 1,
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                          // Month text
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              DateFormat('MMM yyyy').format(selectedMonth), // Shorter format
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Styles.highlightColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          // Right arrow
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.chevron_right, size: 16),
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                final nextMonth = DateTime(
                                                  selectedMonth.year,
                                                  selectedMonth.month + 1,
                                                );
                                                // Fixed the condition - removed extra parenthesis
                                                if (nextMonth.isBefore(DateTime.now().add(const Duration(days: 31)))) {
                                                  setState(() {
                                                    selectedMonth = nextMonth;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(16),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('bookings')
                                    .where('customerId', isEqualTo: currentUser?.uid)
                                    .where('status', isEqualTo: 'Active')
                                    .snapshots(),
                                builder: (context, activitySnapshot) {
                                  if (!activitySnapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  // Get all active bookings
                                  final activeBookings = activitySnapshot.data!.docs;

                                  if (activeBookings.isEmpty) {
                                    return _buildEmptyMonthlyStats();
                                  }

                                  // Fetch activities from all active bookings for selected month
                                  return StreamBuilder<List<QuerySnapshot>>(
                                    stream: Stream.fromFuture(
                                      Future.wait(
                                        activeBookings.map((booking) {
                                          return FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(booking.id)
                                              .collection('activities')
                                              .get();
                                        }).toList(),
                                      ),
                                    ),
                                    builder: (context, activitiesSnapshot) {
                                      if (!activitiesSnapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      // Combine all activities from all bookings
                                      final allActivities = <DocumentSnapshot>[];
                                      for (var snapshot in activitiesSnapshot.data!) {
                                        allActivities.addAll(snapshot.docs);
                                      }

                                      // Filter activities by selected month
                                      final monthActivities = allActivities.where((doc) {
                                        final data = doc.data() as Map<String, dynamic>?;
                                        if (data == null) return false;

                                        final activityDateStr = data['date'] as String?;
                                        if (activityDateStr == null) return false;

                                        try {
                                          final activityDate = DateFormat('yyyy-MM-dd').parse(activityDateStr);
                                          return activityDate.year == selectedMonth.year &&
                                                 activityDate.month == selectedMonth.month;
                                        } catch (e) {
                                          return false;
                                        }
                                      }).toList();

                                      if (monthActivities.isEmpty) {
                                        return _buildEmptyMonthlyStats();
                                      }

                                      // Calculate statistics based on activity status
                                      final now = DateTime.now();
                                      final today = DateTime(now.year, now.month, now.day);
                                      
                                      int incoming = 0;
                                      int pending = 0;
                                      int completed = 0;

                                      for (var activity in monthActivities) {
                                        final data = activity.data() as Map<String, dynamic>;
                                        final status = data['status'] as String?;
                                        final dateStr = data['date'] as String?;

                                        if (dateStr != null) {
                                          try {
                                            final activityDate = DateFormat('yyyy-MM-dd').parse(dateStr);
                                            final dateOnly = DateTime(activityDate.year, activityDate.month, activityDate.day);

                                            if (status == 'Completed') {
                                              completed++;
                                            } else if (dateOnly.isAfter(today)) {
                                              incoming++; // Future activities
                                            } else if (dateOnly.isAtSameMomentAs(today)) {
                                              pending++; // Today's pending activities
                                            } else {
                                              // Past uncompleted activities count as pending
                                              pending++;
                                            }
                                          } catch (e) {
                                            // Skip invalid dates
                                          }
                                        }
                                      }

                                      final total = monthActivities.length;

                                      return _buildPieChart(
                                        incoming: incoming,
                                        pending: pending,
                                        completed: completed,
                                        total: total,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const Gap(25),
                        
                        const Gap(20),

                       
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildActionCard(
                            'My Pets',
                            Icons.pets,
                            Colors.orange,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyPetsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const Gap(20),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const Gap(8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart({
    required int incoming,
    required int pending,
    required int completed,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pie Chart
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (incoming > 0)
                          PieChartSectionData(
                            value: incoming.toDouble(),
                            title: incoming.toString(),
                            color: Colors.purple,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (pending > 0)
                          PieChartSectionData(
                            value: pending.toDouble(),
                            title: pending.toString(),
                            color: Colors.orange,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (completed > 0)
                          PieChartSectionData(
                            value: completed.toDouble(),
                            title: completed.toString(),
                            color: Colors.green,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Incoming', incoming, Colors.purple),
                      const Gap(12),
                      _buildLegendItem('Pending', pending, Colors.orange),
                      const Gap(12),
                      _buildLegendItem('Completed', completed, Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),
          Divider(color: Colors.grey.shade200),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Styles.highlightColor),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.shade300,
              ),
              _buildStatItem(
                'Completion',
                total > 0 ? '${((completed / total) * 100).toStringAsFixed(0)}%' : '0%',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMonthlyStats() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const Gap(16),
          Text(
            'No activities this month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(8),
          Text(
            'Your monthly activity statistics will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}