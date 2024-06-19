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
  final user = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance.collection("users");
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    late String lat;
    late String long;
    return  Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Hi, ${user.currentUser?.displayName?.substring(0, 9) ?? 'User'}',
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search videos',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Implement search functionality
                },
              ),
            ),


          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: SizedBox(
                  height: 20, // CircleAvatar's diameter
                  width: 20, // CircleAvatar's diameter
                  child: user.currentUser?.photoURL != null && user.currentUser!.photoURL!.isNotEmpty
                      ? Image.network(
                    user.currentUser!.photoURL!,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/image/profileIcon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            onPressed: () {
              _showPopupMenu(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.5),
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
      }, child: const Icon(Icons.add)),
    );
  }
  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
      items: [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit Profile'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        // Navigate to edit profile page
      } else if (value == 'logout') {
        user.signOut();
      }
    });
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
