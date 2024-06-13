import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video/widget/textBox.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  final videoCollection =FirebaseFirestore.instance.collection("video");
  late FlickManager flickManager;
  String? thumbNailPath;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  bool isVideoPlay = false;
  bool _isEmpty = false;
  bool _isDescriptionEmpty = false;
  bool _isUploading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _generateThumbnail();
    flickManager = FlickManager(videoPlayerController: VideoPlayerController.asset("assets/video/video2.mp4"));
    flickManager.flickVideoManager?.videoPlayerController?.addListener(() {
      final position = flickManager.flickVideoManager?.videoPlayerController?.value.position;
      final duration = flickManager.flickVideoManager?.videoPlayerController?.value.duration;
      if (position != null && duration != null && position >= duration) {
        setState(() {
          isVideoPlay = false;
        });
      }
    });
  }

  Future<void> _generateThumbnail() async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = directory.path;
      final byteData = await rootBundle.load("assets/video/video2.mp4");
      File tempVideo = File("${directory.path}/temp_video.mp4")
        ..createSync(recursive: true)
        ..writeAsBytesSync(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      thumbNailPath = await VideoThumbnail.thumbnailFile(
        video: tempVideo.path,
        thumbnailPath: filePath,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
      );
      setState(() {});
    } catch (e) {
      log("Error generating thumbnail: ${e.toString()}");
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    flickManager.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Uploading"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Title",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14,right: 14),
              child: TextBoxCustom(controller:_title,
                hint: "Enter title for video",
                errorText: _isEmpty?"Title Cannot be empty":null,
              ),
            ),
            const SizedBox(height: 30,),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Description",
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14,right: 14),
              child: TextBoxCustom(controller: _description,
                errorText: _isDescriptionEmpty?"Description Can't be empty":null,
                hint:"Enter Description for video",
                maxLine: 6,
              ),
            ),
            const SizedBox(height: 40,),
            const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text("Video",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),) ,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14,right:14,top: 14),
              child: thumbNailPath != null ?getVideo(): const CircularProgressIndicator(),
            ),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: LinearProgressIndicator(value: _uploadProgress),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: SizedBox(
                  width:130,
                    child: ElevatedButton(onPressed: _isUploading?
                    null:uploadVideo,
                        child:_isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Center(child: Text("Post")),)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void uploadVideo() async {
    final videoDatabase = FirebaseFirestore.instance.collection("video");
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final uuid = Uuid();

    // Copy video from assets to temp directory
    final directory = await getTemporaryDirectory();
    final byteData = await rootBundle.load("assets/video/video2.mp4");
    File tempVideo = File("${directory.path}/temp_video.mp4")
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    setState(() {
      _title.text.isEmpty ? _isEmpty = true : _isEmpty = false;
      _description.text.isEmpty ? _isDescriptionEmpty = true : _isDescriptionEmpty = false;
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    if (_isEmpty || _isDescriptionEmpty) {
      setState(() {
        _isUploading = false;
      });
      return;
    }

    try {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("${user!.uid}/videUpload/${uuid.v1()}_ss");
      UploadTask uploadTask = firebaseStorageRef.putFile(tempVideo);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred.toDouble() / snapshot.totalBytes.toDouble();
        });
      });

      await uploadTask;
      String url = await firebaseStorageRef.getDownloadURL();
      final docID = videoDatabase.doc(uuid.v1());
      final data = <String, dynamic>{
        "userID": user.uid,
        "videoUrl": url,
        "Location": "India",
        "Time": DateTime.now(),
      };
      await docID.set(data);
      setState(() {
        _title.clear();
        _description.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video uploaded successfully")));
    } catch (e) {
      log("Error uploading video: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to upload video")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  Widget getVideo(){
    if (isVideoPlay){
      return FlickVideoPlayer(flickManager: flickManager,
      flickVideoWithControls: const FlickVideoWithControls(
        controls: CustomFlickPortraitControls(),
      ),);
    }

    else {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Image.file(File(thumbNailPath!)),
          Align(
              alignment: AlignmentDirectional.topCenter,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isVideoPlay = true;
                      flickManager.flickControlManager?.play();
                    });
                  },
                  child: const FaIcon(
                    FontAwesomeIcons.circlePlay,
                    size: 50,
                    color: Colors.redAccent,
                  )))
        ],
      );
    }
  }
}
class CustomFlickPortraitControls extends StatelessWidget {
  const CustomFlickPortraitControls({super.key});

  @override
  Widget build(BuildContext context) {
    return FlickShowControlsAction(
      child: FlickSeekVideoAction(
        child: FlickAutoHideChild(
          showIfVideoNotInitialized: false,
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: FlickVideoBuffer(),
              ),
              Positioned.fill(
                child: FlickAutoHideChild(
                  child: FlickShowControlsAction(
                    child: Column(
                      children: <Widget>[
                        Expanded(child: Container()),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          color: Colors.black38,
                          child: Row(
                            children: <Widget>[
                              const FlickPlayToggle(),
                              const SizedBox(width: 10),
                              const FlickCurrentPosition(),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FlickVideoProgressBar(
                                  flickProgressBarSettings: FlickProgressBarSettings(
                                    handleColor: Colors.red,
                                    height: 5,
                                    bufferedColor: Colors.white38,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                              ),
                              const FlickTotalDuration(),
                              const SizedBox(width: 10),
                              const FlickSoundToggle(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}