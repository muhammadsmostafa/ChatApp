import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/chat_details/chat_details_screen.dart';
import 'package:chat_app/modules/image_viewer/image_viewer_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileScreen extends StatelessWidget {
  UserModel model;
  UserProfileScreen(this.model);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state){},
      builder: (context,state)
      {
        return WillPopScope(
          onWillPop: ()
          async {
            AppCubit.get(context).getFollowing();
            return true;
          },
          child: Scaffold(
          appBar: AppBar(
                leading: IconButton(
                  onPressed: ()
                  {
                    AppCubit.get(context).getFollowing();
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    IconBroken.Arrow___Left_2,
                  ),
                ),
            ),
          body: Column(
            children:
            [
              InkWell(
                onTap: ()
                {
                  navigateTo(context, ImageViewerScreen('${model.image}'));
                },
                child: CircleAvatar(
                  radius: 104,
                  backgroundColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
                  child:  CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                      '${model.image}',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '${model.name}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                '${model.bio}',
                style: Theme.of(context).textTheme.caption,
              ),
              Row(
                children: [
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(10.0),
                  //     child: defaultButton(
                  //         function: (){
                  //           navigateTo(context,
                  //               ChatDetailsScreen(userModel: model,));
                  //         },
                  //         text: 'send message'),
                  //   ),
                  // ),
                  AppCubit.get(context).followHim || state is AppFollowSuccessState
                  ?
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: defaultButton(
                          function: ()
                          {
                            AppCubit.get(context).unfollowUser(userId: model.uId);
                            AppCubit.get(context).followHim=false;
                          },
                          text: 'Unfollow'),
                      ),
                    )
                      :
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: defaultButton(
                          function: ()
                          {
                            AppCubit.get(context).followUser(userId: model.uId);
                          },
                          text: 'Follow'),
                    ),
                  ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
