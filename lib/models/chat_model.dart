import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel
{
  String? senderName;
  String? receiverName;
  String? receiverId;
  String? senderId;
  String? receiverProfilePic;
  String? senderProfilePic;
  String? lastMessageText;
  String? lastMessageImage;
  String? time;
  Timestamp? dateTime;
  String? senderOfThisMessage;

  ChatModel({
    this.senderName,
    this.receiverName,
    this.receiverId,
    this.senderId,
    this.lastMessageText,
    this.lastMessageImage,
    this.time,
    this.receiverProfilePic,
    this.senderProfilePic,
    this.dateTime,
    this.senderOfThisMessage,
  });

  ChatModel.fromJson(Map<String, dynamic> json){
    senderName = json['senderName'];
    receiverName = json['receiverName'];
    receiverId = json['receiverId'];
    senderId = json['senderId'];
    lastMessageText = json['lastMessageText'];
    lastMessageImage = json['lastMessageImage'];
    time = json['time'];
    receiverProfilePic = json['receiverProfilePic'];
    senderProfilePic = json['senderProfilePic'];
    senderOfThisMessage = json['senderOfThisMessage'];
  }

  Map<String, dynamic> toMap (){
    return {
      'senderName' : senderName,
      'receiverName' : receiverName,
      'receiverId' : receiverId,
      'senderId' : senderId,
      'lastMessageText' : lastMessageText,
      'lastMessageImage': lastMessageImage,
      'time' : time,
      'receiverProfilePic' : receiverProfilePic,
      'senderProfilePic' : senderProfilePic,
      'dateTime' : dateTime,
      'senderOfThisMessage' : senderOfThisMessage,
    };
  }
}