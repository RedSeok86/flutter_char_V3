import 'dart:async';

import 'dart:convert';
import 'dart:core';

import 'dart:io';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ios_voip_kit/call_state_type.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:papucon/main.dart';
import 'package:papucon/model/db_helper.dart';
import 'package:papucon/pages/coming_soon.dart'; // 추후 삭제 요망
import 'package:papucon/pages/profile_screen.dart';
import 'package:papucon/pages/storageBox.dart';
import 'package:papucon/widgets/bubble_bottom_bar_custom.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/widgets/video_call.dart';
import 'package:papucon/widgets/voice_call.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/pages/friend_list.dart';
import 'package:papucon/pages/chat_page.dart';
import 'package:papucon/pages/chat_list.dart';
import 'package:papucon/pages/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:get/get.dart';

import '../theme.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'friend_find_page.dart';

import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import 'login_page.dart';

// Global Properties
int currentProfile = 0;
String pid;
var payload_data;
var payload_notification;

class HomePage extends StatefulWidget {
  // State Properties
  final int menuNum;
  const HomePage({Key key, this.menuNum}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Private Properties
  //Flutter_local_nofitacation 사용시 적용
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');
  String uid;
  int _menuIndex = 0;
  int _profileIndex = 0;
  SharedPreferences prefs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      Firestore.instance.collection('Users');
  static final now = DateTime.now();
  String _uid;

  //System overlay
  String _platformVersion = 'Unknown';
  bool _isShowingWindow = false;
  bool _isUpdatedWindow = false;

  List<MyProfile> myProfiles = List<MyProfile>();

  TabController _tabController;
  bool push_bool = true;

  int _selectedIndex = 0;
  int _currentIndex = 0;
  List<String> categories = ['로딩중'];

  DBHelper db = new DBHelper();

  final List<Widget> _children = [
    FriendList(),
    ChatList(),
//    StorageBox(),     // 비활성화
    ComingSoon(),
    SettingPage()
  ];

  List<Profile> userdata = List<Profile>();
  Map<String, dynamic> chatInfo = {
    'rId': '',
    'withUser': '',
  };

  // CallKit Properties
  final voIPKit = FlutterIOSVoIPKit.instance;
  Timer timeOutTimer;
  String rId = '';
  String type = '';

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    print('----------HOMEPAGE: initState()----------');
    db.initDB();
    getPerfs().then((value) => loadProfile());
    if (widget.menuNum == 2)
      _selectedIndex = 1;
    else if (widget.menuNum == 1) _currentIndex = 1;

    // pid = Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid;
    //nickname= Provider.of<nowProfile>(context, listen: false).getMyProfile().myNickname;

    super.initState();
    _requestIOSPermissions();
    registerNotification();
    configLocalNotification();
    _configureSelectNotificationSubject();
    initCallKit();
    super.initState();
  }

  Future<void> initCallKit() async {
    await voIPKit.getVoIPToken().then((voIPToken) async {
      print('-----iOS CallKit: Getting VoIP Token.');
      if (uid == null || uid == '') {
        await FirebaseAuth.instance.signOut();
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (Route<dynamic> route) => false);
        return;
      }
      Firestore.instance.collection('Users').document(uid).setData({
        'voIPToken': voIPToken,
      }, merge: true);
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });

    // CallKit Methods
    voIPKit.onDidReceiveIncomingPush = (
      Map<String, dynamic> payload,
    ) async {
      await Firestore.instance
          .collection('Room')
          .document(payload['rId'].toString())
          .get()
          .then((value) async {
        MyProfile myprofile;
        List<Profile> userdata = List<Profile>();
        await Firestore.instance
            .collection('Profile')
            .where('pid', whereIn: value['user'])
            .getDocuments()
            .then((user) {
          print('-----User: $user');
          user.documents.forEach((element) {
            if (element['uid'] == uid) {
              //My Profile
              myprofile = MyProfile(element['pid'], element['nickname']);
              print(uid);
              print('-----My User Nickname: ${element['nickname']}');
            } else {
              //Other User Profile
              final otherUser = Profile(
                  element['uid'],
                  element['pid'],
                  element['id'],
                  element['nickname'],
                  element['aboutMe'],
                  element['photoUrl'],
                  element['backgroundUrl']);
              userdata.add(otherUser);
              print('-----UserData: $userdata');
              print('-----UserData First: ${userdata.first.nickname}');
            }
            print('-----UserData: $userdata');
            chatInfo['withUser'] = userdata;
          });
        });
      });

      chatInfo['rId'] = payload['rId'];
      print('-----Payload: ${payload.toString()}');
      print('-----Payload: ${payload['rId']}');
      rId = payload['rId'];
      print('-----Payload: ${payload['type']}');
      if (payload['type'] == 2)
        type = 'voice'; // 2
      else {
        type = 'video'; // 3
      }
    };

