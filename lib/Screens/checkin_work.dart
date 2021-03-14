import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Checkin.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/screenmap.dart';
import 'package:http/http.dart' as http;
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:intl/intl.dart';


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
                child: Text("OK"),
              ),
            ],
          );
        });
  }

  double calculateDistance(double lat1,double lon1,double lat2,double lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastposition = await Geolocator.getLastKnownPosition();
    // print(lastposition);
    setState(() {
      locationMessage = "$position.latitude , $position.longitude";
      lat = position.latitude;
      lng = position.longitude;
    });
  }

  checkindistance(lat,lng) async {
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

  checkinwork(){
    int dt = distance.toInt();
    // print(dt);
    if(dt <= 300){
      showAlertPostCheckin();
    }else if(dt == null){
      showAlertfaild();
    }else{
      showAlertfaild();
    }
  }

  showAlertCheckout(String cid) async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text("ท่านต้องการปิดงานหรือสานงานต่อ ?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _showDialog(cid);
                  postCheckout(cid);
                },
                child: Text("ปิดงาน"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _showDialog2(cid);
                },
                child: Text("สานงานต่อ"),
              ),
            ],
          );
        });
  }

  _showDetail(int index) async {
    await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Detail : '
                // + _checkin[index].detail
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  showAlertfaild() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("ท่านไม่ได้อยู่ระยะที่จะเช็คอินได้กรุณาไปยังจุดเช็คอินของท่านบริเวณใกล้ว่านี้"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
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
            title: Text("ท่านต้องการเช็คอินเข้างานใช่หหรือไม่"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  postCheckin();
                  showAlertsuccess();
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
                  // _handleRefresh();
                },
                child: Text("ปิด"),
              ),
            ],
          );
        });
  }

  postCheckin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    setState(() {
      id = sharedPreferences.getInt("userid").toString();
    });
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'userid': id,
      };
      var jsonData = null;
      var response = await http
          .post(Apiurl+"/api/checkin", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {}
      } else {
        print(response.body);
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
      var response = await http
          .post(Apiurl+"/api/checkout", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {}
      } else {
        print(response.body);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Padding(
              padding: EdgeInsets.only(right: 40),
              child: Text(_loading ? 'Loading...' : "Checkin-Checkout")),
        ),
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
                  MaterialPageRoute(
                      builder: (context) => MapSample(lat,lng)),
                );
              } ,
              child: Icon(Icons.map),
            )
          ],
        ),
      ),
      backgroundColor: kPrimaryColor,
    );
  }

  Widget _showJsondata()=> new RefreshIndicator(
    child: ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      itemCount: null == _checkin ? 0 : _checkin.length + 1,
      itemExtent: 170,
      itemBuilder: (context, index) {
        if (_checkin.length == 0) {
          return Center(
            child: Text(
              "No Result",
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
        return  Card(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Column(
                      children:<Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                        "Name : " +
                                            _checkin[index].name.toString(),
                                        // overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700)
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      "DateStart : " +
                                          formatter.formatInBuddhistCalendarThai(
                                              _checkin[index].dateStart),
                                      style: TextStyle(
                                          color: Colors.black45,
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
                                children: <Widget>[
                                  TextStatus(index),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  TextDateEnd(index),
                                ],
                              ),
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
        "DateEnd : No Checkout",
        style: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w700),
      );
    } else if (_checkin[index].status == 2) {
      DateTime dte = DateTime.parse(_checkin[index].dateEnd);
      return Text(
        "DateEnd : " +
            formatter.formatInBuddhistCalendarThai(
                dte),
        style: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w700),
      );
    }
  }

  TextStatus(int index) {
    if (_checkin[index].status == 1) {
      return Text(
        "Status : CheckIn",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (_checkin[index].status == 2) {
      return Text(
        "Status : CheckOut",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }
  }

  showButton(int index) {
    if (_checkin[index].status == 1) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: RaisedButton(
          color: Colors.red,
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
            "CheckOut",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    } else if (_checkin[index].status == 2) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: RaisedButton(
          color: Colors.blueGrey,
          onPressed: () {
            setState(() {
              _showDetail(index);
              // showAlertUpdate(news);
              // showAlertCheckout(news,_checkin[index].checkinid.toString());
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "Detail",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    } else if (_checkin[index].status == 3) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: RaisedButton(
          color: Colors.blueGrey,
          onPressed: () {
            setState(() {
              _showDetail(index);
              // showAlertUpdate(news);
              // showAlertCheckout(news,_checkin[index].checkinid.toString());
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "Detail",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
  }
}
