import 'package:flutter/material.dart';
import 'package:sih_admin/gallery/db_helper.dart';
import 'package:sih_admin/gallery/photo.dart';
import 'package:sih_admin/gallery/utility.dart';
import 'package:sih_admin/model.dart';

class Fullscreenimageview extends StatelessWidget {
  final String base64String;
  final DbHelper dbHelper;

  Fullscreenimageview({
    Key? key,
    required this.base64String,
    required this.dbHelper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Image Viewer'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => HandleClick(value, context),
            itemBuilder: (BuildContext context) {
              return {'Delete', 'Colorize'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Center(
        child: Utility.imageFromBase64String(base64String),
      ),
    );
  }

  void HandleClick(String value, BuildContext context) {
    switch (value) {
      case 'Delete':
        Utility.deleteFromDb(context,base64String,dbHelper);
        break;
      case 'Colorize':
        Navigator.push(
          context,
          PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
              => Model(base64String: base64String),
            transitionsBuilder: (context, animation, secondaryAnimation, child){
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                  position: offsetAnimation,
                  child: child);
            },
            transitionDuration: Duration(milliseconds: 100)
          )
          // MaterialPageRoute(
          //   builder: (context) => Model(base64String: base64String),
          // ),
        );
        break;
    }
  }
}
