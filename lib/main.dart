import 'package:bloc/bloc.dart';
import 'package:chat_app/shared/components/components.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/layout/cubit/states.dart';
import 'package:chat_app/shared/bloc_observer.dart';
import 'package:chat_app/shared/components/constants.dart';
import 'package:chat_app/shared/network/local/cashe_helper.dart';
import 'package:chat_app/shared/network/remote/dio_helper.dart';
import 'package:chat_app/shared/styles/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'layout/app_layout.dart';
import 'modules/login/login_screen.dart';


void main() async
{
  WidgetsFlutterBinding
      .ensureInitialized(); //to be sure that every thing on the method done and then open the app

  await Firebase.initializeApp();
  await DioHelper.init();

  myToken = (await FirebaseMessaging.instance.getToken())!;
  FirebaseMessaging.onMessage.listen((event) {
    showToast(message: 'you have new message');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    showToast(message: 'you have new message');
  });

  Bloc.observer = MyBlocObserver();
  await CasheHelper.init();

  bool? isDark = CasheHelper.getData(key: 'isDark');
  Widget widget;

  uId = CasheHelper.getData(key: 'uId') ?? '';

  if(uId == '')
  {
    widget = LoginScreen();
  } else
  {
    widget=const AppLayout();
  }

  isDark ??= false;

  runApp(MyApp(
    isDark: isDark,
    startWidget: widget,
  ));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final Widget startWidget;
  const MyApp({Key? key, required this.isDark, required this.startWidget}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool firstTime = true;
    return BlocProvider(
      create: (context) => AppCubit(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (context,state) {},
        builder: (context,state){
          if(uId != '' && firstTime)
          {
            AppCubit.get(context).getUserData();
            AppCubit.get(context).getChats();
            AppCubit.get(context).getFollowing();
            AppCubit.get(context).getAllUsers();
            firstTime = false;
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: AppCubit.get(context).isDark ? ThemeMode.dark : ThemeMode.light,
            home: startWidget,
          );
        },
      ),
    );
  }
}