import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_query_firestore/multi_query_firestore.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/util/image.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';
import 'package:easy_localization/easy_localization.dart';

class InvitePage extends StatefulWidget {
  @override
  _InvitePageStat createState() => _InvitePageStat();
}

class _InvitePageStat extends State<InvitePage> {
  ImagesUtil img = new ImagesUtil();

  String mypid;
  DBHelper db = DBHelper();
  List<String> withUser = List<String>();
  bool actionVisibility = false;
  List<bool> _checkProfile = List.filled(50, false);
  List<String> firendsList = List<String>();

  void initState() {
    mypid =
        Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid;
    super.initState();
  }

  String createChat(String myPid, List pid) {
    final collMessage = Firestore.instance.collection('Room');
    DocumentReference docMessage = collMessage.document();

    var rid = docMessage.documentID;

    List<String> exitUser = [];
//    pid.add(myPid);
    var _roomData = {
      'rid': rid,
      'createTime': FieldValue.serverTimestamp(),
      'actionTime': FieldValue.serverTimestamp(),
      'user': pid,
      'exitUser': exitUser
    };

    docMessage.setData(_roomData).then((data) async {
      docMessage.collection('user').add({
        'user': pid,
      });
    });

    return rid;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Platform.isIOS ? const Color(0xFFf2f3f6) : null,
//      padding: Platform.isIOS ? null : EdgeInsets.only(top: statusBarHeight),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: EdgeInsets.only(top: 10),
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            '그룹채팅방 초대',
            style: TextStyle(color: Colors.black, fontSize: 23, height: 1.6)
          ).tr(),
          toolbarHeight: 70,
          brightness: Brightness.light,
          backgroundColor: Color(0xFFf2f3f6),
          elevation: 0.0,
          bottom: PreferredSize(
            child: SizedBox(height: 10),
          ),
          bottomOpacity: 0.1,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          actions: <Widget>[
            Visibility(
              visible: actionVisibility,
              child: FlatButton(
                  child: Text(
                    '확인',
                    style: TextStyle(color: Color(0xFFd0393e), fontWeight: FontWeight.bold),
                  ).tr(),
                  onPressed: () {
                    print(withUser.toString());
                    if(withUser.contains(Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid) == false) {
                      withUser.add(Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid);
                    }
                    var rId = createChat(mypid, withUser);
                    //print('rid : $rId');
                    db.getProfileList(withUser).then((value) {
                      print('invite people : $value');
                      Map<String, dynamic> chatInfo = {
                        'rId': rId,
                        'nowProfile': Provider.of<nowProfile>(context, listen: false).getMyProfile(),
                        'withUser': value
                      };
                      Navigator.of(context).pop();  // 그룹 채팅 초대할 경우 그룹초대 페이지를 닫아주기 위한것
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(chatInfo: chatInfo)));  // 채팅방으로 페이지 이동
                    });

                  }),
            )
          ],
        ),
        body: Container(
          color: Color(0xFFf2f3f6),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19.0),
                topRight: Radius.circular(19.0),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(3, 3),
                  blurRadius: 6
                ),
                BoxShadow(
                  color: Colors.white12,
                  offset: Offset(-3, -3),
                  blurRadius: 6
                )
              ]
            ),
            child: StreamBuilder(
//                stream: db.getFirend(mypid).asStream(),
//                builder: (context, getFirendList) {
//                  if (!getFirendList.hasData) Loading();
//                  if (getFirendList.data == null) Loading();
//                  return ListView.builder(
//                      physics: BouncingScrollPhysics(),
//                      itemCount: getFirendList.data.length,
//                      itemBuilder: (BuildContext context, int index) {
//                        Profile profile = getFirendList.data[index];
//                        print(getFirendList.data[index].toString());
//                        return CheckboxListTile(
//                          title: Text(profile.nickname),
//                          //앞부분에 체크박수를 두어 체크박스업룰 누르게 되면 해당 index의 것이 체크가 될수 있도록 해주는 작
//                          secondary: (profile.photoUrl.toString() == 'null')
//                              ? CircleAvatar(
//                                  backgroundImage:
//                                      AssetImage('assets/img/noface.png'),
//                                )
//                              : CircleAvatar(
//                                  backgroundImage: NetworkImage(
//                                      img.getThumb(profile.photoUrl))),
//                          value: _checkProfile[index],
//                          activeColor: Colors.black,
//                          onChanged: (bool value) {
//                            setState(() {
//                              if (value) {
//                                actionVisibility = withUser.length <= 0 ? false : true;
//                                print(profile.pid);
//
//                                withUser.add(getFirendList.data[index].pid);
//                              } else {
//                                withUser.remove(getFirendList.data[index].pid);
//
//                                if(withUser.length <= 1) {
//                                  actionVisibility = false;
//                                }
//                              }
//                              _checkProfile[index] = value;
//                            });
//                          },
//                        );
//                      });
              stream: Firestore.instance
                  .collection('Profile')
                  .document(Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid)
                  .collection('firend')
                  .where('status', isEqualTo: 'accept')
                  .snapshots(),
              builder: (context, getList) {
                if (!getList.hasData) {
                  return const Loading();
                }
                print('part 1');
                firendsList = [];
                getList.data.documents.forEach((doc) {
                  //친구 리스트 Pid 임시 저장
                  firendsList.add(doc['firendPid']);
                });
                var chunks = [];
                for (var i = 0; i < firendsList.length; i += 10) {
                  chunks.add(firendsList.sublist(
                  i, i + 10 > firendsList.length ? firendsList.length : i + 10));
                }
                List<Query> doc_query = List<Query>();
                chunks.forEach((element) {
                  doc_query.add(Firestore.instance
                    .collection('Profile')
                    .where('pid', whereIn: element)
                    .orderBy('nickname'));
                });
                if (firendsList.toString() == '[]')
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(19.0),
                      topRight: Radius.circular(19.0),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(3, 3),
                        blurRadius: 6
                      ),
                      BoxShadow(
                        color: Colors.white12,
                        offset: Offset(-3, -3),
                        blurRadius: 6
                      )
                    ]
                  ),
                  child: Center(
                    child: Text('친구를 추가해주세요.').tr(),
                  ),
                );
                else {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(19.0),
                        topRight: Radius.circular(19.0),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(3, 3),
                          blurRadius: 6
                        ),
                        BoxShadow(
                          color: Colors.white12,
                          offset: Offset(-3, -3),
                          blurRadius: 6
                        )
                      ]
                    ),
                    child: StreamBuilder(
                      stream: MultiQueryFirestore(list: doc_query).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) return Loading();
                        return Stack(
                          children: <Widget>[
                            Container(
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return CheckboxListTile(
                                    title: Text(snapshot.data.documents[index]['nickname']),
                                    //앞부분에 체크박수를 두어 체크박스업룰 누르게 되면 해당 index의 것이 체크가 될수 있도록 해주는 작
                                    secondary: (snapshot.data.documents[index]['photoUrl'].toString() == 'null')
                                      ? CircleAvatar(backgroundImage: AssetImage('assets/img/noface.png'),)
                                      : CircleAvatar(backgroundImage: NetworkImage(img.getThumb(snapshot.data.documents[index]['photoUrl']))),
                                      value: _checkProfile[index],
                                      activeColor: Colors.black,
                                      onChanged: (bool value) {
                                        setState(() {
                                          if (value) {
                                            actionVisibility = withUser.length <= 0 ? false : true;
                                            print(snapshot.data.documents[index]['pid']);
                                            withUser.add(snapshot.data.documents[index]['pid']);
                                          } else {
                                            withUser.remove(snapshot.data.documents[index]['pid']);
                                            if(withUser.length <= 1) {
                                              actionVisibility = false;
                                            }
                                          }
                                          _checkProfile[index] = value;
                                        });
                                      },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
              }
            ),
          ),
        ),
      )
    );
  }
}
