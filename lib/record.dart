import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:video/play.dart';

class Record extends StatefulWidget {
  final List<CameraDescription>? camera;
  final String? latitude;
  final String? longitude;
  const Record({super.key, this.camera, this.latitude, this.longitude});

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  late double lat = double.parse(widget.latitude!);
  late double longi = double.parse(widget.longitude!);
  late String location;
  late CameraController controller;
  XFile? videoFile;
  bool isNotRecording = true;
  bool isResume = true;
  bool flashOn = false;
  int selectedCamera = 0;
  Timer? timer;
  int remainingTime = 300;
  bool isCameraInitialized = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log("Location is $lat and $longi");
    getAddress(lat, longi);
    controller = CameraController(widget.camera![0], ResolutionPreset.high);
    controller.initialize().then((_){
      if(!mounted)
        {
          return ;
        }
      setState(() {
        isCameraInitialized = true;
      });
    });
  }
  Future<void> getAddress(double latitude, double longitude) async{
    List<Placemark> placeMark = await placemarkFromCoordinates(latitude, longitude);
    Placemark place  = placeMark[0];
    location = "${place.subLocality}, ${place.locality}, ${place.country}";
  }
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          stopRecording();
        }
      });
    });
  }
  void stopRecording() async {
    isNotRecording = true;
    flashOn = false;
    controller.setFlashMode(FlashMode.off);
    if (controller.value.isRecordingVideo) {
      await controller.stopVideoRecording().then((file) {
        videoFile = file;
        timer?.cancel();
        remainingTime = 300;// Cancel the timer
          setState(() {
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayer(videoFIle: videoFile!, location: location),
            ),
          );

      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    if(File(videoFile!.path).existsSync() && File(videoFile!.path).lengthSync() > 0){
      File(videoFile!.path).delete();
    }
    timer?.cancel();
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(!isCameraInitialized)
      {
        return const SizedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50,right: 30),
              child: getFlash(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
        Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height-150,
            width: 500,
            child: CameraPreview(controller),
          ),
        ),
        Padding(padding: const EdgeInsets.only(top: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getRecording(),
            const SizedBox(width: 60,),
            getLens()
          ],
        )),

      ],
    );
  }
  Widget getFlash()
  {
    if (selectedCamera == 1){
      return const SizedBox(
        height: 30,
        width: 30,
      );
    }
    else {
      return GestureDetector(
        onTap: () {
          flashOn = !flashOn;
          controller.setFlashMode(flashOn ? FlashMode.torch : FlashMode.off);
          setState(() {});
        },
        child: Icon(
          flashOn ? Icons.flash_on_outlined : Icons.flash_off_outlined,
          color: Colors.orange,
          size: 30,
        ),
      );
    }
  }
  Widget getRecording() {
    if (isNotRecording) {
      return GestureDetector(
        onTap: () async {
          isNotRecording = false;
          await controller.startVideoRecording();
          startTimer();
          setState(() {});
        },
        child: const FaIcon(FontAwesomeIcons.circleDot, color: Colors.redAccent, size: 40),
      );
    } else if (!isNotRecording && isResume) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              isResume = false;
              await controller.pauseVideoRecording();
              setState(() {});
            },
            child: const FaIcon(FontAwesomeIcons.pause, color: Colors.redAccent, size: 40),
          ),
          const SizedBox(width: 40),
          GestureDetector(
            onTap: () async {
              stopRecording();
            },
            child: const FaIcon(FontAwesomeIcons.solidSquare, color: Colors.redAccent, size: 40),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              isResume = true;
              await controller.resumeVideoRecording();
              setState(() {});
            },
            child: const FaIcon(FontAwesomeIcons.play, color: Colors.redAccent, size: 40),
          ),
          const SizedBox(width: 40),
          GestureDetector(
            onTap: () async {
              isNotRecording = true;
              flashOn = false;
              await controller.stopVideoRecording().then((file) {
                videoFile = file;
              });
              controller.setFlashMode(FlashMode.off);
              setState(() {});
            },
            child: const FaIcon(FontAwesomeIcons.solidSquare, color: Colors.redAccent, size: 40),
          ),
        ],
      );
    }
  }
  Widget getLens(){
    if (!isNotRecording){
      return const SizedBox(
        width: 40,
        height: 40,
      );
    }
    else{
      if(selectedCamera == 0)
      {
        return GestureDetector(
            onTap: (){
              selectedCamera =1;
              flashOn = false;
              controller = CameraController(widget.camera![1], ResolutionPreset.max);
              controller.initialize().then((_){
                if(!mounted)
                {
                  return ;
                }
                setState(() {

                });
              });
            },
            child: const Icon(Icons.change_circle,color: Colors.red,size: 40,));

      }
      else{
        return GestureDetector(
            onTap: (){
              selectedCamera = 0;
              controller = CameraController(widget.camera![0], ResolutionPreset.max);
              controller.initialize().then((_){
                if(!mounted)
                {
                  return ;
                }
                setState(() {

                });
              });
            },
            child: const Icon(Icons.change_circle,color: Colors.red,size: 40,));
      }
    }
  }
}
