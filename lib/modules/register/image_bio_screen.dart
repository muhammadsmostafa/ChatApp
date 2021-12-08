import 'package:chat_app/layout/app_layout.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageBioScreen extends StatelessWidget {
  var bioController= TextEditingController();
  var formKey = GlobalKey<FormState>();
  String name;
  String phone;
  ImageBioScreen({
    required this.name,
    required this.phone,
});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state){},
      builder: (context,state){
        var profileImage = AppCubit.get(context).profileImage;
        return Scaffold(
            appBar: AppBar(
              actions:
                [
                  defaultTextButton(
                      function: ()
                      {
                        AppCubit.get(context).getChats();
                        AppCubit.get(context).getFollowing();
                        navigateAndFinish(context, AppLayout());
                      }, text: 'Skip')
                ]
            ),
            body: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                  [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 104,
                          child:
                              profileImage == null
                              ?
                              const Icon(
                            IconBroken.Profile,
                            size: 200,
                          )
                              :
                              CircleAvatar(
                                radius: 100,
                                backgroundImage: FileImage(profileImage),
                              )
                        ),
                        CircleAvatar(
                          radius: 20,
                          child: IconButton(
                              onPressed: ()
                              {
                                AppCubit.get(context).getProfileImage();
                              },
                              icon: const Icon(
                                  IconBroken.Camera,
                                color: Colors.white,
                                size: 20,
                              )),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: defaultFormField(
                          controller: bioController,
                          type: TextInputType.text,
                          validate: (String? value)
                          {
                            if (value!.isEmpty)
                            {
                              return 'please enter your bio';
                            }
                          },
                          label: 'Bio',
                          prefix: IconBroken.Edit,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:
                        state is AppUploadProfileImagePickedLoadingState
                        ?
                        const Center(child: CircularProgressIndicator())
                      :
                      defaultButton(
                          function: ()
                          {
                            if(profileImage != null && formKey.currentState!.validate())
                              {

                                AppCubit.get(context).uploadProfileImage(
                                    name: name,
                                    phone: phone,
                                    bio: bioController.text
                                ).then((value){
                                  AppCubit.get(context).getUserData();
                                  navigateAndFinish(context, AppLayout());
                                });
                              } else if(profileImage == null)
                                {
                                  showToast(message: 'please choose picture');
                                }
                            else if(profileImage == null && !formKey.currentState!.validate())
                            {
                              showToast(message: 'please choose picture and write your bio');
                            }
                          },
                          text: 'continue'),
                    ),
                  ],
                ),
              ),
            )
        );
      },
    );
  }
}
