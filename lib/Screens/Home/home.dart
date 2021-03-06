import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workfromhome/Other/services/BadgeIcon.dart';
import 'package:workfromhome/Screens/task.dart';
import 'package:workfromhome/Screens/home_page.dart';
import 'package:workfromhome/Screens/menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _tabBarCount = 0;
  List<Widget> pages;
  Widget currantpage;
  int count = 0;
  bool _loading;
  StreamController<int> _countController = StreamController<int>();
  Home home = new Home();
  Task task = new Task();
  Menu menu = new Menu();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages = [home, task, menu];
    currantpage = home;
    // _loading = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Row(
      //    mainAxisAlignment: MainAxisAlignment.center,
      //    children: [
      //      Text(
      //        "WFH",
      //      )
      //    ],
      //  ),
      // ),
      backgroundColor: Color(0xFF00BFFF),
      body: currantpage,
      bottomNavigationBar: RefreshIndicator(
        child: SafeArea(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              // backgroundColor: Color(0xFF34558b),
              selectedItemColor: Color(0xFF00BFFF),
              items: [
                BottomNavigationBarItem(
                  icon: StreamBuilder(
                    initialData: _tabBarCount,
                    stream: _countController.stream,
                    builder: (_, snapshot) => BadgeIcon(
                      icon: Icon(
                        Icons.home,
                      ),
                      badgeCount: snapshot.data,
                    ),
                  ),
                  title: const Text("หน้าแรก"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assistant_photo),
                  title: Text("งาน"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  title: Text("เมนู"),
                ),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  currantpage = pages[index];
                });
              },
            ),
          ),
        ),
        onRefresh: _handleRefresh,
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    Completer<Null> completer = new Completer<Null>();

    new Future.delayed(new Duration(milliseconds: 5)).then((_) {
      completer.complete();
      // setState(() {
      //   _loading = true;
      //   initializing();
      //   Jsondata.getNew().then((_newss) {
      //     setState(() {
      //       _new = _newss;
      //       _loading = false;
      //       if (_new.isNotEmpty) {
      //         return _new.elementAt(0);
      //       }
      //       if (_new.length != 0) {
      //         _tabBarCount = _new.length;
      //         _countController.sink.add(_tabBarCount);
      //       } else {
      //         _tabBarCount = _new.length;
      //         _countController.sink.add(_tabBarCount);
      //       }
      //     });
      //   });
      // });
    });

    return null;
  }
}
