import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_query_firestore/multi_query_firestore.dart';
import 'package:papucon/main.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/pages/profile_page.dart';
import 'package:papucon/pages/profile_screen.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/util/image.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'friend_find_page.dart';
import 'dart:io' show Platform;

// Global Properties
String uid = '';
String nickname = '';
String aboutMe = '';
String photoUrl = '';

List<MyProfile> myProfiles = List<MyProfile>();

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

enum Answers { YES, NO, MAYBE }

class _FriendListState extends State<FriendList> {
  var currentProfile;
  DBHelper db = new DBHelper();
  ImagesUtil img = new ImagesUtil();

  //List<Map> getFirends = List<Map>();
  SharedPreferences prefs;
  List<Map> acceptFirends = List<Map>();
  List<String> firendsList = List<String>();

  final profile = nowProfile();

  @override
  void initState() {
    print('----------FRIENDLISTPAGE: initState()----------');
    super.initState();
  }

  void loadProfile() async {
    List<MyProfile> tempList = List<MyProfile>();
    ;

    Firestore.instance
        .collection('Users')
        .document(uid)
        .collection('profile')
        .getDocuments()
        .then((value) async {
      setState(() {});
      //Provider.of<nowProfile>(context, listen: false).setMyProfile(MyProfile(value.documents.first['pid'], value.documents.first['nickname']));
    });

    // Force refresh input
    //setState(() {});
  }

  Future<void> getPerfs() async {
    print('-----getPerfs()-----');
    prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    return uid;
  }

  Future syncFirned(String myPid) {
    print('-----syncFriend()-----');
    db.getFirend(myPid).then((list) {
      list.forEach((user) async {
        var getProfile = await Firestore.instance
            .collection("Profile")
            .document(user.pid)
            .get();
        if (!getProfile.exists) {
          Firestore.instance
              .collection('Profile')
              .document(myPid)
              .collection("firend")
              .document(user.pid)
              .delete();
          db.deleteProfile(user.pid);
        }
      });
    });
  }

