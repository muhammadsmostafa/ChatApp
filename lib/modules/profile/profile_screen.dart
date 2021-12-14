import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/modules/edit_profile/edit_profile_screen.dart';
import 'package:chat_app/modules/image_viewer/image_viewer_screen.dart';
import 'package:chat_app/modules/login/login_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        Column(
          children:
          [
            if(!FirebaseAuth.instance.currentUser!.emailVerified)
              emailNotVerifyed(context: context),
            SizedBox(height: 10,),
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
                    AppCubit.get(context).removeTokenAndUid();
                    AppCubit.get(context).changeBottomNav(1);
                      navigateAndFinish(context, LoginScreen()).then((value){
                        AppCubit.get(context).logout();
                    });
                  },
                  text: 'logout'),
            ),
          ],
        )
        :
        const Center(child: CircularProgressIndicator());
      },
    );
  }
}
