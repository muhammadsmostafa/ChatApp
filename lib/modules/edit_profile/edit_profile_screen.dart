import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/modules/profile/profile_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatelessWidget
{
  var nameController = TextEditingController();
  var bioController = TextEditingController();
  var phoneController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener:(context,state){},
      builder: (context,state){
        var userModel= AppCubit.get(context).userModel;
        var profileImage = AppCubit.get(context).profileImage;

        nameController.text=userModel!.name!;
        bioController.text=userModel.bio!;
        phoneController.text=userModel.phone!;
        return Scaffold(
            appBar: AppBar(
                leading: IconButton(
                  onPressed: ()
                  {
                    Navigator.pop(context);
                    AppCubit.get(context).removeProfileImage();
                  },
                  icon: const Icon(
                    IconBroken.Arrow___Left_2,
                  ),
                ),
                titleSpacing: 5.0,
                title: const Text(
                    'Edit Profile'
                ),
                actions: [
                  defaultTextButton(
                      function: ()
                      {
                        if(profileImage != null)
                          {
                            AppCubit.get(context).uploadProfileImage(
                                name: nameController.text,
                                phone: phoneController.text,
                                bio: bioController.text
                            );
                          }
                        AppCubit.get(context).updateUser(
                          name: nameController.text,
                          phone: phoneController.text,
                          bio: bioController.text,
                        );
                      },
                      text: 'Update'
                  ),
                  const SizedBox(
                    width: 15,
                  )
                ]
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children:
                  [
                    if (AppCubit.get(context).uploadingImage || state is AppUserUpdateLoadingState)
                      const LinearProgressIndicator(),
                    const SizedBox(height: 10,),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                            radius: 104,
                            child:
                            profileImage == null
                                ?
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage('${userModel.image}'),
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
                    const SizedBox(
                      height: 20,
                    ),
                    defaultFormField(
                      controller: nameController,
                      type: TextInputType.name,
                      validate: (String? value)
                      {
                        if(value!.isEmpty)
                        {
                          return 'name must not be empty';
                        }

                        return null;
                      },
                      label: 'Name',
                      prefix: IconBroken.User,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    defaultFormField(
                      controller: bioController,
                      type: TextInputType.name,
                      validate: (String? value)
                      {
                        if(value!.isEmpty)
                        {
                          return 'bio must not be empty';
                        }

                        return null;
                      },
                      label: 'Bio',
                      prefix: IconBroken.Info_Circle,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    defaultFormField(
                      controller: phoneController,
                      type: TextInputType.phone,
                      validate: (String? value)
                      {
                        if(value!.isEmpty)
                        {
                          return 'phone must not be empty';
                        }

                        return null;
                      },
                      label: 'Phone',
                      prefix: IconBroken.Call,
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
