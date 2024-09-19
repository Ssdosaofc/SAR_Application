import 'dart:ui';

import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:sih_admin/gallery/db_helper.dart';
import 'package:sih_admin/gallery/photo.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'dart:convert';

import 'fullScreenImageView.dart';

class Utility{

  static Image imageFromBase64String(String base64String){
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.fill,
        height: 256.0,width: 256.0,
      );
    } catch (e) {
      print("Error decoding base64 image: $e");
      return Image.asset('assets/error_image.png');
    }
  }

  static Uint8List dataFromBase64String(String base64String){
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data){
    return base64Encode(data);
  }

  Widget gridView(BuildContext context, List<Photo> photos, int cross, DbHelper dbHelper, Function(String) Open){
    return Padding(padding: EdgeInsets.all(5.0),
      child: GridView.count(crossAxisCount: cross,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: photos.map((photo){
          return GestureDetector(
            onTap: (){
              Open(photo.photoName);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context)=>
              //         Fullscreenimageview(base64String: photo.photoName, dbHelper: dbHelper,)
              //     )
              // );
            },
            child: Utility.imageFromBase64String(photo.photoName),
          );
          // return Utility.imageFromBase64String(photo.photoName);
        }).toList(),
      ),
    );
  }

  static void deleteFromDb(BuildContext context, String base64String,DbHelper dbHelper) async {
    try {
      List<Photo> photos = await dbHelper.getPhotos();

      Photo? photoToDelete;
      for (Photo photo in photos) {
        if (photo.photoName == base64String) {
          photoToDelete = photo;
          break;
        }
      }

      if (photoToDelete != null) {
        await dbHelper.deletePhoto(photoToDelete.id!);
        Navigator.pop(context, true);
        Toast.show("Image deleted successfully",duration: Toast.lengthShort);
      } else {
        Toast.show("Image not found in the database",duration: Toast.lengthShort);
      }
    } catch (e) {
      Toast.show("Error deleting image: $e",duration: Toast.lengthShort);
    }
  }

}