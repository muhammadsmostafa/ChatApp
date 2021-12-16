import 'package:buildcondition/buildcondition.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/modules/user_profile/user_profile_screen.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:chat_app/shared/styles/colors.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailsScreen extends StatelessWidget
{
  UserModel userModel;
  var messageController = TextEditingController();
  ChatDetailsScreen({required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context){
        AppCubit.get(context).getMessages(receiverId: userModel.uId);
        return BlocConsumer<AppCubit,AppStates>(
          listener: (context , state) {},
          builder: (context , state) {
            var messageImage = AppCubit.get(context).messageImage;
            return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      onPressed: ()
                      {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        IconBroken.Arrow___Left_2,
                      ),
                    ),
                  titleSpacing: 0,
                  title: InkWell(
                    onTap: ()
                    {
                      AppCubit.get(context).checkFollow(uId: userModel.uId);
                      navigateTo(context, UserProfileScreen(userModel));
                    },
                    child: Row(
                      children:
                      [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              '${userModel.image}'
                          ),
                        ),
                        const SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${userModel.name}'),
                            Text(
                              AppCubit.get(context).getLastSeen(lastSeen: userModel.lastSeen),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                body: BuildCondition(
                  condition: true,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                              reverse: true,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index)
                              {
                                var message = AppCubit.get(context).messages[index];
                                if(AppCubit.get(context).userModel!.uId == message.senderId) {
                                  return buildMyMessage(message);
                                }
                                else {
                                  return buildMessage(message, userModel.image);
                                }
                              },
                              separatorBuilder: (context, index) => const SizedBox(height: 15,),
                              itemCount: AppCubit.get(context).messages.length
                          ),
                        ),
                        if(messageImage != null)
                          Stack(
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration:  BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage
                                    (
                                    image: FileImage(messageImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: ()
                                  {
                                    AppCubit.get(context).removeMessageImage();
                                  },
                                  icon: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: defaultColor,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  )
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                  15
                              )
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Row(
                            children:
                            [
                              MaterialButton(
                                onPressed:()
                                {
                                  AppCubit.get(context).getMessageImage();
                                },
                                minWidth: 1,
                                child: const Icon(
                                  IconBroken.Camera,
                                  size: 16,
                                  color: defaultColor,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: messageController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'type your message here ...',
                                  ),
                                ),
                              ),
                              MaterialButton(
                                onPressed:()
                                {
                                  if(messageImage != null || messageController.text.isNotEmpty) {
                                    if (messageImage == null) {
                                      AppCubit.get(context).sendMessage(
                                          receiverId: userModel.uId,
                                          dateTime: DateTime.now().toString(),
                                          message: messageController.text
                                      );
                                    } else {
                                      AppCubit.get(context)
                                          .uploadMessageImage(
                                          receiverId: userModel.uId,
                                          dateTime: DateTime.now().toString(),
                                          message: messageController.text
                                      );
                                    }
                                    AppCubit.get(context).removeMessageImage();
                                    messageController.text = '';
                                  }
                                },
                                minWidth: 1,
                                child: const Icon(
                                  IconBroken.Send,
                                  size: 16,
                                  color: defaultColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  fallback: (context) => Center(
                    child: Column(
                      children: const [
                        Text('No messages yet'),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                )
            );
          },
        );
      },
    );
  }
}

Widget buildMessage(MessageModel messageModel , String? image) => Align(
  alignment: AlignmentDirectional.centerStart,
  child: Row(
    children: [
      CircleAvatar(
        radius: 15,
        backgroundImage: NetworkImage(
            '${image}'
        ),
      ),
      SizedBox(width: 5,),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd : Radius.circular(10),
            topEnd : Radius.circular(10),
            topStart : Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10
        ),
        child: messageModel.image==''
            ?
        Text(
            '${messageModel.message}'
        )
            :
        Column(
          children: [
            Image(image: NetworkImage(
              '${messageModel.image}',
            ),
              width: 250,
            ),
            if(messageModel.message != '')
              Text(
                '${messageModel.message}',
              )
          ],
        ),
      ),
    ],
  ),
);

Widget buildMyMessage(MessageModel messageModel) => Align(
  alignment: AlignmentDirectional.centerEnd,
  child: Container(
    decoration: BoxDecoration(
      color: defaultColor.withOpacity(0.2),
      borderRadius: const BorderRadiusDirectional.only(
        bottomStart : Radius.circular(10),
        topEnd : Radius.circular(10),
        topStart : Radius.circular(10),
      ),
    ),
    padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10
    ),
    child: messageModel.image==''
        ?
    Text(
        '${messageModel.message}'
    )
        :
    Column(
      children: [
        Image(image: NetworkImage(
          '${messageModel.image}',
        ),
          width: 250,
        ),
        if(messageModel.message != '')
          Text(
            '${messageModel.message}',
          )
      ],
    ),
  ),
);
