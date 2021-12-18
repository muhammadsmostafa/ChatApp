import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel
{
  String? senderId;
  String? receiverId;
  Timestamp? dateTime;
  String? message;
  String? image;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.dateTime,
    required this.message,
    required this.image,
  });

  MessageModel.fromJson(Map <String, dynamic>? json)
  {
    senderId = json!['senderId'];
    receiverId = json['receiverId'];
    dateTime = json['dateTime'];
    message = json['message'];
    image = json['image'];
  }

  Map <String, dynamic> toMap()
  {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'dateTime': dateTime,
      'message' : message,
      'image' : image,
    };
  }
}