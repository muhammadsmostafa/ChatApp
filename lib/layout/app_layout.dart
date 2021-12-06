import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/cubit.dart';
import 'cubit/states.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context, state){},
      builder: (context, state){
        var cubit = AppCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(
              cubit.titles[cubit.currentIndex],
            ),
            actions:
            [
              IconButton(
                icon: const Icon(
                  Icons.brightness_4_outlined,
                ),
                onPressed: ()
                {
                  AppCubit.get(context).changeAppMode();
                },
              ),
            ],
          ),
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar: BottomNavigationBar
            (
            currentIndex: cubit.currentIndex,
            onTap: (index)
            {
              cubit.changeBottomNav(index);
            },
            items:
            const [
              BottomNavigationBarItem(
                  icon: Icon(
                    IconBroken.Chat
                  ),
                  label: 'Chats'
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                      IconBroken.User1
                  ),
                  label: 'Users'
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                      IconBroken.Profile
                  ),
                  label: 'Profile'
              ),
            ],
          ),
        );
      },
    );
  }
}
