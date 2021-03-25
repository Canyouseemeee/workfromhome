import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:http/http.dart' as http;
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/ViewPDF.dart';
import 'package:workfromhome/Screens/managesolvework.dart';

class DetailTask extends StatefulWidget {
  Task task;

  DetailTask(this.task);

  @override
  _DetailTaskState createState() => _DetailTaskState(task);
}

class _DetailTaskState extends State<DetailTask> {
  Task task;
  var received;
  var total;

  _DetailTaskState(this.task);

  bool _loading;
  bool _disposed = false;
  DateTime time = DateTime.now();
  var timePicked;
  final df = new DateFormat('dd-MM-yyyy HH:mm a');
  var due;
  DateTime newDateTime;
  final Dio dio = new Dio();
  String url;
  int progress = 0;
  ReceivePort receivePort = ReceivePort();
  bool downloading = false;
  int count;
  String pathPDF = "";
  String taskid;
  TextEditingController EditSub = TextEditingController();
  TextEditingController EditDue = TextEditingController();

  void _dowloadFile(url) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();

      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: baseStorage.path,
        fileName: 'filename.pdf',
        showNotification: true,
        // show download progress in status bar (for Android)
        openFileFromNotification: true,
      );
      downloading = false;
      showAlertsuccess();
      // print(baseStorage.path);
    } else {
      print('no permission');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    taskid = task.taskid.toString();
    postCountResolve(taskid);
    Timer(Duration(seconds: 1), () {
      if (!_disposed) if (mounted)
        setState(() {
          time = time.add(Duration(seconds: -1));
        });
    });
    url = Apiurl + "/storage/" + task.file.toString();
    EditSub.text = "";
    EditDue.text = "";
    IsolateNameServer.registerPortWithName(receivePort.sendPort, "donwload");
    receivePort.listen((message) {
      if (mounted)
        setState(() {
          progress = message;
        });
    });
    FlutterDownloader.registerCallback(dowloadCallback);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  static dowloadCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName('donwload');
    sendPort.send(progress);
  }

  postReTask(int tid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    var jsonData = null;
    setState(() {
      id = sharedPreferences.getString("userid");
    });
    // print(tid.toString());
    // print(id);
    // print(EditSub.text);
    // print(task.assignment);
    // print(task.departmentid.toString());
    // print(due.toString());
    if (sharedPreferences.getString("token") != null) {
      Map<String, String> data = {
        'taskid': int.parse(taskid).toString(),
        'userid': id.toString(),
        'subject': EditSub.text,
        'assignment': task.assignment.toString(),
        'duedate': DateTime.parse(due).toString(),
        'departmentid': task.departmentid.toString(),
      };
      var response = await http.post(Apiurl + "/api/postretask", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {
          Navigator.pop(context);
          Toast.show("บันทึกสำเร็จ", context,
              gravity: Toast.CENTER, duration: 2);
          _handleRefresh();
          Navigator.pop(context);
        }
      } else {
        print(response.body);
      }
    }
  }

  postCountResolve(String tid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    var jsonData = null;
    setState(() {
      id = sharedPreferences.getString("userid");
    });
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'taskid': tid,
      };
      var response =
          await http.post(Apiurl + "/api/countsolvework", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {
          if (mounted) setState(() {
            count = jsonData;
            _loading = false;
          });
        }
      } else {
        print(response.body);
      }
    }
  }

  showAlertsuccess() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("โหลดไฟล์งานสำเร็จ"),
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

  showAlertFaild() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("กรุณาโหลดไฟล์ใหม่อีกครั้งค่ะ"),
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
                        Text("อธิบายสิ่งที่ให้แก้ไข: "),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              minLines: 1,
                              maxLines: 5,
                              controller: EditSub,
                              decoration: InputDecoration(
                                // labelText: "Subject",
                                hintText: "อธิบายสิ่งที่ให้แก้",
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
                        // print(task.taskid.toString());
                        postReTask(task.taskid);
                      },
                    ),
                    new FlatButton(
                      child: new Text('ปิด'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            );
          });
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'กำลังโหลด...' : "รายละเอียดภาระงาน"),
        backgroundColor: Colors.white,
        elevation: 6.0,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60.0),
            bottomRight: Radius.circular(60.0),
          ),
        ),
      ),
      body: (_loading
          ? new Center(
              child: new CircularProgressIndicator(
              backgroundColor: Colors.pinkAccent,
            ))
          : ListView(children: <Widget>[
              _titleSection(context),
            ])),
      backgroundColor: kPrimaryColor,
    );
  }

  Widget _titleSection(context) => Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children:[
            Card(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Center(
                      child: Text(
                        "ภาระงาน : " + task.taskid.toString(),
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "หัวเรื่อง : " + task.subject,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "รายละเอียด : " + task.description,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextStatus(),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "แผนก : " + task.dmname,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "หัวหน้าที่สร้างงาน : " + task.createtask,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "วันที่ให้งาน : " +
                          df.format(task.assignDate).substring(0, 10),
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "เวลาให้งาน : " +
                          df.format(task.assignDate).substring(11, 19),
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "ให้งานกับพนักงาน : " + task.name,
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "วันที่ส่งงาน : " + df.format(task.dueDate).substring(0, 10),
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),

                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "เวลาส่งงาน : " + df.format(task.dueDate).substring(11, 19),
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),

                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                ButtonCountsolve(),
                ButtonDownloadfile(task),
                ButtonViewfile(task),
              ],
            )
          ],
        ),
      );

  TextStatus() {
    if (task.statustaskid == 1) {
      return Text(
        "สถานะ : งานใหม่",
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),

      );
    } else if (task.statustaskid == 2) {
      return Text(
        "สถานะ : กำลังดำเนินการ",
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),

      );
    } else if (task.statustaskid == 3) {
      return Text(
        "สถานะ : ปิดงานแล้ว",
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
      );
    }
  }

  ButtonCountsolve() {
    if (count != 0) {
      return Container(
        // width: MediaQuery.of(context).size.width - 100,
        height: 50.0,
        margin: EdgeInsets.all(5),
        // padding: EdgeInsets.symmetric(horizontal: 90.0),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () async {
            // _showDialog(context);
            // _dowloadFile(url);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageSolvework(task)),
            ).then((value) {
              setState(() {
                _handleRefresh();
              });
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "ดูงานที่แก้ไข",
            style: TextStyle(fontSize: 16,color: Colors.white),
          ),
        ),
      );
    } else if (count == 0) {
      return Padding(
        padding: EdgeInsets.only(left: 20),
        child: Container(
          // width: MediaQuery.of(context).size.width - 100,
          height: 50.0,
          margin: EdgeInsets.all(5),
          // padding: EdgeInsets.symmetric(horizontal: 90.0),
          child: RaisedButton(
            color: Colors.green,
            onPressed: () {
              setState(() {
                // _openFileExplorer();
                // _showDialog(context);
                // postReTask(task.taskid.toString());
                _showDialog(context);
                // Navigator.pop(context);
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              "ให้แก้ไขงาน",
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  ButtonDownloadfile(Task task) {
    if (task.statustaskid == 3) {
      return Container(
        // width: MediaQuery.of(context).size.width - 100,
        height: 50.0,
        margin: EdgeInsets.all(5),
        // padding: EdgeInsets.symmetric(horizontal: 90.0),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () async {
            // _showDialog(context);
            _dowloadFile(url);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "โหลดไฟล์งาน",
            style: TextStyle(fontSize: 16,color: Colors.white),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  ButtonViewfile(Task task) {
    if (task.statustaskid == 3) {
      return Container(
        // width: MediaQuery.of(context).size.width - 100,
        height: 50.0,
        margin: EdgeInsets.all(5),
        // padding: EdgeInsets.symmetric(horizontal: 90.0),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () {
            setState(() {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PDFScreen(url)))
                  .then((value) {
                setState(() {
                  _handleRefresh();
                });
              });
              // postReTask(task.taskid.toString());
              // Navigator.pop(context);
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "ดูไฟล์งาน",
            style: TextStyle(fontSize: 16,color: Colors.white),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<Null> _handleRefresh() async {
    Completer<Null> completer = new Completer<Null>();

    new Future.delayed(new Duration(milliseconds: 2)).then((_) {
      completer.complete();
      setState(() {
        Timer(Duration(seconds: 1), () {
          if (!_disposed)
            setState(() {
              time = time.add(Duration(seconds: -1));
            });
        });
        _loading = true;
        Jsondata.getAssignTask().then((news) {
          setState(() {
            _loading = false;
          });
        });
      });
    });

    return null;
  }
}
