import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/styles.dart';

class AppointmentsListPage extends StatefulWidget {
  const AppointmentsListPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Upcoming', 'Completed'];

  // Sample appointments data (in real app, this would come from database)
  final List<Map<String, dynamic>> sampleAppointments = [
    {
      'id': 'PG1234567',
      'petName': 'Max',
      'petType': 'Cat',
      'Actitivies': 'Medication',
      'date': 'Nov 15, 2025',
      'time': '2:30 PM',
      'status': 'Upcoming',
      'color': Colors.blue,
    },
    {
      'id': 'PG1234568',
      'petName': 'Max',
      'petType': 'Cat',
      'Actitivies': 'Cat Walking',
      'date': 'Nov 12, 2025',
      'time': '10:00 AM',
      'status': 'Upcoming',
      'color': Colors.orange,
    },
    {
      'id': 'PG1234569',
      'petName': 'Max',
      'petType': 'Cat',
      'Actitivies': 'Feeding',
      'date': 'Nov 8, 2025',
      'time': '3:00 PM',
      'status': 'Completed',
      'color': Colors.green,
    },
  ];

  List<Map<String, dynamic>> get filteredAppointments {
    if (selectedFilter == 'All') {
      return sampleAppointments;
    }
    return sampleAppointments
        .where((apt) => apt['status'] == selectedFilter)
        .toList();
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
          'My Appointments',
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
              height: 60,
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

            // Appointments list
            Expanded(
              child: filteredAppointments.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredAppointments.length,
                      separatorBuilder: (context, index) => const Gap(15),
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Styles.highlightColor,
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status'] as String;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Upcoming':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Styles.highlightColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAppointmentDetails(appointment),
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
                        color: (appointment['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: appointment['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['petName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                          Text(
                            appointment['petType'],
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const Gap(4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
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

                // Service info
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
                        appointment['Actitivies'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Styles.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(10),

                // Date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Text(
                      appointment['date'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Styles.blackColor.withOpacity(0.7),
                      ),
                    ),
                    const Gap(20),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Text(
                      appointment['time'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Styles.blackColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),

                const Gap(12),

                // Booking ID
                Text(
                  'Booking ID: ${appointment['id']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Styles.blackColor.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
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
            'No $selectedFilter Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor,
            ),
          ),
          const Gap(10),
          Text(
            'Book a service for your pet',
            style: TextStyle(
              fontSize: 14,
              color: Styles.blackColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Styles.blackColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(20),
            _buildDetailRow('Booking ID', appointment['id']),
            const Gap(12),
            _buildDetailRow('Pet Name', appointment['petName']),
            const Gap(12),
            _buildDetailRow('Pet Type', appointment['petType']),
            const Gap(12),
            _buildDetailRow('Service', appointment['service']),
            const Gap(12),
            _buildDetailRow('Date', appointment['date']),
            const Gap(12),
            _buildDetailRow('Time', appointment['time']),
            const Gap(12),
            _buildDetailRow('Status', appointment['status']),
            const Gap(25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Reschedule feature coming soon!'),
                          backgroundColor: Styles.highlightColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Reschedule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Styles.highlightColor,
                      side: BorderSide(color: Styles.highlightColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Cancel feature coming soon!'),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Styles.blackColor.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Styles.blackColor,
            ),
          ),
        ),
      ],
    );
  }
}