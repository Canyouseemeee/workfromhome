import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workfromhome/Models/Task.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Other/services/Jsondata.dart';
import 'package:workfromhome/Screens/addtask.dart';
import 'package:workfromhome/Screens/detailtask.dart';
import 'package:workfromhome/Screens/edittask.dart';

class ManageTask extends StatefulWidget {
  @override
  _ManageTaskState createState() => _ManageTaskState();
}

class _ManageTaskState extends State<ManageTask> {
  List<Task> _task;
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



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    Jsondata.getTask().then((checkins) {
      setState(() {
        _task = checkins;
        // print(_checkin.length.toString());
        if (_task.length == 0) {
          // showAlertNullData();
          _loading = false;
        } else {
          max = _task.length;
          if (_task.length > 10) {
            _task = List.generate(10, (index) => _task[index]);
          } else {
            _task = checkins;
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
        Jsondata.getTask().then((checkins) {
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
        title: Text(_loading ? 'Loading...' : "Task"),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTask()),
              ).then((value) {
                setState(() {
                  _handleRefresh();
                });
              });
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
      itemCount: _task.length,
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
        Task task = _task[index];
        return Padding(
          padding: EdgeInsets.all(3.0),
          child: Card(
            child: ListTile(
              leading: Icon(
                Icons.assignment_rounded,
                color: Colors.lightGreen,
              ),
              title: Text(task.subject,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("[ DESCRIPTION: " +
                  task.description +
                  " ] \n[ ASSIGNMENT: " +
                  task.assignment +
                  " ]"),
              trailing: Wrap(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailTask(_task[index])),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditTask(task)),
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
        Jsondata.getTask().then((checkins) {
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

}
