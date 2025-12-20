import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AI Service using Groq API - Matches exact Firebase booking structure
class AIService {
  final String apiKey;
  final bool isStaffMode;
  final String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  AIService({
    required this.apiKey,
    this.isStaffMode = false,
  });

  Future<String> getAIResponse(String userMessage) async {
    try {
      final firebaseContext = await _fetchRelevantFirebaseData(userMessage);
      final systemPrompt = _buildSystemPrompt(firebaseContext);
      final response = await _callGroqAPI(userMessage, systemPrompt);
      return response;
    } catch (e) {
      print('Error getting AI response: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  Future<String> _callGroqAPI(String message, String systemPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Groq API error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(message);
      }
    } catch (e) {
      print('Error calling Groq API: $e');
      return _getFallbackResponse(message);
    }
  }

  Future<Map<String, dynamic>> _fetchRelevantFirebaseData(String query) async {
    final user = FirebaseAuth.instance.currentUser;
    final context = <String, dynamic>{};
    
    if (user == null) return context;

    try {
      final lowerQuery = query.toLowerCase();
      
      if (isStaffMode) {
        // Staff: All active bookings
        if (_isAboutBookings(lowerQuery) || _isAboutTodaySchedule(lowerQuery)) {
          final bookingsSnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('status', isEqualTo: 'Active')
              .orderBy('startDate', descending: false)
              .limit(20)
              .get();
          
          context['activeBookings'] = bookingsSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'customerName': data['customerName'] ?? 'Unknown',
              'petName': data['petName'],
              'petType': data['petType'],
              'breed': data['breed'] ?? '',
              'package': data['selectedPackage'],
              'checkInTime': data['checkInTime'],
              'totalAmount': data['totalAmount'],
            };
          }).toList();
        }

        // Staff: Activities from all bookings
        if (_isAboutActivities(lowerQuery)) {
          final bookingsSnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('status', isEqualTo: 'Active')
              .limit(10)
              .get();
          
          final List<Map<String, dynamic>> allActivities = [];
          
          for (var bookingDoc in bookingsSnapshot.docs) {
            final bookingData = bookingDoc.data();
            final activitiesSnapshot = await bookingDoc.reference
                .collection('activities')
                .orderBy('updatedAt', descending: true)
                .limit(5)
                .get();
            
            for (var activityDoc in activitiesSnapshot.docs) {
              final activityData = activityDoc.data();
              allActivities.add({
                'petName': bookingData['petName'],
                'activityName': activityData['activityName'],
                'status': activityData['status'],
                'time': activityData['time'],
              });
            }
          }
          
          context['activities'] = allActivities;
        }
      } else {
        // Customer: Own bookings (using customerId)
        if (_isAboutBookings(lowerQuery) || _isAboutPets(lowerQuery)) {
          final bookingsSnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('customerId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();
          
          context['myBookings'] = bookingsSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'petName': data['petName'],
              'petType': data['petType'],
              'breed': data['breed'] ?? '',
              'package': data['selectedPackage'],
              'service': data['serviceName'],
              'status': data['status'],
              'checkInTime': data['checkInTime'],
              'totalAmount': data['totalAmount'],
            };
          }).toList();
        }

        // Customer: Own pet activities
        if (_isAboutActivities(lowerQuery)) {
          final bookingsSnapshot = await FirebaseFirestore.instance
              .collection('bookings')
              .where('customerId', isEqualTo: user.uid)
              .where('status', isEqualTo: 'Active')
              .limit(5)
              .get();
          
          final List<Map<String, dynamic>> myActivities = [];
          
          for (var bookingDoc in bookingsSnapshot.docs) {
            final bookingData = bookingDoc.data();
            final activitiesSnapshot = await bookingDoc.reference
                .collection('activities')
                .orderBy('updatedAt', descending: true)
                .limit(10)
                .get();
            
            for (var activityDoc in activitiesSnapshot.docs) {
              final activityData = activityDoc.data();
              myActivities.add({
                'petName': bookingData['petName'],
                'activityName': activityData['activityName'],
                'status': activityData['status'],
                'time': activityData['time'],
                'note': activityData['note'] ?? '',
              });
            }
          }
          
          context['myActivities'] = myActivities;
        }
      }
      
      if (_isAboutPackages(lowerQuery)) {
        context['packages'] = [
          {'name': 'Daycare', 'info': 'Daily care'},
          {'name': 'Normal', 'info': 'Standard stay'},
          {'name': 'Premium', 'info': 'Enhanced comfort'},
          {'name': 'VIP', 'info': 'Luxury service'},
        ];
      }
      
    } catch (e) {
      print('Error fetching Firebase: $e');
    }
    
    return context;
  }

  String _buildSystemPrompt(Map<String, dynamic> firebaseContext) {
    final buffer = StringBuffer();
    
    if (isStaffMode) {
      buffer.writeln('You are PawGoda Staff AI.');
      buffer.writeln('Help staff manage bookings and activities.');
    } else {
      buffer.writeln('You are PawGoda Customer AI.');
      buffer.writeln('Help customers with pet bookings.');
      buffer.writeln('Be friendly and use emojis.');
    }
    
    if (firebaseContext.isNotEmpty) {
      buffer.writeln('\nDATA: ${jsonEncode(firebaseContext)}');
    }
    
    return buffer.toString();
  }

  String _getFallbackResponse(String message) {
    if (isStaffMode) {
      return "📋 I can help with bookings and activities. What do you need?";
    }
    return "👋 I can help with your pet bookings and activities! What would you like to know?";
  }

  bool _isAboutPets(String q) => q.contains('pet') || q.contains('dog') || q.contains('cat');
  bool _isAboutBookings(String q) => q.contains('book') || q.contains('stay');
  bool _isAboutPackages(String q) => q.contains('package') || q.contains('price');
  bool _isAboutActivities(String q) => q.contains('activity') || q.contains('doing') || q.contains('update');
  bool _isAboutTodaySchedule(String q) => q.contains('today') || q.contains('schedule');
}