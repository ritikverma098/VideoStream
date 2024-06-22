
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class VideoDisplay extends StatefulWidget {
  final String title;
  final String detail;
  final String videoUrl;
  final String thumbnailUrl;
  final DateTime uploadTime;
  final String location;
  const VideoDisplay({super.key,
    required this.title,
    required this.detail,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.uploadTime,
    required this.location
  });

  @override
  State<VideoDisplay> createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  late FlickManager videoManager;
  bool isPlaying = false;
  @override
  void initState() {
    // TODO: implement initState
    videoManager = FlickManager(videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl)));
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    videoManager.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Display"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            getVideo(),
            const Divider(
              thickness: 3,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.5),
              child: Align(
                alignment: Alignment.topLeft,
                  child: Text(
                    "Title: ${widget.title}",style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
            ),
            Padding(
              padding: const EdgeInsets.only(top:10.5,left: 10.5),
              child: Text("Uploaded on: ${timeago.format(widget.uploadTime)}",style: const TextStyle(fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.5,left: 10.5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Uploaded from: ${widget.location}",style: const TextStyle(fontSize: 20),),
              ),
        
            ),
            Padding(padding: const EdgeInsets.only(top: 10.5,left: 10.5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Details: ${widget.detail}",style: const TextStyle(fontSize: 20),),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget getVideo() {
    return isPlaying? FlickVideoPlayer(flickManager: videoManager):
    Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(widget.thumbnailUrl,width:370,height: 200,fit: BoxFit.cover,),
          Align(
            alignment: Alignment.center,
            child:GestureDetector(
              onTap: (){
                setState(() {
                  isPlaying = true;
                  videoManager.flickControlManager?.play();
                });
              },
              child: const Icon(Icons.play_arrow_outlined,size:100,),
            ) ,
          )
        ],
      ),
    );
  }
}
