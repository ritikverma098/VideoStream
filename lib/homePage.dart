import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video/record.dart';
import 'package:video/play.dart';
import 'package:video/widget/textBox.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    late String lat;
    late String long;
    return  Scaffold(
      appBar: AppBar(
        title: CircleAvatar(
          child: SizedBox(
            height: 20,
              width: 20,
              child: Image.asset("assets/image/profileIcon.png")),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.notifications),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    child: TextBoxCustom(controller: _controller,
                        hint: "Search",
                        ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20,left: 10),
                child: Icon(Icons.filter_alt),
              )
            ],
          ),
          ElevatedButton(onPressed: (){
            _getLocation().then((value) {
              lat = '${value.latitude}';
              long = '${value.longitude}';
            }).then((value)async {
              await availableCameras().then((value) =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> Record(camera: value,latitude: lat,longitude: long,))));
            });
          }, child: const Text("Next Page"))
        ],
      )
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
