import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:papucon/pages/settingPage/helps/faqs/faq.dart';
import 'package:papucon/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'helps/contact/contact.dart';
import 'helps/notices/notice.dart';
import 'helps/privacy/privacy_policy.dart';
import 'helps/terms/terms.dart';
import 'package:papucon/pages/settingPage/helps/security/security.dart';

class SettingHelpe extends StatefulWidget {
  const SettingHelpe({Key key}) : super(key: key);

  @override
  _SettingHelpeState createState() => _SettingHelpeState();
}

class _SettingHelpeState extends State<SettingHelpe> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Container(
      color: const Color(0xFFf2f3f6),
      padding: EdgeInsets.only(top: 23.0),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text('도움말',
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
          child: Stack(
            children: [
              Container(
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
                        child: ListTile(
                          title: Text('FAQ').tr(),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingFaq()));
                          },
                        )),
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
                        child: ListTile(
                          title: Text('공지 사항').tr(),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NoticeQuestion()));
                          },
                        )),
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
                        child: ListTile(
                          title: Text('이용 약관').tr(),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TermsAndConditions()));
                          },
                        )),
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
                        child: ListTile(
                          title: Text('개인정보 보호정책').tr(),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PrivacyPolicy()));
                          },
                        )),
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
                        child: ListTile(
                          title: Text('정보보안 기본정책').tr(),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BasicSecurityData()));
                          },
                        )),
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
                        child: ListTile(
                          title: Text('문의하기').tr(),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContactToUs()));
                          },
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
