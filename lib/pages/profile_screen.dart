import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:papucon/pages/profile_page.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/model/model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:papucon/util/image.dart';
import 'package:papucon/widgets/full_photo_profile.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import 'chat_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  final Profile currentProfile;
  //0 myprofile , 1 Firend
  final String mypid;

  ProfileScreen({Key key, @required this.currentProfile, this.mypid})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ImagesUtil img = new ImagesUtil();

  var documents;
  bool isMyProfile = false;

  void initState() {
//    var providerProfile = Provider.of<nowProfile>(context, listen: false).getMyProfile();
//
//    print(providerProfile.myPid);
//    if( providerProfile.myPid == widget.currentProfile.pid) {
//       isMyProfile = true;
//    }
    super.initState();
  }

  void _enterChat() async {
    var providerProfile =
    await Provider.of<nowProfile>(context, listen: false).getMyProfile();
    //  print('내 아이디 : ${providerProfile.myPid}');
    Firestore.instance
        .collection('Profile')
        .document(widget.mypid)
        .collection('firend')
        .where('firendPid', isEqualTo: widget.currentProfile.pid)
        .getDocuments()
        .then((value) {
      print(widget.mypid);
      print(widget.currentProfile.pid);
      print('rid ${value.documents.first.toString()}');
      List<Profile> userdata = List<Profile>();
      userdata.add(widget.currentProfile);
      print('Enter');
      print(value.documents.first['chatOn'].toString());
      if (value.documents.first['chatOn'] == null) {
        var rid = createChat(widget.mypid, widget.currentProfile.pid);
        Map<String, dynamic> chatInfo = {
          'rId': rid,
          'nowProfile': providerProfile,
          'withUser': userdata
        };
        Firestore.instance
            .collection('Profile')
            .document(widget.mypid)
            .collection('firend')
            .document(widget.currentProfile.pid)
            .updateData({'chatOn': rid});
        Firestore.instance
            .collection('Profile')
            .document(widget.currentProfile.pid)
            .collection('firend')
            .document(widget.mypid)
            .updateData({'chatOn': rid});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chatInfo: chatInfo),
          ),
        );
      } else {
        var rid = value.documents.first['chatOn'];

        Map<String, dynamic> chatInfo = {
          'rId': rid,
          'nowProfile': providerProfile,
          'withUser': userdata
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chatInfo: chatInfo),
          ),
        );
      }
    });
  }

  String createChat(String myPid, String pid) {
    final collMessage = Firestore.instance.collection('Room');
    DocumentReference docMessage = collMessage.document();

    var rid = docMessage.documentID;

    List<String> exitUser = [];

    var _roomData = {
      'rid': rid,
      'createTime': FieldValue.serverTimestamp(),
      'actionTime': FieldValue.serverTimestamp(),
      'user': [myPid, pid],
      'exitUser': exitUser
    };

    docMessage.setData(_roomData).then((data) async {
      docMessage.collection('user').add({
        'user': [myPid, pid],
      });
    });
    docMessage.setData(_roomData).then((data) async {
      docMessage.collection('user').add({
        'user': pid,
      });
      docMessage
          .collection('user')
          .document(myPid)
          .setData({'title': widget.currentProfile.nickname});
    });

    return rid;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Scaffold(
//      appBar: AppBar(
//        elevation: 0.0,
//        backgroundColor: Colors.transparent,
//        leading: IconButton(
//          icon: Icon(Icons.close, color: Colors.black),
//          onPressed: () {
//            Navigator.pop(context);
//          },
//        ),
//      ),
        body: Container(
          color: Color(0xFFf2f3f6),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              // Profile Card
              Align(
                alignment: Alignment(0.0, 1.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 4.55,
                  margin:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 80),
                  child: Neumorphic(
                      style: NeumorphicStyle(
                        border: NeumorphicBorder(
                            width: 0.5, color: Color(0xFFf0f0f0)),
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(16)),
                        shadowDarkColor: Colors.black.withOpacity(0.5),
                        shadowLightColor: Colors.white,
                        depth: 3,
                        intensity: 1,
                        color: Color(0xFFf2f3f6),
                      ),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin:
                                    EdgeInsets.only(top: 17, bottom: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Text(widget.currentProfile.nickname,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 23)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('ID : ' + widget.currentProfile.id,
                                        style: TextStyle(
                                            color: Color(0xFFa8a8a8),
                                            fontSize: 13)),
                                    SizedBox(width: 15),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.content_copy,
                                        color: Color(0xFFa8a8a8),
                                        size: 14,
                                      ),
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: widget.currentProfile.id));
                                        Fluttertoast.showToast(
                                            msg: "복사되었습니다.".tr(),
                                            gravity: ToastGravity.TOP,
                                            timeInSecForIos: 1,
                                            backgroundColor:
                                            Colors.black.withAlpha(130),
                                            textColor: Colors.white,
                                            fontSize: 15.0);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width:
                                    MediaQuery.of(context).size.width / 1.5,
                                    margin:
                                    EdgeInsets.only(top: 12, bottom: 18),
                                    child: Text(
                                        widget.currentProfile.aboutme
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            height: 1.2),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),

              // Background Image
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.58,
                decoration: BoxDecoration(
                    image: widget.currentProfile.backgroundUrl == null
                        ? DecorationImage(
                        image: AssetImage("assets/img/papucon_prof.png"),
                        fit: BoxFit.cover)
                        : DecorationImage(
                        image: NetworkImage(
                            img.getThumb(widget.currentProfile.backgroundUrl)),
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x4C000000), Colors.transparent],
                        stops: [0.18, 0.4],
                      )),
                  child: FlatButton(
                    //highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      if (widget.currentProfile.backgroundUrl != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullPhotoProfile(
                                    url: widget.currentProfile.backgroundUrl)));
                      }
                    },
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(top: 50, left: 20),
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: EdgeInsets.all(0.0),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Profile Image
              Align(
                alignment: Alignment(0.0, 0.3),
                child: Container(
                  width: /* 130 */ MediaQuery.of(context).size.width / 4,
                  height: /* 130 */ MediaQuery.of(context).size.width / 4,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x80d6d6d6),
                            blurRadius: 3,
                            offset: Offset(1, 2))
                      ],
                      image: widget.currentProfile.photoUrl == null
                          ? DecorationImage(
                          image: AssetImage('assets/img/noface.png'),
                          fit: BoxFit.cover)
                          : DecorationImage(
                          image:
                          NetworkImage(widget.currentProfile.photoUrl),
                          fit: BoxFit.cover)),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    color: Colors.transparent,
                    onPressed: () {
                      if (widget.currentProfile.photoUrl != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullPhotoProfile(
                                    url: widget.currentProfile.photoUrl)));
                      }
                    },
                  ),
                ),
              ),

              // Button
              Align(
                alignment: Alignment(0.0, 1.0),
                child: Container(
                    child: Consumer<nowProfile>(builder: (context, profile, _) {
                      return (widget.currentProfile.pid ==
                          profile.getMyProfile().myPid)
                          ? Container(
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                        currentProfile:
                                        widget.currentProfile)));
                          },
                          color: Color(0xFF1a1a1a),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 3.0),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text('프로필 편집',
                                    style: TextStyle(color: Colors.white))
                                    .tr(),
                              ],
                            ),
                          ),
                        ),
                      )
                          : Container(
                        child: Consumer<nowProfile>(
                            builder: (context, profile, _) {
                              return FlatButton(
                                onPressed: () {
                                  _enterChat();
                                },
                                color: MyColors.primaryColor,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 3.0),
                                        child: GestureDetector(
                                          child: Icon(
                                            Icons.textsms,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Text('채팅하기'.tr(),
                                          style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    })),
              ),
            ],
          ),
        ),
      ),
    );
  }
}