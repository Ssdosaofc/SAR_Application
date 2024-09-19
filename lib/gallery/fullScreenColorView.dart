import 'package:flutter/material.dart';
import 'package:sih_admin/gallery/utility.dart';
import 'package:sih_admin/model.dart';

import 'db_helper.dart';

class Fullscreencolorview extends StatelessWidget {
  final String base64String;
  final DbHelper dbHelper;

  const Fullscreencolorview({Key? key, required this.base64String, required this.dbHelper}) : super(key: key);

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
              return {'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice)
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

  void HandleClick(String value,BuildContext context) {
    switch (value) {
      case 'Delete':
        Utility.deleteFromDb(context,base64String,dbHelper);
        break;
    }
  }
}