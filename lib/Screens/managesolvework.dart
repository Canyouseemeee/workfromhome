import 'dart:async';
import 'dart:convert';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:workfromhome/Models/Solvework.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/detailsolvework.dart';

class ManageSolvework extends StatefulWidget {
  Task task;
  ManageSolvework(this.task);
  @override
  _ManageSolveworkState createState() => _ManageSolveworkState(task);
}

class _ManageSolveworkState extends State<ManageSolvework> {
  Task task;
  _ManageSolveworkState(this.task);
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

  datepicker() async {
    newDateTime = await showRoundedDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
      borderRadius: 16,
    );
    timePicked = await showRoundedTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    due = newDateTime.toString().substring(0, 10) +
        " " +
        timePicked.toString().substring(10, timePicked.toString().length - 1) +
        ":00";
    // DateTime.parse(due);
    // print(DateTime.parse(due).toString());
    // print(timePicked.toString().substring(10,timePicked.toString().length - 1));
    var ndt = df.format(newDateTime);
    EditDue.text = ndt.toString().substring(0, 10) +
        " " +
        timePicked.toString().substring(10, timePicked.toString().length - 1) +
        ":00";
    return EditDue.text;
  }

  postReTask(String tid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    var jsonData = null;
    setState(() {
      id = sharedPreferences.getString("userid");
    });
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'taskid': tid,
        'userid': id,
        'subject': EditSub.text,
        'assignment': task.assignment,
        'departmentid': int.parse(task.departmentid.toString()),
        'duedate': DateTime.parse(due).toString(),
      };
      var response = await http.post(Apiurl + "/api/postretask", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {}
      } else {
        print(response.body);
      }
    }
  }

  updatesolve(String solveworkid) async {
    print(solveworkid.toString());
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonData = null;
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'solveworkid': int.parse(solveworkid).toString(),
        'subject': EditSub.text,
        'duedate': DateTime.parse(due).toString(),
      };
      var response = await http.post(Apiurl + "/api/updatesolve", body: data);
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
              content: Container(
                height: 190,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("หัวเรื่องที่ให้แก้ไข: "),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              minLines: 1,
                              maxLines: 5,
                              controller: EditSub,
                              decoration: InputDecoration(
                                // labelText: "Subject",
                                hintText: "หัวเรื่องที่ให้แก้ไข",
                              ),
                              validator: (value) {
                                if ((value == null) || (value.isEmpty)) {
                                  return "กรุณากรอกข้อมูล";
                                } else if (value.length <= 5) {
                                  return "กรุณากรอกข้อมูลอย่างน้อย 5 ตัว";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("วันที่จะให้ส่ง: "),
                        Expanded(
                          child: TextFormField(
                            controller: EditDue,
                            decoration: InputDecoration(
                                icon: Icon(Icons.calendar_today)),
                            onTap: () {
                              datepicker();
                            },
                            readOnly: true,
                            validator: (value) {
                              if ((value == null) || (value.isEmpty)) {
                                return "กรุณาเลือกวันที่และเวลา";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    new FlatButton(
                      child: new Text('บันทึก'),
                      onPressed: () {
                        postReTask(task.taskid.toString());
                      },
                    ),
                    new FlatButton(
                      child: new Text('ยกเลิก'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            );
          });
        }
    );
  }

  Future<void> _showDialogEdit(BuildContext context,String solveworkid) async {
    return await showDialog<AlertDialog>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 190,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("หัวเรื่องที่ให้แก้ไข: "),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              minLines: 1,
                              maxLines: 5,
                              // expands: true,
                              controller: EditSub,
                              decoration: InputDecoration(
                                // labelText: "Subject",
                                hintText: "อธิบายสิ่งที่ให้แก้ไข",
                              ),
                              validator: (value) {
                                if ((value == null) || (value.isEmpty)) {
                                  return "กรุณากรอกข้อมูล";
                                } else if (value.length <= 5) {
                                  return "กรุณากรอกข้อมูลอย่างน้อย 5 ตัว";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("วันที่จะให้ส่ง: "),
                        Expanded(
                          child: TextFormField(
                            controller: EditDue,
                            decoration: InputDecoration(
                                icon: Icon(Icons.calendar_today)),
                            onTap: () {
                              datepicker();
                            },
                            readOnly: true,
                            validator: (value) {
                              if ((value == null) || (value.isEmpty)) {
                                return "กรุณาเลือกวันที่และเวลา";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    new FlatButton(
                      child: new Text('บันทึก'),
                      onPressed: () {
                        // postReTask(task.taskid.toString());
                        updatesolve(solveworkid);
                        Toast.show("อัพเดทข้อมูลสำเร็จ", context,
                            gravity: Toast.CENTER, duration: 2);
                        Navigator.pop(context);
                        _handleRefresh();
                      },
                    ),
                    new FlatButton(
                      child: new Text('ยกเลิก'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            );
          });
        }
    );
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AddTask()),
              // ).then((value) {
              //   setState(() {
              //     _handleRefresh();
              //   });
              // });
              EditDue.text = "";
              EditSub.text = "";
              _showDialog(context);
            },
          ),
        ],
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
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      EditDue.text = solvework.dueDate.toString();
                      EditSub.text = solvework.subject;
                      due = solvework.dueDate.toString();
                      _showDialogEdit(context,solvework.solveworkid.toString());
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
