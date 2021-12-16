import 'package:buildcondition/buildcondition.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/chat_details/chat_details_screen.dart';
import 'package:chat_app/modules/user_profile/user_profile_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context , state) {},
      builder: (context, state){
      List<UserModel> chatUsers = AppCubit.get(context).chatUsers;
        return BuildCondition(
          condition: chatUsers.isNotEmpty || AppCubit.get(context).following.isNotEmpty,
          builder: (context) => RefreshIndicator(
          onRefresh: () async {
            await AppCubit.get(context).getChats().then((value){
              AppCubit.get(context).empty=false;
              AppCubit.get(context).getFollowing();
              AppCubit.get(context).setLastSeen(hisUID: uId);
            });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!FirebaseAuth.instance.currentUser!.emailVerified)
                    emailNotVerifyed(context: context),
                AppCubit.get(context).following.isNotEmpty
                ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 10),
                      child: Text(
                        'Following',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 10),
                      child: Container(
                        height: 90.0,
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => buildFollowingItem(context, AppCubit.get(context).following[index],),
                            separatorBuilder: (context, index) => SizedBox(width: 10,),
                            itemCount: AppCubit.get(context).following.length,
                        ),
                      ),
                    ),
                  ],
                )
                :
                SizedBox(),
                Expanded(
                  child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemBuilder: (context, index) => buildChatItem(context, chatUsers[index],AppCubit.get(context).lastMessage[index],),
                      separatorBuilder: (context, index) => myDivider(),
                      itemCount: chatUsers.length
                  ),
                ),
              ],

            ),
          ),
          fallback: (context)  {
            Future.delayed(Duration(milliseconds: 700)).then((value){
              AppCubit.get(context).changeBottomNav(4);
              if(chatUsers.isEmpty)
                AppCubit.get(context).empty=true;
            });
            return AppCubit.get(context).empty
                ?
                Column(
                  children: [
                    if(!FirebaseAuth.instance.currentUser!.emailVerified)
                      emailNotVerifyed(context: context),
                  ],
                )
                :
                LinearProgressIndicator();
          },
        );
      },
    );
  }

  Widget buildChatItem(context, UserModel model, String message,) => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
        children:
        [
          InkWell(
            onTap: ()
            {
              AppCubit.get(context).checkFollow(uId: model.uId);
              navigateTo(
                context,
                UserProfileScreen(model),
              );
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    '${model.image}',
                  ),
                ),
                AppCubit.get(context).wasActive(lastSeen: model.lastSeen)
                    ?
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.green,
                    ),
                  ],
                )
                    :
                SizedBox()
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: InkWell(
              onTap: ()
              {
                navigateTo(
                  context,
                  ChatDetailsScreen(userModel: model),
                );
              },
              child: Container(
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model.name}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          '${message}',
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
    ),
  );
  
  Widget buildFollowingItem(context, UserModel followingUserModel,) => Container(
    width: 70,
    child: InkWell(
      onTap: ()
      {
        AppCubit.get(context).checkFollow(uId: followingUserModel.uId);
        navigateTo(context,
          UserProfileScreen(followingUserModel),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  '${followingUserModel.image}',
                ),
              ),
              AppCubit.get(context).wasActive(lastSeen: followingUserModel.lastSeen)
                  ?
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.green,
                  ),
                ],
              )
                  :
              SizedBox()
            ],
          ),
          SizedBox(height: 10,),
          Text(
            '${followingUserModel.name}',
            style: Theme.of(context).textTheme.subtitle1,maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
