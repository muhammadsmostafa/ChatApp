import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/modules/login/cubit/cubit.dart';
import 'package:chat_app/modules/login/login_screen.dart';
import 'package:chat_app/modules/register/image_bio_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/network/local/cashe_helper.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class RegisterScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => RegisterCubit(),),
        BlocProvider(create: (BuildContext context) => LoginCubit(),),
      ],
      child: BlocConsumer<RegisterCubit,RegisterStates>(
        listener: (context,state) async {
          if(RegisterCubit.get(context).isSuccessRegister)
            {
              uId=FirebaseAuth.instance.currentUser!.uid;
              CasheHelper.saveData(
                key: 'uId',
                value: FirebaseAuth.instance.currentUser!.uid,
              ).then((value) async {
                FirebaseFirestore.instance.collection('users').doc(uId).update({'token': myToken});
                AppCubit.get(context).getUserData();
                navigateAndFinish(context, ImageBioScreen(name: nameController.text,phone: phoneController.text,));
              });
            }
        },
        builder: (context,state)
        {
          return Scaffold(
            body: Center (
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGISTER',
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Register now to communicate with friends',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        defaultFormField(
                          controller: nameController,
                          type: TextInputType.name,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'please enter your name address';
                            }
                          },
                          label: 'Name',
                          prefix: IconBroken.Profile,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        defaultFormField(
                          controller: emailController,
                          type: TextInputType.emailAddress,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'please enter your email address';
                            }
                          },
                          label: 'Email Address',
                          prefix: IconBroken.Message,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        defaultFormField(
                          controller: phoneController,
                          type: TextInputType.phone,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'please enter your phone address';
                            }
                          },
                          label: 'Phone Number',
                          prefix: IconBroken.Call,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        defaultFormField(
                          controller: passwordController,
                          type: TextInputType.visiblePassword,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'password is too short';
                            }
                          },
                          isPassword: RegisterCubit.get(context).isPassword,
                          label: 'Password',
                          prefix: IconBroken.Password,
                          suffix: RegisterCubit.get(context).suffix,
                          suffixPressed: ()
                          {
                            RegisterCubit.get(context).changePasswordVisibility();
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        defaultFormField(
                          controller: confirmPasswordController,
                          type: TextInputType.visiblePassword,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'you should confirm your password';
                            }
                            if (passwordController.text!=value)
                            {
                              return 'password not match';
                            }
                          },
                          onSubmit: (value)
                          {
                            if(formKey.currentState!.validate())
                            {
                              RegisterCubit.get(context).userRegister(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                phone: phoneController.text,
                              );
                            }
                          },
                          isPassword: RegisterCubit.get(context).isConfirmPassword,
                          label: 'Confirm password',
                          prefix: IconBroken.Password,
                          suffix: RegisterCubit.get(context).suffixConfirm,
                          suffixPressed: ()
                          {
                            RegisterCubit.get(context).changeConfirmPasswordVisibility();
                          },

                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        state is RegisterLoadingState
                        ?
                        const Center(child: CircularProgressIndicator())
                        :
                        defaultButton(
                          function: () {
                            if(formKey.currentState!.validate())
                            {
                              RegisterCubit.get(context).userRegister(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                phone: phoneController.text,
                              );
                            }
                          },
                          text: 'register',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                            ),
                            defaultTextButton(
                                function: () {
                                  navigateAndFinish(
                                      context,
                                      LoginScreen());
                                },
                                text: 'login'
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
