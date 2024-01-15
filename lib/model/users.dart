import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  static const String collectionName = "users";
  String userId;
  final String userEmail;
  final String mobileNum;
  final String name;
  final String gender;
  final DateTime birthDate;
  final String image;

  Users({
    this.userId = "",
    required this.userEmail,
    required this.mobileNum,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.image,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['userId'],
      userEmail: json['userEmail'],
      mobileNum: json['mobileNum'],
      name: json['name'],
      gender: json['gender'],
      birthDate: (json['birthDate'] as Timestamp).toDate(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userEmail': userEmail,
        'mobileNum': mobileNum,
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
        'image': image,
      };
}
