import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../utils/styles.dart';
import 'activity_selection_page.dart';

class BookingPage extends StatefulWidget {
  final String petType;
  
  const BookingPage({Key? key, required this.petType}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? checkInDate;
  DateTime? checkOutDate;
  TimeOfDay? checkInTime;
  String? selectedService;
  String? selectedPackage; // For hotel accommodation

  // Service options
  List<String> get availableServices {
    final petType = widget.petType;
    return [
      '$petType Hotel Accommodation',
      '$petType Daycare',
    ];
  }

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

  bool get isHotelAccommodation => 
      selectedService?.contains('Hotel Accommodation') ?? false;
  
  bool get isDaycare => 
      selectedService?.contains('Daycare') ?? false;

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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
        checkInTime = picked;
      });
    }
  }

  void _submitBooking() {
    // Validation logic
    bool isValid = _formKey.currentState!.validate() &&
        checkInDate != null &&
        checkInTime != null &&
        selectedService != null;

    // Additional validations based on service type
    if (isHotelAccommodation) {
      isValid = isValid && checkOutDate != null && selectedPackage != null;
    } else if (isDaycare) {
      // Daycare doesn't need checkout date or package
      isValid = isValid;
    }

    if (isValid) {
      // Generate booking ID
      final bookingId = 'PG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Navigate to Activity Selection Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivitySelectionPage(
            petType: widget.petType,
            serviceName: selectedService!,
            checkInDate: checkInDate!,
            checkOutDate: checkOutDate,
            checkInTime: checkInTime!,
            bookingId: bookingId,
            petName: petNameController.text,
            breed: breedController.text,
            specialNotes: notesController.text,
            selectedPackage: selectedPackage,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please complete all required fields"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      Text(
                        'RM ${package['price']}/day',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: package['color'] as Color,
                        ),
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
  void dispose() {
    petNameController.dispose();
    breedController.dispose();
    notesController.dispose();
    super.dispose();
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Styles.bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedService == null 
                        ? Colors.grey.shade300 
                        : Styles.highlightColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedService,
                    hint: Text(
                      'Choose a service',
                      style: TextStyle(color: Styles.blackColor.withOpacity(0.5)),
                    ),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Styles.highlightColor),
                    items: availableServices.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(
                          service,
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedService = value;
                        // Reset package and checkout date when service changes
                        if (value?.contains('Daycare') ?? false) {
                          selectedPackage = null;
                          checkOutDate = null;
                        }
                      });
                    },
                  ),
                ),
              ),
              const Gap(20),

              // Hotel Package Selection (only for Hotel Accommodation)
              if (isHotelAccommodation) ...[
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
                const Gap(10),
              ],

              // Pet Name
              TextFormField(
                controller: petNameController,
                decoration: InputDecoration(
                  labelText: "${widget.petType} Name *",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Styles.highlightColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.pets, color: Styles.highlightColor),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your ${widget.petType.toLowerCase()}'s name" : null,
              ),
              const Gap(15),

              // Breed
              TextFormField(
                controller: breedController,
                decoration: InputDecoration(
                  labelText: "Breed *",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Styles.highlightColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.info_outline, color: Styles.highlightColor),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter the breed" : null,
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
                        ? isDaycare 
                            ? "Select Service Date *"
                            : "Select Check-In Date *"
                        : isDaycare
                            ? "Service Date: ${DateFormat('MMM d, yyyy').format(checkInDate!)}"
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
              const Gap(15),

              // Check-in time
              Container(
                decoration: BoxDecoration(
                  color: Styles.bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: checkInTime == null 
                        ? Colors.grey.shade300 
                        : Styles.highlightColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: Styles.highlightColor),
                  title: Text(
                    checkInTime == null
                        ? isDaycare
                            ? "Select Drop-off Time *"
                            : "Select Check-In Time *"
                        : isDaycare
                            ? "Drop-off: ${checkInTime!.format(context)}"
                            : "Time: ${checkInTime!.format(context)}",
                    style: TextStyle(
                      color: checkInTime == null 
                          ? Styles.blackColor.withOpacity(0.5)
                          : Styles.blackColor,
                      fontWeight: checkInTime != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Styles.highlightColor),
                  onTap: _pickTime,
                ),
              ),
              
              // Check-out date (only for Hotel Accommodation)
              if (isHotelAccommodation) ...[
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
              ],
              
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