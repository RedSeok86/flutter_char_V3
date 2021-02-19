import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:papucon/pages/settingPage/accountDel.dart';
import 'package:papucon/pages/settingPage/profileDelete.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingSecurity extends StatefulWidget {
  const SettingSecurity({Key key}) : super(key: key);

  @override
  _SettingSecurityState createState() => _SettingSecurityState();
}

class _SettingSecurityState extends State<SettingSecurity> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(builder: (_, loginStore, __) {
      return Container(
        color: const Color(0xFFf2f3f6),
        padding: EdgeInsets.only(top: 23.0),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text('계정',
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
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Neumorphic(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                    child: ListTile(
                      title: Text('프로필 삭제').tr(),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => profileDelete()));
                      },
                    )),
                // Neumorphic(
                //     margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                //     style: NeumorphicStyle(
                //       border: NeumorphicBorder(
                //           width: 0.5, color: Color(0xFFf0f0f0)),
                //       shape: NeumorphicShape.flat,
                //       boxShape: NeumorphicBoxShape.roundRect(
                //           BorderRadius.circular(20)),
                //       shadowDarkColor: Colors.black.withOpacity(0.5),
                //       shadowLightColor: Colors.white,
                //       depth: 3,
                //       intensity: 0.7,
                //       color: Colors.white,
                //     ),
                //     child: ListTile(
                //       title: Text('회원 탈퇴',
                //               style: TextStyle(
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.red))
                //           .tr(),
                //       onTap: () {
                //         Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: (context) => AccountDel()));
                //       },
                //     )),
              ],
            ),
          ),
        ),
      );
    });
  }
}
