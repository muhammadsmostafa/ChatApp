import 'package:bloc/bloc.dart';
import 'package:chat_app/modules/login/cubit/states.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  void userLogin({
  required String email,
  required String password,})
  {
    emit(LoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
    ).then((value) async {
      myToken = (await FirebaseMessaging.instance.getToken())!;
      emit(LoginSuccessState(value.user!.uid));
      FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .update({'token': myToken});
    }).catchError((error){
      emit(LoginErrorState());
    });
  }

  IconData suffix = IconBroken.Shield_Done;
  bool isPassword = true;

  void changePasswordVisibility()
  {
    isPassword=!isPassword;
    isPassword ? IconBroken.Shield_Done : IconBroken.Shield_Fail;
    emit(LoginChangePasswordVisibilityState());
  }
}