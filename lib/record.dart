import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Record extends StatefulWidget {
  final List<CameraDescription>? camera;
  final String? latitude;
  final String? longitude;
  const Record({super.key, this.camera, this.latitude, this.longitude});

  @override
  State<Record> createState() => _RecordState();
}

class _RecordState extends State<Record> {
  late CameraController controller;
  XFile? videoFile;
  bool isNotRecording = true;
  bool isResume = true;
  bool flashOn = false;
  int selectedCamera = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log("Location is ${widget.longitude} and ${widget.latitude}");
    controller = CameraController(widget.camera![0], ResolutionPreset.max);
    controller.initialize().then((_){
      if(!mounted)
        {
          return ;
        }
      setState(() {

      });
    });
  }
  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(!controller.value.isInitialized)
      {
        return const SizedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: getFlash(),
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
    else{
      if (flashOn){
        return GestureDetector(
          onTap: (){
            flashOn = false;
            controller.setFlashMode(FlashMode.off);
            setState(() { });

          },
          child: const Icon(Icons.flash_on_outlined,color: Colors.orange,size: 30,),
        );
      }
      else{
        return GestureDetector(
          onTap: (){
            flashOn = true;
            controller.setFlashMode(FlashMode.torch);
            setState(() { });
          },
          child: const Icon(Icons.flash_off_outlined,color: Colors.orange,size: 30,) ,
        );
      }
    }
  }
  Widget getRecording()
  {
    if(isNotRecording)
      {
        return GestureDetector(
          onTap: (){
            isNotRecording = false;
            setState(() {});
          },
          child: const FaIcon(FontAwesomeIcons.circleDot,color: Colors.redAccent,size:40,),
        );
      }
    else if (!isNotRecording && isResume)
      {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                isResume = false;
                setState(() {});
              },
                child: const SizedBox(
                  width: 30,
                    child: FaIcon(FontAwesomeIcons.pause,color: Colors.redAccent,size:40))),
            Padding(padding: const EdgeInsets.only(left: 40),
            child: GestureDetector(
              onTap: (){
                isNotRecording = true;
                flashOn = false;
                controller.setFlashMode(FlashMode.off);
                setState(() {});
              },
                child: const FaIcon(FontAwesomeIcons.solidSquare,color: Colors.redAccent,size:40)),)
          ],

        );
      }
    else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: (){
                isResume = true;
                setState(() {});
              },
              child: const FaIcon(FontAwesomeIcons.play,color: Colors.redAccent,size:40)),
          Padding(padding: const EdgeInsets.only(left: 40),
            child: GestureDetector(
                onTap: (){
                  isNotRecording = true;
                  flashOn = false;
                  controller.setFlashMode(FlashMode.off);
                  setState(() {});
                },
                child: const FaIcon(FontAwesomeIcons.solidSquare,color: Colors.redAccent,size:40)),)
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
