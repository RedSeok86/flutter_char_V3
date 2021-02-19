import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/pages/chat_page.dart';
import 'package:papucon/pages/friend_list.dart';
import 'package:papucon/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'loading.dart';

class FileSharePage extends StatefulWidget {
  String filename;

  FileSharePage({Key key, @required this.filename}) : super(key: key);
  @override
  FileSharePageState createState() => FileSharePageState();
}

class FileSharePageState extends State<FileSharePage> {
  DBHelper db = new DBHelper();
  bool isChat = false;
  String selectRoom;
  String selectFirend;
  bool rs = false;
  String chatRoomie;
  @override
  void initState() {
    var file = widget.filename.toString();
    print(file);
    super.initState();
  }

  Future<List> getChatList(getList, myPid) async {
    List<dynamic> chatRoom = List<Map>();

    for (var room in getList.data.documents) {
      var rid = room['rid'];

      var chatUser = List<String>.from(room['user'].toList());
      chatUser.remove(myPid);
      List<Profile> userList = List<Profile>();
      for (var user in chatUser) {
        var profile_data = await getProfile(user);
        userList.add(profile_data);
      }

      chatRoom.add(
          {'rid': rid, 'user': userList, 'lastMessage': room['lastMessage']});
    }
    return chatRoom;
  }

