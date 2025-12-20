import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/utils/styles.dart';
import 'staff_activity_management_page.dart';

/// Staff Bookings List Page
/// Shows all active bookings for staff to manage activities
class StaffBookingsListPage extends StatefulWidget {
  const StaffBookingsListPage({Key? key}) : super(key: key);

  @override
  State<StaffBookingsListPage> createState() => _StaffBookingsListPageState();
}

class _StaffBookingsListPageState extends State<StaffBookingsListPage> {
  String selectedFilter = 'Active';
  final List<String> filters = ['All', 'Active', 'Completed'];

  // Mock bookings data (in real app, fetch from Firebase based on staff role)
  final List<Map<String, dynamic>> staffBookings = [
    {
      'bookingId': 'PG1234567',
      'petName': 'Max',
      'petType': 'Cat',
      'customerName': 'Afi',
      'serviceType': 'Hotel Accommodation',
      'package': 'Deluxe',
      'checkInDate': 'Nov 9, 2025',
      'checkOutDate': 'Nov 15, 2025',
      'status': 'Active',
      'selectedActivities': ['Feeding', 'Walking', 'Playtime'],
      'pendingActivities': 8,
      'completedActivities': 4,
      'color': Colors.blue,
    },
    {
      'bookingId': 'PG1234568',
      'petName': 'Bella',
      'petType': 'Dog',
      'customerName': 'Edda',
      'serviceType': 'Daycare',
      'package': null,
      'checkInDate': 'Nov 9, 2025',
      'checkOutDate': null,
      'status': 'Active',
      'selectedActivities': ['Feeding', 'Playtime'],
      'pendingActivities': 3,
      'completedActivities': 1,
      'color': Colors.orange,
    },
    {
      'bookingId': 'PG1234569',
      'petName': 'Charlie',
      'petType': 'Cat',
      'customerName': 'Faizal',
      'serviceType': 'Hotel Accommodation',
      'package': 'VIP',
      'checkInDate': 'Nov 5, 2025',
      'checkOutDate': 'Nov 8, 2025',
      'status': 'Completed',
      'selectedActivities': ['Feeding', 'Walking', 'Playtime', 'Medication'],
      'pendingActivities': 0,
      'completedActivities': 12,
      'color': Colors.green,
    },
  ];

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedFilter == 'All') {
      return staffBookings;
    }
    return staffBookings
        .where((booking) => booking['status'] == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Manage Bookings',
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
                  content: const Text('Bookings refreshed'),
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
            // Staff info card
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
                      Icons.admin_panel_settings,
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
                          'Staff Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.blackColor,
                          ),
                        ),
                        Text(
                          '${filteredBookings.length} ${selectedFilter.toLowerCase()} bookings',
                          style: TextStyle(
                            fontSize: 13,
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
                          'On Duty',
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

            // Bookings list
            Expanded(
              child: filteredBookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredBookings.length,
                      separatorBuilder: (context, index) => const Gap(15),
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return _buildBookingCard(booking);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final isActive = status == 'Active';
    final pendingCount = booking['pendingActivities'] as int;

    return Container(
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Styles.highlightColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isActive
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffActivityManagementPage(
                        bookingId: booking['bookingId'],
                        petName: booking['petName'],
                        selectedActivities: List<String>.from(
                          booking['selectedActivities'],
                        ),
                      ),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (booking['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: booking['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['petName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                          Text(
                            '${booking['petType']} • ${booking['customerName']}',
                            style: TextStyle(
                              fontSize: 13,
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
                        color: isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(12),
                Divider(color: Colors.grey.shade300),
                const Gap(12),

                // Booking details
                Row(
                  children: [
                    Icon(
                      Icons.room_service,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        booking['serviceType'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Styles.blackColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    if (booking['package'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking['package'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                  ],
                ),

                const Gap(10),

                // Dates
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Text(
                      booking['checkInDate'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Styles.blackColor.withOpacity(0.7),
                      ),
                    ),
                    if (booking['checkOutDate'] != null) ...[
                      const Gap(8),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Styles.blackColor.withOpacity(0.5),
                      ),
                      const Gap(8),
                      Text(
                        booking['checkOutDate'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Styles.blackColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),

                const Gap(10),

                // Booking ID
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Text(
                      booking['bookingId'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Styles.blackColor.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                if (isActive) ...[
                  const Gap(12),
                  Divider(color: Colors.grey.shade300),
                  const Gap(12),

                  // Activity stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          'Pending',
                          pendingCount.toString(),
                          Colors.orange,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: _buildStatChip(
                          'Completed',
                          booking['completedActivities'].toString(),
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // Action button
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: Styles.highlightColor,
                      ),
                      const Gap(8),
                      Text(
                        'Tap to manage activities',
                        style: TextStyle(
                          fontSize: 12,
                          color: Styles.highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Styles.highlightColor,
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

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
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
            'No $selectedFilter Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor,
            ),
          ),
          const Gap(10),
          Text(
            'Bookings will appear here when assigned',
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