    voIPKit.onDidAcceptIncomingCall = (
      String uuid,
      String callerId,
    ) {
      print('-----Call accepted.');
      voIPKit.acceptIncomingCall(callerState: CallStateType.calling);
      voIPKit.callConnected();
      timeOutTimer?.cancel();
      onJoin(type, rId);
    };

    voIPKit.onDidRejectIncomingCall = (
      String uuid,
      String callerId,
    ) {
      print('-----Call rejected.');
    };
  }

  Future<void> onJoin(String type, String rId) async {
    // update input validation
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();
    // push video page with given channel name
    if (type == 'video') {
      await Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => videoCallPage(
            channelName: rId,
            role: ClientRole.Broadcaster,
            callKit: voIPKit,
          ),
        ),
      );
    } else if (type == 'voice') {
      //print(widget.chatInfo.toString());

      /* Map endMsg = {
        'uidFrom': uid,
        'idFrom': Provider.of<nowProfile>(context, listen: false).getMyProfile().myPid,
        'idTo': toUid,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': '通話終了',
        'type': 0,
        'locale': context.locale.languageCode.toString()
      }; */
      //widget.chatInfo['endMsg'] = endMsg;
      await Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => voiceCallPage(
            chatInfo: chatInfo,
            channelName: rId,
            role: ClientRole.Broadcaster,
            callKit: voIPKit,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  void dispose() {
    //  didReceiveLocalNotificationSubject.close();
    //selectNotificationSubject.close();
    //CallKit Dispose
    timeOutTimer?.cancel();
    voIPKit.dispose();
    super.dispose();
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((var payload) async {
      print('----------configSelectNotificationSubject()----------');
      //print('PAYLOAD DATA: CHECK :${payload_data.toString()}');
      //print(payload_data['type'].toString());
      //Map json_firend = json.decode(payload_data);
      showNotification(payload_data);
      //   print('호있 : ${json_firend.length}');
      //  print('호있 : ${json_firend['nickname'].toString()}');
//      if (payload_data['type'].toString() == "firend") {
//        //print("payload ge t" + payload_data['pid']);
//        MyProfile passingdata =
//        MyProfile(payload_data['pid'], payload_data['nickname']);
//        await Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => FriendFind(nowProfile: passingdata)),
//        );
//      }else {
//        Firestore.instance
//            .collection('Room')
//            .document(payload_data['rid'].toString())
//            .get()
//            .then((value) {
//          print(value['user'].toString());
//          MyProfile myprofile;
//          List<Profile> userdata = List<Profile>();
//          Firestore.instance
//              .collection('Profile')
//              .where("pid", whereIn: value['user'])
//              .getDocuments()
//              .then((user) {
//            user.documents.forEach((element) {
//              if (element['uid'] == uid)
//                myprofile = MyProfile(element['pid'], element['nickname']);
//              var tapProfile = Profile(
//                  element['uid'],
//                  element['pid'],
//                  element['id'],
//                  element['nickname'],
//                  element['aboutMe'],
//                  element['photoUrl'],
//                  element['backgroundUrl']);
//              print("USEr ${element['nickname']}");
//              userdata.add(tapProfile);
//            });
////            if(user.length==0){
////              userdata.add(Profile(null, null, null, '종료된 채팅방'.tr(), null, null,  'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=3c64781a-8c71-4ca6-bbae-78bbf1662241'));
////            }else{
////              userdata.addAll(list.data[index]['user']);
////            }
//            Map<String, dynamic> chatInfo = {
//              'rId': payload_data['rid'].toString(),
//              'nowProfile': myprofile,
//              'withUser': userdata,
//            };
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => ChatPage(chatInfo: chatInfo),
//                ));
//          });
//        });
//      }
    });
  }

  Future<void> getPerfs() async {
    print('-----getPerfs()-----');
    prefs = await SharedPreferences.getInstance();

    uid = prefs.getString('uid') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    push_bool = prefs.getBool('push_bool') ?? true;
    return uid;
  }

  void loadProfile() async {
    print('-----loadProfile()-----');

    if (uid == null || uid == '') {
      await FirebaseAuth.instance.signOut();
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (Route<dynamic> route) => false);
      return;
    }
    Firestore.instance.collection('Users').document(uid).get().then((value1) {
      Firestore.instance
          .collection('Users')
          .document(uid)
          .collection('profile')
          .getDocuments()
          .then((value) {
            var lastProfile;  // 마지막 접속 프로필 값
            var lastProfileName;  // 마지막 접속 프로필 닉네임
        lastProfile = value1.data['lastProfile'];
        lastProfileName = value1.data['lastProfileName'];
        for (var user in value.documents) {
          myProfiles.add(MyProfile(user.data['pid'], user.data['nickname']));
        }

        setState(() {});
        if (Provider.of<nowProfile>(context, listen: false).getMyProfile().toString() == 'null') {
          if(lastProfile == null) {
            Provider.of<nowProfile>(context, listen: false).setMyProfile(myProfiles.last);  // 프로필 생성 후 프로필 변경을 한번도 하지 않았을 때
          } else {
            Provider.of<nowProfile>(context, listen: false).setMyProfile(MyProfile(lastProfile, lastProfileName));  // 프로필 생성 후 한번이라도 변경했을 때
          }
        }
      });
    });
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print('----------onMessage()----------');
          print('---Message. $message');
          payload_data = Platform.isAndroid
              ? message['data'] //Android
              : message; //iOS
          payload_notification =
              Platform.isIOS ? message['aps'] : message['notification'];
          //payload_notification = message['notification'];
          //if (push_bool) {
          print('FCM Configure: Default');
          showNotification(payload_notification);
          //notificationAction(payload_data, context);
          selectNotificationSubject.add(message['data'].toString());

          //} // Platform.isAndroid ? selectNotificationSubject.add(message['notification']):selectNotificationSubject.add(message['notification']);//showNotification(message['notification']) : showNotification(message['aps']['alert']);
          return;
        },
        onBackgroundMessage: Platform.isIOS
            ? null
            : Fcm.myBackgroundMessageHandler, //Fcm.myBackgroundMessageHandler,
        onResume: (Map<String, dynamic> message) {
          payload_data = Platform.isAndroid
              ? message['data'] //Android
              : message; //iOS
          print('onResume: $message');
          if (push_bool) {
            notificationAction(payload_data);
            //print('FCM configure: onResume');
            //showNotification(message['notification']);
            selectNotificationSubject.add(message['data']);
          } //selectNotificationSubject.add(message['notification']);//Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print('onLaunch: $message');
          print('FCM configure: onLaunch');
          if (push_bool) {
            showNotification(message['notification']);
            selectNotificationSubject.add(message['data']);
          }
          //selectNotificationSubject.add(message['notification']);//Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
          return;
        });
    // Token 등록
    firebaseMessaging.getToken().then((token) async {
      if (uid == null || uid == '') {
        await FirebaseAuth.instance.signOut();
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (Route<dynamic> route) => false);
        return;
      }
      Firestore.instance.collection('Users').document(uid).setData({
        'pushToken': token,
        'locale': context.locale.languageCode.toString()
      }, merge: true);
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void notificationAction(var payload_data) async {
    print('notificationAction');
    print(payload_data);
    if (payload_data['type'].toString() == "firend") {
      print("Payload get" + payload_data['pid']);
      MyProfile passingdata =
          MyProfile(payload_data['pid'], payload_data['nickname']);
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FriendFind(nowProfile: passingdata)),
      );
    } else if (payload_data['type'].toString() == "voice") {
      Firestore.instance
          .collection('Room')
          .document(payload_data['rid'].toString())
          .get()
          .then((value) {
        MyProfile myprofile;
        List<Profile> userdata = List<Profile>();
        Firestore.instance
            .collection('Profile')
            .where("pid", whereIn: value['user'])
            .getDocuments()
            .then((user) async {
          user.documents.forEach((element) {
            if (element['uid'] == uid)
              myprofile = MyProfile(element['pid'], element['nickname']);
            var tapProfile = Profile(
                element['uid'],
                element['pid'],
                element['id'],
                element['nickname'],
                element['aboutMe'],
                element['photoUrl'],
                element['backgroundUrl']);
            userdata.add(tapProfile);
          });
          print('voice');

          Map endMsg = {
            'uidFrom': uid,
            'idFrom': Provider.of<nowProfile>(context, listen: false)
                .getMyProfile()
                .myPid,
            'idTo': payload_data['topid'].toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': '通話終了',
            'type': 0,
            'locale': context.locale.languageCode.toString()
          };

          Map<String, dynamic> chatInfo = {
            'rId': payload_data['rid'].toString(),
            'endMsg': endMsg,
            'nowProfile': myprofile,
            'withUser': userdata,
            'type': 'voice'
          };
          print(payload_data['rid'].toString());
          print(chatInfo);

          try {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(chatInfo: chatInfo),
                ));
          } catch (e) {
            print('네비게이션 에러 $e');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatPage(chatInfo: chatInfo)));
          }
        });
      });
    } else if (payload_data['type'].toString() == "video") {
      Firestore.instance
          .collection('Room')
          .document(payload_data['rid'].toString())
          .get()
          .then((value) {
        MyProfile myprofile;
        List<Profile> userdata = List<Profile>();
        Firestore.instance
            .collection('Profile')
            .where("pid", whereIn: value['user'])
            .getDocuments()
            .then((user) async {
          user.documents.forEach((element) {
            if (element['uid'] == uid)
              myprofile = MyProfile(element['pid'], element['nickname']);
            var tapProfile = Profile(
                element['uid'],
                element['pid'],
                element['id'],
                element['nickname'],
                element['aboutMe'],
                element['photoUrl'],
                element['backgroundUrl']);
            userdata.add(tapProfile);
          });
          print('voice');

          Map endMsg = {
            'uidFrom': uid,
            'idFrom': Provider.of<nowProfile>(context, listen: false)
                .getMyProfile()
                .myPid,
            'idTo': payload_data['topid'].toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': '通話終了',
            'type': 0,
            'locale': context.locale.languageCode.toString()
          };

          Map<String, dynamic> chatInfo = {
            'rId': payload_data['rid'].toString(),
            'endMsg': endMsg,
            'nowProfile': myprofile,
            'withUser': userdata,
            'type': 'video'
          };
          print(payload_data['rid'].toString());
          print(chatInfo);

          try {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(chatInfo: chatInfo),
                ));
          } catch (e) {
            print('네비게이션 에러 $e');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatPage(chatInfo: chatInfo)));
          }
        });
      });
    } else {
      Firestore.instance
          .collection('Room')
          .document(payload_data['rid'].toString())
          .get()
          .then((value) {
        print(value['user'].toString());
        MyProfile myprofile;
        List<Profile> userdata = List<Profile>();
        Firestore.instance
            .collection('Profile')
            .where("pid", whereIn: value['user'])
            .getDocuments()
            .then((user) {
          user.documents.forEach((element) {
            if (element['uid'] == uid)
              myprofile = MyProfile(element['pid'], element['nickname']);
            var tapProfile = Profile(
                element['uid'],
                element['pid'],
                element['id'],
                element['nickname'],
                element['aboutMe'],
                element['photoUrl'],
                element['backgroundUrl']);
            userdata.add(tapProfile);
          });
//            if(user.length==0){
//              userdata.add(Profile(null, null, null, '종료된 채팅방'.tr(), null, null,  'https://firebasestorage.googleapis.com/v0/b/tapick-chat.appspot.com/o/no_pofile.png?alt=media&token=3c64781a-8c71-4ca6-bbae-78bbf1662241'));
//            }else{
//              userdata.addAll(list.data[index]['user']);
//            }
          Map<String, dynamic> chatInfo = {
            'rId': payload_data['rid'].toString(),
            'nowProfile': myprofile,
            'withUser': userdata,
          };
          try {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(chatInfo: chatInfo),
                ));
          } catch (e) {
            print('네비게이션 에러 $e');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatPage(chatInfo: chatInfo)));
          }
        });
      });
    }
    return;
  }

  void showNotification(message) async {
    print('----------showNotification()----------');
    var messagePlatform = message;
    if (Platform.isIOS) {
      messagePlatform = message['alert'];
    }
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'papucon_chat' : 'com.duytq.flutterchatdemo',
      'papucon_chat',
      'Papucon Messenger',
      sound: RawResourceAndroidNotificationSound('papupapu'),
      playSound: true,
      enableVibration: true,
      enableLights: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: 'papupapu.caf');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print('---Notification body.' + messagePlatform['body'].toString());
    print('---Notification json encoded.' + json.encode(messagePlatform));
    if (messagePlatform['title'].toString() != 'null' &&
        messagePlatform['body'].toString() != 'null') {
      await flutterLocalNotificationsPlugin.show(
          0,
          messagePlatform['title'].toString(),
          messagePlatform['body'].toString(),
          platformChannelSpecifics,
          payload: json.encode(messagePlatform));
    }

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  Future<void> configLocalNotification() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    //flutterLocalNotificationsPlugin.initialize(initializationSettings);// onSelectNotification: selectNotification);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      notificationAction(payload_data);
    });
  }

  //////Widget Start

  @protected
  @mustCallSuper
  void deactivate() {
    print('deactivate');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // WidgetsBinding.instance.addPostFrameCallback((_) =>getCurrentUser(context));
    developer.log('log me', name: '222.app.category');
    return Consumer2<LoginStore, nowProfile>(
      builder: (context, loginStore, profile, _) {
        return Scaffold(
          body: Platform.isAndroid
              ? Padding(
                  padding: const EdgeInsets.only(top: 23),
                  child: _children[_currentIndex],
                )
              : Container(
                  color: const Color(0xFFf2f3f6),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 23),
                    child: _children[_currentIndex],
                  ),
                ),
          bottomNavigationBar: SizedBox(
              height: MediaQuery.of(context).viewPadding.bottom > 0.0 ? 80 : 55,
              child: BottomNaviBar()),
        );
      },
    );
  }

  void changePage(int index) {
    print('Bottom Menu Click $index');
    //print(myProfiles.first.myNickname);

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget BottomNaviBar() {
    return BubbleBottomBar(
      opacity: .2,
      currentIndex: _currentIndex,
      onTap: changePage,
      backgroundColor: Color(0xFFf2f3f6),
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      //fabLocation: BubbleBottomBarFabLocation.center, //new
      hasNotch: true,
      //new
      hasInk: true,
      //new, gives a cute ink effect
      inkColor: Colors.black12,
      //optional, uses theme color if not specified
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: Color(0xFFD0393e),
            icon: SvgPicture.asset("assets/img/home_on.svg",
                color: Color(0xFF1a1a1a), width: 14, height: 18),
            activeIcon: SvgPicture.asset("assets/img/home_on.svg",
                color: Color(0xFFD0393e), width: 14, height: 18),
            title: Text("Home", style: TextStyle(fontSize: 11)).tr()),
        BubbleBottomBarItem(
            backgroundColor: Color(0xFFD0393e),
            icon: SvgPicture.asset("assets/img/chat_on.svg",
                color: Color(0xFF1a1a1a), width: 14, height: 18),
            activeIcon: SvgPicture.asset("assets/img/chat_on.svg",
                color: Color(0xFFD0393e), width: 14, height: 18),
            title: Text("Chat", style: TextStyle(fontSize: 11)).tr()),
        BubbleBottomBarItem(
            backgroundColor: Color(0xFFD0393e),
            icon: SvgPicture.asset("assets/img/storage_on.svg",
                color: Color(0xFF1a1a1a), width: 14, height: 18),
            activeIcon: SvgPicture.asset("assets/img/storage_on.svg",
                color: Color(0xFFD0393e), width: 14, height: 18),
            title: Text("Storage", style: TextStyle(fontSize: 11)).tr()),
        BubbleBottomBarItem(
            backgroundColor: Color(0xFFD0393e),
            icon: SvgPicture.asset("assets/img/set_on.svg",
                color: Color(0xFF1a1a1a), width: 14, height: 18),
            activeIcon: SvgPicture.asset("assets/img/set_on.svg",
                color: Color(0xFFD0393e), width: 14, height: 18),
            title: Text("Setting", style: TextStyle(fontSize: 11)).tr())
      ],
    );
  }
}

class Fcm {
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print('BACKWORK showOverlayWindow ${data}');
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print('notification BACK ${notification}');
    }
    developer.log('myBackgroundMessageHandler', name: 'my.app.category');
    print('myBackgroundMessageHandler ${message}');

    // Or do other work.
    // showOverlayWindow();
  }
}
