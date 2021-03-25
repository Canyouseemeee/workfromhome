import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Screens/checkin_work.dart';
import 'package:workfromhome/Screens/historycheckin.dart';
import 'package:workfromhome/Screens/reportdepartment.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading;
  var usertype;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;
    _handleRefresh();
    ut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:
              Text(
                "WFH",
              ),
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
        body: (_loading
            ? new Center(
                child: new CircularProgressIndicator(
                backgroundColor: Colors.pinkAccent,
              ))
            : Center(
                child: Container(
                  // alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        _logo(),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: RaisedButton(
                            color: Color(0xFFFF9C68),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Checkinwork()),
                              ).then((value) {
                                setState(() {
                                  _handleRefresh();
                                });
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text("เช็คอินเข้างาน",style: TextStyle(fontSize: 16),),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: RaisedButton(
                            color: Color(0xFFFF9C68),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HistoryCheckin()),
                              ).then((value) {
                                setState(() {
                                  _handleRefresh();
                                });
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text("ดูประวัติเช็คอินเข้างาน",style: TextStyle(fontSize: 16),),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        ShowButton2(),
                      ],
                    ),
                  ),
                ),
              )
        ),
      ),
    );
  }

  Future<void> ut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      usertype = sharedPreferences.getString('usertype');
    });
    // print(usertype);
    return usertype;
  }

  ShowButton2() {
    if(usertype == 'ADMIN'){
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.07,
        child: RaisedButton(
          color: Color(0xFFFF9C68),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReprotDepartment()),
            ).then((value) {
              setState(() {
                _handleRefresh();
              });
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text("รายงานแผนก",style: TextStyle(fontSize: 16),),
        ),
      );
    }else if(usertype == 'SUPERUSER'){
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.07,
        child: RaisedButton(
          color: Color(0xFFFF9C68),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReprotDepartment()),
            ).then((value) {
              setState(() {
                _handleRefresh();
              });
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text("รายงานแผนก",style: TextStyle(fontSize: 16),),
        ),
      );
    }else if(usertype == 'USER'){
      return Container();
    }
  }

  Future<Null> _handleRefresh() async {
    Completer<Null> completer = new Completer<Null>();

    new Future.delayed(new Duration(milliseconds: 2)).then((_) {
      completer.complete();
      if (mounted)
        setState(() {
          _loading = false;
        });
    });
    return null;
  }

  Widget _logo() => Padding(
        padding: EdgeInsets.only(top: 10),
        child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            width: MediaQuery.of(context).size.width * 0.8,
            image:
                "https://www2.plu.ac.th/wp-content/uploads/2020/03/WorkFromHome2.jpg"),
      );
}
