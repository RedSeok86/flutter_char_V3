import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingTheme extends StatefulWidget {
  const SettingTheme({Key key}) : super(key: key);

  @override
  _SettingThemeState createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      appBar: AppBar(
        title: Text('테마').tr(),
        backgroundColor: MyColors.primaryColor,
        elevation: 0.0,
      ),
      body: Container(
//              color: Color(0xFFFFFFFF),
//              height: MediaQuery.of(context).size.height / 7.5,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('밝은 모드').tr(),
            ),
            ListTile(
              title: Text('어두운 모드').tr(),
            ),
            ListTile(
              title: Text('시스템설정과 같이').tr(),
            ),
          ],
        ),
      ),
    );
  }
}
