import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:workfromhome/Models/Checkin.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/detailcheckin.dart';
import 'package:workfromhome/Screens/screenmap.dart';
import 'package:http/http.dart' as http;
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:intl/intl.dart';
import 'package:workfromhome/Screens/source_page.dart';
import 'package:workfromhome/Screens/video_widget.dart';

class Checkinwork extends StatefulWidget {
  @override
  _CheckinworkState createState() => _CheckinworkState();
}

class _CheckinworkState extends State<Checkinwork> {
  bool _loading;
  var locationMessage = "";
  double lat;
  double lng;
  double latpoint;
  double lngpoint;
  double distance;
  List<Checkin> _checkin;
  var max;
  var min;
  var formatter = DateFormat.yMd().add_jm();
  ScrollController _scrollController = new ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime time = DateTime.now();
  int _currentMax = 10;
  String cid;
  bool _disposed = false;
  File imageFile;
  MediaSource source;
  VideoPlayerController videoPlayerController;
  Future<void> _future;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    getCurrentLocation();
    Jsondata.getCheckin().then((checkins) {
      setState(() {
        _checkin = checkins;
        // print(_checkin.length.toString());
        if (_checkin.length == 0) {
          // showAlertNullData();
          _loading = false;
        } else {
          max = _checkin.length;
          if (_checkin.length > 10) {
            _checkin = List.generate(10, (index) => _checkin[index]);
          } else {
            _checkin = checkins;
          }
          min = _checkin.length;
          _scrollController.addListener(() {
            if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent) {
              getMoreData();
            }
          });
          _loading = false;
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    videoPlayerController.dispose();
  }

  getMoreData() {
    if (min == 10) {
      for (int i = _currentMax; i < max - 1; i++) {
        Jsondata.getCheckin().then((checkins) {
          setState(() {
            _checkin = checkins;
            _checkin.add(_checkin[i]);
            _checkin.length = max;
            _loading = false;
            if (_checkin.isNotEmpty) {
              return _checkin.elementAt(0);
            }
          });
        });
      }
      if (_checkin.length == max) {
        showAlertLimitData();
      }
    }
    setState(() {});
  }

  showAlertLimitData() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("ข้อมูลสิ้นสุดแค่นี้"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ปิด"),
              ),
            ],
          );
        });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastposition = await Geolocator.getLastKnownPosition();
    // print(lastposition);
    setState(() {
      locationMessage = "$position.latitude , $position.longitude";
      lat = position.latitude;
      lng = position.longitude;
    });
  }

  checkindistance(lat, lng) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    latpoint = double.parse(sharedPreferences.getString("latitude"));
    lngpoint = double.parse(sharedPreferences.getString("longitude"));
    double lp1 = latpoint;
    double lp2 = lngpoint;
    // print(lat);
    // print(lng);
    // print(lp1);
    // print(lp2);
    // print(latpoint.toString());
    double distanceInMeters = await GeolocatorPlatform.instance.distanceBetween(
      lat,
      lng,
      lp1,
      lp2,
    );
    setState(() {
      distance = distanceInMeters;
    });
    // double distanceInMeters = calculateDistance(lat, lng, lp1, lp2);
    // print(distanceInMeters);
    return distance;
  }

  checkinwork() {
    int dt = distance.toInt();
    // print(dt);
    if (dt <= 300) {
      showAlertPostCheckin();
    } else if (dt == null) {
      showAlertfaild();
    } else {
      showAlertfaild();
    }
  }

  showAlertCheckout(String cid) async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text("ท่านต้องการออกงานใช่หรือไม่ ?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _showDialog(cid);
                  postCheckout(cid);
                  _handleRefresh();
                },
                child: Text("ออกงาน"),
              ),
              // FlatButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //     // _showDialog2(cid);
              //   },
              //   child: Text("สานงานต่อ"),
              // ),
            ],
          );
        });
  }

  showAlertfaild() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "ท่านไม่ได้อยู่ระยะที่จะเช็คอินได้กรุณาไปยังจุดเช็คอินของท่านบริเวณใกล้กว่านี้"),
            content: Text(
              "หมายเหตุ : ท่านสามารถเช็คอินนอกสถานที่ได้จากตำแหน่งที่อยู่ของท่านเอง",
              style: TextStyle(color: Colors.black54),
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ปิด"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  showAlertPostCheckin();
                },
                child: Text("เช็คอินนอกสถานที่"),
              ),
            ],
          );
        });
  }

  showAlertPostCheckin() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("ท่านต้องการเช็คอินเข้างานใช่หรือไม่"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  // postCheckin(imageFile);
                  // showAlertsuccess();
                  _showDialog(context);
                },
                child: Text("ใช่"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ไม่ใช่"),
              ),
            ],
          );
        });
  }

  showAlertsuccess() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("เช็คอินเข้างานสำเร็จ"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleRefresh();
                },
                child: Text("ปิด"),
              ),
            ],
          );
        });
  }

  postCheckin(File image) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    setState(() {
      id = sharedPreferences.getString("userid");
    });
    // var id;
    // setState(() {
    //   id = sharedPreferences.getInt("userid").toString();
    // });
    // if (sharedPreferences.getString("token") != null) {
    //   Map data = {
    //     'userid': id,
    //   };
    //   var jsonData = null;
    //   var response = await http
    //       .post(Apiurl+"/api/checkin", body: data);
    //   if (response.statusCode == 200) {
    //     jsonData = json.decode(response.body);
    //     if (jsonData != null) {}
    //   } else {
    //     print(response.body);
    //   }
    // }
    if (image != null) {
      String fileName = image.path.split('/').last;
      if (sharedPreferences.getString("token") != null) {
        var data = FormData.fromMap({
          'userid': id,
          'latitude': lat,
          'longitude': lng,
          "file": await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          ),
        });
        // print(fileName.toString());
        // print(image.path.toString());
        Dio dio = new Dio();
        await dio
            .post(Apiurl + "/api/checkin", data: data)
            .then((response) => print(response))
            .catchError((error) => print(error));
      }
    } else {
      if (sharedPreferences.getString("token") != null) {
        var data = FormData.fromMap({
          'userid': id,
          'latitude': lat,
          'longitude': lng,
          "file": null,
        });
        Dio dio = new Dio();
        await dio
            .post(Apiurl + "/api/checkin", data: data)
            .then((response) => print(response))
            .catchError((error) => print(error));
      }
    }
  }

  postCheckout(String cid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'checkinid': cid,
      };
      var jsonData = null;
      var response = await http.post(Apiurl + "/api/checkout", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {}
      } else {
        print(response.body);
      }
    }
  }

  Future<void> _showDialog(BuildContext context) async {
    return await showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('เช็คอินเข้างาน'),
            content: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: imageFile == null
                          ? Icon(Icons.photo, size: 120)
                          : (source == MediaSource.image
                              ? Image.file(
                                  imageFile,
                                  width: 300,
                                  height: 300,
                                )
                              : VideoWidget(imageFile)),
                    ),
                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  imageFile == null
                      ? Container()
                      : new FlatButton(
                          child: new Text('บันทึก'),
                          onPressed: () {
                            setState(() {
                              // if (_formKey.currentState.validate()) {
                              //   _formKey.currentState.save();
                              postCheckin(imageFile);
                              //   // print(news);
                              //   // print(imageFile.path.split('/').last);
                              Navigator.pop(context);
                              showAlertsuccess();
                            });
                          },
                        ),
                  new FlatButton(
                    child: new Text('เลือก รูป หรือ วีดีโอ'),
                    onPressed: () {
                      Navigator.pop(context);
                      showAlertCameraorVideo(context);
                    },
                  ),
                  new FlatButton(
                    child: new Text('ปิด'),
                    onPressed: () {
                      imageFile = null;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  showAlertCameraorVideo(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("เลือก"),
            actions: [
              FlatButton(
                onPressed: () {
                  // _handleRefresh();
                  // imageFile = null;
                  Navigator.pop(context);
                  // _openCamera();
                  // pickCameraMedia(context);
                  capture(MediaSource.image);
                  // _showDialog(context);
                },
                child: Text("กล้อง"),
              ),
              FlatButton(
                onPressed: () {
                  // _handleRefresh();
                  // imageFile = null;
                  Navigator.pop(context);
                  // _openVideo();
                  capture(MediaSource.video);
                  // _showDialog(context);
                },
                child: Text("วีดีโอ"),
              ),
            ],
          );
        });
  }

  Future capture(MediaSource source) async {
    setState(() {
      this.source = source;
      this.imageFile = null;
    });

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SourcePage(),
        settings: RouteSettings(
          arguments: source,
        ),
      ),
    );

    // final result = pickCameraMedia(source);

    if (result == null) {
      return;
    } else {
      setState(() {
        imageFile = result;
      });
    }
    _showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'กำลังโหลด...' : "เข้างาน-ออกงาน"),
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
          : _showJsondata()),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 630.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: Colors.green,
              heroTag: "btn",
              onPressed: () {
                checkindistance(lat, lng);
                checkinwork();
              },
              child: Icon(Icons.location_on_outlined),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              backgroundColor: Colors.green,
              heroTag: "btn2",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapSample(lat, lng)),
                );
              },
              child: Icon(Icons.map),
            )
          ],
        ),
      ),
      backgroundColor: kPrimaryColor,
    );
  }

  Widget _showJsondata() => new RefreshIndicator(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          itemCount: null == _checkin ? 0 : _checkin.length + 1,
          itemExtent: 170,
          itemBuilder: (context, index) {
            if (_checkin.length == 0) {
              return Center(
                child: Text(
                  "ไม่มีข้อมูล",
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              );
            } else {
              if (index == _checkin.length &&
                  _checkin.length > 10 &&
                  index > 10) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white70,
                ));
              } else if (index == _checkin.length &&
                  _checkin.length <= 10 &&
                  index <= 10) {
                return Center(child: Text(""));
              }
            }
            // New _new[index] = _new[index];
            cid = _checkin[index].checkinid.toString();
            return Card(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  // mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                            "ชื่อ : " +
                                                _checkin[index].name.toString(),
                                            // overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w700)),
                                      SizedBox(
                                        width: 127,
                                      ),
                                      TextStatus(index),
                                    ],
                                  ),
                                Row(
                                  // mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 70,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "วันที่ : " +
                                              df
                                                  .format(
                                                      _checkin[index].dateStart)
                                                  .substring(0, 10),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          "เวลา : " +
                                              df
                                                  .format(
                                                      _checkin[index].dateStart)
                                                  .substring(11, 19),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 70,
                                    ),
                                    TextDateEnd(index),
                                  ],
                                ),
                              ],
                            ),
                            showButton(index),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // onTap: () {
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(
              //   //       builder: (context) => IssuesNewDetail(_new[index])),
              //   // );
              // },
            );
          },
        ),
        onRefresh: _handleRefresh,
      );

  Future<Null> _handleRefresh() async {
    Completer<Null> completer = new Completer<Null>();

    new Future.delayed(new Duration(milliseconds: 2)).then((_) {
      completer.complete();
      setState(() {
        _loading = false;
        Jsondata.getCheckin().then((checkins) {
          setState(() {
            _checkin = checkins;
            max = _checkin.length;
            // _new = List.generate(10, (index) => _new[index]);
            min = _checkin.length;
            _scrollController.addListener(() {
              if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent) {
                getMoreData();
              }
            });
            _loading = false;
          });
        });
      });
    });

    return null;
  }

  TextDateEnd(int index) {
    if (_checkin[index].status == 1) {
      return Text(
        "เวลาออก : ยังไม่ออกงาน",
        style: TextStyle(fontSize: 16,color: Colors.black45, fontWeight: FontWeight.w700),
      );
    } else if (_checkin[index].status == 2) {
      DateTime dte = DateTime.parse(_checkin[index].dateEnd);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            "วันที่ : " + df.format(dte).toString().substring(0, 10),
            style:
                TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
          ),
          Text(
            "เวลา : " + df.format(dte).toString().substring(11, 19),
            style:
                TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }
  }

  TextStatus(int index) {
    if (_checkin[index].status == 1) {
      return Text(
        "สถานะ : เข้างาน",
        style: TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (_checkin[index].status == 2) {
      return Text(
        "สถานะ : ออกงาน",
        style: TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }
  }

  showButton(int index) {
    if (_checkin[index].status == 1) {
      return Padding(
        padding: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () {
            setState(() {
              // showAlertUpdate(news);
              showAlertCheckout(_checkin[index].checkinid.toString());
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "ออกงาน",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    } else if (_checkin[index].status == 2) {
      return Padding(
        padding: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () {
            setState(() {
              // _showDetail(index);
              // showAlertUpdate(news);
              // showAlertCheckout(news,_checkin[index].checkinid.toString());
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailCheckin(_checkin[index])),
              ).then((value) {
                setState(() {
                  _handleRefresh();
                });
              });
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "รายละเอียด",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    } else if (_checkin[index].status == 3) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () {
            setState(() {
              // _showDetail(index);
              // showAlertUpdate(news);
              // showAlertCheckout(news,_checkin[index].checkinid.toString());
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "รายละเอียด",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
  }
}
