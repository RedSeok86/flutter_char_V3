import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDel extends StatefulWidget {
  @override
  _AccountDelState createState() => _AccountDelState();
}

class _AccountDelState extends State<AccountDel> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var isChecked = false;
  SharedPreferences prefs;
  String uid = '';
  DBHelper db = new DBHelper();

  void initState() {
    getUID();
    super.initState();
  }

  Future<void> _delUser() async {
    print('uid :$uid');
    var res =
        await Firestore.instance.collection('Users').document(uid).delete();
    return res;
  }

  Future<String> getUID() async {
    prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';
    return uid;
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
            title: Text('회원 탈퇴',
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
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '정말로 탈퇴하시겠습니까?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ).tr(),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '회원 탈퇴를 하시면 계정이 삭제되어 모든 프로필, \n친구목록, 대화내용이 영구적으로 삭제됩니다.',
                        style: TextStyle(fontSize: 13),
                      ).tr(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '모든 내용은 한번 삭제되면 복구가 불가능 합니다.',
                        style:
                            TextStyle(color: Color(0xFFd50000), fontSize: 13),
                      ).tr(),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              16,
                                          child: RaisedButton(
                                            elevation: 0,
                                            color: Color(0xff3c3c3c),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                            ),
                                            child: Text(
                                              '취소',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ).tr(),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 20),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.2,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              16,
                                                      child: RaisedButton(
                                                        elevation: 0,
                                                        color:
                                                            Color(0xffffffff),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          30)),
                                                          side: BorderSide(
                                                              color: Color(
                                                                  0xFFd50000)),
                                                        ),
                                                        child: Text(
                                                          '탈퇴하기',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xFFd50000),
                                                          ),
                                                        ).tr(),
                                                        onPressed: () {
//                                                          db.dropProfileTable();
//                                                          _delUser().then(
//                                                                  (value) => loginStore
//                                                                  .signOut(
//                                                                  context));
                                                          showAlertDialog(context);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원탈퇴').tr(),
          content:
              Text("회원 탈퇴시 모든 정보가 삭제되며 삭제된 정보는 복구할 수 없습니다. 정말 탈퇴하시겠습니까?").tr(),
          actions: <Widget>[
            RaisedButton(
              child: Text('아니오').tr(),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Consumer<LoginStore>(builder: (_, loginStore, __) {
              return RaisedButton(
                child: Text('탈퇴하기').tr(),
                onPressed: () {
                  _delUser();
                  db.dropProfileTable();
                  loginStore.signOut(context);
                },
              );
            }),
          ],
        );
      },
    );

    scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("Result: $result"),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: "Done",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }
}

//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:papucon/pages/settingPage/accountDelSecond.dart';
//import 'package:papucon/pages/settingPage/accountDel_T.dart';
//import 'package:papucon/stores/login_store.dart';
//import 'package:papucon/theme.dart';
//import 'package:provider/provider.dart';
//import 'package:easy_localization/easy_localization.dart';
//
//
//
//class accountDel extends StatefulWidget {
//  const accountDel({Key key}) : super(key: key);
//
//  @override
//  _accountDelState createState() => _accountDelState();
//}
//class _accountDelState extends State<accountDel> {
//
//  @override
//  Widget build(BuildContext context) {
//    return Consumer<LoginStore>(
//        builder: (_, loginStore, __) {
//          return Scaffold(
//            appBar: AppBar(
//              title: Text('회원 탈퇴').tr(),
//              backgroundColor: MyColors.primaryColor,
//              elevation: 0.0,
//            ),
//            body: Container(
//              child: Padding(
//                padding: const EdgeInsets.only(top: 80),
//                child: Column(
//                  children: <Widget>[
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Text('현재 등록되어 있는 이메일이 없습니다.',style: TextStyle(fontSize: 16,),).tr(),
//                        ],
//                      ),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Text('이메일을 먼저 등록해 주세요',style: TextStyle(fontSize: 16,)).tr(),
//                      ],
//                    ),
//                    Container(
//                      child:Padding(
//                        padding: const EdgeInsets.only(top:20),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Container(
//                              width: MediaQuery.of(context).size.width / 1.3,
//                              height: MediaQuery.of(context).size.height / 16,
//                              child: RaisedButton(
//
//                                color: Color(0xff3c3c3c),
//                                shape: const RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.all(Radius.circular(3)),
//                                ),
//                                child: Text('이메일 등록하러 가기',style: TextStyle(fontSize: 18, color: Colors.white),).tr(),
//                                onPressed: () {
//                                  Navigator.push(context,MaterialPageRoute(builder: (context) => accountDel_T()),
//                                  );
//                                },
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          );
//        }
//    );
//  }
//}
//
//
//
//
