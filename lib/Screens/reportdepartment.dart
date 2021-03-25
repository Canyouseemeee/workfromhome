import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workfromhome/Models/Departments.dart';
import 'package:workfromhome/Models/Users.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:http/http.dart' as http;

class ReprotDepartment extends StatefulWidget {
  @override
  _ReprotDepartmentState createState() => _ReprotDepartmentState();
}

class _ReprotDepartmentState extends State<ReprotDepartment> {
  List<Department> _department;
  List<DropdownMenuItem<Department>> _dropdownMenuDepartmentItems;
  Department _selectedDepartment;
  bool disabledropdown = true;
  bool _loading;
  var max;
  var min;
  var formatter = DateFormat.yMd().add_jm();
  ScrollController _scrollController = new ScrollController();
  DateTime time = DateTime.now();
  int _currentMax = 10;
  List<Users> _users;
  String cid;
  bool selected = false;
  Timer _timer;
  bool _disposed = false;
  final df = new DateFormat('dd/MM/yyyy HH:mm a');
  TextEditingController idtask = TextEditingController();
  String _myState;

  static Future<List<Users>> getUsers(String _myState) async {
    const String url = Apiurl + "/api/getuser";
    Map data = {
      'departmentid': _myState,
    };
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Users> users = usersFromJson(response.body);
          return users;
        }
      } else {
        return List<Users>();
      }
    } catch (e) {
      return List<Users>();
    }
  }

  static Future<List<Department>> getDepartments() async {
    const String url = Apiurl + "/api/getdepartment";
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final List<Department> departments =
              departmentFromJson(response.body);
          return departments;
        }
      } else {
        return List<Department>();
      }
    } catch (e) {
      return List<Department>();
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
    _dropDownMenuDepartment();
    getUsers(_myState).then((historycin) {
      if (mounted)
        setState(() {
          _users = historycin;
          // print(_historycin.length.toString());
          if (_users.length == 0) {
            // showAlertNullData();
            _loading = false;
          } else {
            max = _users.length;
            if (_users.length > 10) {
              _users = List.generate(10, (index) => _users[index]);
            } else {
              _users = historycin;
            }
            min = _users.length;
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
        getUsers(_myState).then((historycin) {
          if (mounted)
            setState(() {
              _users = historycin;
              _users.add(_users[i]);
              _users.length = max;
              _loading = false;
              if (_users.isNotEmpty) {
                return _users.elementAt(0);
              }
            });
        });
      }
      if (_users.length == max) {
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
        title: Text(_loading ? 'กำลังโหลด...' : "รายงานแผนก"),
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
              Container(
                padding: EdgeInsets.only(right: 15, top: 5),
                color: Colors.white,
                child: Expanded(
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        value: _myState,
                        iconSize: 30,
                        icon: (null),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                        hint: Text('เลือกแผนก'),
                        onChanged: (String newValue) {
                          setState(() {
                            _myState = newValue;
                            // _myCity;
                            // _getCitiesList();
                            // getUsers(_myState);
                            // print(_myState);
                          });
                        },
                        items: _department?.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item.dmname),
                                value: item.departmentid.toString(),
                              );
                            })?.toList() ??
                            [],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 2,
              ),
              RaisedButton(
                  child: Text("ค้นหา"),
                  onPressed: () async {
                    // getHistoryBetweenCheckin(_startDate,_endDate);
                    if (mounted) {
                      setState(() {
                        selected = true;
                        _loading = true;
                        _timer =
                            new Timer.periodic(Duration(seconds: 3), (timer) {
                          getUsers(_myState).then((historycin) {
                            if (mounted)
                              setState(() {
                                _users = historycin;
                                // print(_historycin.length.toString());
                                if (_users.length == 0) {
                                  // showAlertNullData();
                                  _loading = false;
                                } else {
                                  max = _users.length;
                                  if (_users.length > 10) {
                                    _users = List.generate(
                                        10, (index) => _users[index]);
                                  } else {
                                    _users = historycin;
                                  }
                                  min = _users.length;
                                  _scrollController.addListener(() {
                                    if (_scrollController.position.pixels ==
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
              // SizedBox(height: 20,),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView(
                  children: [
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
    );
  }

  Widget _showJsondata() => new RefreshIndicator(
        child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          itemCount: null == _users ? 0 : _users.length + 1,
          itemExtent: 70,
          itemBuilder: (context, index) {
            if (_users.length == 0) {
              return Center(
                child: Text(
                  "ไม่มีข้อมูล",
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              );
            } else {
              if (index == _users.length && _users.length > 10 && index > 10) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white70,
                ));
              } else if (index == _users.length &&
                  _users.length <= 10 &&
                  index <= 10) {
                return Center(child: Text(""));
              }
            }
            // New _new[index] = _new[index];
            cid = _users[index].toString();
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
                            SizedBox(
                              height: 2,
                            ),
                            Text("รหัสพนักงาน : " + _users[index].id,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700)),
                            Text(
                              "ชื่อ - นามสกุล : " + _users[index].name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700),
                            ),
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
          getUsers(_myState).then((checkins) {
            if (mounted)
              setState(() {
                _users = checkins;
                max = _users.length;
                // _new = List.generate(10, (index) => _new[index]);
                min = _users.length;
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

  _dropDownMenuDepartment() async {
    _department = await getDepartments();
    _dropdownMenuDepartmentItems =
        _loading ? _buildDropdownMenuCategoryItems(_department) : List();
    _selectedDepartment = _dropdownMenuDepartmentItems[0].value;
    setState(() {
      _loading = false;
    });
  }

  List<DropdownMenuItem<Department>> _buildDropdownMenuCategoryItems(
      List depatments) {
    List<DropdownMenuItem<Department>> items = List();
    for (Department d in depatments) {
      items.add(
        DropdownMenuItem(
          value: d,
          child: Text(d.dmname),
        ),
      );
    }
    return items;
  }
}
