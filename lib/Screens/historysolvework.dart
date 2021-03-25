import 'dart:async';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Solvework.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:http/http.dart' as http;
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/detailsolvework.dart';

class HistorySolvework extends StatefulWidget {
  @override
  _HistorySolveworkState createState() => _HistorySolveworkState();
}

class _HistorySolveworkState extends State<HistorySolvework> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  bool _loading;
  var max;
  var min;
  var formatter = DateFormat.yMd().add_jm();
  ScrollController _scrollController = new ScrollController();
  DateTime time = DateTime.now();
  int _currentMax = 10;
  List<Solvework> _solvework;
  String cid;
  bool selected = false;
  Timer _timer;
  bool _disposed = false;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  TextEditingController idtask = TextEditingController();
  String id2;

  Future displayDateRangePicker(BuildContext context) async {
    // selected = false;
    // _startDate = DateTime.now();
    // _endDate = DateTime.now().add(Duration(days: 7));
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

  static Future<List<Solvework>> getHistoryBetweenSolvework(
      id2,_startDate, _endDate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getString("userid");
    // print(DateFormat('yyyy-MM-dd').format(_startDate).toString());
    Map data = {
      'userid': id,
      'taskid' : id2.toString(),
      'fromdate': DateFormat('yyyy-MM-dd').format(_startDate).toString(),
      'todate': DateFormat('yyyy-MM-dd').format(_endDate).toString(),
    };
    const String url = Apiurl + "/api/gethistorybetweenassigntask";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Solvework> hisc = solveworkFromJson(response.body);
          return hisc;
        }
      } else {
        return List<Solvework>();
      }
    } catch (e) {
      return List<Solvework>();
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
    idtask.text = "";
    id2 = idtask.text = "";
    Jsondata.getHistorysolvework().then((historycin) {
      if (mounted)
        setState(() {
          _solvework = historycin;
          // print(_historycin.length.toString());
          if (_solvework.length == 0) {
            // showAlertNullData();
            _loading = false;
          } else {
            max = _solvework.length;
            if (_solvework.length > 10) {
              _solvework = List.generate(10, (index) => _solvework[index]);
            } else {
              _solvework = historycin;
            }
            min = _solvework.length;
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
        Jsondata.getHistorysolvework().then((historycin) {
          if (mounted)
            setState(() {
              _solvework = historycin;
              _solvework.add(_solvework[i]);
              _solvework.length = max;
              _loading = false;
              if (_solvework.isNotEmpty) {
                return _solvework.elementAt(0);
              }
            });
        });
      }
      if (_solvework.length == max) {
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
                child: Text("ปิด"),
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
        title: Text(_loading ? 'กำลังโหลด...' : "ประวัติการแก้ไขงาน"),
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
              TextFormField(
                controller: idtask,
                decoration: InputDecoration(
                  // labelText: "Subject",
                  hintText: "กรอกไอดีงาน",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "วันที่: ${DateFormat('dd/MM/yyyy').format(_startDate).toString()}"
                    ,style: TextStyle(fontSize: 16),),
                  SizedBox(width: 8,),
                  Text(
                    "ถึงวันที่: ${DateFormat('dd/MM/yyyy').format(_endDate).toString()}"
                    ,style: TextStyle(fontSize: 16),),
                  SizedBox(width: 2,),
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
                              getHistoryBetweenSolvework(id2,_startDate, _endDate)
                                  .then((historycin) {
                                if (mounted)
                                  setState(() {
                                    _solvework = historycin;
                                    // print(_historycin.length.toString());
                                    if (_solvework.length == 0) {
                                      // showAlertNullData();
                                      _loading = false;
                                    } else {
                                      max = _solvework.length;
                                      if (_solvework.length > 10) {
                                        _solvework = List.generate(10,
                                                (index) => _solvework[index]);
                                      } else {
                                        _solvework = historycin;
                                      }
                                      min = _solvework.length;
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
      itemCount: null == _solvework ? 0 : _solvework.length + 1,
      itemExtent: 150,
      itemBuilder: (context, index) {
        if (_solvework.length == 0) {
          return Center(
            child: Text(
              "ไม่มีข้อมูล",
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
          );
        } else {
          if (index == _solvework.length &&
              _solvework.length > 10 &&
              index > 10) {
            return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white70,
                ));
          } else if (index == _solvework.length &&
              _solvework.length <= 10 &&
              index <= 10) {
            return Center(child: Text(""));
          }
        }
        // New _new[index] = _new[index];
        cid = _solvework[index].toString();
        // print(index.toString());
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
                              flex: 7,
                              child: Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                        "รายละเอียด : " +
                                            _solvework[index].subject,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      "วันที่ให้งาน : " +
                                          df
                                              .format(
                                              _solvework[index].assignDate)
                                              .substring(0, 10),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "เวลาให้งาน : " +
                                          df
                                              .format(
                                              _solvework[index].assignDate)
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
                                  // TextStatus(index),
                                  Text(
                                    "หมอบหมายให้ : " +_solvework[index].name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "วันที่ส่งงาน : " +
                                        df
                                            .format(
                                            _solvework[index].dueDate)
                                            .substring(0, 10),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    "เวลาส่งงาน : " +
                                        df
                                            .format(
                                            _solvework[index].dueDate)
                                            .substring(11, 19),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ].toList(),
                              ),
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: EdgeInsets.all(4),
                        //   child: RaisedButton(
                        //     color: Colors.green,
                        //     onPressed: () {
                        //       setState(() {
                        //         // _showDetail(index);
                        //         // showAlertUpdate(news);
                        //         // showAlertCheckout(news,_checkin[index].checkinid.toString());
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => DetailSolvework(_solvework[index])),
                        //         ).then((value) {
                        //           setState(() {
                        //             _handleRefresh();
                        //           });
                        //         });
                        //       });
                        //     },
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(30.0),
                        //     ),
                        //     child: Text(
                        //       "รายละเอียด",
                        //       style: TextStyle(color: Colors.white70),
                        //     ),
                        //   ),
                        // ),
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
          Jsondata.getHistorysolvework().then((checkins) {
            if (mounted)
              setState(() {
                _solvework = checkins;
                max = _solvework.length;
                // _new = List.generate(10, (index) => _new[index]);
                min = _solvework.length;
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

  TextStatus(int index) {
    // print(index.toString());
    // if (index == 1) {
    //   return Text(
    //     "สถานะ : ยังไม่ได้แก้ไข",
    //     style: TextStyle(fontSize:16,color: Colors.black87, fontWeight: FontWeight.w700),
    //   );
    // } else if (index == 2) {
    //   return Text(
    //     "สถานะ : แก้ไขแล้ว",
    //     style: TextStyle(fontSize:16,color: Colors.black87, fontWeight: FontWeight.w700),
    //   );
    // }
  }
}
