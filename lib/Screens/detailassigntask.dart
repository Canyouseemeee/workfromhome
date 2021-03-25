import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:workfromhome/Screens/managesolvework.dart';
import 'package:http/http.dart' as http;
import 'package:workfromhome/Screens/managesolveworkassign.dart';

class DetailAssignTask extends StatefulWidget {
  Task task;
  DetailAssignTask(this.task);
  @override
  _DetailAssignTaskState createState() => _DetailAssignTaskState(task);
}

class _DetailAssignTaskState extends State<DetailAssignTask> {
  Task task;
  _DetailAssignTaskState(this.task);
  bool _loading;
  bool _disposed = false;
  DateTime time = DateTime.now();
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  File localfile;
  int count;
  String taskid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    Timer(Duration(seconds: 1), () {
      if (!_disposed)
        setState(() {
          time = time.add(Duration(seconds: -1));
        });
    });
    taskid = task.taskid.toString();
    postCountResolve(taskid);
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
      var response = await http.post(Apiurl + "/api/countsolvework", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {
          if(mounted) setState(() {
            _loading = false;
            count = jsonData;
          });

        }
      } else {
        print(response.body);
      }
    }
  }

  void _openFileExplorer() async {
    File pickedFile = await FilePicker.getFile(
        allowedExtensions: ['pdf'], type: FileType.custom);
    setState(() {
      localfile = pickedFile;
    });
    _showDialog(context);
  }

  postSubmitTask(File file) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    setState(() {
      id = sharedPreferences.getString("userid");
    });
    if (file != null) {
      String fileName = file.path.split('/').last.replaceAll(" ", "_");
      if (sharedPreferences.getString("token") != null) {
        var data = FormData.fromMap({
          'taskid': task.taskid,
          'userid': id,
          "file": await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        });
        // print(fileName.toString());
        // print(image.path.toString());
        Dio dio = new Dio();
        await dio
            .post(Apiurl + "/api/postsubmittask", data: data)
            .then((response) => print(response))
            .catchError((error) => print(error));
      }
    } else {
      if (sharedPreferences.getString("token") != null) {
        var data = FormData.fromMap({
          'taskid': task.taskid,
          'userid': id,
          "file": null
        });
        Dio dio = new Dio();
        await dio
            .post(Apiurl + "/api/postsubmittask", data: data)
            .then((response) => print(response))
            .catchError((error) => print(error));
      }
    }
  }

  showAlertsuccess() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("ส่งงานสำเร็จ"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleRefresh();
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
            title: Text('ส่งงาน'),
            content: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: localfile == null
                          ? Icon(Icons.picture_as_pdf, size: 120)
                          :  Text(localfile.toString()),
                    ),
                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  localfile == null
                      ? Container()
                      : new FlatButton(
                    child: new Text('บันทึก'),
                    onPressed: () {
                      setState(() {
                        // if (_formKey.currentState.validate()) {
                        //   _formKey.currentState.save();
                        postSubmitTask(localfile);
                        //   // print(news);
                        //   // print(imageFile.path.split('/').last);
                        Navigator.pop(context);
                        showAlertsuccess();
                        _handleRefresh();
                      });
                    },
                  ),
                  new FlatButton(
                    child: new Text('เลือกไฟล์'),
                    onPressed: () {
                      Navigator.pop(context);
                      _openFileExplorer();
                    },
                  ),
                  new FlatButton(
                    child: new Text('ปิด'),
                    onPressed: () {
                      localfile = null;
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
            ButtonStatus(),
          ],
        )
      ],
    ),
  );

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

  TextStatus() {
    if (task.statustaskid == 1) {
      return Text(
        "สถานะ : งานใหม่",
        style: TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (task.statustaskid == 2) {
      return Text(
        "สถานะ : กำลังดำเนินการ",
        style: TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }else if (task.statustaskid == 3) {
      return Text(
        "สถานะ : ปิดงานแล้ว",
        style: TextStyle(fontSize: 16,color: Colors.black87, fontWeight: FontWeight.w700),
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
              MaterialPageRoute(builder: (context) => ManageSolveworkassign(task)),
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
    } else {
      return Container();
    }
  }

  ButtonStatus(){
    if(task.statustaskid == 1 && count == 0){
      return Center(
        child: Container(
            height: 50.0,
            margin: EdgeInsets.all(5),
            child: RaisedButton(
              color: Colors.green,
              onPressed: () {
                setState(() {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           Comment(task.issuesid.toString())),
                  // ).then((value) {
                  //   setState(() {
                  //     _handleRefresh();
                  //
                  //   });
                  // });
                  // _openFileExplorer();
                  _showDialog(context);
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                "ส่งงาน",
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
        ),
      );
    }else if(task.statustaskid == 2 && count == 0){
      return Center(
        child: Container(
            height: 50.0,
            margin: EdgeInsets.all(5),
            child: RaisedButton(
              color: Colors.green,
              onPressed: () {
                setState(() {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           Comment(task.issuesid.toString())),
                  // ).then((value) {
                  //   setState(() {
                  //     _handleRefresh();
                  //
                  //   });
                  // });
                  // _openFileExplorer();
                  _showDialog(context);
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                "ส่งงาน",
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
        ),
      );
    }else{
      return Container();
    }
  }
}
