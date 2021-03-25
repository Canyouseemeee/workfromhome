import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Models/Solvework.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/ViewPDF.dart';

class DetailSolvework extends StatefulWidget {
  Solvework solvework;

  DetailSolvework(this.solvework);

  @override
  _DetailSolveworkState createState() => _DetailSolveworkState(solvework);
}

class _DetailSolveworkState extends State<DetailSolvework> {
  Solvework solvework;

  _DetailSolveworkState(this.solvework);

  bool _loading;
  bool _disposed = false;
  DateTime time = DateTime.now();
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  File localfile;
  bool downloading;
  var url;
  int progress = 0;
  ReceivePort receivePort = ReceivePort();

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
      showAlertsuccessdowload();
      // print(baseStorage.path);
    } else {
      print('no permission');
    }
  }

  static dowloadCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName('donwload');
    sendPort.send(progress);
  }

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
    url = Apiurl + "/storage/" + solvework.file.toString();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, "donwload");
    receivePort.listen((message) {
      if (mounted)
        setState(() {
          progress = message;
        });
    });
    FlutterDownloader.registerCallback(dowloadCallback);
  }

  void _openFileExplorer() async {
    File pickedFile = await FilePicker.getFile(
        allowedExtensions: ['pdf'], type: FileType.custom);
    setState(() {
      localfile = pickedFile;
    });
    _showDialog(context);
  }

  postSubmitSolvework(File file) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (file != null) {
      String fileName = file.path.split('/').last.replaceAll(" ", "_");
      if (sharedPreferences.getString("token") != null) {
        var data = FormData.fromMap({
          'solveworkid': solvework.solveworkid,
          'taskid': solvework.taskid,
          "file": await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        });
        Dio dio = new Dio();
        await dio
            .post(Apiurl + "/api/postsubmitsolvework", data: data)
            .then((response) => print(response))
            .catchError((error) => print(error));
      }
    } else {
      if (sharedPreferences.getString("token") != null) {
        var data = FormData.fromMap({
          'solveworkid': solvework.solveworkid,
          'taskid': solvework.taskid,
          "file": null
        });
        Dio dio = new Dio();
        await dio
            .post(Apiurl + "/api/postsubmitsolvework", data: data)
            .then((response) => print(response))
            .catchError((error) => print(error));
      }
    }
  }

  poststatus(String tid) async {
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
          await http.post(Apiurl + "/api/poststatussolve", body: data);
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

  showAlertsuccessdowload() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("โหลดไฟล์สำเร็จ"),
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
                          : Text(localfile.toString()),
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
                              postSubmitSolvework(localfile);
                              poststatus(solvework.taskid.toString());
                              //   // print(news);
                              //   // print(imageFile.path.split('/').last);
                              Navigator.pop(context);
                              showAlertsuccess();
                              // _handleRefresh();
                              // Navigator.pop(context);
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
        title: Text(_loading ? 'กำลังโหลด...' : "รายละเอียดภาระงานที่ให้แก้"),
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
                    "ภาระงาน : " + solvework.taskid.toString(),
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "หัวเรื่อง : " + solvework.subject,
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
                  "แผนก : " + solvework.dmname,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "หัวหน้าที่สร้างงาน : " + solvework.createsolvework,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "วันที่ให้งาน : " +
                      df.format(solvework.assignDate).substring(0, 10),
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "เวลาให้งาน : " +
                      df.format(solvework.assignDate).substring(11, 19),
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "ให้งานกับพนักงาน : " + solvework.name,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "วันที่ส่งงาน : " + df.format(solvework.dueDate).substring(0, 10),
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),

                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "เวลาส่งงาน : " + df.format(solvework.dueDate).substring(11, 19),
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
            ButtonStatus(),
            ButtonDownloadfile(solvework),
            ButtonViewfile(solvework),
          ],
        )
      ],
    ),
  );

  static Future<List<Solvework>> getSolvework(String taskid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'taskid': taskid};
    var jsonData = null;
    const String url = Apiurl + "/api/getsolvework";
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          print(taskid);
          final List<Solvework> slovework = solveworkFromJson(response.body);
          return slovework;
        }
      } else {
        print(response);
        return List<Solvework>();
      }
    } catch (e) {
      print("e2");
      return List<Solvework>();
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
        getSolvework(solvework.taskid.toString()).then((news) {
          setState(() {
            _loading = false;
          });
        });
      });
    });

    return null;
  }

  TextStatus() {
    if (solvework.statussolveworkid == 1) {
      return Text(
        "สถานะ : ยังไม่ได้แก้งาน",
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
      );
    } else if (solvework.statussolveworkid == 2) {
      return Text(
        "สถานะ : แก้งานแล้ว",
        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
      );
    }
  }

  ButtonStatus() {
    if (solvework.statussolveworkid == 1 ) {
      return Center(
        child: Container(
          height: 50.0,
          margin: EdgeInsets.all(10),
          // padding: EdgeInsets.symmetric(horizontal: 80.0),
          child: RaisedButton(
            color: Colors.green,
            onPressed: () {
              setState(() {
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
    } else if (solvework.statussolveworkid == 2) {
      return Container();
    }
  }

  ButtonDownloadfile(Solvework task) {
    if (task.statussolveworkid == 2) {
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
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.white),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  ButtonViewfile(Solvework task) {
    if (task.statussolveworkid == 2) {
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
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.white),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
