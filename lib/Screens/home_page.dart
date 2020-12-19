
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:workfromhome/Other/constants.dart';

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
                 "Home",
               )
             ],
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
                          onPressed: (){},
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
        "https://lh3.googleusercontent.com/proxy/655Uyo1QEUIC4pMiTxratrOddB7f4Mmmtw3Rs7nn93jixlzxbapGlUgzCtK4viBT_Qw9IddixkzU-W6xVfUqPgYL80NpDA9Q12DItYVfDsa4HCXazIt4SFXbxe-SaYXDwHDbx1lE"),
  );
}
