import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Solvework.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Screens/detailsolvework.dart';

class ManageSolveworkassign extends StatefulWidget {
  Task task;
  ManageSolveworkassign(this.task);
  @override
  _ManageSolveworkassignState createState() => _ManageSolveworkassignState(task);
}

class _ManageSolveworkassignState extends State<ManageSolveworkassign> {
  Task task;
  _ManageSolveworkassignState(this.task);
  List<Solvework> _solvework;
  bool taskLoading = true;
  var max;
  var min;
  var formatter = DateFormat.yMd().add_jm();
  ScrollController _scrollController = new ScrollController();
  bool _loading;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  int _currentMax = 10;
  String cid;
  DateTime time = DateTime.now();
  TextEditingController EditSub = TextEditingController();
  TextEditingController EditDue = TextEditingController();
  DateTime newDateTime;
  var timePicked;
  var due;

  static Future<List<Solvework>> getSolvework(String taskid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'taskid': taskid};
    var jsonData = null;
    const String url = Apiurl+"/api/getsolvework";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          // print(taskid);
          final List<Solvework> slovework = solveworkFromJson(response.body);
          return slovework;
        }
      } else {
        // print(response);
        return List<Solvework>();
      }
    } catch (e) {
      // print("e2");
      return List<Solvework>();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    String tid = task.taskid.toString();
    getSolvework(tid).then((solvework) {
      setState(() {
        _solvework = solvework;
        // print(_solvework.length.toString());
        if (_solvework.length == 0) {
          // showAlertNullData();
          _loading = false;
        } else {
          max = _solvework.length;
          if (_solvework.length > 10) {
            _solvework = List.generate(10, (index) => _solvework[index]);
          } else {
            _solvework = solvework;
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

  getMoreData() {
    if (min == 10) {
      for (int i = _currentMax; i < max - 1; i++) {
        getSolvework(task.taskid.toString()).then((solvework) {
          setState(() {
            _solvework = solvework;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'กำลังโหลด...' : "ภาระงานที่ให้แก้"),
        elevation: 6.0,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60.0),
            bottomRight: Radius.circular(60.0),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(backgroundColor: Colors.pinkAccent,))
          : _productListView(),
      backgroundColor: kPrimaryColor,
    );
  }

  _productListView() {
    return ListView.builder(
      itemCount: _solvework.length,
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
        Solvework solvework = _solvework[index];
        return Padding(
          padding: EdgeInsets.all(3.0),
          child: Card(
            child: ListTile(
              leading: Icon(
                Icons.assignment_rounded,
                color: Colors.lightGreen,
              ),
              title: Text("รายละเอียดที่ให้แก้งาน" + solvework.subject,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "[ วันนที่ส่งงาน: " +
                      df.format(task.dueDate).substring(0, 10) +
                      " ] \n"+ "[ เวลาส่งงาน: " +
                      df.format(task.dueDate).substring(11, 19) +" ] \n[ ให้กับพนักงาน: " +
                      solvework.assignment +
                      " ]",style: TextStyle(fontSize: 16),),
              trailing: Wrap(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailSolvework(_solvework[index])),
                      ).then((value) {
                        setState(() {
                          _handleRefresh();
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Null> _handleRefresh() async {
    Completer<Null> completer = new Completer<Null>();

    new Future.delayed(new Duration(milliseconds: 2)).then((_) {
      completer.complete();
      setState(() {
        _loading = false;
        getSolvework(task.taskid.toString()).then((checkins) {
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
}