  Future<Profile> getProfile(String pid) async {
    Profile profile;
    var doc =
        await Firestore.instance.collection('Profile').document(pid).get();
    if (!doc.exists) {
      //profile =  Profile(null, null, null, '삭제된 프로필'.tr(), null, null, 'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=ee44d43a-fd92-4bc0-b942-af8d84cac583', null);
      profile = Profile(
          null,
          null,
          null,
          '삭제된 프로필'.tr(),
          null,
          'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=ee44d43a-fd92-4bc0-b942-af8d84cac583',
          null);
    } else {
//      profile =  Profile(doc.data['uid'], doc.data['pid'], doc.data['id'], doc.data['nickname'], doc.data['group'], doc.data['aboutme'], doc.data['photoUrl'], doc.data['backgroundUrl']);
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

  Future<String> DownloadURL(var filename) async {
    StorageReference ref =
        FirebaseStorage.instance.ref().child("$uid/storages/$filename");
    return (await ref.getDownloadURL()).toString();
  }

  bool tabChange() {
    isChat = !isChat;
  }

  void _getRadioValue(String value) {
    setState(() {
      selectRoom = value;
    });
  }

  Future<List<Profile>> _shareMessage(String rid, String fileUrl) async {
    List<Profile> userlist = List<Profile>();
    var documentReference = Firestore.instance
        .collection('Room')
        .document(rid)
        .collection('Message')
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    var pid =
        Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid;
    final room_data =
        await Firestore.instance.collection('Room').document(rid).get();
    List<String> uid_list = List<String>();
    for (var user_id in room_data['user']) {
      Profile tempUid = await getProfile(user_id);
      uid_list.add(tempUid.uid);
    }
    uid_list.remove(
        Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid);
    print(uid_list.toString());
    documentReference.setData(
      {
        'uidFrom': uid,
        'idFrom': pid,
        'idTo': uid_list,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': fileUrl,
        'type': 6
      },
    );

    for (var user in room_data.data['user']) {
      userlist.add(await getProfile(user));
    }
    print('for 완료--------------');
    print(userlist.toString());
    return userlist;
  }

  Future<String> _enterChat(String firendPid, String myPid) async {
    String rid;
    var providerProfile =
        await Provider.of<nowProfile>(context, listen: false).getMyProfile();
    //  print('내 아이디 : ${providerProfile.myPid}');
    var process = Firestore.instance
        .collection('Profile')
        .document(myPid)
        .collection('firend')
        .where('firendPid', isEqualTo: firendPid)
        .getDocuments()
        .then((value) {
      print(myPid);
      print(firendPid);
      print('rid ${value.documents.first.toString()}');
      List<Profile> userdata = List<Profile>();
      getProfile(firendPid).then((value) => userdata.add(value));
      print('Enter');
      print(value.documents.first['chatOn'].toString());
      if (value.documents.first['chatOn'] == null) {
        rid = createChat(myPid, firendPid);
        Map<String, dynamic> chatInfo = {
          'rId': rid,
          'nowProfile': providerProfile,
          'withUser': userdata
        };
        Firestore.instance
            .collection('Profile')
            .document(myPid)
            .collection('firend')
            .document(firendPid)
            .updateData({'chatOn': rid});
        Firestore.instance
            .collection('Profile')
            .document(firendPid)
            .collection('firend')
            .document(myPid)
            .updateData({'chatOn': rid});
      } else {
        rid = value.documents.first['chatOn'];
      }
    });
    return rid;
  }

  String createChat(String myPid, String pid) {
    final collMessage = Firestore.instance.collection('Room');
    DocumentReference docMessage = collMessage.document();

    var rid = docMessage.documentID;

    var _roomData = {
      'rid': rid,
      'createTime': FieldValue.serverTimestamp(),
      'actionTime': FieldValue.serverTimestamp(),
      'user': [myPid, pid]
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
      // docMessage.collection('user').document(myPid).setData({'title':widget.currentProfile.nickname});
    });

    return rid;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '공유하기',
            style: TextStyle(color: Colors.black, fontSize: 23),
          ).tr(),
          bottom: TabBar(
            onTap: (value) => tabChange(),
            tabs: [
              Tab(
                child: Text('친구', style: TextStyle(color: Colors.black)).tr(),
              ),
              Tab(
                child: Text('채팅', style: TextStyle(color: Colors.black)).tr(),
              ),
            ],
            indicatorColor: MyColors.primaryColor,
          ),
          toolbarHeight: 100,
          backgroundColor: Color(0xFFf2f3f6),
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.send,
                color: MyColors.primaryColor,
              ),
              onPressed: () async {
                final ProgressDialog pr = ProgressDialog(context,
                    type: ProgressDialogType.Normal,
                    isDismissible: false,
                    showLogs: true);
                await pr.show();
                DownloadURL(widget.filename).then((fileurl) async {
                  print(fileurl);
                  if (!isChat) {
                    print('친구 선택 : ${isChat.toString()} - $selectFirend');
                    var rid = rs == true
                        ? createChat(
                            Provider.of<nowProfile>(context, listen: false)
                                .getMyProfile()
                                .myPid,
                            selectFirend)
                        : chatRoomie;
                    print('채팅방 아이디 $rid');

                    _shareMessage(rid, fileurl).then((userdata) async {
                      Map<String, dynamic> chatInfo = {
                        'rId': rid,
                        'nowProfile':
                            Provider.of<nowProfile>(context, listen: false)
                                .getMyProfile(),
                        'withUser': userdata,
                      };
                      await pr.hide();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(chatInfo: chatInfo),
                          ));
                    });
                  } else {
                    print('채팅 선택 : ${isChat.toString()} - $selectRoom');
                    _shareMessage(selectRoom, fileurl).then((userdata) async {
                      Map<String, dynamic> chatInfo = {
                        'rId': selectRoom,
                        'nowProfile':
                            Provider.of<nowProfile>(context, listen: false)
                                .getMyProfile(),
                        'withUser': userdata,
                      };
                      await pr.hide();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(chatInfo: chatInfo),
                          ));
                    });
                  }
                });
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            buildFirendList(),
            buildChatList(),
          ],
        ),
      ),
    );
  }

  Widget buildFirendList() {
    return Consumer<nowProfile>(builder: (context, profile, _) {
      return PreferredSize(
        child: FutureBuilder(
            future: db.getFirend(profile.getMyProfile().myPid),
            builder: (context, getList) {
              if (!getList.hasData) return Loading();

              return PreferredSize(
                  child: ListView.builder(
                      itemCount: getList.data.length,
                      itemBuilder: (context, index) {
                        Profile profile = getList.data[index];
                        return ListTile(
                          leading: profile.photoUrl == null
                              ? CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/img/noface.png'))
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(profile.photoUrl),
                                ),
                          title: Text(profile.nickname.toString()),
                          trailing: Radio(
                            value: profile.pid,
                            groupValue: selectFirend,
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                selectFirend = value;

                                Firestore.instance
                                    .collection('Profile')
                                    .document(Provider.of<nowProfile>(context,
                                            listen: false)
                                        .getMyProfile()
                                        .myPid)
                                    .collection('firend')
                                    .document(selectFirend)
                                    .get()
                                    .then((val) {
                                  if (val.data['chatOn'] == null) {
                                    var rid = createChat(
                                        Provider.of<nowProfile>(context,
                                                listen: false)
                                            .getMyProfile()
                                            .myPid,
                                        selectFirend);
                                    Map<String, dynamic> chatInfoo = {
                                      'rId': rid,
                                      'nowProfile': Provider.of<nowProfile>(
                                              context,
                                              listen: false)
                                          .getMyProfile(),
                                      'withUser': [
                                        Provider.of<nowProfile>(context,
                                                listen: false)
                                            .getMyProfile()
                                            .myPid,
                                        selectFirend
                                      ]
                                    };
                                    Firestore.instance
                                        .collection('Profile')
                                        .document(Provider.of<nowProfile>(
                                                context,
                                                listen: false)
                                            .getMyProfile()
                                            .myPid)
                                        .collection('firend')
                                        .document(selectFirend)
                                        .updateData({'chatOn': rid});
                                    Firestore.instance
                                        .collection('Profile')
                                        .document(selectFirend)
                                        .collection('firend')
                                        .document(Provider.of<nowProfile>(
                                                context,
                                                listen: false)
                                            .getMyProfile()
                                            .myPid)
                                        .updateData({'chatOn': rid});
                                  } else {
                                    val.data['chatOn'];
                                  }

                                  chatRoomie = val.data['chatOn'];

                                  if (val.data['chatOn'] == null) {
                                    return rs = true;
                                  } else {
                                    return rs = false;
                                  }
                                });
                              });
                            },
                          ),
                        );
                      }));
            }),
      );
    });
  }

  Widget buildChatList() {
    return Consumer<nowProfile>(builder: (context, profile, _) {
      return PreferredSize(
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
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('생성된 채팅방이 없습니다.').tr(),
                    )
                  ],
                );
              }
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
                    return ListView.builder(
                        itemCount: list.data.length,
                        itemBuilder: (context, index) {
                          print('리스트 빌더');
                          //print(.toString());
                          List<Profile> userdata = List<Profile>();
                          if (list.data[index]['user'].length == 0) {
                            userdata.add(Profile(
                                null,
                                null,
                                null,
                                '종료된 채팅방'.tr(),
                                null,
                                'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=3c64781a-8c71-4ca6-bbae-78bbf1662241',
                                null));
//                            userdata.add(Profile(null, null, null, '종료된 채팅방'.tr(), null, null,'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=3c64781a-8c71-4ca6-bbae-78bbf1662241', null));
                          } else {
                            userdata.addAll(list.data[index]['user']);
                          }
                          List<String> chatTitleList = List<String>();
                          userdata.forEach((element) {
                            chatTitleList.add(element.nickname.toString());
                          });

                          return //Text(userdata[0].nickname);
                              MaterialButton(
                                  padding: EdgeInsets.all(0.0),
                                  onLongPress: () async {
                                    await showDialog(
                                        context: context,
                                        child: SimpleDialog(
                                          title: Text(chatTitleList.join(', '),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          children: <Widget>[
                                            SimpleDialogOption(
                                              padding: EdgeInsets.only(
                                                  left: 24.0, top: 20.0),
                                              child: Text('채팅방 알람').tr(),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Fluttertoast.showToast(
                                                  msg: '채팅방 알림이 해제되었습니다.'.tr(),
                                                  gravity: ToastGravity.TOP,
                                                  backgroundColor: Colors.black
                                                      .withOpacity(0.7),
                                                  textColor: Colors.white,
                                                );
                                              },
                                            ),
                                            /*
                                        SimpleDialogOption(
                                          padding: EdgeInsets.only(left: 24.0, top: 20.0),
                                          child: Text('모두 읽음 처리'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                         */
                                            SimpleDialogOption(
                                              padding: EdgeInsets.only(
                                                  left: 24.0,
                                                  top: 20.0,
                                                  bottom: 10.0),
                                              child: Text('채팅방나가기').tr(),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ));
                                  },
                                  child: ListTile(
                                    leading: userdata[0].photoUrl == null
                                        ? CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'assets/img/noface.png'))
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                userdata[0].photoUrl),
                                          ),
                                    title: Text(chatTitleList.join(', ')),
                                    subtitle: (list.data[index]['lastMessage'] != null)
                                        ? (list.data[index]['lastMessage']
                                                    .toString()
                                                    .indexOf(
                                                        'firebasestorage') ==
                                                -1)
                                            ? (list.data[index]['lastMessage'].toString().length < 40)
                                                ? Text(list.data[index]
                                                        ['lastMessage']
                                                    .toString()
                                                    .replaceAll("\n", " "))
                                                : Text(list.data[index]
                                                            ['lastMessage']
                                                        .toString()
                                                        .substring(0, 40) +
                                                    "...")
                                            : Text('Image/File')
                                        : Text('-'),
                                    trailing: Radio<String>(
                                      value: list.data[index]['rid'],
                                      onChanged: _getRadioValue,
                                      groupValue: selectRoom,
                                    ),
                                  ));
                        });
                  });
            }),
      );
    });
  }
}
