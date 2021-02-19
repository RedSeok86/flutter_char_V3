import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/widgets/loading.dart';
import '../theme.dart';
import 'package:easy_localization/easy_localization.dart';

class FriendFind extends StatefulWidget {
  final MyProfile nowProfile;
  FriendFind({Key key, @required this.nowProfile}) : super(key: key);

  @override
  _FiendFindState createState() => _FiendFindState();
}

class _FiendFindState extends State<FriendFind> {
  bool _firstPress = true;
  bool _showClearButton = false;
  bool searchResultReset = false;
  var search_text = '';
  var documents;
  var resultText = '';
  List<String> exitsFriend = List<String>();
  List<Profile> responsFirends = List<Profile>();

  TextEditingController _firendSearchController = new TextEditingController();
  ScrollController listScrollController = new ScrollController();
  StreamController _streamController;
  Stream _stream;

  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
    //getResponseFirend( Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid);
    _firendSearchController.addListener(() {
      setState(() {
        _showClearButton = _firendSearchController.text.length > 0;
      });
    });
  }

/*
  void getResponseFirend(String myPid) async{
    print('친구 요청');
    var tempList=[];
    await Firestore.instance.collection('Profile')
        .document(myPid)
        .collection('firend')
        .where('status',isEqualTo: 'response')
        .snapshots().listen((event) {
            event.documents.forEach((doc) {
              tempList.add(['firendPid']);
            });
            Firestore.instance.collection('Profile')
                .where('pid',  whereIn:tempList)
                .orderBy('nickname')
                .snapshots().listen((get_profile) {
              setState(() {
                responsFirends=[];
                get_profile.documents.forEach((result) {
                  responsFirends.add(result.data);
                });
              }); // setState(() {
            });
        });
  }


 */
  void acceptFirend(String myPid, String myNickname, String toUid, String pid,
      String friendNickname) {
    Firestore.instance
        .collection('Profile')
        .document(myPid)
        .collection('firend')
        .document(pid)
        .updateData({
      'status': 'accept',
      'acceptTime': FieldValue.serverTimestamp(),
    }).then((value) {
      Firestore.instance
          .collection('Profile')
          .document(pid)
          .collection('firend')
          .document(myPid)
          .updateData({
        'status': 'accept',
        'acceptTime': FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(msg: '친구수락 완료'.tr());

//      Firestore.instance
//      .collection('Friend')
//      .add({
//        'idTo':toUid,
//        'pidTo':pid,
//        'nicknameTo':friendNickname,
//        'idFrom':myPid,
//        'nicknameFrom':myNickname,
//        'acceptTime':FieldValue.serverTimestamp(),
//      });
    }).catchError((err) {
      setState(() {});
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  _search() async {
    DBHelper db = new DBHelper();
    List<Profile> firendList = await db.getFirend(widget.nowProfile.myPid);
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    var queryDocument = await Firestore.instance
        .collection('Profile')
        //.document().collection('profile')
        .where('nickname', isEqualTo: search_text)
        .getDocuments();
    resultText = search_text;
    templist = queryDocument.documents;
    if (_firendSearchController.text == null ||
        _firendSearchController.text.length == 0) {
      _streamController.add(null);
    }

    list = templist.map((DocumentSnapshot docSnapshot) {
      return docSnapshot.data;
    }).toList();
    exitsFriend.clear();
    firendList.forEach((firend) {
      list.forEach((element) {
        if (firend.pid == element['pid']) exitsFriend.add(element['pid']);
      });
    });

    setState(() {
      _streamController.add(list.asMap());
    });
    searchResultReset = false;
  }

  _firendAdd(String myPid, String myNickname, String toUid, String pid,
      String friendNickname) {
    print('내 pid : $myPid');
    print('친구 pid : $pid');
    //나의 친구 리스트
    Firestore.instance
        .collection('Profile')
        .document(myPid)
        .collection('firend')
        .document(pid)
        .setData({
      'myPid': myPid,
      'chatOn': null,
      'firendPid': pid,
      'status': 'request',
      'requestTime': FieldValue.serverTimestamp(),
    }).then((value) {
      Firestore.instance
          .collection('Profile')
          .document(pid)
          .collection('firend')
          .document(myPid)
          .setData({
        'myPid': pid,
        'chatOn': null,
        'firendPid': myPid,
        'status': 'response',
        'responseTime': FieldValue.serverTimestamp(),
      });
      Firestore.instance.collection('Friend').add({
        'idTo': toUid,
        'pidTo': pid,
        'nicknameTo': friendNickname,
        'idFrom': myPid,
        'nicknameFrom': myNickname,
        'acceptTime': FieldValue.serverTimestamp(),
      });
      //Fluttertoast.showToast(msg: "Request success".tr());
    }).catchError((err) {
      setState(() {});
      Fluttertoast.showToast(msg: err.toString());
    });
    _firendSearchController.clear();
  }

  Future<List<Profile>> getProfileDetail(List<String> firenListPid) async {
    //친구 리스트 Pid 임시 저장
    List<Profile> tempProfileList = <Profile>[];

    for (int i = 0; i < firenListPid.length; i++) {
      print('검색 값');
      var Usersnap = await Firestore.instance
          .collection('Profile')
          .document(firenListPid[i])
          .get();
      print(Usersnap.data.toString());
      if (Usersnap.data.toString() != 'null') {
        var insertProfile = Profile(
            Usersnap.data['uid'],
            Usersnap.data['pid'],
            Usersnap.data['id'].toString(),
            Usersnap.data['nickname'],
            Usersnap.data['aboutMe'],
            Usersnap.data['photoUrl'].toString(),
            Usersnap.data['backgroundUrl'].toString());
        tempProfileList.add(insertProfile);
      }
    }
    print('값이 얼마나?');
    print(tempProfileList.length);
    print(tempProfileList[0].id);
    return tempProfileList;
  }

  void requestDel(String firendID) {
    print(firendID);
    Firestore.instance
        .collection('Profile')
        .document(widget.nowProfile.myPid)
        .collection('firend')
        .document(firendID)
        .delete();
    Fluttertoast.showToast(msg: '친구 요청이 삭제되었습니다'.tr());
  }

  Widget _getClearButton() {
    if (!_showClearButton) {
      return null;
    }
    return IconButton(
      padding: EdgeInsets.all(0.0),
      onPressed: () => _firendSearchController.clear(),
      icon: Icon(Icons.cancel, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
        backgroundColor: Color(0xFFf2f3f6),
        appBar: AppBar(
          title: Text(
            "친구추가",
            style: TextStyle(color: Colors.black),
          ).tr(),
          brightness: Platform.isIOS ? Brightness.light : null,
          toolbarHeight: 110,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Color(0xFFf2f3f6),
          elevation: 0.0,
          actions: <Widget>[
//                IconButton(
//                  icon: Icon(
//                    MdiIcons.qrcodeScan,
//                    color: Colors.white,
//                  ),
//                  onPressed: (){
//
//                  },
//                ),
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(49.0),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 30,
                        margin:
                            EdgeInsets.only(left: 16.0, bottom: 9.0, top: 9.0),
                        child: TextFormField(
                          controller: _firendSearchController,
                          decoration: InputDecoration(
                              suffixIcon: _getClearButton(),
                              hintText: '닉네임 검색'.tr(),
                              hintStyle: TextStyle(fontSize: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding:
                                  EdgeInsets.only(left: 20.0, bottom: 12.0),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF666666), width: 0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              filled: true,
                              fillColor: Colors.white),
                          onChanged: (String value) {
                            search_text = value;
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Color(0xFFd0393e),
                      ),
                      onPressed: () {
                        _search();
                      },
                    ),
                  ],
                ),
              )),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            findFirendList(),
            Container(
              decoration: BoxDecoration(color: Color(0xFFf2f3f6)),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 19.0,
                      top: 7.0,
                    ),
                    child: Text(
                      '나의 요청 목록'.tr(),
                      style: TextStyle(fontSize: 10.0),
                    ).tr(),
                  ),
                ],
              ),
            ),
            requestFirendList(),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Color(0xffE8E8E8)),
                  ),
                  color: Color(0xFFf2f3f6)),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 19.0,
                      top: 7.0,
                    ),
                    child: Text(
                      '내가 받은 요청 목록'.tr(),
                      style: TextStyle(fontSize: 10.0),
                    ).tr(),
                  ),
                ],
              ),
            ),
            responsFirendList(),
          ],
        )));
  }

  Widget responsFirendList() {
    return Expanded(
        //요청리스트
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('Profile')
                .document(widget.nowProfile.myPid)
                .collection('firend')
                .where('status', isEqualTo: 'response')
                .snapshots(),
            builder: (context, getList) {
              if (!getList.hasData) return Loading();
              //print(getList.data.documents.toString());
              List<String> tempList = List<String>();
              getList.data.documents.forEach(
                  (document) => tempList.add(document['firendPid'].toString()));
              return Container(
                  color: Color(0xFFf2f3f6),
                  child: FutureBuilder(
                      future: getProfileDetail(tempList),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                        if (snapshot.hasData == false)
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            color: Color(0xFFf2f3f6),
                            child: Text(''),
                          );
                        print('갯수');
                        var ProfileList = snapshot.data;
                        print(ProfileList[0].id);
                        return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            controller: listScrollController,
                            itemCount: ProfileList.length,
                            itemBuilder: (context, index) {
                              print(ProfileList[index].aboutme);
                              return ListTile(
                                leading: ProfileList[index].photoUrl == null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            AssetImage('assets/img/noface.png'),
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            ProfileList[index].photoUrl),
                                      ),
                                title: Text(ProfileList[index].id),
//                          subtitle: Text(ProfileList[index].aboutme),
                                trailing: Stack(
                                  children: <Widget>[
                                    Container(
                                      width: 66.0,
                                      child: MaterialButton(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          elevation: 0.0,
                                          color: MyColors.primaryColor,
                                          textColor: Colors.white,
                                          child: Text('수락',
                                                  style:
                                                      TextStyle(fontSize: 14))
                                              .tr(),
                                          onPressed: () {
                                            print(widget.nowProfile.myPid);
                                            acceptFirend(
                                                widget.nowProfile.myPid,
                                                widget.nowProfile.myNickname,
                                                ProfileList[index].uid,
                                                ProfileList[index].pid,
                                                ProfileList[index].nickname);
                                          }),
                                    ),
                                    Container(
                                      width: 66.0,
                                      height: 36.0,
                                      margin:
                                          EdgeInsets.only(left: 76.0, top: 6.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.0,
                                            color: MyColors.primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                      child: MaterialButton(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          elevation: 0.0,
                                          color: Colors.white,
                                          textColor: MyColors.primaryColor,
                                          child: Text('삭제',
                                                  style:
                                                      TextStyle(fontSize: 14))
                                              .tr(),
                                          onPressed: () {
                                            requestDel(ProfileList[index].pid);
                                          }),
                                    ),
                                  ],
                                ),
                              );
                            });
                      }));
            }));
  } //Widget responsFirendList()

  Widget requestFirendList() {
    return Expanded(
        //요청리스트
        child: Container(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('Profile')
                    .document(widget.nowProfile.myPid)
                    .collection('firend')
                    .where('status', isEqualTo: 'request')
                    .snapshots(),
                builder: (context, getList) {
                  if (!getList.hasData) return Loading();
                  //print(getList.data.documents.toString());
                  List<String> tempList = List<String>();
                  getList.data.documents.forEach((document) =>
                      tempList.add(document['firendPid'].toString()));
                  return Container(
                      color: Color(0xFFf2f3f6),
                      child: FutureBuilder(
                          future: getProfileDetail(tempList),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                            if (snapshot.hasData == false)
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Color(0xFFf2f3f6),
                                  child: Text(''));
                            print('갯수');

                            var ProfileList = snapshot.data;
                            print(ProfileList[0].id);
                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                controller: listScrollController,
                                itemCount: ProfileList.length,
                                itemBuilder: (context, index) {
                                  print(ProfileList[index].aboutme);
                                  return ListTile(
                                    leading: ProfileList[index].photoUrl == null
                                        ? CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'assets/img/noface.png'),
                                          )
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                ProfileList[index].photoUrl),
                                          ),
                                    title: Text(ProfileList[index].id),
//                            subtitle: Text(ProfileList[index].aboutme),
                                    trailing: Stack(
                                      children: <Widget>[
                                        Container(
                                          width: 66.0,
                                          height: 36.0,
                                          margin: EdgeInsets.only(
                                              left: 76.0, top: 6.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: MyColors.primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                          child: MaterialButton(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              elevation: 0.0,
                                              color: Colors.white,
                                              textColor: MyColors.primaryColor,
                                              child: Text('삭제',
                                                      style: TextStyle(
                                                          fontSize: 14))
                                                  .tr(),
                                              onPressed: () {
                                                requestDel(
                                                    ProfileList[index].pid);
                                              }),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }));
                })));
  } //Widget responsFirendList()

  bool exitCheck(String pid) {
    var result;
    print('존재여부 체크');
    print(!(exitsFriend.indexOf(pid) == -1));
    return exitsFriend.indexOf(pid) == -1;
  }

  Widget findFirendList() {
    return StreamBuilder(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) {
          return Center();
        }
        print('widget findFirendList 그리기');
        print(snapshot.data[0].toString());
        if (snapshot.data[0] == null) {
          return Container(
              height: 80,
              decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: 1.0, color: Colors.black.withOpacity(0.1)),
                  ),
                  color: Color(0xFFf2f3f6)),
              child: Center(
                child: Text('"${resultText}"' + '의\n검색 결과가 없습니다.'.tr()),
              ));
        }
        if (searchResultReset == true) {
          return Container();
        }
        return Flexible(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
//            controller: listScrollController,
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 3.5),
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1.0, color: Colors.black.withOpacity(0.1)),
                        ),
                        color: Color(0xFFf2f3f6)),
                    child: ListBody(
                      children: <Widget>[
                        Container(
                          child: ListTile(
                              leading: snapshot.data[index]['photoUrl'] == null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/img/noface.png'),
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          snapshot.data[index]['photoUrl']),
                                    ),
                              title: Text(snapshot.data[index]['id']),
//                              subtitle: Text(snapshot.data[index]['aboutMe']),
                              trailing: (exitCheck(snapshot.data[index][
                                      'pid'])) //(exitsFriend.indexOf(snapshot.data[index]['pid'])==-1)
                                  ? Container(
                                      width: 66.0,
                                      child: MaterialButton(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          padding: EdgeInsets.all(0.0),
                                          child: Text('친구 추가',
                                                  style:
                                                      TextStyle(fontSize: 14))
                                              .tr(),
                                          color: MyColors.primaryColor,
                                          textColor: Colors.white,
                                          elevation: 0.0,
                                          onPressed: () {
                                            //                                    if(_firstPress){
                                            //                                        _firstPress = false;
                                            //                                      _firendAdd(
                                            //                                          widget.nowProfile.myPid,
                                            //                                          widget.nowProfile.myNickname,
                                            //                                          snapshot.data[index]['uid'],
                                            //                                          snapshot.data[index]['pid'],
                                            //                                          snapshot.data[index]['nickname']);
                                            //                                      print(snapshot.data[index]['pid']);
                                            //
                                            //                                      Fluttertoast.showToast(msg: '친구요청 완료'.tr());
                                            //                                    }
                                            _firendAdd(
                                                widget.nowProfile.myPid,
                                                widget.nowProfile.myNickname,
                                                snapshot.data[index]['uid'],
                                                snapshot.data[index]['pid'],
                                                snapshot.data[index]
                                                    ['nickname']);
                                            print(snapshot.data[index]['pid']);

                                            searchResultReset = true;

                                            Fluttertoast.showToast(
                                                msg: '친구요청 완료'.tr());
                                          }))
                                  : Text('추가된 친구',
                                          style: TextStyle(
                                              color: Color(0xFFb2b2b2)))
                                      .tr()),
                        )
                      ],
                    ));
              } //itemBuilder
              ),
        );
      },
    );
  } ////Widget findFirendList
}
