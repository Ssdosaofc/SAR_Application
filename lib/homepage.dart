import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sih_admin/gallery/db_helper.dart';
import 'package:sih_admin/gallery/fullScreenImageView.dart';
import 'package:sih_admin/gallery/utility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'gallery/photo.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  int activeIndex =0;
  String name = 'SSD';
  final images = [
    'assets/s1.png',
    'assets/s2.png',
    'assets/s3.png',
    'assets/s4.png'];

  late Future<File> imageFile ;
  late Image image;
  late DbHelper dbHelper;
  late List<Photo> photos;
  Utility utility  = Utility();

  @override
  void initState() {
    super.initState();
    photos = [];
    dbHelper = DbHelper(TABLE: 'PhotosTable',DB_NAME: 'photos.db');
    refreshImages();
  }

  refreshImages(){
    dbHelper.getPhotos().then((imgs){
      setState(() {
        photos.clear();
        photos.addAll(imgs);
      });
    });
  }

  pickFromGallery(){
    final imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.gallery).then((imgFile) async {
      Uint8List? imgBytes = await imgFile?.readAsBytes();
      String imgString = Utility.base64String(imgBytes!);
      Photo photo = Photo(id: 0, photoName: imgString);
      dbHelper.save(photo);
      refreshImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Home",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),centerTitle: true,backgroundColor: Colors.deepPurple,),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 5,),
                Text(
                  // 'Recently Added'
                  'Have a look at the best outputs of our model'
                  ,style: TextStyle(color: Colors.black,fontSize: 15),textAlign: TextAlign.left,)
              ],
            ),
            SizedBox(height: 12,),
            CarouselSlider.builder(itemCount: images.length, itemBuilder: (context,index,realindex){
              final urlImage = images[index];
              return buildImage(urlImage,index);
            }, options: CarouselOptions(height: 200,onPageChanged: (index,reason){
              setState(() {
                activeIndex = index;
              });
            }
            )
            ),
            SizedBox(height: 12,),
            buildIndicator(),
            SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 12,),
                Text('Gallery',style: TextStyle(color: Colors.black,fontSize: 25),textAlign: TextAlign.left,),
                SizedBox(width: 5,),
                IconButton(onPressed: (){
                  pickFromGallery();
                }, icon:Icon(Icons.add_a_photo),)
              ],
            ),
            SizedBox(height: 12,),
            Flexible(child: utility.gridView(context,photos,4,dbHelper,_openFullscreenImageView))
          ],
        ),
      ),
    );
  }
  Widget buildIndicator()=>AnimatedSmoothIndicator(
    effect: ExpandingDotsEffect(dotWidth: 10,activeDotColor: Colors.blue,dotHeight: 5),
    activeIndex: activeIndex,
    count: images.length,
  );

  Widget buildImage(String urlImage,int index)=>
      Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: Image.asset(urlImage,fit: BoxFit.fitWidth,),
      );

  void _openFullscreenImageView(String base64String) async {
    bool? result = await
    Navigator.push(
        context,
        PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
        => Fullscreenimageview(
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
      //   builder: (context) => Model(base64String: base64String),
      // ),
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Fullscreenimageview(
    //       base64String: base64String,
    //       dbHelper: dbHelper,
    //     ),
    //   ),
    // );

    if (result ?? false) {
      refreshImages(); // Refresh images if any change is detected
    }
  }

}




