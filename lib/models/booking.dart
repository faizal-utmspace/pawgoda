import 'dart:convert';

List<Booking> bookingFromJson(String str) => List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  Booking({
    required this.id,
    required this.customerId,
    required this.petId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String petId;
  final String startDate;
  final String endDate;
  final String status;
  final double totalAmount;
  final String createdAt;
  final String updatedAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json["id"],
    customerId: json["customerId"],
    petId: json["petId"],
    startDate: json["startDate"],
    endDate: json["endDate"],
    status: json["status"],
    totalAmount: json["totalAmount"].toDouble(),
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customerId": customerId,
    "petId": petId,
    "startDate": startDate,
    "endDate": endDate,
    "status": status,
    "totalAmount": totalAmount,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
