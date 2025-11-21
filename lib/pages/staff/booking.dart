import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/utils/helpers.dart';
import 'package:pawgoda/utils/styles.dart';
import 'staff_activity_management_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Staff Bookings List Page
/// Shows all active bookings for staff to manage activities
class StaffBookingPage extends StatefulWidget {
  const StaffBookingPage({Key? key}) : super(key: key);

  @override
  State<StaffBookingPage> createState() => _StaffBookingPageState();
}

class _StaffBookingPageState extends State<StaffBookingPage> {
  String selectedFilter = 'Active';
  final List<String> filters = ['All', 'Active', 'Completed'];

  // Fetch bookings from Firestore
    Future<void> _fetchBookings() async {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('status', whereIn: ['Active', 'Completed'])
            .get();

            log('Snapshowt docs: ${snapshot.docs.length}');
            log('Snapshot details: ${snapshot.docs.map((e) => e.data())}');

        // Fetch activities for each booking
        for (var doc in snapshot.docs) {
          final bookingId = doc.data()['bookingId'] ?? doc.id;
          final activitiesSnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .collection('activities')
              .get();
          
          snapshot.docs.firstWhere((d) => d.id == doc.id).data()['activities'] = 
            activitiesSnapshot.docs.map((aDoc) => aDoc.data()).toList();
        }

        setState(() {
          bookings.clear();
          bookings.addAll(
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'bookingId': data['bookingId'] ?? doc.id,
                'petName': data['petName'] ?? '',
                'petType': data['petType'] ?? '',
                'customerName': data['customerName'] ?? '',
                'serviceType': data['serviceType'] ?? '',
                'package': data['package'],
                'checkInDate': data['startDate'] != null 
                  ? convertDate((data['startDate'] as Timestamp))
                  : '',
                'checkOutDate': data['endDate'] != null
                  ? convertDate((data['endDate'] as Timestamp))
                  : null,
                'status': data['status'] ?? 'Active',
                'activities': data['activities'] ?? [],
                'selectedActivities': List<String>.from(data['selectedActivities'] ?? []),
                'pendingActivities': data['pendingActivities'] ?? 0,
                'completedActivities': data['completedActivities'] ?? 0,
                'color': _getColorForPetType(data['petType'] ?? ''),
              };
            }).toList(),
          );
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

    Color _getColorForPetType(String petType) {
      switch (petType.toLowerCase()) {
        case 'dog':
          return Colors.orange;
        case 'cat':
          return Colors.blue;
        default:
          return Colors.green;
      }
    }

    @override
    void initState() {
      super.initState();
      _fetchBookings();
    }
  // Mock bookings data (in real app, fetch from Firebase based on staff role)
  final List<Map<String, dynamic>> bookings = [];

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedFilter == 'All') {
      return bookings;
    }
    return bookings
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
          'Bookings',
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
                          booking['activities'],
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