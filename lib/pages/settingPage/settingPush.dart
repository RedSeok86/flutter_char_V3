import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:papucon/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SettingPush extends StatefulWidget {
  const SettingPush({Key key}) : super(key: key);

  @override
  _SettingPushState createState() => _SettingPushState();
}

class _SettingPushState extends State<SettingPush> {
  bool isSwitched = true;
  SharedPreferences prefs;
  bool isSwitchedFT = true;

  bool push_bool = true;

  void initState() {
    super.initState();
    getSwitchState();
  }

  getSwitchValues() async {
    isSwitchedFT = await getSwitchState();
    setState(() {});
  }

  Future<bool> saveSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("push_bool", value);
    print('Switch Value saved $value');
    return prefs.setBool("push_bool", value);
  }

  Future<bool> getSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSwitchedFT = prefs.getBool("push_bool") ?? true;
    print('default value $isSwitchedFT');

    return isSwitchedFT;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Container(
      color: const Color(0xFFf2f3f6),
      padding: EdgeInsets.only(top: 23.0),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text('알림',
                    style:
                        TextStyle(color: Colors.black, fontSize: 23, height: 1))
                .tr(),
            toolbarHeight: 60,
            backgroundColor: Color(0xFFf2f3f6),
            elevation: 0.0,
            bottom: PreferredSize(
              child: SizedBox(height: 10),
            ),
            bottomOpacity: 0.1,
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
          ),
          body: Container(
            color: Color(0xFFf2f3f6),
            child: FutureBuilder(
                future: getSwitchState(),
                builder: (context, snapshot) {
                  print(snapshot.data.toString());
                  if (!snapshot.hasData) Loading();
                  bool push_status = true;
                  if (snapshot.data != null) push_status = snapshot.data;
                  return Container(
                    //color: Color(0xFFFFFFFF),
//                      height: MediaQuery.of(context).size.height/6.4,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        Neumorphic(
                          margin:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          style: NeumorphicStyle(
                            border: NeumorphicBorder(
                                width: 0.5, color: Color(0xFFf0f0f0)),
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(20)),
                            shadowDarkColor: Colors.black.withOpacity(0.5),
                            shadowLightColor: Colors.white,
                            depth: 3,
                            intensity: 0.7,
                            color: Colors.white,
                          ),
                          child: SwitchListTile(
                            title: Text('전체 PUSH 설정').tr(),
                            value: push_status,
                            onChanged: (value) {
                              setState(() {
                                isSwitchedFT = value;
                                saveSwitchState(value);
                                print('Saved state is $isSwitchedFT');
                                //switch works
                              });
                              print(isSwitchedFT);
                            },
                            activeTrackColor: MyColors.primaryColor,
                            activeColor: Colors.white,
                          ),
                        ),

//                    ListTile(
//                      title: Text('프로필별 알림 설정').tr(),
//                      trailing: Icon(Icons.refresh),
//                      onTap: () {},
//                    ),
                      ],
                    ),
                  );
                }),
          )),
    );
  }
}
