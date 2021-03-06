import 'package:bloc/bloc.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/register/cubit/states.dart';
import 'package:chat_app/shared/components/components.dart';
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
      if(error.code == 'weak-password')
      {
        showToast(message: 'Password Weak');
      } else if(error.code == 'email-already-in-use')
      {
        showToast(message: 'This Email Already Used');
      }
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
      image: 'https://meetanentrepreneur.lu/wp-content/uploads/2019/08/profil-linkedin.jpg',
      bio: 'No Bio Yet',
      lastSeen: Timestamp.now(),
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap()).then((value)
    {
      emit(CreateUserSuccessState());
    }).catchError((error) {
      emit(CreateUserErrorState());
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