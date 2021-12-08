import 'package:chat_app/layout/cubit/cubit.dart';
import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function(String val)? onSubmit,
  Function(String val)? onChange,
  Function()? onTap,
  Function()? suffixPressed,
  bool isPassword = false,
  required String? Function(String? val)? validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  bool isClickable = true,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      enabled: isClickable,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      onTap: onTap,
      validator: validate,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
          onPressed: suffixPressed,
          icon: Icon(
            suffix,
          ),
        )
            :null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 3.0,
  required Function() function,
  required String text,
}) =>
    Container(
      width: width,
      height: 40.0,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius,
        ),
        color: background,
      ),
    );

Widget defaultTextButton({
  required Function() function,
  required String text,
}) => TextButton(
  onPressed: function,
  child: Text(text.toUpperCase()),
);

Widget myDivider() => Padding (
  padding: const EdgeInsetsDirectional.only(
    start:10.0,
    end: 10.0,
  ),
  child: Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[300],
  ),
);

void navigateTo(context , widget) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => widget,
  ),
);

void navigateAndFinish(context , widget) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
        (route)
    {
      return false;
    }
);

void showToast({
  required String message,
})=> Fluttertoast.showToast(
  msg: message,
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 5,
  fontSize: 16.0,
);

Widget emailNotVerifyed({
  required context,
}) => Container(
  color: Colors.amber,
  height: 40,
  child: Padding(
    padding: const EdgeInsetsDirectional.only(start: 10),
    child: Row(
      children: [
        Icon(
            IconBroken.Shield_Fail
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Please verify your email',
          style: TextStyle(
            color: Colors.white,
          )
        ),
        Spacer(),
        TextButton(
          onPressed: ()
          {
            FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value){
              AppCubit.get(context).logout();
              showToast(message: 'Verify your mail and login again');
            });
          },
          child: Text(
              'SEND'
          ),
        )
      ],
    ),
  ),
);