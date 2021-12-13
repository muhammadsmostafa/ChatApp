import 'package:buildcondition/buildcondition.dart';
import 'package:chat_app/layout/app_layout.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/modules/register/register_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/network/local/cashe_helper.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class LoginScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state)
        {
          if(state is LoginErrorState)
          {
            showToast(
                message: 'Login Error',
            );
          }
          if(state is LoginSuccessState)
          {
            uId=state.uId;
            CasheHelper.saveData(
              key: 'uId',
              value: state.uId,
            ).then((value)
            {
              AppCubit.get(context).getUserData();
              showToast(
                message: 'Login Successfully',
              );
              AppCubit.get(context).getChats();
              AppCubit.get(context).getFollowing();
              navigateAndFinish(
                context,
                const AppLayout(),
              );
              LoginCubit.get(context).updateToken();
            });
          }
        },
        builder: (context, state){
          return Scaffold (
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
                          'LOGIN',
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Login now to communicate with friends',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
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
                          controller: passwordController,
                          type: TextInputType.visiblePassword,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'password is too short';
                            }
                          },
                          onSubmit: (value)
                          {
                            if(formKey.currentState!.validate()) {
                              LoginCubit.get(context).userLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          isPassword: LoginCubit.get(context).isPassword,
                          label: 'Password',
                          prefix: IconBroken.Password,
                          suffix: LoginCubit.get(context).suffix,
                          suffixPressed: ()
                          {
                            LoginCubit.get(context).changePasswordVisibility();
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        BuildCondition(
                          condition: state is! LoginLoadingState,
                          builder: (context)=> defaultButton(
                            function: () {
                              if(formKey.currentState!.validate())
                              {
                                LoginCubit.get(context).userLogin(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                              }
                            },
                            text: 'login',
                          ),
                          fallback: (context)=> const Center(child: CircularProgressIndicator()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                            ),
                            defaultTextButton(
                                function: () {
                                  navigateTo(
                                      context,
                                      RegisterScreen());
                                },
                                text: 'register'
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
