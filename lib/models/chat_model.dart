import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel
{
  String? senderName;
  String? receiverName;
  String? receiverId;
  String? receiverProfilePic;
  String? senderProfilePic;
  String? lastMessageText;
  Timestamp? dateTime;
  String? senderOfThisMessage;

  ChatModel({
    this.senderName,
    this.receiverName,
    this.receiverId,
    this.lastMessageText,
    this.receiverProfilePic,
    this.senderProfilePic,
    this.dateTime,
    this.senderOfThisMessage,
  });

  ChatModel.fromJson(Map<String, dynamic> json){
    senderName = json['senderName'];
    receiverName = json['receiverName'];
    receiverId = json['receiverId'];
    lastMessageText = json['lastMessageText'];
    receiverProfilePic = json['receiverProfilePic'];
    senderProfilePic = json['senderProfilePic'];
    senderOfThisMessage = json['senderOfThisMessage'];
  }

  Map<String, dynamic> toMap (){
    return {
      'senderName' : senderName,
      'receiverName' : receiverName,
      'receiverId' : receiverId,
      'lastMessageText' : lastMessageText,
      'receiverProfilePic' : receiverProfilePic,
      'senderProfilePic' : senderProfilePic,
      'dateTime' : dateTime,
      'senderOfThisMessage' : senderOfThisMessage,
    };
  }
}