import 'dart:io';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/chat/chats_screen.dart';
import 'package:chat_app/modules/profile/profile_screen.dart';
import 'package:chat_app/modules/users/users_screen.dart';import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/network/local/cashe_helper.dart';
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


  List<UserModel> chatUsers =[];
  bool getChatsFinished = true;
  Future <void> getChats() async {
    emit(AppGetChatsLoadingState());
    getChatsFinished=false;
    chatUsers=[];
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('chats')
        .orderBy('dateTime', descending: true)
        .get()
        .then((value){
      for(var element in value.docs)
      {
        FirebaseFirestore.instance
            .collection('users')
            .doc(element.id)
            .get()
            .then((value){
          chatUsers.add(UserModel.fromJson((value.data())));
        });
      }
      emit(AppGetChatsSuccessState());
    });
    getChatsFinished=true;
  }

  Future<void> logout()
  async {
    emit(AppLogoutLoadingState());
    FirebaseAuth.instance.signOut()
    .then((value){
      emit(AppLogoutSuccessState());
    });
  }

  int currentIndex = 0;
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

  bool empty = false;
  void changeBottomNav(int index) {
    if (index == 4)
      {
        emit(AppShowSuccess());
      }
    else
      {
        if(index == 0)
        {
          empty = false;
          if(getChatsFinished && getFollowingFinished) {
            getChats();
            getFollowing();
          }
        }
        if (index == 1) {
          if(getAllUserFinished) {
            getAllUsers();
          }
        }
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
  bool getAllUserFinished = true;
  Future<dynamic> getAllUsers() async {
    users = [];
    getAllUserFinished=false;
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.id != uId) {
          users.add(UserModel.fromJson(element.data()));
        }
        users.shuffle();
      }
      emit(AppGetAllUsersSuccessState());
      getAllUserFinished=true;
    }).catchError((error) {
      emit(AppGetAllUsersErrorState(error.toString()));
    });
  }

  void setupChats({
    required String? receiverId,
  }) {
    //set my chat
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('chats')
        .doc(receiverId)
        .set({'dateTime' : DateTime.now().toString()})
        .then((value) {
    });

    //set receiver chat
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .set({'dateTime' : DateTime.now().toString()})
        .then((value) {
    });
  }

  void sendMessage({
    required String? receiverId,
    required String dateTime,
    required String message,
    String? image,
  }) {
    MessageModel model = MessageModel(
      message: message,
      senderId: userModel!.uId,
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
    setupChats(receiverId: receiverId);
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
        .orderBy('dateTime')
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
    required String dateTime,
    required String message,
  }) {
    emit(AppSendMessageLoadingState());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('messageImage/${Uri.file(messageImage!.path).pathSegments.last}')
        .putFile(messageImage!)
        .then((value) {
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
        .set({'dateTime' : DateTime.now().toString()}).then((value){
          emit(AppFollowSuccessState());
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
      emit(AppUnfollowSuccessState());
      getFollowing();
    });
  }

  List<UserModel> following = [];
  List<String> followingId = [];
  bool getFollowingFinished = true;
  void getFollowing() {
    emit(AppGetFollowingLoadingState());
    getFollowingFinished = false;
    following = [];
    followingId=[];
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('following')
        .orderBy('dateTime', descending: true)
        .get()
        .then((value){
       for(var element in value.docs)
         {
           FirebaseFirestore.instance
               .collection('users')
               .doc(element.id)
               .get()
               .then((value){
                 following.add(UserModel.fromJson((value.data())));
                 followingId.add(element.id);
           });
         }
       getFollowingFinished = true;
    });
  }

  bool followHim = false;
  void checkFollow({
  String? uId
  })
  {
    followHim=false;
    followingId.forEach((element) {
      if(element.toString()==uId)
        {
          followHim = true;
        }
    });
  }

  bool isDark = CasheHelper.getData(key: 'isDark') ?? false;

  void changeAppMode() {
    isDark = !isDark;
    CasheHelper.putData(key: 'isDark', value: isDark).then((value) {
      emit(AppChangeModeState());
    });
  }

  // List<String> lastMessages = [];
  // List<String> dateTime = [];
  // void getLastMessage({
  //   required String hisUID,
  // })
  // {
  //   lastMessages=[];
  //   dateTime=[];
  //   FirebaseFirestore.instance.collection('users')
  //       .doc(uId)
  //       .collection('chats')
  //       .doc(hisUID)
  //       .collection('messages')
  //       .orderBy('dateTime' , descending: true)
  //       .get()
  //       .then((value){
  //         value.docs.first.reference.get()
  //         .then((value){
  //           if(uId == value['senderId'])
  //             {
  //               lastMessages.add('You: '+ value['message'].toString());
  //               dateTime.add(value['dateTime'].toString());
  //             }
  //           else {
  //         lastMessages.add(value['message'].toString());
  //         dateTime.add(value['dateTime'].toString());
  //       }
  //     });
  //   });
  // }
}

