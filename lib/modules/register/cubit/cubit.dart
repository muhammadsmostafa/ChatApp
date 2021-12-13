import 'package:bloc/bloc.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/register/cubit/states.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  bool isSuccessRegister = false;
  RegisterCubit() : super(RegisterInitialState());
  static RegisterCubit get(context) => BlocProvider.of(context);

  Future<void> userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
  })
  async {
    emit(RegisterLoadingState());
    FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
    ).then((value){
      isSuccessRegister=true;
      emit(RegisterSuccessState());
      userCreate(
          name: name,
          email: email,
          password: password,
          phone: phone,
          uId: value.user!.uid);
    }).catchError((error){
      isSuccessRegister=false;
      emit(RegisterErrorState(error.toString()));
    });
  }

  void userCreate({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String uId,
  })
  {
    UserModel model = UserModel(
      name: name,
      email: email,
      password: password,
      phone: phone,
      uId: uId,
      image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQP-i5liksKo3g85Qz90jpYieJ4J_YGy5S7JQ&usqp=CAU',
      bio: 'No Bio Yet',
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap()).then((value)
    {
      emit(CreateUserSuccessState());
    })
        .catchError((error)
    {
      emit(CreateUserErrorState(error.toString()));
    });
  }

  IconData suffix = IconBroken.Shield_Done;
  bool isPassword = true;

  void changePasswordVisibility()
  {
    isPassword = !isPassword;
    suffix = isPassword ? IconBroken.Shield_Done : IconBroken.Shield_Fail;
    emit(RegisterChangePasswordVisibilityState());
  }

  IconData suffixConfirm = IconBroken.Shield_Done;
  bool isConfirmPassword = true;

  void changeConfirmPasswordVisibility()
  {
    isConfirmPassword = !isConfirmPassword;
    suffixConfirm = isConfirmPassword ?IconBroken.Shield_Done : IconBroken.Shield_Fail;
    emit(RegisterChangePasswordVisibilityState());
  }
}