import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sih_admin/saved_images.dart';
import 'package:toast/toast.dart';

import 'gallery/db_helper.dart';
import 'gallery/photo.dart';
import 'gallery/utility.dart';

class Model extends StatefulWidget {
  final String? base64String;
  const Model({Key? key,required this.base64String}):super(key: key);

  @override
  State<Model> createState() => _ModelState();
}

class _ModelState extends State<Model> {

  // File? _imageFile;
  Image? _resultImage;
  late DbHelper dbHelper;
  late String base64String_color;
  Utility utility  = Utility();
  ToastContext toastContext = ToastContext();

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper(TABLE: 'SavedTable',DB_NAME: 'saved.db');
    toastContext.init(context);
  }

  final Dio _dio = Dio();

  Image? _displayImage() {
    if (widget.base64String != null) {
      return Utility.imageFromBase64String(widget.base64String!);
    }
    return null;
  }

  //function to upload image from gallery
  // Future<void> _pickImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //       _resultImage = null; // Clear the result image when picking a new image
  //     });
  //   }
  // }

  Future<void> _uploadAndFetchResult() async {
    if (widget.base64String == null || widget.base64String!.isEmpty) return;

    try {
      final response = await _dio.post(
        'http://172.22.107.88:5001/predict',
        data: jsonEncode({'image': widget.base64String}),
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      base64String_color = response.data['result'] as String;
      final imageBytes = base64Decode(base64String_color);

      setState(() {
        _resultImage = Image.memory(imageBytes);
      });

      Toast.show("Generated successfully",duration: Toast.lengthShort);
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  void saveToDb(){

    if (_resultImage == null){
      Toast.show("No Image Found",duration: Toast.lengthShort);
    }

    Photo photo = Photo(id: 0, photoName: base64String_color);
    try {
      dbHelper.save(photo).then((_) {

        Toast.show("Saved successfully",duration: Toast.lengthShort);
      });
    } catch (e) {
      Toast.show("Unable to save: $e",duration: Toast.lengthShort);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // appBar: AppBar(title: Text("SAR Image Detector",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),centerTitle: true,backgroundColor: Colors.deepPurple,),
      body: Container(
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         image: NetworkImage('https://t4.ftcdn.net/jpg/02/43/75/73/360_F_243757367_gBpS6R5c8DB7pL5gw9gi9KXlzFfbdZOA.jpg'),
        //         fit: BoxFit.cover)
        //
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            _displayImage() ?? Text("Image Not Found"),
            // _imageFile == null
            //     ? Text("Image Not Found")
            //     :
            // Image.file(_imageFile!,height: 256.0,width: 256.0,),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _uploadAndFetchResult,
                  child: Text("Generate"),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: saveToDb,
                  child: Text("Save"),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (_resultImage != null) ...[
              Text("Processed Image:"),
              SizedBox(height: 10.0),
              _resultImage!,
            ],
          ],
        ),
      ),
    );
  }
}
