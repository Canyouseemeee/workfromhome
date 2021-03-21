import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Checkin.dart';
import 'package:workfromhome/Models/Historycin.dart';
import 'package:workfromhome/Other/components/rounded_button.dart';
import 'package:intl/intl.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:workfromhome/Screens/detailcheckin.dart';

class HistoryCheckin extends StatefulWidget {
  @override
  _HistoryCheckinState createState() => _HistoryCheckinState();
}

class _HistoryCheckinState extends State<HistoryCheckin> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  bool _loading;
  var max;
  var min;
  var formatter = DateFormat.yMd().add_jm();
  ScrollController _scrollController = new ScrollController();
  DateTime time = DateTime.now();
  int _currentMax = 10;
  List<Checkin> _historycin;
  String cid;
  bool selected = false;
  Timer _timer;
  bool _disposed = false;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');

  Future displayDateRangePicker(BuildContext context) async {
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: _startDate,
        initialLastDate: _endDate,
        firstDate: new DateTime(DateTime.now().year - 50),
        lastDate: new DateTime(DateTime.now().year + 50));
    if (picked != null && picked.length == 2) {
      // print(picked);
      if (mounted)
        setState(() {
          _startDate = picked[0];
          _endDate = picked[1];
          // print(_startDate);
          // print(_endDate);
        });
    }
  }

  static Future<List<Checkin>> getHistoryBetweenCheckin(
      _startDate, _endDate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    // print(DateFormat('yyyy-MM-dd').format(_startDate).toString());
    Map data = {
      'userid': id,
      'fromdate': DateFormat('yyyy-MM-dd').format(_startDate).toString(),
      'todate': DateFormat('yyyy-MM-dd').format(_endDate).toString(),
    };
    const String url = Apiurl + "/api/historybetween";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Checkin> hisc = checkinFromJson(response.body);
          return hisc;
        }
      } else {
        return List<Checkin>();
      }
    } catch (e) {
      return List<Checkin>();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    Timer(Duration(seconds: 1), () {
      if (!_disposed)
        setState(() {
          time = time.add(Duration(seconds: -1));
        });
    });
    super.initState();
    _loading = true;
    Jsondata.getHistoryCheckin().then((historycin) {
      if (mounted)
        setState(() {
          _historycin = historycin;
          // print(_historycin.length.toString());
          if (_historycin.length == 0) {
            // showAlertNullData();
            _loading = false;
          } else {
            max = _historycin.length;
            if (_historycin.length > 10) {
              _historycin = List.generate(10, (index) => _historycin[index]);
            } else {
              _historycin = historycin;
            }
            min = _historycin.length;
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
    _disposed = true;
    super.dispose();
    // _timer.cancel();
  }

  getMoreData() {
    if (min == 10) {
      for (int i = _currentMax; i < max - 1; i++) {
        Jsondata.getHistoryCheckin().then((historycin) {
          if (mounted)
            setState(() {
              _historycin = historycin;
              _historycin.add(_historycin[i]);
              _historycin.length = max;
              _loading = false;
              if (_historycin.isNotEmpty) {
                return _historycin.elementAt(0);
              }
            });
        });
      }
      if (_historycin.length == max) {
        showAlertLimitData();
      }
    }
    if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'Loading...' : "History"),
        elevation: 6.0,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60.0),
            bottomRight: Radius.circular(60.0),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: kPrimaryColor,
      body: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                          "วันที่: ${DateFormat('dd/MM/yyyy').format(_startDate).toString()}"),
                      Text(
                          "ถึงวันที่: ${DateFormat('dd/MM/yyyy').format(_endDate).toString()}"),
                      RaisedButton(
                          child: Text("ค้นหา"),
                          onPressed: () async {
                            // getHistoryBetweenCheckin(_startDate,_endDate);
                            if (mounted) {
                              setState(() {
                                selected = true;
                                _loading = true;
                                _timer = new Timer.periodic(
                                    Duration(seconds: 3), (timer) {
                                  getHistoryBetweenCheckin(_startDate, _endDate)
                                      .then((historycin) {
                                    if (mounted)
                                      setState(() {
                                        _historycin = historycin;
                                        // print(_historycin.length.toString());
                                        if (_historycin.length == 0) {
                                          // showAlertNullData();
                                          _loading = false;
                                        } else {
                                          max = _historycin.length;
                                          if (_historycin.length > 10) {
                                            _historycin = List.generate(10,
                                                (index) => _historycin[index]);
                                          } else {
                                            _historycin = historycin;
                                          }
                                          min = _historycin.length;
                                          _scrollController.addListener(() {
                                            if (_scrollController
                                                    .position.pixels ==
                                                _scrollController
                                                    .position.maxScrollExtent) {
                                              // getMoreData();
                                            }
                                          });
                                          _loading = false;
                                        }
                                      });
                                  });
                                });
                              });
                            }
                          }),
                    ],
                  ),
                  // SizedBox(height: 20,),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView(
                      children:[
                        SelectedBetween(),
                      ],
                    ),
                  ),
                  // (_loading
                  //     ? new Center(
                  //         child: new CircularProgressIndicator(
                  //         backgroundColor: Colors.pinkAccent,
                  //       ))
                  //     : _showJsondata()),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        heroTag: "btn",
        onPressed: () async {
          await displayDateRangePicker(context);
        },
        child: Icon(
          Icons.calendar_today,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _showJsondata() => new RefreshIndicator(
        child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          itemCount: null == _historycin ? 0 : _historycin.length + 1,
          itemExtent: 150,
          itemBuilder: (context, index) {
            if (_historycin.length == 0) {
              return Center(
                child: Text(
                  "ไม่มีข้อมูล",
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              );
            } else {
              if (index == _historycin.length &&
                  _historycin.length > 10 &&
                  index > 10) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white70,
                ));
              } else if (index == _historycin.length &&
                  _historycin.length <= 10 &&
                  index <= 10) {
                return Center(child: Text(""));
              }
            }
            // New _new[index] = _new[index];
            cid = _historycin[index].checkinid.toString();
            return Card(
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
                                                  .format(_historycin[index]
                                                      .dateStart)
                                                  .substring(0, 10),
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          "เวลา : " +
                                              df
                                                  .format(_historycin[index]
                                                      .dateStart)
                                                  .substring(11, 19),
                                          style: TextStyle(
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
                                                .format(DateTime.parse(
                                                    _historycin[index].dateEnd))
                                                .substring(0, 10),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "เวลา : " +
                                            df
                                                .format(DateTime.parse(
                                                    _historycin[index].dateEnd))
                                                .substring(11, 19),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(4),
                              child: RaisedButton(
                                color: Colors.blueGrey,
                                onPressed: () {
                                  setState(() {
                                    // _showDetail(index);
                                    // showAlertUpdate(news);
                                    // showAlertCheckout(news,_checkin[index].checkinid.toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailCheckin(
                                              _historycin[index])),
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
                                  "Detail",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        onRefresh: _handleRefresh,
      );

  Future<Null> _handleRefresh() async {
    Completer<Null> completer = new Completer<Null>();

    new Future.delayed(new Duration(milliseconds: 2)).then((_) {
      completer.complete();
      if (mounted)
        setState(() {
          _loading = false;
          Jsondata.getHistoryCheckin().then((checkins) {
            if (mounted)
              setState(() {
                _historycin = checkins;
                max = _historycin.length;
                // _new = List.generate(10, (index) => _new[index]);
                min = _historycin.length;
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

  SelectedBetween() {
    if (selected) {
      return (_loading
          ? new Center(
              child: new CircularProgressIndicator(
              backgroundColor: Colors.pinkAccent,
            ))
          : _showJsondata());
    } else if (!selected) {
      return (_loading
          ? new Center(
              child: new CircularProgressIndicator(
              backgroundColor: Colors.pinkAccent,
            ))
          : _showJsondata());
    }
  }
}
