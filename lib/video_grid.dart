import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video/video_display.dart';

class VideoList extends StatelessWidget {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance;

  VideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('video').where('userID', isEqualTo: user.currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No videos found'));
        }

        var videos = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(left: 12.5,right: 12.5),
          child: ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var video = videos[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: Image.network(video['thumbnailUrl'], fit: BoxFit.cover, width: 100, height: 100),
                title: Text(video['title']),
                subtitle: Text(video['Detail']),
                trailing: const Icon(Icons.play_circle_outline, size: 30, color: Colors.redAccent),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context)=>
                      VideoDisplay(
                        title:video['title'],
                        detail: video['Detail'],
                        thumbnailUrl:video['thumbnailUrl'],
                        videoUrl: video['videoUrl'],
                        uploadTime: (video['Time'] as Timestamp).toDate(),
                        location: video['Location'],
                      )
                  ));
                },
              );
            },
          ),
        );
      },
    );
  }
}
