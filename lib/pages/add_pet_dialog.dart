import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/utils/styles.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({Key? key}) : super(key: key);

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedType = 'Dog';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _petTypes = [
    {'name': 'Dog', 'icon': '🐕', 'color': Colors.brown},
    {'name': 'Cat', 'icon': '🐱', 'color': Colors.orange},
    {'name': 'Bird', 'icon': '🦜', 'color': Colors.blue},
    {'name': 'Rabbit', 'icon': '🐰', 'color': Colors.pink},
    {'name': 'Hamster', 'icon': '🐹', 'color': Colors.amber},
    {'name': 'Other', 'icon': '🐾', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _imageUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final petRef = FirebaseFirestore.instance.collection('pets').doc();
      final now = DateTime.now().toIso8601String();
      
      await petRef.set({
        'id': petRef.id,
        'name': _nameController.text.trim(),
        'breed': _breedController.text.trim(),
        'gender': _selectedGender,
        'type': _selectedType,
        'imageUrl': _imageUrlController.text.trim().isEmpty 
            ? '' 
            : _imageUrlController.text.trim(),
        'notes': _notesController.text.trim().isEmpty 
            ? '' 
            : _notesController.text.trim(),
        'ownerId': user.uid,
        'createdAt': now,
        'updatedAt': now,
      });

      if (mounted) {
        // Show success animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const Gap(12),
                Expanded(
                  child: Text(
                    '${_nameController.text} added successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const Gap(12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPetTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pet Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Styles.blackColor,
          ),
        ),
        const Gap(12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _petTypes.length,
          itemBuilder: (context, index) {
            final petType = _petTypes[index];
            final isSelected = _selectedType == petType['name'];
            
            return InkWell(
              onTap: () => setState(() => _selectedType = petType['name']),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? petType['color'].withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? petType['color']
                        : Colors.grey.shade300,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      petType['icon'],
                      style: TextStyle(fontSize: isSelected ? 36 : 32),
                    ),
                    const Gap(6),
                    Text(
                      petType['name'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? petType['color'] : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Styles.blackColor,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Male', Icons.male, Colors.blue)),
            const Gap(12),
            Expanded(child: _buildGenderOption('Female', Icons.female, Colors.pink)),
            const Gap(12),
            Expanded(child: _buildGenderOption('Unknown', Icons.help_outline, Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 28,
            ),
            const Gap(6),
            Text(
              gender,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Styles.blackColor,
          ),
        ),
        const Gap(12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Styles.highlightColor),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Styles.highlightColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.blackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add New Pet',
          style: TextStyle(
            color: Styles.blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header illustration
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Styles.highlightColor.withOpacity(0.1),
                          Styles.highlightColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '🐾',
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                  const Gap(32),

                  // Pet Type Selector
                  _buildPetTypeSelector(),
                  const Gap(28),

                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Pet Name',
                    icon: Icons.pets,
                    hint: 'e.g., Fluffy, Max, Charlie',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your pet\'s name';
                      }
                      return null;
                    },
                  ),
                  const Gap(24),

                  // Breed Field
                  _buildTextField(
                    controller: _breedController,
                    label: 'Breed',
                    icon: Icons.category,
                    hint: 'e.g., Golden Retriever, Persian Cat',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the breed';
                      }
                      return null;
                    },
                  ),
                  const Gap(24),

                  // Gender Selector
                  _buildGenderSelector(),
                  const Gap(24),

                  // Image URL Field (Optional)
                  _buildTextField(
                    controller: _imageUrlController,
                    label: 'Image URL (Optional)',
                    icon: Icons.image_outlined,
                    hint: 'https://example.com/pet-photo.jpg',
                    keyboardType: TextInputType.url,
                  ),
                  const Gap(24),

                  // Notes Field (Optional)
                  _buildTextField(
                    controller: _notesController,
                    label: 'Additional Notes (Optional)',
                    icon: Icons.notes,
                    hint: 'Any special information about your pet...',
                    maxLines: 4,
                  ),
                  const Gap(40),

                  // Save Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Styles.highlightColor,
                          Styles.highlightColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Styles.highlightColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline, size: 24),
                                Gap(12),
                                Text(
                                  'Add Pet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const Gap(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}