  Widget buildSeletprofile(var getProfile) {
    return ButtonTheme(
      minWidth: 50.0,
      height: 60.0,
      child: FlatButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          padding: EdgeInsets.only(left: 0, top: 0),
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(242, 243, 246, 1),
                borderRadius: BorderRadius.circular(5.0)),
            margin: EdgeInsets.only(top: 0, left: 0),
            child: Row(
              children: <Widget>[
                getProfile.data.documents.first['photoUrl'] == null
                    ? CircleAvatar(
                        backgroundImage: AssetImage('assets/img/noface.png'),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            getProfile.data.documents.first['photoUrl']),
                      ),
                SizedBox(width: 15),
                Text(
                  getProfile.data.documents.first['nickname'],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
                Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
          onPressed: () {
            showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext context) {
                  return Container(
                      height: 200,
                      padding: EdgeInsets.only(
                          left: 20, top: 10, right: 20, bottom: 0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0),
                          )),
                      child: Stack(children: <Widget>[
                        Container(
                          child: StreamBuilder(
                            stream: Firestore.instance
                                .collection('Profile')
                                .where('uid', isEqualTo: uid)
                                .orderBy('createTime')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Loading();
                              if (snapshot.data.documents.length == 0)
                                return Loading();
                              return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: snapshot.data.documents.length + 1,
                                itemBuilder: (context, id) {
                                  return (id == snapshot.data.documents.length)
                                      ? Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: ListTile(
                                            leading: Container(
                                              padding: EdgeInsets.all(11),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.black26)),
                                              child: Icon(Icons.add),
                                            ),
                                            title: Text('새 프로필').tr(),
                                            onTap: () {
                                              if (snapshot
                                                      .data.documents.length <
                                                  5) {
                                                Profile emptyProfile = Profile(
                                                    uid,
                                                    null,
                                                    null,
                                                    null,
                                                    null,
                                                    null,
                                                    null);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfilePage(
                                                              currentProfile:
                                                                  emptyProfile)),
                                                );
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "프로필은 5개까지 생성 가능합니다"
                                                        .tr(),
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIos: 2,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              }
                                            },
                                          ),
                                        )
                                      : ListTile(
                                          leading: CircleAvatar(
                                            foregroundColor: Colors.transparent,
                                            backgroundImage: snapshot
                                                            .data.documents[id]
                                                        ['photoUrl'] ==
                                                    null
                                                ? AssetImage(
                                                    'assets/img/noface.png')
                                                : NetworkImage(snapshot.data
                                                    .documents[id]['photoUrl']),
                                            radius: 24.0,
                                          ),
                                          title: Text(snapshot
                                              .data.documents[id]['nickname']),
                                          onTap: () {
                                            Firestore.instance.collection('Users').document(uid).updateData({
                                              "lastProfile": snapshot.data.documents[id]['pid'],  // 마지막 접속 프로필
                                              "lastProfileName": snapshot.data.documents[id]['nickname']  // 마지막 접속 프로필 닉네임
                                            });
                                            Provider.of<nowProfile>(context,
                                                    listen: false)
                                                .setMyProfile(MyProfile(
                                                    snapshot.data.documents[id]
                                                        ['pid'],
                                                    snapshot.data.documents[id]
                                                        ['nickname']));
                                            Navigator.pop(context);
                                          },
                                        );
//                                      Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ]));
                });
          }),
    );
  }

  Widget buildFriendAction() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Container(
      margin: EdgeInsets.only(right: 14.0, bottom: 8),
      child: Neumorphic(
        padding: EdgeInsets.all(0),
        style: NeumorphicStyle(
          color: Color.fromRGBO(242, 243, 246, 255),
          boxShape: NeumorphicBoxShape.circle(),
          depth: 3,
          shape: NeumorphicShape.concave,
        ),
        child: IconButton(
          icon: Icon(Icons.person_add, color: Colors.black),
          iconSize: 25,
          onPressed: () {
            setState(() {});
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FriendFind(
                      nowProfile:
                          Provider.of<nowProfile>(context, listen: false)
                              .getMyProfile())),
            );
          },
        ),
      ),
    );
  }

  Widget buildMyprofile(String myPid) {
    print('---buildMyProfile()');
    return Expanded(
        child: StreamBuilder(
      stream:
          Firestore.instance.collection('Profile').document(myPid).snapshots(),
      builder: (context, snapshot) {
        //이미지 테스트
        if (!snapshot.hasData) return Loading();
        String get_thumb;
        if (snapshot.data['photoUrl'].toString() != 'null')
          get_thumb = img.getThumb(snapshot.data['photoUrl']);
        var tapProfile = Profile(
            snapshot.data['uid'],
            snapshot.data['pid'],
            snapshot.data['id'],
            snapshot.data['nickname'],
            snapshot.data['aboutMe'],
            snapshot.data['photoUrl'],
            snapshot.data['backgroundUrl']);
        db.insertTableProfile('1', tapProfile);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          height: 120,
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: Neumorphic(
            style: NeumorphicStyle(
              color: Colors.white,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(19)),
            ),
            child: Stack(
              children: <Widget>[
                ListTile(
                  leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 2.0, color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(2, 2),
                                blurRadius: 1),
                            BoxShadow(
                                color: Colors.white12,
                                offset: Offset(-1, -1),
                                blurRadius: 3)
                          ]),
                      padding: EdgeInsets.all(2.0),
                      child: CircleAvatar(
                        foregroundColor: Colors.transparent,
                        backgroundImage: snapshot.data['photoUrl'] == null
                            ? AssetImage('assets/img/noface.png')
                            : NetworkImage(get_thumb),
                        radius: 24.0,
                      )),
                  title: Text(snapshot.data['nickname'],
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w600)),
                  subtitle: (snapshot.data['aboutMe'] != null)
                      ? Text(
                          snapshot.data['aboutMe'].toString().length < 20
                              ? snapshot.data['aboutMe']
                              : snapshot.data['aboutMe']
                                      .toString()
                                      .substring(0, 20) +
                                  "...",
                          style: TextStyle(
                              height: 2,
                              color: Colors.black38,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500))
                      : Text(''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(currentProfile: tapProfile)),
                    );
                  },
                ),
                Positioned.fill(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          child: Container(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Text(
                                '프로필편집',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      MyColors.primaryColor.withAlpha(80),
                                  decorationThickness: 15,
                                  decorationStyle: TextDecorationStyle.solid,
                                ),
                              ).tr()),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                        currentProfile: tapProfile)));
                          },
                        ))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[],
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  Widget buildFirendList(String pid) {
    print('---buildFriendList()');
    print('---pid: $pid');
    WidgetsBinding.instance.addPostFrameCallback((_) => syncFirned(pid));
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Profile')
          .document(pid)
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
                      blurRadius: 6),
                  BoxShadow(
                      color: Colors.white12,
                      offset: Offset(-3, -3),
                      blurRadius: 6)
                ]),
            margin: EdgeInsets.only(left: 20, right: 20, top: 7),
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
                      blurRadius: 6),
                  BoxShadow(
                      color: Colors.white12,
                      offset: Offset(-3, -3),
                      blurRadius: 6)
                ]),
            margin: EdgeInsets.only(left: 20, right: 20, top: 7),
            child: StreamBuilder(
              stream: MultiQueryFirestore(list: doc_query).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return Loading();
                print('part 2');
                return Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 45),
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          if (snapshot.data.documents[index]['uid']
                                  .toString() ==
                              null) {}

                          var tapProfile = Profile(
                              //입력 순서 중요!!!!
                              snapshot.data.documents[index]['uid'],
                              snapshot.data.documents[index]['pid'],
                              snapshot.data.documents[index]['id'],
                              snapshot.data.documents[index]['nickname'],
                              snapshot.data.documents[index]['aboutMe'],
                              snapshot.data.documents[index]['photoUrl'],
                              snapshot.data.documents[index]['backgroundUrl']);
                          print('part 3: ${tapProfile.pid}');
                          print('part 3: ${tapProfile.nickname}');
                          db.insertTableProfile(pid, tapProfile);
                          print(
                              '-----${tapProfile.pid} inserted into DATABASE.');
                          return ListTile(
                            leading: snapshot.data.documents[index]
                                        ['photoUrl'] ==
                                    null
                                ? CircleAvatar(
                                    foregroundColor: Colors.transparent,
                                    backgroundImage:
                                        AssetImage('assets/img/noface.png'),
                                  )
                                : CircleAvatar(
                                    foregroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(snapshot
                                        .data.documents[index]['photoUrl'])),
                            title: Text(
                                snapshot.data.documents[index]['nickname'],
                                style: TextStyle(fontSize: 13.0)),
                            subtitle: Text(
                                snapshot.data.documents[index]['aboutMe'],
                                style: TextStyle(
                                    color:
                                        MyColors.primaryColor.withOpacity(0.7),
                                    fontSize: 11.0)),
                            onLongPress: () {},
                            onTap: () {
                              var mypid = Provider.of<nowProfile>(context,
                                      listen: false)
                                  .getMyProfile()
                                  .myPid;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                        currentProfile: tapProfile,
                                        mypid: mypid)),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Positioned(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(19.0),
                            topRight: Radius.circular(19.0),
                          ),
                        ),
                        padding: EdgeInsets.only(top: 15, left: 18, right: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.5,
                                    color: Color(0xFFe8e8e8).withOpacity(0.8))),
                          ),
                          child: Text(
                            '친구'.tr() + '    ${snapshot.data.documents.length}',
                            style: TextStyle(
                                fontSize: 14,
                                backgroundColor: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('-----build()');
    if (Platform.isIOS) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 48, //add
          backgroundColor: const Color(0xFFf2f3f6),
          brightness: Brightness.light,
          elevation: 0.0,
          title: FutureBuilder(
            future: getPerfs(),
            builder: (context, getUid) {
              if (!getUid.hasData) return Loading();
              return Consumer<nowProfile>(
                builder: (context, profile, _) {
                  if (profile.getMyProfile().toString() == 'null')
                    return const Loading();
                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection('Profile')
                        .where('pid', isEqualTo: profile.getMyProfile().myPid)
                        .snapshots(),
                    builder: (context, getProfile) {
                      if (!getProfile.hasData) return Loading();
                      return buildSeletprofile(getProfile);
                    },
                  );
                },
              );
            },
          ),
          actions: [buildFriendAction()],
        ),
        body: Container(
          color: const Color(0xfff2f3f6),
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Consumer<nowProfile>(
              builder: (context, profile, _) {
                if (profile.getMyProfile().toString() == 'null')
                  return const Loading();
                return BuildContent(
                  getPerfs: getPerfs(),
                  buildMyprofile: buildMyprofile(profile.getMyProfile().myPid),
                  buildFirendList:
                      buildFirendList(profile.getMyProfile().myPid),
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFf2f3f6),
            toolbarHeight: 48,
            elevation: 0.0,
            title: FutureBuilder(
              future: getPerfs(),
              builder: (context, getUid) {
                if (!getUid.hasData) return const Loading();
                print('---building AppBar...');
                return Consumer<nowProfile>(
                  builder: (context, profile, _) {
                    if (profile.getMyProfile().toString() == 'null')
                      return Loading();
                    return StreamBuilder(
                      stream: Firestore.instance
                          .collection('Profile')
                          .where('pid', isEqualTo: profile.getMyProfile().myPid)
                          .snapshots(),
                      builder: (context, getProfile) {
                        if (!getProfile.hasData) return Loading();
                        return buildSeletprofile(getProfile);
                      },
                    );
                  },
                );
              },
            ),
            actions: [buildFriendAction()],
          ),
          backgroundColor: Color(0xfff2f3f6),
          body: Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Consumer<nowProfile>(builder: (context, profile, _) {
              if (profile.getMyProfile().toString() == 'null') return Loading();
              print('---building Body...');
              return BuildContent(
                getPerfs: getPerfs(),
                buildMyprofile: buildMyprofile(profile.getMyProfile().myPid),
                buildFirendList: buildFirendList(profile.getMyProfile().myPid),
              );
            }),
          ));
    }
  }
}

