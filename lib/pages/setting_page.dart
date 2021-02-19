import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:papucon/pages/helper.dart';
import 'package:papucon/pages/home_page.dart';
import 'package:papucon/pages/settingPage/parkingService.dart';
import 'package:papucon/pages/settingPage/settingHelpe.dart';
import 'package:papucon/pages/settingPage/settingPush.dart';
import 'package:papucon/pages/settingPage/settingSecurity.dart';
import 'package:papucon/pages/storageBox.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _selectedIndex = 3;

  DBHelper db = DBHelper();

  void _onTabMenu(int index) {
    setState(() {
      debugPrint('Click');
      debugPrint(index.toString());
      if (index == 0) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage()),
            (Route<dynamic> route) => false);
      } else if (index == 1) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage(menuNum: 2)),
            (Route<dynamic> route) => false);
      } else if (index == 2) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => StorageBox()),
            (Route<dynamic> route) => false);
      }
    });
  }

  Widget build_bottom() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: _onTabMenu,
          currentIndex: 3,
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? Image.asset("assets/img/home_red.png",
                      width: 25, height: 25)
                  : Image.asset("assets/img/home.png", width: 25, height: 25),
              title: Text('Home').tr(),
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Image.asset("assets/img/chat_red.png",
                      width: 25, height: 25)
                  : Image.asset("assets/img/chat.png", width: 25, height: 25),
              title: Text('Chat').tr(),
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Image.asset("assets/img/storage_red.png",
                      width: 25, height: 25)
                  : Image.asset("assets/img/storage.png",
                      width: 25, height: 25),
              title: Text('Inbox').tr(),
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Image.asset("assets/img/set_red.png", width: 25, height: 25)
                  : Image.asset("assets/img/set.png", width: 25, height: 25),
              title: Text('Setting').tr(),
            )
          ],
          showSelectedLabels: false,
          //text remove
          showUnselectedLabels: false,
          //text remove
          selectedItemColor: MyColors.primaryColor,
          backgroundColor: Colors.white,
          elevation: 0.0,
          unselectedItemColor: Color.fromARGB(200, 179, 179, 179)),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(builder: (_, loginStore, __) {
      if (Platform.isIOS) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: const Text('설정',
                    style: TextStyle(
                        color: Colors.black, fontSize: 26, height: 0.5))
                .tr(),
            toolbarHeight: 60,
            brightness: Platform.isIOS ? Brightness.light : null,
            backgroundColor: const Color(0xFFf2f3f6),
            elevation: 0.0,
            bottom: PreferredSize(
              child: const SizedBox(height: 10),
            ),
            bottomOpacity: 0.1,
          ),
          body: Container(
            color: Color.fromRGBO(242, 243, 246, 1),
            child: Stack(children: <Widget>[
              Container(
                child: ListView(

                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    children: <Widget>[
                      Neumorphic(
                        margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.local_parking,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('주차 알림 서비스').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ParkingService()));
                            }),
                      ),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.alarm,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('알림').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingPush()));
                            }),
                      ),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.verified_user,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('계정').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingSecurity()));
                            }),
                      ),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.help_outline,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('도움말').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingHelpe()));
                            }),
                      ),
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
                          leading: Neumorphic(
                            padding: EdgeInsets.all(5),
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.concave,
                              depth: 1,
                              intensity: 1,
                              color: Colors.white,
                            ),
                            child: Icon(
                              MdiIcons.doorOpen,
                              color: MyColors.primaryColor,
                            ),
                          ),
                          title:
                              Text('로그아웃', style: TextStyle(color: Colors.red))
                                  .tr(),
                          onTap: () {
                            db.dropProfileTable();
                            loginStore.signOut(context);
                          },
                        ),
                      ),
                    ]),
              ),
            ]),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text('설정',
                    style: TextStyle(
                        color: Colors.black, fontSize: 26, height: 0.5))
                .tr(),
            toolbarHeight: 60,
            backgroundColor: Color(0xFFf2f3f6),
            elevation: 0.0,
            bottom: PreferredSize(
              child: SizedBox(height: 10),
            ),
            bottomOpacity: 0.1,
          ),
          body: Container(
            color: Color.fromRGBO(242, 243, 246, 1),
            child: Stack(children: <Widget>[
              Container(
                child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    children: <Widget>[
                      Neumorphic(
                        margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.local_parking,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('주차 알림 서비스').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ParkingService()));
                            }),
                      ),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.alarm,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('알림').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingPush()));
                            }),
                      ),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.verified_user,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('계정').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingSecurity()));
                            }),
                      ),
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
                            leading: Neumorphic(
                              padding: EdgeInsets.all(5),
                              style: NeumorphicStyle(
                                shape: NeumorphicShape.concave,
                                depth: 1,
                                intensity: 1,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.help_outline,
                                color: MyColors.primaryColor,
                              ),
                            ),
                            title: Text('도움말').tr(),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingHelpe()));
                            }),
                      ),
                     // Neumorphic(
                     //   margin:
                     //   EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                     //   style: NeumorphicStyle(
                     //     border: NeumorphicBorder(
                     //         width: 0.5, color: Color(0xFFf0f0f0)),
                     //     shape: NeumorphicShape.flat,
                     //     boxShape: NeumorphicBoxShape.roundRect(
                     //         BorderRadius.circular(20)),
                     //     shadowDarkColor: Colors.black.withOpacity(0.5),
                     //     shadowLightColor: Colors.white,
                     //     depth: 3,
                     //     intensity: 0.7,
                     //     color: Colors.white,
                     //   ),
                     //   child: ListTile(
                     //       leading: Neumorphic(
                     //         padding: EdgeInsets.all(5),
                     //         style: NeumorphicStyle(
                     //           shape: NeumorphicShape.concave,
                     //           depth: 1,
                     //           intensity: 1,
                     //           color: Colors.white,
                     //         ),
                     //         child: Icon(
                     //           Icons.help_outline,
                     //           color: MyColors.primaryColor,
                     //         ),
                     //       ),
                     //       title: Text('설정페이지').tr(),
                     //       trailing: Icon(Icons.keyboard_arrow_right),
                     //       onTap: () {
                     //         Navigator.push(
                     //             context,
                     //             MaterialPageRoute(
                     //                 builder: (context) => Helper(currentProfile: null)));
                     //       }),
                     // ),
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
                         leading: Neumorphic(
                           padding: EdgeInsets.all(5),
                           style: NeumorphicStyle(
                             shape: NeumorphicShape.concave,
                             depth: 1,
                             intensity: 1,
                             color: Colors.white,
                           ),
                           child: Icon(
                             MdiIcons.doorOpen,
                             color: MyColors.primaryColor,
                           ),
                         ),
                         title:
                             Text('로그아웃', style: TextStyle(color: Colors.red))
                                 .tr(),
                         onTap: () {
                           db.dropProfileTable();
                           loginStore.signOut(context);
                         },
                       ),
                     ),
                    ]),
              ),
            ]),
          ),
        );
      }
    });
  }
}
