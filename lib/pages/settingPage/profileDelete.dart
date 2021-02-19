import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/pages/home_page.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class profileDelete extends StatefulWidget {
  const profileDelete({Key key}) : super(key: key);

  @override
  _profileDeleteState createState() => _profileDeleteState();
}

class _profileDeleteState extends State<profileDelete> {
  SharedPreferences prefs;
  String uid;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  Future<String> getUID() async {
    prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';
    return uid;
  }

  Future<void> DelProfile(String pid) {
    String result;
    Firestore.instance.collection('Profile').document(pid).delete();
    Firestore.instance
        .collection('Users')
        .document(uid)
        .collection('profile')
        .document(pid)
        .delete();
    print('pid $pid');

    Timer(Duration(milliseconds: 500), () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (Route<dynamic> route) => false
      );
    });
  }

  Future<void> _asyncConfirmDialog(BuildContext context, String pid) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('프로필 삭제').tr(),
          content: Text('정말 프로필을 삭제하시겠습니까?').tr(),
          actions: <Widget>[
            FlatButton(
              child: Text('취소').tr(),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('동의').tr(),
              onPressed: () {
                DelProfile(pid);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

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
            title: Text('프로필 삭제',
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
            child: Form(
              child: Column(children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(25, 15, 0, 10),
                        child: Text('삭제하고자 하는 프로필을 선택하세요.',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold))
                            .tr(),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getUID(),
                    builder: (context, future_data) {
                      if (!future_data.hasData) return Loading();
                      return StreamBuilder(
                        stream: Firestore.instance
                          .collection('Profile')
                          .where('uid', isEqualTo: future_data.data.toString())
                          .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Loading();
                          print('uid $uid');
                          var ProfileList = snapshot.data.documents;
                          return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: ProfileList.length,
                              itemBuilder: (context, index) {
                                return Neumorphic(
                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  style: NeumorphicStyle(
                                    border: NeumorphicBorder(
                                      width: 0.5,
                                      color: Color(0xFFf0f0f0)
                                    ),
                                    shape: NeumorphicShape.flat,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                                    shadowDarkColor: Colors.black.withOpacity(0.5),
                                    shadowLightColor: Colors.white,
                                    depth: 3,
                                    intensity: 0.7,
                                    color: Colors.white,
                                  ),
                                  child: Container(
                                    color: Colors.white70,
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      leading: ProfileList[index]['photoUrl'] == null
                                        ? CircleAvatar(
                                          foregroundColor: Colors.transparent,
                                          backgroundImage: AssetImage('assets/img/noface.png'),
                                        )
                                        : CircleAvatar(
                                          backgroundImage: NetworkImage(ProfileList[index]['photoUrl']),
                                        ),
                                      title: Text(ProfileList[index]['id']),
                                      onTap: () {
                                        if (ProfileList.length <= 1) {
                                          Fluttertoast.showToast(
                                            msg: '최소 1개 이상의 프로필은 있어야 합니다.'.tr(),
                                            backgroundColor: MyColors.primaryColor,
                                            textColor: Colors.white
                                          );

                                          Timer(Duration(milliseconds: 500), () {
                                            Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(builder: (_) => const HomePage()),
                                                    (Route<dynamic> route) => false
                                            );
                                          });
                                        } else {
                                          if(Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid == ProfileList[index]['pid']) {
                                            Fluttertoast.showToast(
                                                msg: '현재 접속중인 프로필은\n삭제가 불가능합니다.'.tr(),
                                                backgroundColor: MyColors.primaryColor,
                                                textColor: Colors.white
                                            ).then((value) => {
                                              Timer(Duration(milliseconds: 300), () {
                                                Navigator.of(context).pushAndRemoveUntil(
                                                    MaterialPageRoute(builder: (_) => const HomePage()),
                                                        (Route<dynamic> route) => false
                                                );
                                              })
                                            });
                                          } else {
                                            _asyncConfirmDialog(context, ProfileList[index]['pid']);
                                          }
                                        }
                                      },
                                    )
                                  )
                                );
                              }
                            );
                          }
                        );
                      }
                    ),

/*
                Container(
                  child: ListTile(
                    title: Text('확인페이지',style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => profileDeleteTwo()));
                    },
                  ),
                ),*/
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }
}
