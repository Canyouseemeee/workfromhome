import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:workfromhome/Models/Checkin.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';

class DetailCheckin extends StatefulWidget {
  Checkin checkin;
  DetailCheckin(this.checkin);
  @override
  _DetailCheckinState createState() => _DetailCheckinState(checkin);
}

class _DetailCheckinState extends State<DetailCheckin> {
  Checkin checkin;
  _DetailCheckinState(this.checkin);
  VideoPlayerController videoPlayerController;
  Future<void> _future;
  bool _loading;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  static const LatLng _center = const LatLng(13.5843667, 100.7279383);
  final Set<Marker> _makers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  Completer<GoogleMapController> _controller = Completer();
  double lat, lng;
  VoidCallback listener;
  String result = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    videoPlayerController = VideoPlayerController.network(
        Apiurl + "/storage/" + checkin.file);
    _future = videoPlayerController.initialize().then((_){
      videoPlayerController.setLooping(true);
      videoPlayerController.setVolume(1.0);
      videoPlayerController.addListener(listener);
      setState(() {

      });
    });
    localMarker();
    _loading = false;
    if ((checkin != null) && (checkin.file.length > 0)) {
      result = checkin.file.substring(checkin.file.length - 3,checkin.file.length);
    }
    // print(result);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  localMarker() {
    lat = double.parse(checkin.latitude);
    lng = double.parse(checkin.longitude);
    setState(() {
      _makers.add(Marker(
          markerId: MarkerId("myLocation"),
          infoWindow: InfoWindow(
            title: 'You are here.',
            snippet: 'lat = 13.5843667,  lng = 100.7279383',
          ),
          position: LatLng(lat, lng)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'กำลังโหลด...' : "รายละเอียดเข้างาน-ออกงาน"),
        elevation: 6.0,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60.0),
            bottomRight: Radius.circular(60.0),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: (_loading
          ? new Center(
          child: new CircularProgressIndicator(
            backgroundColor: Colors.pinkAccent,
          ))
          : Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "เข้างาน",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "วันที่ : " +
                                        df
                                            .format(
                                            checkin
                                                .dateStart).substring(0,10),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    "เวลา : " +
                                        df
                                            .format(
                                            checkin
                                                .dateStart).substring(11,19),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Text(
                                    "ออกงาน",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "วันที่ : " +
                                      df
                                          .format(
                                          DateTime.parse(checkin.dateEnd)).substring(0,10),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "เวลา : " +
                                      df
                                          .format(
                                          DateTime.parse(checkin.dateEnd)).substring(11,19),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16,),
                      checkin.file == null
                          ? Icon(Icons.photo, size: 120)
                          : (result == 'jpg')
                          ? CachedNetworkImage(
                        imageUrl: Apiurl + "/storage/" + checkin.file,
                        height: 200,
                        placeholder: (context, url) =>
                        new CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        new CircularProgressIndicator(),
                      ) : Container(
                        child: FutureBuilder(
                          future: _future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return Center(
                                child: AspectRatio(
                                  aspectRatio: 16/9,
                                  child: (videoPlayerController != null
                                  ? VideoPlayer(videoPlayerController) : Container()),
                                ),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                      Text("รูปภาพหรือวีดีโอ", style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 16,),
                      Container(
                        height: 250,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          initialCameraPosition:
                          CameraPosition(target: LatLng(lat, lng), zoom: 19.0),
                          mapType: _currentMapType,
                          markers: _makers,
                          onCameraMove: _onCameraMove,
                        ),
                      ),
                      Text("ตำแหน่งที่เช็คอิน", style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      )),
      floatingActionButton: checkin.file == null
          ? Icon(Icons.photo, size: 120)
          : (result == 'jpg')
          ? Container() : FloatingActionButton(
        onPressed: () {
          setState(() {
            if (videoPlayerController.value.isPlaying) {
              videoPlayerController.pause();
            } else {
              videoPlayerController.play();
            }
          });
        },
        child:
        Icon(videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
      backgroundColor: kPrimaryColor,
    );
  }
}
