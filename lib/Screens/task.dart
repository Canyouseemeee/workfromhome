import 'package:flutter/material.dart';
import 'package:workfromhome/Other/constants.dart';

class Task extends StatefulWidget {
  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "WFH",
              )
            ],
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
        body: Container(
          child: Text("Task"),
        ),
      ),
    );
  }
}

