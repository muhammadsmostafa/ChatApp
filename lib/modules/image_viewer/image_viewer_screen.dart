import 'package:chat_app/shared/styles/icon_broken.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImageViewerScreen extends StatelessWidget {
  late String image;
  ImageViewerScreen(this.image);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          icon: const Icon(
            IconBroken.Arrow___Left_2,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Image(
            image: NetworkImage(image)),
      )
    );
  }
}
