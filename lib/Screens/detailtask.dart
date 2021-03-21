import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buddhist_datetime_dateformat/buddhist_datetime_dateformat.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:http/http.dart' as http;
import 'package:workfromhome/Other/services/Jsondata.dart';

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
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  File localfile;
  // final imgUrl = Apiurl + "/storage/" + task.file.toString();
  final Dio dio = new Dio();
  String path;
  String fullPath;
  var url;

//get mobile download path
  getmobildedowloanpath() async {
     path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
     setState(() {
       fullPath = path+"/"+"task.pdf";
     });
     // print(fullPath);
    return fullPath;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    // dio = new Dio();
    Timer(Duration(seconds: 1), () {
      if (!_disposed)
        setState(() {
          time = time.add(Duration(seconds: -1));
        });
    });
    getmobildedowloanpath();
    getPermission();
    url = Apiurl + "/storage/" + task.file.toString();
    if(url != null){
      _handleRefresh();
      // print(url);
    }
  }

  postReTask(String tid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'taskid': tid,
      };
      var jsonData = null;
      var response = await http.post(Apiurl + "/api/postretask", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        if (jsonData != null) {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'Loading...' : "Detail"),
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

  void getPermission() async {
    // print("getPermission");
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            maxRedirects: 20,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      if(response.statusCode == 200){
        showAlertsuccess();
      }
      // print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
      showAlertFaild();
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Widget _titleSection(context) => Padding(
        padding: EdgeInsets.all(0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 150),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Taskid : " + task.taskid.toString(),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subject = " + task.subject,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Description = " + task.description,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextStatus(),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Department = " + task.dmname,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CreateTask = " + task.createtask,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "วันที่ให้งาน : " +
                                df
                                    .format(
                                    task.assignDate)
                                    .substring(0, 10),
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "เวลาให้งาน : " +
                                df
                                    .format(
                                    task.assignDate)
                                    .substring(11, 19),
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            "AssignTask = " + task.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "วันที่ส่งงาน : " +
                                df
                                    .format(
                                    task.dueDate)
                                    .substring(0, 10),
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "เวลาส่งงาน : " +
                                df
                                    .format(
                                    task.dueDate)
                                    .substring(11, 19),
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 75),
                      child: Container(
                        // width: MediaQuery.of(context).size.width - 100,
                        height: 50.0,
                        margin: EdgeInsets.all(5),
                        // padding: EdgeInsets.symmetric(horizontal: 90.0),
                        child: RaisedButton(
                          color: Colors.orange,
                          onPressed: () {
                            setState(() {
                              // _openFileExplorer();
                              // _showDialog(context);
                              postReTask(task.taskid.toString());
                              Navigator.pop(context);
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text(
                            "ให้แก้ไขงาน",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    ButtonDownloadfile(task),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  TextStatus() {
    if (task.statustaskid == 1) {
      return Text(
        "Status : งานใหม่",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (task.statustaskid == 2) {
      return Text(
        "Status : กำลังดำเนินการ",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (task.statustaskid == 3) {
      return Text(
        "Status : ปิดงานแล้ว",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }
  }

  ButtonDownloadfile(Task task)  {
    if(task.statustaskid == 3){
      return Container(
        // width: MediaQuery.of(context).size.width - 100,
        height: 50.0,
        margin: EdgeInsets.all(5),
        // padding: EdgeInsets.symmetric(horizontal: 90.0),
        child: RaisedButton(
          color: Colors.green,
          onPressed: () {
            setState(()  {
              // _openFileExplorer();
              // _showDialog(context);
              // var url = Apiurl + "/storage/" + task.file.toString();
              getmobildedowloanpath();
              getPermission();
              download2(dio,url,fullPath);
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "โหลดไฟล์งาน",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }else{
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
