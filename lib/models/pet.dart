import 'dart:convert';

List<Pet> petFromJson(String str) => List<Pet>.from(json.decode(str).map((x) => Pet.fromJson(x)));

String petToJson(List<Pet> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Pet {
  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.imageUrl,
    required this.notes,
    required this.ownerId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String breed;
  final String gender;
  final String imageUrl;
  final String notes;
  final String ownerId;
  final String type;
  final String createdAt;
  final String updatedAt;

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json["id"],
    name: json["name"],
    breed: json["breed"],
    gender: json["gender"],
    imageUrl: json["imageUrl"],
    notes: json["notes"],
    ownerId: json["ownerId"],
    type: json["type"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "breed": breed,
    "gender": gender,
    "imageUrl": imageUrl,
    "notes": notes,
    "ownerId": ownerId,
    "type": type,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
