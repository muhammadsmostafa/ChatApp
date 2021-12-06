import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/modules/edit_profile/edit_profile_screen.dart';
import 'package:chat_app/modules/image_viewer/image_viewer_screen.dart';
import 'package:chat_app/modules/login/login_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/network/local/cashe_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state){},
      builder: (context,state)
      {
        var userModel = AppCubit.get(context).userModel;
        return userModel!=null
            ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children:
            [
              InkWell(
                onTap: ()
                {
                  navigateTo(context, ImageViewerScreen('${userModel.image}'));
                },
                child: CircleAvatar(
                  radius: 104,
                  backgroundColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                  child:  CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                      '${userModel.image}',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '${userModel.name}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                '${userModel.bio}',
                style: Theme.of(context).textTheme.caption,
              ),
                   Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: defaultButton(
                          function: (){
                            navigateTo(context,
                                EditProfileScreen());
                          },
                          text: 'edit profile'),
                    ),
              const Spacer(),
              state is AppLogoutLoadingState
              ?
              const Center(child: Padding(
                padding: EdgeInsets.all(10.0),
                child: CircularProgressIndicator(),
              ))
              :
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: defaultButton(
                  background: Colors.red,
                    function: (){
                      AppCubit.get(context).logout()
                      .then((value){
                        CasheHelper.saveData(key: 'uId', value: '');
                        uId='';
                        navigateAndFinish(context, LoginScreen());
                      });
                    },
                    text: 'logout'),
              ),
            ],
          ),
        )
            :
        const Center(child: CircularProgressIndicator());
      },
    );
  }
}
