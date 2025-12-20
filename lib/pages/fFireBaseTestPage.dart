import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _status = "Checking Firebase...";

  @override
  void initState() {
    super.initState();
    testFirebase();
  }

  Future<void> testFirebase() async {
    try {
      // Try reading a collection
      final snapshot = await FirebaseFirestore.instance.collection('users').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _status = "✅ Firebase connected! Found ${snapshot.docs.length} documents.";
        });
      } else {
        setState(() {
          _status = "✅ Firebase connected! No documents found.";
        });
      }
    } catch (e) {
      setState(() {
        _status = "❌ Firebase connection failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: Text(_status, textAlign: TextAlign.center),
      ),
    );
  }
}