class BuildContent extends StatefulWidget {
  final Future<void> getPerfs;
  final Widget buildMyprofile;
  final Widget buildFirendList;
  const BuildContent({
    this.getPerfs,
    this.buildMyprofile,
    this.buildFirendList,
    Key key,
  }) : super(key: key);

  @override
  _BuildContentState createState() => _BuildContentState();
}

class _BuildContentState extends State<BuildContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Consumer<nowProfile>(builder: (context, profile, _) {
          String mypid;

          if (profile.getMyProfile().toString() == 'null') return Loading();
          return FutureBuilder(
              future: widget.getPerfs,
              builder: (context, getUid) {
                String uid = getUid.data.toString();
                if (!getUid.hasData) return Loading();
                return StreamBuilder(
                    stream:
//                       Firestore.instance.collection('Users')
//                           .document(uid).collection('profile').orderBy("createTime", descending: false).snapshots(),
                        Firestore.instance
                            .collection('Profile')
                            .where('pid',
                                isEqualTo: profile.getMyProfile().myPid)
                            .snapshots(),
                    builder: (context, getProfile) {
                      if (!getProfile.hasData) return Loading();
                      return Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[],
                          ),
                          Row(
                            children: <Widget>[
                              widget.buildMyprofile,
                            ],
                          ),
                          Expanded(child: widget.buildFirendList
                              //Text(getProfile.data.documents.first['pid']);
                              ),
                        ],
                      ));
                    });
              });
        })
      ],
    );
  }
}
