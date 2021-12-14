import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel
{
  String? name;
  String? email;
  String? password;
  String? phone;
  String? uId;
  String? image;
  String? bio;
  Timestamp? lastSeen;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.uId,
    required this.image,
    required this.bio,
    required this.lastSeen,
  });

  UserModel.fromJson(Map <String, dynamic>? json)
  {
    name = json!['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    uId = json['uId'];
    image = json['image'];
    bio = json['bio'];
    lastSeen = json['lastSeen'];
  }

  Map <String, dynamic> toMap()
  {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'uId': uId,
      'image': image,
      'bio': bio,
      'lastSeen': lastSeen,
    };
  }
}