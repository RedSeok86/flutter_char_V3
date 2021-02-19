import 'package:flutter/cupertino.dart';

class MyProfile {
  final String myPid;
  final String myNickname;
  MyProfile(this.myPid, this.myNickname);
}

class nowProfile extends ChangeNotifier {
  MyProfile _nowProfile;

  MyProfile getMyProfile() => _nowProfile;

  setMyProfile(MyProfile myprofile) {
    print('----------Provider: Setting Profile ...----------');
    _nowProfile = myprofile;
    notifyListeners();
    print('----------Current Profile: ${_nowProfile.myNickname}');
  }
}

class storeUID extends ChangeNotifier {
  String _uid;

  getUID() => _uid;

  setUID(String uid) {
    _uid = uid;
    notifyListeners();
    print('UID 적용');
  }
}

class menuIndex extends ChangeNotifier {
  int _index;
  getIndex() => _index;

  setIndex(int index) {
    _index = index;
    notifyListeners();
    print('현재 메뉴 $index');
  }
}

class Profile {
  final String uid;
  final String pid;
  final String id;
  final String nickname;
// final String group;
  final String aboutme;
  final String photoUrl;
  final String backgroundUrl;

  Profile _profile;
  Profile(this.uid, this.pid, this.id, this.nickname, this.aboutme,
      this.photoUrl, this.backgroundUrl);

  Profile getMyProfile() => _profile;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pid': pid,
      'id': id,
      'nickname': nickname,
      'aboutme': aboutme,
      'photoUrl': photoUrl,
      'backgroundUrl': backgroundUrl
    };
  }
}

class ChatInfo {
  final String rid;
  final String user;
  final bool alert;
  final bool translate;
  final String status;
  final String owner;
  final String lastMessage;
  ChatInfo _chatInfo;

  ChatInfo(
      {this.rid,
      this.user,
      this.alert,
      this.translate,
      this.status,
      this.owner,
      this.lastMessage});

  ChatInfo getChatInfo() => _chatInfo;

  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'user': user,
      'alert': alert,
      'translate': translate,
      'status': status,
      'owner': owner,
      'lastMessage': lastMessage,
    };
  }

  getuser(rid) => _chatInfo.user;
  getTranslate(rid) => _chatInfo.translate;
}
