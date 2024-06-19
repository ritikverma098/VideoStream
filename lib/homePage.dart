import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video/record.dart';
import 'package:video/play.dart';
import 'package:video/video_grid.dart';
import 'package:video/widget/textBox.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final userInfo = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance.collection("users");
  String? userName = "";
  @override
  void initState() {
    userName = "Hi ${userInfo!.displayName}";
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    late String lat;
    late String long;
    return  Scaffold(
      appBar: AppBar(
        title: SizedBox(width: 180,
            child: Text(userName!,style: const TextStyle(fontSize:27,fontStyle:FontStyle.normal),overflow: TextOverflow.fade,)),
        actions:[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: ()async{
                await FirebaseAuth.instance.signOut();
                log("Loo");
              },
              child: CircleAvatar(
                child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset("assets/image/profileIcon.png")),
              ),
            )
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: VideoList(),
      ),
      floatingActionButton: ElevatedButton(onPressed: (){
        _getLocation().then((value) {
          lat = '${value.latitude}';
          long = '${value.longitude}';
        }).then((value)async {
          await availableCameras().then((value) =>
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> Record(camera: value,latitude: lat,longitude: long,))));
        });
      }, child: const Text("Next Page")),
    );
  }

  Future<Position> _getLocation() async{
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled){
      return Future.error("Location Service are disabled");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Location Permission denied");
      }
    }
    if (permission == LocationPermission.deniedForever){
      return Future.error("Location permissions are permanently, cannot access location ");
    }
    return await Geolocator.getCurrentPosition();

  }
}
