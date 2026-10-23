import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Property
  late Position currentPosition;
  late double latData;
  late double longData;
  late MapController mapController;
  late bool canRun;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    canRun = false;
    checkLocationPermission(); // 첫 화면에 지도 자체가 닥 떠야하니 함수 만들어서 그걸 가져오는 함수
  }

  void checkLocationPermission()async{ // 첫화면애서 허용함 체크 후 넘어오는 동안 화면 구성이 시간이 걸리니 어싱크 쓴다
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if(permission == LocationPermission.deniedForever){
      return;  
    }

    if(permission == LocationPermission.whileInUse || permission == LocationPermission.always){
      getCurrentLocation();
    }
  }


  void getCurrentLocation()async{
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    canRun = true;
    latData = currentPosition.latitude;
    longData = currentPosition.longitude;
    print("------> lat : $latData, long : $longData");
    setState(() {});
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: canRun
          ? flutterMap()// 삼항 연산자
          : Center(child: CircularProgressIndicator(),),
    
    );
  }

  // Widget
  Widget flutterMap(){
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(latData, longData), initialZoom: 15.0
      ),
      children: [ //지도
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.mega.gpsmapapp',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 40,
              height: 40,
              point: latlng.LatLng(latData, longData), 
              child: Icon(
                  Icons.pin_drop,
                  size: 50,
                  color: Colors.red,
                ),
            ),
          ]
        ),
      ]
    );
  }

}