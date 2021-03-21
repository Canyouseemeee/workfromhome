import 'dart:async';
import 'dart:convert';
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:http/http.dart' as http;
import 'package:workfromhome/Screens/detailassigntask.dart';

class ManageAssignTask extends StatefulWidget {
  @override
  _ManageAssignTaskState createState() => _ManageAssignTaskState();
}

class _ManageAssignTaskState extends State<ManageAssignTask> {

  bool _loading;
  var max;
  var min;
  var formatter = DateFormat.yMd().add_jm();
  ScrollController _scrollController = new ScrollController();
  DateTime time = DateTime.now();
  int _currentMax = 10;
  String tid;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  List<Task> _task;

  postStatusSoon(String tid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'taskid': tid,
      };
      var jsonData = null;
      var response = await http.post(Apiurl + "/api/poststatustask", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {}
      } else {
        print(response.body);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    Jsondata.getAssignTask().then((tasks) {
      setState(() {
        _task = tasks;
        // print(_checkin.length.toString());
        if (_task.length == 0) {
          // showAlertNullData();
          _loading = false;
        } else {
          max = _task.length;
          if (_task.length > 10) {
            _task = List.generate(10, (index) => _task[index]);
          } else {
            _task = tasks;
          }
          min = _task.length;
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
        Jsondata.getAssignTask().then((checkins) {
          setState(() {
            _task = checkins;
            _task.add(_task[i]);
            _task.length = max;
            _loading = false;
            if (_task.isNotEmpty) {
              return _task.elementAt(0);
            }
          });
        });
      }
      if (_task.length == max) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'Loading...' : "Your Task"),
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
      backgroundColor: kPrimaryColor,
    );
  }

  Widget _showJsondata() => new RefreshIndicator(
    child: ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      itemCount: null == _task ? 0 : _task.length + 1,
      itemExtent: 160,
      itemBuilder: (context, index) {
        if (_task.length == 0) {
          return Center(
            child: Text(
              "No Result",
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
          );
        } else {
          if (index == _task.length &&
              _task.length > 10 &&
              index > 10) {
            return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white70,
                ));
          } else if (index == _task.length &&
              _task.length <= 10 &&
              index <= 10) {
            return Center(child: Text(""));
          }
        }
        // New _new[index] = _new[index];
        tid = _task[index].taskid.toString();
        return GestureDetector(
          // child: Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      // height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                          "Subject : " +
                                              _task[index].subject,
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
                                                _task[index].assignDate)
                                                .substring(0, 10),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "เวลาให้งาน : " +
                                            df
                                                .format(
                                                _task[index].assignDate)
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
                                flex: 5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 16,
                                    ),
                                    TextStatus(index),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      "วันที่ส่งงาน : " +
                                          df
                                              .format(
                                              _task[index].dueDate)
                                              .substring(0, 10),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "เวลาส่งงาน : " +
                                          df
                                              .format(
                                              _task[index].dueDate)
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
          // ),
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
        Jsondata.getAssignTask().then((checkins) {
          setState(() {
            _task = checkins;
            max = _task.length;
            // _new = List.generate(10, (index) => _new[index]);
            min = _task.length;
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

  TextStatus(int index) {
    if (_task[index].statustaskid == 1) {
      return Text(
        "Status : งานใหม่",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (_task[index].statustaskid == 2) {
      return Text(
        "Status : กำลังดำเนินการ",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }else if (_task[index].statustaskid == 3) {
      return Text(
        "Status : ปิดงานแล้ว",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }
  }

  showButton(int index) {
    if (_task[index].statustaskid == 1) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: RaisedButton(
          color: Colors.amber,
          onPressed: () {
            setState(() {
              // showAlertUpdate(news);
              // showAlertCheckout(_checkin[index].checkinid.toString());
              postStatusSoon(tid);
              _handleRefresh();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailAssignTask(_task[index])),
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
            "รับรู้งาน",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    } else if (_task[index].statustaskid == 2) {
      return Padding(
        padding: EdgeInsets.all(4),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailAssignTask(_task[index])),
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
            "ส่งงาน",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    } else if (_task[index].statustaskid == 3) {
      return Padding(
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
                    builder: (context) => DetailAssignTask(_task[index])),
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
      );
    }
  }
}
