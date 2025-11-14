import 'dart:convert';

import 'package:pawgoda/models/booking.dart';
import 'package:pawgoda/models/pet.dart';

List<User> userFromJson(String str) => List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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
    // required this.bookings,
    // required this.pets,
  });

  final String? name;
  final String? email;
  final String? photoURL;
  final String? role;
  final String? uid;
  final String? createdAt;
  final String? updatedAt;
  final String? phoneNumber;
  // final List<Booking>? bookings;
  // final List<Pet>? pets;

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"],
    email: json["email"],
    photoURL: json["photoURL"],
    role: json["role"],
    uid: json["uid"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    phoneNumber: json["phoneNumber"],
    // bookings: List<Booking>.from(json["bookings"].map((x) => Booking.fromJson(x))),
    // pets: List<Pet>.from(json["pets"].map((x) => Pet.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "photoURL": photoURL,
    "role": role,
    "uid": uid,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "phoneNumber": phoneNumber,
    // "bookings": bookings == null ? null : List<dynamic>.from(bookings!.map((x) => x.toJson())),
    // "pets": pets == null ? null : List<dynamic>.from(pets!.map((x) => x.toJson())),
  };

  @override
  String toString() {
    return 'User(name: $name, email: $email, role: $role, uid: $uid, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt, photoURL: $photoURL)';
  }
}
