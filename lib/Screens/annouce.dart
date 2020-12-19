import 'package:flutter/material.dart';
import 'package:workfromhome/Other/constants.dart';

class Annouce extends StatefulWidget {
  @override
  _AnnouceState createState() => _AnnouceState();
}

class _AnnouceState extends State<Annouce> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Annouce",
              )
            ],
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: kPrimaryColor,
        body: Container(
          child: Text("Annouce"),
        ),
      ),
    );
  }
}
