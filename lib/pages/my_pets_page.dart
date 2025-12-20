import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:pawgoda/utils/styles.dart';
import 'package:pawgoda/pages/add_pet_dialog.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({Key? key}) : super(key: key);

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _showAddPetPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPetPage(),
      ),
    );

    // Refresh the list if a pet was added
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deletePet(String petId, String petName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete $petName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('pets')
            .doc(petId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$petName deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting pet: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Pets'),
        ),
        body: const Center(
          child: Text('Please log in to view your pets'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        backgroundColor: Styles.bgColor,
        actions: [
          IconButton(
            onPressed: _showAddPetPage,
            icon: const Icon(Icons.add),
            tooltip: 'Add Pet',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pets')
            .where('ownerId', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const Gap(16),
                  Text('Error: ${snapshot.error}'),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final pets = snapshot.data?.docs ?? [];

          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const Gap(20),
                  Text(
                    'No pets yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    'Tap the + button to add your first pet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Gap(30),
                  ElevatedButton.icon(
                    onPressed: _showAddPetPage,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Pet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.highlightColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final petData = pets[index].data() as Map<String, dynamic>;
              final petId = pets[index].id;

              return _PetCard(
                petId: petId,
                petData: petData,
                onDelete: () => _deletePet(petId, petData['name'] ?? 'Pet'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPetPage,
        backgroundColor: Styles.highlightColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final String petId;
  final Map<String, dynamic> petData;
  final VoidCallback onDelete;

  const _PetCard({
    required this.petId,
    required this.petData,
    required this.onDelete,
  });

  IconData _getPetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'hamster':
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = petData['name'] ?? 'Unknown';
    final breed = petData['breed'] ?? 'Unknown';
    final type = petData['type'] ?? 'Unknown';
    final gender = petData['gender'] ?? 'Unknown';
    final imageUrl = petData['imageUrl'] as String?;
    final notes = petData['notes'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Pet image or placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Styles.bgColor,
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image loading error
                            },
                          )
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Icon(
                          _getPetIcon(type),
                          size: 40,
                          color: Styles.highlightColor,
                        )
                      : null,
                ),
                const Gap(16),

                // Pet details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        breed,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: _getPetIcon(type),
                            label: type,
                          ),
                          const Gap(8),
                          _InfoChip(
                            icon: gender == 'Male'
                                ? Icons.male
                                : gender == 'Female'
                                    ? Icons.female
                                    : Icons.help_outline,
                            label: gender,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Delete pet',
                ),
              ],
            ),

            // Notes section
            if (notes != null && notes.isNotEmpty) ...[
              const Gap(12),
              const Divider(),
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Styles.highlightColor),
          const Gap(4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}