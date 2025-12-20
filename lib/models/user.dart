import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  User({
    required this.name,
    required this.email,
    required this.photoURL,
    required this.role,
    required this.uid,
    required this.createdAt,
    required this.updatedAt,
    required this.phoneNumber,
  });

  final String? name;
  final String? email;
  final String? photoURL;
  final String? role;
  final String? uid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        email: json["email"],
        photoURL: json["photoURL"],
        role: json["role"],
        uid: json["uid"],
        phoneNumber: json["phoneNumber"],
        createdAt: json["createdAt"] is Timestamp
            ? (json["createdAt"] as Timestamp).toDate()
            : DateTime.tryParse(json["createdAt"] ?? ''),
        updatedAt: json["updatedAt"] is Timestamp
            ? (json["updatedAt"] as Timestamp).toDate()
            : DateTime.tryParse(json["updatedAt"] ?? ''),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "photoURL": photoURL,
        "role": role,
        "uid": uid,
        "phoneNumber": phoneNumber,
        "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  @override
  String toString() {
    return 'User(name: $name, email: $email, role: $role, uid: $uid, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt, photoURL: $photoURL)';
  }
}
