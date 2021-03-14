
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Screens/checkin_work.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        body: Center(
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
                          color: Colors.green,
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Checkinwork()),
                            );
                            //     .then((value) {
                            //   setState(() {
                            //     // _handleRefresh();
                            //   });
                            // });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30.0),
                          ),
                          child: Text("เช็คอินเข้างาน"),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: RaisedButton(
                          color: Colors.blue,
                          onPressed: (){},
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30.0),
                          ),
                          child: Text("ดูประวัติเช็คอินเข้างาน"),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
        ),
      ),
    );
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
