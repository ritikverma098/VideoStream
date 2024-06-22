import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final user = FirebaseAuth.instance;
  String email = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    log("Page closed ");
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: (){
                log("${user.currentUser}");
              },
              child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: user.currentUser?.photoURL != null && user.currentUser!.photoURL!.isNotEmpty
                        ? Image.network(
                      user.currentUser!.photoURL!,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/image/profileIcon.png',
                      fit: BoxFit.cover,
                    ),
                  )
              ),
            )
          ),
          const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Align(
              alignment: Alignment.topRight,
              child: Text("Edit profile",style: TextStyle(color: Colors.blue,fontSize: 20,fontWeight: FontWeight.bold),),
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10),
            child: Container(
              decoration: const BoxDecoration(
                color:Colors.black,
                borderRadius: BorderRadius.only(topLeft:Radius.circular(10),topRight: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left:20),
                    child: Text("Username",style: TextStyle(fontSize: 25),),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${user.currentUser!.displayName}",style:const TextStyle(fontSize: 20,),overflow: TextOverflow.fade,),
                          const Padding(
                            padding: EdgeInsets.only(left: 10,right: 5),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                  ),
                  const Divider(
                    thickness: 3,
                    color: Colors.grey,
                  ),
                  const Text("Email", style: TextStyle(fontSize: 25),),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user.currentUser?.email?.isNotEmpty == true ? user.currentUser!.email!:"Enter Your Email ",
                          style: const TextStyle(fontSize: 20),),
                        const Padding(
                          padding: EdgeInsets.only(left:12.5),
                          child: Icon(Icons.edit),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 3,
                    color: Colors.grey,
                  ),
                  const Text("Creation Date", style: TextStyle(fontSize: 25),),
                  Text("${user.currentUser!.metadata.creationTime}",style: const TextStyle(fontSize: 20),),
                  const Divider(
                    thickness: 3,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10,)
                ],
              ),
            ),
          ),
        ],

      ),
    );
  }
}
