import 'dart:developer';

import 'package:pawgoda/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawgoda/models/user.dart' as user_model;

Future<user_model.User?> getCurrentUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists) return null;

  return user_model.User.fromJson(doc.data()!); // This will include role, createdAt, etc.
}
