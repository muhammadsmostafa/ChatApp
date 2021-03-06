import 'dart:io';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/chat/chats_screen.dart';
import 'package:chat_app/modules/profile/profile_screen.dart';
import 'package:chat_app/modules/users/users_screen.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/network/local/cashe_helper.dart';
import 'package:chat_app/shared/network/remote/dio_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;
  void getUserData() {
    emit(AppGetUserLoadingState());
    FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {
      userModel = UserModel.fromJson(value.data());
      emit(AppGetUserSuccessState());
    }).catchError((error) {
      emit(AppGetUserErrorState(error.toString()));
    });
  }

  late UserModel thisUserModel;
  void getSpecificUserData({
  required String? UID
  }) {
    FirebaseFirestore.instance.collection('users').doc(UID).get().then((value) {
      thisUserModel = UserModel.fromJson(value.data());
      emit(AppGetUserSuccessState());
    }).catchError((error) {
      emit(AppGetUserErrorState(error.toString()));
    });
  }

  List<ChatModel> chatModel =[];
  Future <void> getChats() async {
    emit(AppGetChatsLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('chats')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((value){
        chatModel=[];
        for(var element in value.docs)
        {
        chatModel.add(ChatModel.fromJson(element.data()));
        }
      emit(AppGetChatsSuccessState());
    });
  }

  Future<void> logout()
  async {
    emit(AppLogoutLoadingState());
    FirebaseAuth.instance.signOut()
    .then((value){
      emit(AppLogoutSuccessState());
    });
  }

  Future<void> removeTokenAndUid()
  async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update({'token' : ''}).then((value){
      CasheHelper.saveData(key: 'uId', value: '');
      uId='';
    });
  }

  int currentIndex = 1;
  List<Widget> screens =
  [
    ChatsScreen(),
    UsersScreen(),
    ProfileScreen(),
  ];

  List<String> titles = [
    'Chats',
    'Users',
    'Profile',
  ];


  void changeBottomNav(int index) {
    if(index==4)
      {
        emit(AppFixError());
      }
    else
      {
      currentIndex = index;
      emit(AppChangeBottomNavBarState());
      }

  }

  File? profileImage;

  void removeProfileImage() {
    profileImage = null;
    emit(AppRemoveImageSuccessState());
  }

  var picker = ImagePicker();

  Future<void> getProfileImage() async {
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(AppProfileImagePickedSuccessState());
    } else {
      print('No image selected');
      emit(AppProfileImagePickedErrorState());
    }
  }

  bool uploadingImage = false;
  Future<void> uploadProfileImage({
    required String name,
    required String phone,
    required String bio,
  }) async {
    emit(AppUploadProfileImagePickedLoadingState());
    uploadingImage = true;
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        emit(AppUploadProfileImagePickedSuccessState());
        uploadingImage = false;
        removeProfileImage();
        updateUser(
          name: name,
          phone: phone,
          bio: bio,
          image: value,
        );
      }).catchError((error) {
        emit(AppUploadProfileImagePickedErrorState());
      });
    }).catchError((error) {
      emit(AppUploadProfileImagePickedErrorState());
    });
  }

  void updateUser({
    required String name,
    required String phone,
    required String bio,
    String? image,
  }) {
    emit(AppUserUpdateLoadingState());
    {
      UserModel model = UserModel(
        name: name,
        phone: phone,
        password: userModel!.password,
        email: userModel!.email,
        uId: userModel!.uId,
        image: image ?? userModel!.image,
        bio: bio,
        lastSeen: Timestamp.now(),
      );
      FirebaseFirestore.instance
          .collection('users')
          .doc(userModel!.uId)
          .update(model.toMap())
          .then((value) {
        getUserData();
      }).catchError((error) {
        emit(AppUserUpdateErrorState());
      });
    }
  }

  List<UserModel> users = [];
  int counter = 0;
  Future<dynamic> getAllUsers() async {
    emit(AppGetAllUsersLoadingState());
    users = [];
    counter = 0;
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) {
        setLastSeen(hisUID: uId);
      if (counter <= 20)
     {
        for (var element in value.docs) {
          if (element.id != uId)
          {
            users.add(UserModel.fromJson(element.data()));
            counter++;
          }
        }
    }
      users.shuffle();
      emit(AppGetAllUsersSuccessState());
    }).catchError((error) {
      emit(AppGetAllUsersErrorState(error.toString()));
    });
  }

  void setupChats({
    required String? receiverId,
    required String? receiverName,
    required String? lastMessageText,
    required String? receiverImage,
    required Timestamp? lastMessageTime,
    required String? senderOfThisMessage,
  }) {

    //set my chat
    ChatModel myChatModel = ChatModel(
      senderName: userModel!.name,
      senderProfilePic: userModel!.image,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverProfilePic: receiverImage,
      lastMessageText: lastMessageText,
      dateTime: lastMessageTime,
      senderOfThisMessage: senderOfThisMessage,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('chats')
        .doc(receiverId)
        .set(myChatModel.toMap())
        .then((value) {
    });

    //set receiver chat
    ChatModel chatModel = ChatModel(
      senderName: receiverName,
      senderProfilePic: receiverImage,
      receiverId: uId,
      receiverName: userModel!.name,
      receiverProfilePic: userModel!.image,
      lastMessageText: lastMessageText,
      dateTime: lastMessageTime,
      senderOfThisMessage: senderOfThisMessage,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .set(chatModel.toMap())
        .then((value) {
    });
  }

  late String token;
  Future<void> sendMessage({
    required String? receiverId,
    required Timestamp dateTime,
    required String message,
    String? image,
  }) async {
     await FirebaseFirestore.instance.collection('users').doc(receiverId).get().then((value){
      token =value['token'];
    });
      setLastSeen(hisUID: uId);
      MessageModel model = MessageModel(
      message: message,
      senderId: uId,
      receiverId: receiverId,
      dateTime: dateTime,
      image: image ?? '',
    );
    //set my chat
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .add(model.toMap())
        .then((value) {
      emit(AppSendMessageSuccessState());
    }).catchError((error) {
      emit(AppSendMessageErrorState());
    });

    //set receiver chat
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(uId)
        .collection('messages')
        .add(model.toMap())
        .then((value) {
      emit(AppSendMessageSuccessState());
      }).catchError((error) {
      emit(AppSendMessageErrorState());
      });
    FirebaseFirestore.instance.collection('users').doc(receiverId).get().then((value){
      setupChats(
          receiverId: receiverId,
          receiverName: value['name'],
          receiverImage: value['image'],
          lastMessageText: image != null ? 'Image' : message,
          lastMessageTime: Timestamp.now(),
          senderOfThisMessage: uId,
      );
    });
    sendFCMNotification(token: token, senderName: userModel!.name, messageText: message);
  }

  List<MessageModel> messages = [];
  void getMessages({
    required String? receiverId,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((event) {
      messages = [];
      for (var element in event.docs) {
        messages.add(MessageModel.fromJson(element.data()));
      }
      emit(AppGetMessagesSuccessState());
    });
  }

  File? messageImage;

  void removeMessageImage() {
    messageImage = null;
    emit(AppRemoveImageSuccessState());
  }

  Future<void> getMessageImage() async {
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      messageImage = File(pickedFile.path);
      emit(AppSendImageMessagesSuccessState());
    } else {
      print('No image selected');
      emit(AppSendImageMessagesErrorState());
    }
  }

  void uploadMessageImage({
    String? receiverId,
    required Timestamp dateTime,
    required String message,
  }){
    emit(AppSendMessageLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('messageImage/${Uri.file(messageImage!.path).pathSegments.last}')
        .putFile(messageImage!)
        .then((value) {
        removeMessageImage();
        value.ref.getDownloadURL().then((value) {
        emit(AppSendMessageSuccessState());
        removeMessageImage();
        sendMessage(
          receiverId: receiverId,
          dateTime: dateTime,
          message: message,
          image: value,
        );
      }).catchError((error) {
        emit(AppSendMessageErrorState());
      });
    }).catchError((error) {
      emit(AppSendMessageErrorState());
    });
  }

  void followUser({
  required String? userId
  })
  {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('following')
        .doc(userId)
        .set({'dateTime' : Timestamp.now().toString()}).then((value){
          followingId.add(userId!);
          emit(AppFollowSuccessState());
    }).then((value)
    {
      getFollowing();
    });
  }

  void unfollowUser({
    required String? userId
  })
  {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('following')
        .doc(userId)
        .delete().then((value){
          followingId.remove(userId);
          following.removeWhere((element) => element.uId==userId);
      emit(AppUnfollowSuccessState());
    });
  }

  List<UserModel> following = [];
  List<String> followingId = [];
  void getFollowing() {
    emit(AppGetFollowingLoadingState());
    following = [];
    followingId=[];
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('following')
        .get()
        .then((value){
       for(var element in value.docs)
         {
           followingId.add(element.id);
           FirebaseFirestore.instance
               .collection('users')
               .doc(element.id)
               .get()
               .then((value){
                following.add(UserModel.fromJson((value.data())));
                });
         }
    });
    emit(AppGetFollowingSuccessState());
  }

  bool isDark = CasheHelper.getData(key: 'isDark') ?? false;

  void changeAppMode() {
    isDark = !isDark;
    CasheHelper.putData(key: 'isDark', value: isDark).then((value) {
      emit(AppChangeModeState());
    });
  }

  List<String> lastMessage = [];
  void getLastMessage({
    required String hisUID,
  })
  {
        FirebaseFirestore.instance.collection('users')
        .doc(uId)
        .collection('chats')
        .doc(hisUID)
        .collection('messages')
        .orderBy('dateTime' , descending: true)
        .snapshots()
        .listen((value){
          value.docs.first.reference.snapshots()
          .listen((value){
            if(uId == value['senderId'])
              {
                lastMessage.add('You: '+ value['message'].toString());
              }
            else {
          lastMessage.add(value['message'].toString());
        }
      });
    });
  }

  bool wasActive({
    required Timestamp? lastSeen,
  })
  {
      var now = Timestamp.now().toDate();
      var difference = now.difference(lastSeen!.toDate());
      if (difference.inMinutes <= 15)
        {
          return true;
        }
      else
      {
        return false;
      }
  }

  Timestamp lastSeen=Timestamp.now();

  Future<void> getLastSeen({
  required String? UID
  })async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(UID)
        .get()
        .then((value){
        lastSeen = value['lastSeen'];
        });
  }

  String formatLastSeen({
    required Timestamp? lastSeen,
  })
  {
    var now = Timestamp.now().toDate();
    var difference = now.difference(lastSeen!.toDate());
    if (difference.inHours < 24)
      {
        if(difference.inMinutes < 1)
          {
            return 'Active now';
          }
        else if (difference.inMinutes < 60)
          {
            return 'Active ${difference.inMinutes} minutes ago';
          } else
          {
            return 'Active ${difference.inHours} hours ago';
          }
      }
      else if (difference.inDays <= 30)
      {
        if(difference.inDays < 2)
        {
          return 'last seen yesterday';
        }
        else
        {
          return 'last seen ${difference.inDays} days ago';
        }
      }
    return 'last seen along time ago';
  }

  void setLastSeen({
  required hisUID
})
  {
    FirebaseFirestore.instance
        .collection('users')
        .doc(hisUID)
        .update({'lastSeen': Timestamp.now()});
  }

  void sendFCMNotification({
    required String? token,
    required String? senderName,
    String? messageText,
    String? messageImage,
  }) {
    DioHelper.postData(
        data: {
          "to": "$token",
          "notification": {
            "title": "$senderName",
            "body":
            "${messageText != null ? messageText : messageImage != null ? 'Photo' : 'ERROR 404'}",
            "sound": "default"
          },
          "android": {
            "Priority": "HIGH",
          },
          "data": {
            "type": "order",
            "id": "87",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          }
        });
  }
}

