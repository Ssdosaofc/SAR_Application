import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sih_admin/gallery/fullScreenColorView.dart';

import 'gallery/db_helper.dart';
import 'gallery/fullScreenImageView.dart';
import 'gallery/photo.dart';
import 'gallery/utility.dart';

class SavedImages extends StatefulWidget {
  const SavedImages({super.key});

  @override
  State<SavedImages> createState() => _SavedImagesState();
}

class _SavedImagesState extends State<SavedImages> {

  late Future<File> imageFile ;
  late Image image;
  late DbHelper dbHelper;
  late List<Photo> photos;
  Utility utility  = Utility();

  refreshImages() async {
    try {
      final imgs = await dbHelper.getPhotos();
      setState(() {
        photos.clear();
        photos.addAll(imgs);
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    photos = [];
    dbHelper = DbHelper(TABLE: 'SavedTable',DB_NAME: 'saved.db');
    refreshImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 12,),
              Text('Saved Images',style: TextStyle(color: Colors.black,fontSize: 15),textAlign: TextAlign.left,),
              SizedBox(width: 20,),
              IconButton(onPressed: () async {
                await refreshImages();
              }, icon: Icon(Icons.refresh))
            ],
          ),
          SizedBox(height: 12,),
          Flexible(child: utility.gridView(context, photos,2,dbHelper,_openFullscreenColorView))
        ],
      ),
    );
  }

  void _openFullscreenColorView(String base64String) async {
    bool? result = await Navigator.push(
      context,
        PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
        => Fullscreencolorview(
              base64String: base64String,
              dbHelper: dbHelper,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child){
              return ScaleTransition(
                  scale: animation,
                  child: child
              );
            },
            transitionDuration: Duration(milliseconds: 100)
        )
      // MaterialPageRoute(
      //   builder: (context) => Fullscreencolorview(
      //     base64String: base64String,
      //     dbHelper: dbHelper,
      //   ),
      // ),
    );

    if (result ?? false) {
      refreshImages();
    }
  }
}
