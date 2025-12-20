import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawgoda/utils/styles.dart';
import 'staff_customer_bookings_page.dart';

/// Staff Customer List Page
/// Shows list of customers with active bookings
/// First page in the navigation flow: Customers → Bookings → Activities
class StaffCustomerListPage extends StatefulWidget {
  const StaffCustomerListPage({Key? key}) : super(key: key);

  @override
  State<StaffCustomerListPage> createState() => _StaffCustomerListPageState();
}

class _StaffCustomerListPageState extends State<StaffCustomerListPage> {
  List<Map<String, dynamic>> customers = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch unique customers from bookings
  Future<void> _fetchCustomers() async {
    setState(() => isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', whereIn: ['Active', 'Completed'])
          .get();

      // Group bookings by customer
      Map<String, Map<String, dynamic>> customerMap = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final customerId = data['customerId'] ?? data['customerName'];
        final customerName = data['customerName'] ?? 'Unknown Customer';
        
        if (!customerMap.containsKey(customerId)) {
          customerMap[customerId] = {
            'customerId': customerId,
            'customerName': customerName,
            'customerEmail': data['customerEmail'] ?? '',
            'customerPhone': data['customerPhone'] ?? '',
            'activeBookings': 0,
            'completedBookings': 0,
            'totalBookings': 0,
            'pets': <String>{},
          };
        }
        
        // Count bookings
        customerMap[customerId]!['totalBookings'] = 
            (customerMap[customerId]!['totalBookings'] as int) + 1;
        
        if (data['status'] == 'Active') {
          customerMap[customerId]!['activeBookings'] = 
              (customerMap[customerId]!['activeBookings'] as int) + 1;
        } else if (data['status'] == 'Completed') {
          customerMap[customerId]!['completedBookings'] = 
              (customerMap[customerId]!['completedBookings'] as int) + 1;
        }
        
        // Add pet name to set
        if (data['petName'] != null) {
          (customerMap[customerId]!['pets'] as Set<String>)
              .add(data['petName']);
        }
      }

      setState(() {
        customers = customerMap.values.map((customer) {
          return {
            ...customer,
            'pets': (customer['pets'] as Set<String>).toList(),
            'petCount': (customer['pets'] as Set<String>).length,
          };
        }).toList();
        
        // Sort by active bookings (most active first)
        customers.sort((a, b) => 
            (b['activeBookings'] as int).compareTo(a['activeBookings'] as int));
        
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to customer bookings and refresh on return
  Future<void> _navigateToBookings(Map<String, dynamic> customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffCustomerBookingsPage(
          customerId: customer['customerId'],
          customerName: customer['customerName'],
        ),
      ),
    );
    
    // Auto-refresh when returning from bookings page
    _fetchCustomers();
  }

  List<Map<String, dynamic>> get filteredCustomers {
    if (searchQuery.isEmpty) {
      return customers;
    }
    return customers.where((customer) {
      final name = (customer['customerName'] as String).toLowerCase();
      final email = (customer['customerEmail'] as String).toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Customers',
          style: TextStyle(
            color: Styles.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Styles.highlightColor),
            onPressed: _fetchCustomers,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats card
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
                      Icons.people,
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
                          'Total Customers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Styles.blackColor,
                          ),
                        ),
                        Text(
                          '${customers.length} customers with active/completed bookings',
                          style: TextStyle(
                            fontSize: 13,
                            color: Styles.blackColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  prefixIcon: Icon(Icons.search, color: Styles.highlightColor),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Styles.bgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Styles.highlightColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            const Gap(20),

            // Customer list
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Styles.highlightColor,
                      ),
                    )
                  : filteredCustomers.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredCustomers.length,
                          separatorBuilder: (context, index) => const Gap(15),
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return _buildCustomerCard(customer);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final activeCount = customer['activeBookings'] as int;
    final completedCount = customer['completedBookings'] as int;
    final petCount = customer['petCount'] as int;
    final pets = customer['pets'] as List<dynamic>;

    return Container(
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeCount > 0
              ? Styles.highlightColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToBookings(customer),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Styles.highlightColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Styles.highlightColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer['customerName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                          if (customer['customerEmail'].isNotEmpty)
                            Text(
                              customer['customerEmail'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Styles.blackColor.withOpacity(0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (activeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
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
                            Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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

                // Pet information
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        petCount == 1
                            ? pets.first
                            : '$petCount pets: ${pets.take(2).join(", ")}${pets.length > 2 ? "..." : ""}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Styles.blackColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(10),

                // Booking stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        'Active',
                        activeCount.toString(),
                        Colors.green,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _buildStatChip(
                        'Completed',
                        completedCount.toString(),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),

                const Gap(12),

                // Action hint
                Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: Styles.highlightColor,
                    ),
                    const Gap(8),
                    Text(
                      'Tap to view bookings',
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
            searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 80,
            color: Styles.highlightColor.withOpacity(0.3),
          ),
          const Gap(20),
          Text(
            searchQuery.isEmpty ? 'No Customers' : 'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor,
            ),
          ),
          const Gap(10),
          Text(
            searchQuery.isEmpty
                ? 'Customers will appear here when they have bookings'
                : 'Try searching with a different keyword',
            style: TextStyle(
              fontSize: 14,
              color: Styles.blackColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}