import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:papucon/pages/chat_page.dart';
import 'package:papucon/pages/invite_page.dart';
import 'package:papucon/util/image.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:papucon/model/model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'friend_list.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with SingleTickerProviderStateMixin {
  ImagesUtil img = new ImagesUtil();

  List<MyProfile> myProfiles = List<MyProfile>();

  TabController _tabController;
  List<String> categories = ['로딩중'];
  //List<Map> getFirends = List<Map>();

  var documents = [];
  final List<Profile> profiles = List<Profile>();

  SharedPreferences prefs;
  DBHelper db = DBHelper();
  @override
  void initState() {
    //readLocal();
    //loadTap();
    db.initDB();
    super.initState();
  }

  Future<Profile> getProfile(pid) async {
    Profile profile;
    var doc =
        await Firestore.instance.collection('Profile').document(pid).get();
    if (!doc.exists) {
      profile = Profile(
          null,
          null,
          null,
          '삭제된 프로필'.tr(),
          null,
          'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=ee44d43a-fd92-4bc0-b942-af8d84cac583',
          null);
    } else {
      profile = Profile(
          doc.data['uid'],
          doc.data['pid'],
          doc.data['id'],
          doc.data['nickname'],
          doc.data['aboutme'],
          doc.data['photoUrl'],
          doc.data['backgroundUrl']);
    }

    return profile;
  }

  Future<List> getChatList(getList, myPid) async {
    List<dynamic> chatRoom = List<Map>();
    Completer completer = new Completer();
    for (var room in getList.data.documents) {
      var rid = room['rid'];
//      Firestore.instance.document(room).collection('user').document(pid).get();
      var chatUser = List<String>.from(room['user'].toList());
      chatUser.remove(myPid);
      List<Profile> userList = List<Profile>();
      for (var user in chatUser) {
        var profile_data = await getProfile(user);
        userList.add(profile_data);
      }
//      chatUser.forEach((user){
//        getProfile(user).then((value) => userList.add(value));
//      });
      chatRoom.add(
          {'rid': rid, 'user': userList, 'lastMessage': room['lastMessage']});
      //print('user: $chatUser');
    }
    return chatRoom;
  }

/*
  Future<List> chatQuery(var doc, var myPid) async {
    print('chaQuery Start : $myPid');
    List<dynamic> chatRoom = List<Map>();
   var list = doc.documents;
   print('charquery');
    for(int i = 0; i < list.length; i++) {
      var chatUser = List<String>.from(list[i]['user'].toList());
      //본인계정 삭제
      var rid=list[i].documentID;
      print('방아이디 : $rid');
      chatUser.remove(myPid);
      print('채팅방유저 : $chatUser');
      var roomPerUser=[];
      chatUser.forEach((user) async {
          print('프로필 조회 $user');
              var userSnap= await Firestore.instance
              .collection('Profile')
              .where('pid', isEqualTo:user)
              .getDocuments();
              if(userSnap.documents.length==0){
                print('프로필이 없다고 $user');
                roomPerUser.add(
                    {//'rid': rid,
                      'pid': null,
                      'toUid': null,
                      'photoUrl': 'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=24f7e4de-5108-48c2-89f8-0cd6a1cf2518',
                      'nickname': '삭제된 프로필',
                    }
                );
               }else{
                print('닉네임 ${userSnap.documents.first.data['nickname']}');
                roomPerUser.add(
                    {//'rid': rid,
                      'pid': userSnap.documents[0].data['pid'],
                      'toUid': userSnap.documents[0].data['uid'],
                      'photoUrl': userSnap.documents[0].data['photoUrl'],
                      'nickname': userSnap.documents[0].data['nickname'],
                    }
                );
              }
      });
      chatRoom.add(roomPerUser);
    }
//      var userSnap= await Firestore.instance
//              .collection('Profile')
//              .where('pid', isEqualTo: user_re.first)
//              .getDocuments();
//      print(userSnap.documents[0].data['uid']);
//      chatRoom.add({'rid': rid,
//                  'pid': userSnap.documents[0].data['pid'],
//                  'toUid': userSnap.documents[0].data['uid'],
//                  'photoUrl': userSnap.documents[0].data['photoUrl'],
//                  'nickname': userSnap.documents[0].data['nickname'],
//                });
//
//        }
//
//    var leng = chatRoom.length;
//    print('Chatroom Len : $leng');
    return chatRoom;
  }
*/
  void exitRoom(var rId, List<Profile> userList) {
    print('Disabled Procesxsing $rId');
    print('현재프로필');
    var myPid =
        Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid;
    //Firestore.instance.collection('Room').document(rId).updateData({'diabled':'true'});
    Firestore.instance.collection('Room').document(rId).get().then((value) {
      List<String> updateUser = List<String>.from(value['user'].toList());
      if (updateUser.length < 3) {
        Firestore.instance
            .collection('Profile')
            .document(userList.first.pid)
            .collection('firend')
            .document(myPid)
            .updateData({'chatOn': null});
        Firestore.instance
            .collection('Profile')
            .document(myPid)
            .collection('firend')
            .document(userList.first.pid)
            .updateData({'chatOn': null});
      }
      updateUser.remove(myPid);
      Firestore.instance
          .collection('Room')
          .document(rId)
          .updateData({'user': updateUser});
      print('user $updateUser');
      Navigator.pop(this.context);
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<nowProfile>(builder: (context, profile, _) {
      return Scaffold(
        backgroundColor: Color(0xFFf2f3f6),
        appBar: AppBar(
          brightness: Brightness.light,
          centerTitle: false,
          title: Text(
            '채팅',
            style: TextStyle(color: Colors.black, fontSize: 26, height: 0.5)
          ).tr(),
          toolbarHeight: 60,
          backgroundColor: Color(0xFFf2f3f6),
//          backgroundColor: Colors.amber,
          elevation: 0.0,
          bottom: PreferredSize(
            child: SizedBox(
              height: 10,
            ),
          ),
          bottomOpacity: 0.1,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 14.0, bottom: 10),
              child: Neumorphic(
                padding: EdgeInsets.all(0),
                style: NeumorphicStyle(
                  color: Color.fromRGBO(242, 243, 246, 255),
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 3,
                  shape: NeumorphicShape.concave,
                ),
                child: IconButton(
                  icon: Icon(MdiIcons.chatPlusOutline, color: Colors.black, size: 25),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => InvitePage()));
                  },
                ),
              )
            )
          ],
        ),
        body: PreferredSize(
          child: StreamBuilder(
              stream: Firestore.instance
                .collection('Room')
                .where('user', arrayContains: profile.getMyProfile().myPid)
                .orderBy('actionTime', descending: true)
                .snapshots(),
              builder: (context, getList) {
                if (!getList.hasData) return Loading();
                if (getList.data.documents.length == 0) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        margin: EdgeInsets.only(left: 20, right: 20, top: 0),
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
                          child: Text('생성된 채팅방이 없습니다.').tr(),
                        )
                      )
                    ],
                  );
                }
                print(profile.getMyProfile().myPid);
                print('채팅방 개수 : ${getList.data.documents.length}');
                //Cast List<dynamic> to List<String>

                //본인계정 삭제
                //var roomList= getChatList(getList,  profile.getMyProfile().myPid);

                print(getList.data.runtimeType);
                print(getList.data.documents[0].documentID);
                //chatQuery(getList.data, profile.getMyProfile().myPid);
                return FutureBuilder(
                  future: getChatList(getList, profile.getMyProfile().myPid),
                  builder: (context, list) {
                    if (!list.hasData) return Loading();
                    //return Text(list.data.toString());
                    return Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 0),
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
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: list.data.length,
                        itemBuilder: (context, index) {
                          print('리스트 빌더');
                          //print(.toString());
                          List<Profile> userdata = List<Profile>();
                          if (list.data[index]['user'].length == 0) {
                            userdata.add(Profile(null,null,null,'종료된 채팅방'.tr(),null,
                              'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=3c64781a-8c71-4ca6-bbae-78bbf1662241',
                              null
                            ));
                          } else {
                            userdata.addAll(list.data[index]['user']);
                          }
                          List<String> chatTitleList = List<String>();
                          userdata.forEach((element) {
                            chatTitleList.add(element.nickname.toString());
                          });

                          return MaterialButton(
                            padding: EdgeInsets.all(0.0),
                            onLongPress: () async {
                              await showDialog(
                                context: context,
                                child: SimpleDialog(
                                  title: Text(
                                    chatTitleList.join(', '),
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  children: <Widget>[
                                    SimpleDialogOption(
                                      padding: EdgeInsets.only(
                                        left: 24.0,
                                        top: 20.0,
                                        bottom: 10.0
                                      ),
                                      child: Text('채팅방나가기').tr(),
                                      onPressed: () {
                                        print(list.data[index]['rid']);
                                        exitRoom(list.data[index]['rid'], userdata);
                                        //userdata
                                        //Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                )
                              );
                            },
                            child: ListTile(
                              leading: userdata[0].photoUrl == null
                                ? CircleAvatar(
                                  foregroundColor: Colors.transparent,
                                  backgroundImage: AssetImage('assets/img/noface.png')
                                )
                                : CircleAvatar(
                                  foregroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(userdata[0].photoUrl),
                                ),
                              title: Text(
                                chatTitleList.join(', '),
                                style: TextStyle(fontSize: 15.0)
                              ),
                              subtitle: (list.data[index]['lastMessage'] != null)
                                ? (list.data[index]['lastMessage'].toString().indexOf('firebasestorage') == -1)
                                  ? (list.data[index]['lastMessage'].toString().length < 21)
                                    ? Text(
                                      list.data[index]['lastMessage'].toString().replaceAll("\n", " "),
                                      style: TextStyle(fontSize: 12.0))
                                    : Text(list.data[index]['lastMessage'].toString().substring(0, 20) + "...", style: TextStyle(fontSize: 12.0))
                                  : Text('Image/File')
                                : Text('-'),
                              onTap: () {
                                Map<String, dynamic> chatInfo = {
                                  'rId': list.data[index]['rid'],
                                  'nowProfile': profile.getMyProfile(),
                                  'withUser': userdata,
                                };
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(chatInfo: chatInfo),));
                              },
                            )
                          );
                        }
                      ),
                    );
                  }
                );
              }
            ),
          ),
        );
      }
    );
  }
}
