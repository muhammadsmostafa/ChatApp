import 'package:buildcondition/buildcondition.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/chat_model.dart';
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
      List<ChatModel> chatModel = AppCubit.get(context).chatModel;
        return RefreshIndicator(
          onRefresh: () async {
            await AppCubit.get(context).getChats().then((value){
              AppCubit.get(context).setLastSeen(hisUID: uId);
            });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!FirebaseAuth.instance.currentUser!.emailVerified)
                    emailNotVerifyed(context: context),
                BuildCondition(
                  condition: AppCubit.get(context).following.isNotEmpty,
                  builder: (context) => Column(
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
                  ),
                  fallback: (context) => Builder(
                    builder: (context) {
                      Future.delayed(Duration(milliseconds: 200)).then((value){
                        AppCubit.get(context).changeBottomNav(4);
                      });
                      return SizedBox();
                    }
                  ),
                ),
                BuildCondition(
                  condition: chatModel.isNotEmpty,
                  builder: (context) => Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemBuilder: (context, index) => buildChatItem(context, chatModel[index],),
                        separatorBuilder: (context, index) => myDivider(),
                        itemCount: chatModel.length
                    ),
                  ),
                  fallback: (context) => Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Messages Yet',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
      },
    );
  }

  Widget buildChatItem(context, ChatModel model,) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: InkWell(
          onTap: ()
          {
            AppCubit.get(context).getLastSeen(UID: model.receiverId).then((value){
              navigateTo(
                context,
                ChatDetailsScreen(chatModel: model,),
              );
            });
          },
          child: Row(
              children:
              [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        '${model.receiverProfilePic}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model.receiverName}',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Spacer(),
                        Row(
                          children: [
                            uId == model.senderOfThisMessage
                            ?
                            Text(
                              'you: ${model.lastMessageText}',
                              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                color: Colors.grey,
                              ),
                            )
                            :
                            Text(
                              '${model.lastMessageText}',
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
              ]
          ),
        ),
      );
  
  Widget buildFollowingItem(context, UserModel followingUserModel,) => Container(
    width: 70,
    child: InkWell(
      onTap: ()
      {
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
