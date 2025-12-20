import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import 'activity_selection_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatefulWidget {
  final String petType;
  
  const BookingPage({Key? key, required this.petType}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController notesController = TextEditingController();
  DateTime? checkInDate;
  DateTime? checkOutDate;
  TimeOfDay checkInTime = TimeOfDay.now(); // Auto-set to current time
  String? selectedPackage; // For hotel accommodation
  
  // Pet selection from Firebase
  String? selectedPetId;
  String? selectedPetName;
  String? selectedPetBreed;
  List<Map<String, dynamic>> userPets = [];

  // Only hotel accommodation service
  String selectedService = '';

  // Hotel packages
  final List<Map<String, dynamic>> hotelPackages = [
    {
      'name': 'Normal',
      'price': 80.0,
      'features': ['Standard room', 'Basic care', 'Daily feeding', '1 playtime session'],
      'icon': Icons.hotel,
      'color': Colors.blue,
    },
    {
      'name': 'Deluxe',
      'price': 150.0,
      'features': ['Spacious suite', 'Premium care', 'Custom feeding schedule', '2 playtime sessions', 'Daily grooming'],
      'icon': Icons.star,
      'color': Colors.purple,
    },
    {
      'name': 'VIP',
      'price': 250.0,
      'features': ['Luxury suite', 'VIP care', 'Personalized menu', 'Unlimited playtime', 'Daily grooming & spa', '24/7 camera access', 'Dedicated caretaker'],
      'icon': Icons.diamond,
      'color': Colors.amber,
    },
  ];

  // Calculate total price based on days and package
  double get totalPrice {
    if (selectedPackage == null || checkInDate == null || checkOutDate == null) {
      return 0.0;
    }

    final days = checkOutDate!.difference(checkInDate!).inDays;
    if (days <= 0) return 0.0;

    final packagePrice = hotelPackages.firstWhere(
      (p) => p['name'] == selectedPackage,
      orElse: () => hotelPackages[0],
    )['price'] as double;

    return packagePrice * days;
  }

  @override
  void initState() {
    super.initState();
    selectedService = '${widget.petType} Hotel Accommodation';
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('ownerId', isEqualTo: user.uid)
          .where('type', isEqualTo: widget.petType)
          .get();

      setState(() {
        userPets = petsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'breed': data['breed'] ?? 'Unknown',
            'type': data['type'] ?? 'Unknown',
            'imageUrl': data['imageUrl'],
          };
        }).toList();

        // Auto-select if only one pet
        if (userPets.length == 1) {
          selectedPetId = userPets[0]['id'];
          selectedPetName = userPets[0]['name'];
          selectedPetBreed = userPets[0]['breed'];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading pets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn 
          ? DateTime.now() 
          : (checkInDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: isCheckIn ? DateTime.now() : (checkInDate ?? DateTime.now()),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Styles.highlightColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          // Reset checkout date if it's before new check-in date
          if (checkOutDate != null && checkOutDate!.isBefore(picked)) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  void _submitBooking() {
    // Validation logic - Hotel accommodation requires checkout date and package
    bool isValid = _formKey.currentState!.validate() &&
        checkInDate != null &&
        checkOutDate != null &&
        selectedPackage != null &&
        selectedPetId != null &&
        selectedPetName != null &&
        selectedPetBreed != null;

    if (isValid) {
      // Generate booking ID
      final bookingId = 'PG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Navigate to Activity Selection Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivitySelectionPage(
            petType: widget.petType,
            serviceName: selectedService,
            checkInDate: checkInDate!,
            checkOutDate: checkOutDate,
            checkInTime: checkInTime,
            bookingId: bookingId,
            petName: selectedPetName!,
            breed: selectedPetBreed!,
            specialNotes: notesController.text,
            selectedPackage: selectedPackage,
          ),
        ),
      );
    } else {
      // Show which fields are missing
      List<String> missingFields = [];
      if (!_formKey.currentState!.validate()) missingFields.add('Form validation failed');
      if (checkInDate == null) missingFields.add('Check-in date');
      if (checkOutDate == null) missingFields.add('Check-out date');
      if (selectedPetId == null) missingFields.add('Pet selection');
      if (selectedPackage == null) missingFields.add('Package selection');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            missingFields.isEmpty 
                ? "Please complete all required fields"
                : "Missing: ${missingFields.join(', ')}"
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final isSelected = selectedPackage == package['name'];
    
    return InkWell(
      onTap: () {
        setState(() {
          selectedPackage = package['name'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (package['color'] as Color).withOpacity(0.1)
              : Styles.bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? package['color'] as Color
                : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (package['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                package['icon'] as IconData,
                color: package['color'] as Color,
                size: 28,
              ),
            ),
            const Gap(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Styles.blackColor,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'RM ${package['price']}/day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: package['color'] as Color,
                            ),
                          ),
                          if (checkInDate != null && checkOutDate != null && isSelected) ...[
                            const Gap(2),
                            Text(
                              '${checkOutDate!.difference(checkInDate!).inDays} days',
                              style: TextStyle(
                                fontSize: 11,
                                color: Styles.blackColor.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              'Total: RM ${(package['price'] * checkOutDate!.difference(checkInDate!).inDays).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: package['color'] as Color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Gap(8),
                  ...((package['features'] as List<String>).take(3).map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: package['color'] as Color,
                          ),
                          const Gap(5),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12,
                                color: Styles.blackColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()),
                  if ((package['features'] as List).length > 3)
                    Text(
                      '+${(package['features'] as List).length - 3} more features',
                      style: TextStyle(
                        fontSize: 11,
                        color: package['color'] as Color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.petType} Service"),
        backgroundColor: Styles.bgColor,
        foregroundColor: Styles.blackColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Service Selection
              Text(
                'Select Service *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Styles.blackColor,
                ),
              ),
              const Gap(10),
              
              // Display selected service (Hotel Accommodation only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Styles.highlightColor.withOpacity(0.1),
                      Styles.highlightColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Styles.highlightColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hotel, color: Styles.highlightColor, size: 28),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hotel Accommodation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Styles.blackColor,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Multi-day pet boarding service',
                            style: TextStyle(
                              fontSize: 12,
                              color: Styles.blackColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // Hotel Package Selection
              Text(
                'Select Package *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Styles.blackColor,
                ),
              ),
              const Gap(10),
              ...hotelPackages.map((package) => _buildPackageCard(package)).toList(),
              const Gap(20),

              // Pet Selection Dropdown
              if (userPets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 40, color: Colors.orange.shade700),
                      const Gap(10),
                      Text(
                        'No ${widget.petType.toLowerCase()}s found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        'Please add a ${widget.petType.toLowerCase()} to your profile first',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Styles.bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedPetId != null 
                          ? Styles.highlightColor 
                          : Colors.grey.shade400,
                      width: selectedPetId != null ? 2 : 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedPetId,
                      hint: Row(
                        children: [
                          Icon(Icons.pets, color: Styles.highlightColor),
                          const Gap(10),
                          Text(
                            'Select Your ${widget.petType}',
                            style: TextStyle(
                              color: Styles.highlightColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      items: userPets.map((pet) {
                        return DropdownMenuItem<String>(
                          value: pet['id'],
                          child: Row(
                            children: [
                              // Pet image or icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Styles.highlightColor.withOpacity(0.1),
                                  image: pet['imageUrl'] != null && pet['imageUrl'].isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(pet['imageUrl']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: pet['imageUrl'] == null || pet['imageUrl'].isEmpty
                                    ? Icon(Icons.pets, color: Styles.highlightColor, size: 20)
                                    : null,
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      pet['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      pet['breed'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPetId = value;
                          final pet = userPets.firstWhere((p) => p['id'] == value);
                          selectedPetName = pet['name'];
                          selectedPetBreed = pet['breed'];
                        });
                      },
                      icon: Icon(Icons.arrow_drop_down, color: Styles.highlightColor),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const Gap(20),

              // Check-in date
              Container(
                decoration: BoxDecoration(
                  color: Styles.bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: checkInDate == null 
                        ? Colors.grey.shade300 
                        : Styles.highlightColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Styles.highlightColor),
                  title: Text(
                    checkInDate == null
                        ? "Select Check-In Date *"
                        : "Check-In: ${DateFormat('MMM d, yyyy').format(checkInDate!)}",
                    style: TextStyle(
                      color: checkInDate == null 
                          ? Styles.blackColor.withOpacity(0.5)
                          : Styles.blackColor,
                      fontWeight: checkInDate != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Styles.highlightColor),
                  onTap: () => _pickDate(true),
                ),
              ),
              
              // Check-out date (required for hotel accommodation)
              const Gap(15),
              Container(
                  decoration: BoxDecoration(
                    color: Styles.bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: checkOutDate == null 
                          ? Colors.grey.shade300 
                          : Styles.highlightColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.event_available, color: Styles.highlightColor),
                    title: Text(
                      checkOutDate == null
                          ? "Select Check-Out Date *"
                          : "Check-Out: ${DateFormat('MMM d, yyyy').format(checkOutDate!)}",
                      style: TextStyle(
                        color: checkOutDate == null 
                            ? Styles.blackColor.withOpacity(0.5)
                            : Styles.blackColor,
                        fontWeight: checkOutDate != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Styles.highlightColor),
                    onTap: () => _pickDate(false),
                  ),
                ),
              
              const Gap(20),

              // Special notes
              TextFormField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Special Requests / Notes",
                  hintText: "Any dietary restrictions, medical conditions, or special care instructions...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Styles.highlightColor, width: 2),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.note_add, color: Styles.highlightColor),
                  ),
                ),
              ),
              const Gap(30),

              // Continue button
              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.highlightColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue to Select Activities",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Gap(15),

              // Required fields note
              Center(
                child: Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 12,
                    color: Styles.blackColor.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}