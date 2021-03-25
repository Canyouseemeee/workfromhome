import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workfromhome/Other/constants.dart';
import 'package:workfromhome/Screens/Login/components/body.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  SharedPreferences sharedPreferences;
  String _username;
  String _name;
  String _department;
  String Url;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _settingsection();
  }

  Future<void> _settingsection() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String username = sharedPreferences.getString("username");
    final String name = sharedPreferences.getString("name");
    final String department = sharedPreferences.getString("department");
    setState(() {
      _username = username;
      _name = name;
      _department = department;
    });
    // print(imageAvatar());
    // print(sharedPreferences.getString("image").toString().substring(9).replaceAll("}]", ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      backgroundColor: Color(0xFF00BFFF),
      body: ListView(
        children: <Widget>[
          Card(
            margin: EdgeInsets.only(top: 30, left: 30, right: 30),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                child: Form(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 30.0,
                                        backgroundImage: Url == null
                                            ? NetworkImage(
                                          // "https://cdn.icon-icons.com/icons2/1674/PNG/512/person_110935.png")
                                            "https://media1.tenor.com/images/82c6e055245fc8fa7381dc887bf14e62/tenor.gif?itemid=12170592")
                                            : NetworkImage('${Url}'),
                                        //     : NetworkImage('${Url}'),
                                        // // backgroundImage: NetworkImage("http://cnmihelpdesk.rama.mahidol.ac.th/storage/"+image),
                                        //
                                        // // child: Image,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 16, right: 16),
                                      child: Text(
                                        "ชื่อผู้ใช้ : "+'${_username}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 16, right: 16),
                                      child: Text(
                                        "ชื่อ-นามสกุล : " +'${_name}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 16, right: 16),
                                      child: Text(
                                        "แผนก : " +'${_department}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // Container(
                                    //   width: MediaQuery.of(context).size.width,
                                    //   height: 40.0,
                                    //   margin: EdgeInsets.only(top: 30),
                                    //   padding: EdgeInsets.symmetric(
                                    //       horizontal: 20.0),
                                    //   child: RaisedButton.icon(
                                    //     color: Colors.amberAccent,
                                    //     onPressed: () {
                                    //       setState(() {
                                    //         // checkVersion();
                                    //       });
                                    //     },
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(5.0),
                                    //     ),
                                    //     icon: Icon(
                                    //       Icons.system_update,
                                    //       color: Colors.white70,
                                    //     ),
                                    //     label: Text(
                                    //       "CheckforUpdate v",
                                    //       // + _version,
                                    //       style:
                                    //           TextStyle(color: Colors.white70),
                                    //     ),
                                    //   ),
                                    // ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 40.0,
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: RaisedButton(
                                        color: Colors.redAccent,
                                        onPressed: () {
                                          setState(() {
                                            _showLogoutAlertDialog();
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          "Logout",
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // backgroundColor: Color(0xFF34558b),

      //Todo setting
      // SettingsList(
      //   sections: [
      //     SettingsSection(
      //       title: 'Section',
      //       tiles: [
      //         SettingsTile(
      //           title: 'Profile',
      //           subtitle: '${_username}',
      //           leading: Icon(Icons.person),
      //           onTap: () {},
      //         ),
      //       ],
      //     ),
      //     SettingsSection(
      //       title: 'Setting',
      //       tiles: [
      //         SettingsTile(
      //           title: 'Logout',
      //           leading: Icon(Icons.exit_to_app),
      //           onTap: () {
      //             _showLogoutAlertDialog();
      //           },
      //         ),
      //       ],
      //     ),
      //     SettingsSection(
      //       title: 'Version '+_version,
      //       tiles: [
      //         SettingsTile(
      //           title: 'Checked Update',
      //           leading: Icon(Icons.info),
      //           onTap: () {
      //             checkVersion();
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }

  void _showLogoutAlertDialog() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("${sharedPreferences.getString("username")} ล็อคเอ้าท์"),
            content: Text("คุณต้องการล็อคเอ้าท์ใช่หรือไม่ ?"),
            actions: [
              FlatButton(
                onPressed: () {
                  sharedPreferences.clear();
                  sharedPreferences.commit();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => Body()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text("ใช่"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ไม่"),
              ),
            ],
          );
        });
  }
}
