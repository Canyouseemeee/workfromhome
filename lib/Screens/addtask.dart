import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:workfromhome/Models/Departments.dart';
import 'package:workfromhome/Models/Users.dart';
import 'package:workfromhome/Other/components/text_field_container.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:http/http.dart' as http;

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController taskSub = TextEditingController();
  TextEditingController taskDes = TextEditingController();
  TextEditingController taskDue = TextEditingController();
  bool _loading;

  List<Users> _users;
  bool usersLoading = true;
  List<DropdownMenuItem<Users>> _dropdownMenuUsersItems;
  Users _selectedUsers;

  DateTime newDateTime;
  var timePicked;
  final df = new DateFormat('dd-MM-yyyy HH:mm a');
  var due;
  String _myState;
  String _myCity;
  List<Department> _department;
  List<DropdownMenuItem<Department>> _dropdownMenuDepartmentItems;
  Department _selectedDepartment;

  static Future<List<Users>> getUsers(String _myState) async {
    const String url = Apiurl + "/api/getuser";
    Map data = {
      'departmentid': _myState,
    };
    try {
      final response = await http.post(url,body: data);
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
          final List<Department> departments = departmentFromJson(response.body);
          return departments;
        }
      } else {
        return List<Department>();
      }
    } catch (e) {
      return List<Department>();
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
    taskDue.text = ndt.toString().substring(0, 10) +
        " " +
        timePicked.toString().substring(10, timePicked.toString().length - 1) +
        ":00";
    return taskDue.text;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = false;
    taskSub.text = "";
    taskDes.text = "";
    taskDue.text = "กรุณาเลือกวันที่และเวลาที่จะส่งงาน";
    _dropDownMenuDepartment();
    // datepicker();
  }

  postTask(String _myState,String _myCity) async {
    // print(DateTime.parse(due).toString());
    // print(_myState);
    // print(_myCity);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id;
    var jsonData = null;
    setState(() {
      id = sharedPreferences.getString("userid");
    });
    if (sharedPreferences.getString("token") != null) {
      Map data = {
        'userid': id,
        'subject': taskSub.text,
        'description': taskDes.text,
        'assignment': _myCity,
        'departmentid': _myState,
        'duedate': DateTime.parse(due).toString(),
      };
      var response = await http.post(Apiurl + "/api/posttask/", body: data);
      if (response.statusCode == 200) {
        jsonData = json.decode(response.body);
        // print(jsonData);
        if (jsonData != null) {
          setState(() {
            _loading = false;
          });
          Toast.show("Add Task Successful.", context,
              gravity: Toast.CENTER, duration: 2);
          Navigator.pop(context, true);
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          //         (Route<dynamic> route) => false);
        }
      } else {
        // _showAlertDialog();
        print(response.body);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_loading ? 'Loading...' : "Task [Add]"),
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
          : _formTaskAdd()),
      backgroundColor: kPrimaryColor,
    );
  }

  _formTaskAdd() {
    return Card(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Row(children: [
                Text("SUBJECT: "),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.only(left: 40.0),
                      child: TextFormField(
                        controller: taskSub,
                        decoration: InputDecoration(
                          // labelText: "Subject",
                          hintText: "Enter Subject",
                        ),
                        validator: (value) {
                          if ((value == null) || (value.isEmpty)) {
                            return "This field is not empty.";
                          } else if (value.length <= 5) {
                            return "This field must be equal 5 characters.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ]),
              Row(children: [
                Text("DESCRIPTION: "),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: TextFormField(
                        controller: taskDes,
                        decoration: InputDecoration(
                          // labelText: "Description",
                          hintText: "Enter Description",
                        ),
                        maxLength: 500,
                        validator: (value) {
                          if ((value == null) || (value.isEmpty)) {
                            return "This field is not empty.";
                          } else if (value.length <= 5) {
                            return "This field must be equal 5 characters.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ]),
              Row(
                children: [
                  Text("DUEDATE: "),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: taskDue,
                        decoration: InputDecoration(
                            // labelText: "DueDate",
                            // hintText: "Enter Quantity",
                            icon: Icon(Icons.calendar_today)),
                        onTap: () {
                          datepicker();
                        },
                        readOnly: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              // Row(
              //   children: <Widget>[
              //     SizedBox(width: 1.0),
              //     Text(
              //       "ASSIGNMENT: ",
              //     ),
              //     SizedBox(width: 30.0),
              //     DropdownButton(
              //       value: _selectedUsers,
              //       items: _dropdownMenuUsersItems,
              //       onChanged: _onChangeDropdownItem,
              //     ),
              //   ],
              // ),
              Container(
                padding: EdgeInsets.only( right: 15, top: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("DEPARTMENT: "),
                    Expanded(
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
                            hint: Text('Select Department'),
                            onChanged: (String newValue) {
                              setState(() {
                                _myState = newValue;
                                // _getCitiesList();
                                // getUsers(_myState);
                                // print(_myState);
                                _dropDownMenuUsers();
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only( right: 15, top: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("ASSIGNMENT: "),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: _myCity,
                            iconSize: 30,
                            icon: (null),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            hint: Text('Select Assignment'),
                            onChanged: (String newValue) {
                              setState(() {
                                _myCity = newValue;
                                // _getCitiesList();
                                // print(_myState);
                              });
                            },
                            items: _users?.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item.name),
                                value: item.id.toString(),
                              );
                            })?.toList() ??
                                [],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: () => {
                      if (_formKey.currentState.validate())
                        {
                          postTask(_myState,_myCity)
                        }
                    },
                  ),
                  SizedBox(width: 20.0),
                  RaisedButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dropDownMenuDepartment() async {
    _department = await getDepartments();
    _dropdownMenuDepartmentItems =
        usersLoading ? _buildDropdownMenuCategoryItems(_department) : List();
    _selectedDepartment = _dropdownMenuDepartmentItems[0].value;
    setState(() {
      usersLoading = false;
      _loading = false;
    });
  }

  List<DropdownMenuItem<Department>> _buildDropdownMenuCategoryItems(List depatments) {
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

  _dropDownMenuUsers() async {
    _users = await getUsers(_myState);
    _dropdownMenuUsersItems =
    usersLoading ? _buildDropdownMenuUsersItems(_users) : List();
    // _selectedUsers = _dropdownMenuUsersItems[0].value;
    setState(() {
      usersLoading = false;
      _loading = false;
    });
  }

  List<DropdownMenuItem<Users>> _buildDropdownMenuUsersItems(List users) {
    List<DropdownMenuItem<Users>> items = List();
    for (Users u in users) {
      items.add(
        DropdownMenuItem(
          value: u,
          child: Text(u.name),
        ),
      );
    }
    return items;
  }

  // _onChangeDropdownItem(Users selectedUsers) {
  //   setState(() {
  //     _selectedUsers = selectedUsers;
  //   });
  // }

}
