import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapSample extends StatefulWidget {
  double lat, lng;

  MapSample(this.lat, this.lng);

  @override
  _MapSampleState createState() => _MapSampleState(lat, lng);
}

class _MapSampleState extends State<MapSample> {
  double lat, lng;

  _MapSampleState(this.lat, this.lng);

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(13.5843667, 100.7279383);
  final Set<Marker> _makers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  double latpoint,lngpoint;

  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(13.5843667, 100.7279383),
  //   zoom: 14.4746,
  // );
  //
  // static final CameraPosition _kLake = CameraPosition(
  //     // bearing: 192.8334901395799,
  //     target: LatLng(13.5843667, 100.7279383),
  //     // tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localMarker();
    checkPoint();
    // print(lat.toString());
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  localMarker() {
    setState(() {
      _makers.add(Marker(
          markerId: MarkerId("ตำแหน่งของท่าน"),
          infoWindow: InfoWindow(
            title: 'ท่านอยู่นี่',
            snippet: 'lat = 13.5843667,  lng = 100.7279383',
          ),
          position: LatLng(lat, lng)),
      );
    });
  }

  checkPoint() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    latpoint = double.parse(sharedPreferences.getString("latitude"));
    lngpoint = double.parse(sharedPreferences.getString("longitude"));
    // print(sharedPreferences.getString("latitude"));
    // print(sharedPreferences.getString("longitude"));
    setState(() {
      _makers.add(Marker(
          markerId: MarkerId("ตำแหน่งของจุดเช็คอิน"),
          infoWindow: InfoWindow(
            title: 'จุดเช็คอิน',
            // snippet: 'lat = 13.5843667,  lng = 100.7279383',
          ),
          position: LatLng(latpoint, lngpoint)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("แผนที่"),
        backgroundColor: Colors.white,
        elevation: 6.0,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60.0),
            bottomRight: Radius.circular(60.0),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition:
                CameraPosition(target: LatLng(lat, lng), zoom: 19.0),
            mapType: _currentMapType,
            markers: _makers,
            onCameraMove: _onCameraMove,
            circles: Set.from([
              Circle(
                  circleId: CircleId("1"),
                  center: LatLng(lat, lng),
                  radius: 300,
                  strokeColor: Colors.blue),
              Circle(
                  circleId: CircleId("2"),
                  center: LatLng(latpoint, lngpoint),
                  radius: 300,
                  strokeColor: Colors.redAccent),
            ]),
          ),
        ],
      ),
    );
    //   new Scaffold(
    //   body: Container(
    //     width: MediaQuery.of(context).size.height*MediaQuery.of(context).devicePixelRatio,
    //     child: GoogleMap(
    //       mapType: MapType.normal,
    //       myLocationEnabled: true,
    //       myLocationButtonEnabled: true,
    //       initialCameraPosition: _kGooglePlex,
    //       onMapCreated: (GoogleMapController controller) {
    //         _controller.complete(controller);
    //       },
    //       circles: circles,
    //     ),
    //   ),
    //   floatingActionButton: Padding(
    //     padding: EdgeInsets.only(bottom: 100),
    //     child: FloatingActionButton.extended(
    //       onPressed: _goToTheLake,
    //       label: Text('To the lake!'),
    //       icon: Icon(Icons.directions_boat),
    //     ),
    //   ),
    // );
  }

// Future<void> _goToTheLake() async {
//   final GoogleMapController controller = await _controller.future;
//   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
// }

}
