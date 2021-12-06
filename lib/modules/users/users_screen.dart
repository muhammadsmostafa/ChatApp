import 'package:buildcondition/buildcondition.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/chat_details/chat_details_screen.dart';
import 'package:chat_app/modules/user_profile/user_profile_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context , state) {},
      builder: (context, state){
        return BuildCondition(
          condition: AppCubit.get(context).users.isNotEmpty,
          builder: (context) => RefreshIndicator(
            onRefresh: () async {
              await AppCubit.get(context).getAllUsers();
            },
            child: ListView.separated(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, index) => buildChatItem(context, AppCubit.get(context).users[index]),
                separatorBuilder: (context, index) => myDivider(),
                itemCount: AppCubit.get(context).users.length > 20
                ?
                20
                :
                AppCubit.get(context).users.length
            ),
          ),
          fallback: (context) => LinearProgressIndicator(),
        );
      },
    );
  }

  Widget buildChatItem(context, UserModel model) => Padding(
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
            child: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                '${model.image}',
              ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model.name}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    '${model.bio}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ]
    ),
  );
}
