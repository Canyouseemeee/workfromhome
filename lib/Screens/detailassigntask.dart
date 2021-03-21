import 'dart:async';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = false;
    Timer(Duration(seconds: 1), () {
      if (!_disposed)
        setState(() {
          time = time.add(Duration(seconds: -1));
        });
    });
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
                    child: new Text('SAVE'),
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
                    child: new Text('Chosse File'),
                    onPressed: () {
                      Navigator.pop(context);
                      _openFileExplorer();
                    },
                  ),
                  new FlatButton(
                    child: new Text('Close'),
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
                      SizedBox(
                        height: 16,
                      ),
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
            ButtonStatus(),

          ],
        ),
      ),
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
        "Status : งานใหม่",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    } else if (task.statustaskid == 2) {
      return Text(
        "Status : กำลังดำเนินการ",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }else if (task.statustaskid == 3) {
      return Text(
        "Status : ปิดงานแล้ว",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
      );
    }
  }

  ButtonStatus(){
    if(task.statustaskid == 1){
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(horizontal: 80.0),
          child: RaisedButton(
            color: Colors.pink,
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
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }else if(task.statustaskid == 2){
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(horizontal: 80.0),
          child: RaisedButton(
            color: Colors.pink,
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
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }else{
      return Container();
    }
  }
}
