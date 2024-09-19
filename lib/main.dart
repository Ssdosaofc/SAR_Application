import 'package:flutter/material.dart';
import 'package:sih_admin/homepage.dart';
import 'package:sih_admin/model.dart';
import 'package:sih_admin/saved_images.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int myIndex =0;
  List<Widget> widgetList = [Homepage(),SavedImages()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SAR Image Detector",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),centerTitle: false,backgroundColor: Color(0xFF0C8BD4),),
      // body: Center(
      //   child: widgetList[myIndex],
      // ),
      body: IndexedStack(
        children: widgetList,
        index: myIndex,
      ),
      // appBar: AppBar(title: Text(''),),
      bottomNavigationBar: BottomNavigationBar(
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        // type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black12,
        onTap:
          (index){
        setState(() {
          myIndex = index;
        });
      }
        ,items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.cyan),label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.cable,color: Colors.cyan,),label: 'Saved'),
        ],),
    );
  }
}
