import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:papucon/pages/friend_list.dart';
import 'package:papucon/pages/home_page.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/util/image.dart';
import 'package:papucon/widgets/full_photo.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:papucon/model/model.dart';
import 'package:intl/intl.dart';
import 'package:papucon/widgets/video_call.dart';
import 'package:papucon/widgets/voice_call.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:translator/translator.dart';

import '../main.dart';

class ChatPage extends StatefulWidget {
  Map<String, dynamic> chatInfo;
  ChatPage({Key key, @required this.chatInfo}) : super(key: key);

  @override
  State createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  ImagesUtil img = new ImagesUtil();
  String Uid;

  List<String> items = [
    "AI",
    "日本語",
    "한국어",
    "English",
  ];
  List<String> items_code = [
    "auto",
    "ja",
    "ko",
    "en",
  ];

  Timer startTimer = null;
  int vm = 0;
  String rId = '';
  String renameChat;
  String chatTitle = '';
  MyProfile myProfile;
  SharedPreferences prefs;
  var listMessage;
  File imageFile;
  bool isLoading;
  bool isShowSticker;
  bool isDisabled;
  bool isShowMoreBox;
  bool translate;
  String imageUrl;
  String fileNames;
  bool _getChangeButton = false;
  bool isChangeSearch;
  bool searchClearButton = false;
  bool roomRenameButton = false;
  bool notificationOffButton;
  bool progressbar = false;
  double taskProgressNum = 0.0;

  String local_from = "auto";
  String local_to = "auto";


  int totals = 1;
  QuerySnapshot totals_snap = null;

  Map user = Map();
  List<Profile> userList = List<Profile>();
  List<String> toUid = List<String>();
  List<String> exitUserN = List<String>();

  List<bool> isTranslate = List<bool>();
  List<String> translateText = List<String>();

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController searchEditingController = TextEditingController();
  final TextEditingController roomRenameController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final translator = GoogleTranslator();

  startTime(var type) async {
    print(type);
    var _duration = Duration(milliseconds: 700);
    if (type == 'voice')
      return Timer(_duration, VoiceNavigationPage);
    else if (type == 'video') return Timer(_duration, VideoNavigationPage);
  }

  @override
  void dispose() {
    platform.invokeMethod('noti', "");
    // TODO: implement dispose
    super.dispose();

    platform.invokeMethod('noti', "");
  }

  void VideoNavigationPage() {
    _handleCameraAndMic().then((value) {
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => videoCallPage(
            channelName: rId,
            role: ClientRole.Broadcaster,
          ),
        ),
      );
    });
  }

  void VoiceNavigationPage() {
    _handleCameraAndMic().then((value) {
      Map endMsg = {
        'uidFrom': uid,
        'idFrom': myProfile.myPid,
        'idTo': toUid,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': '通話終了',
        'type': 0,
        'locale': context.locale.languageCode.toString()
      };
      widget.chatInfo['endMsg'] = endMsg;
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => voiceCallPage(
            chatInfo: widget.chatInfo,
            channelName: rId,
            role: ClientRole.Broadcaster,
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    isLoading = false;
    isShowSticker = false;
    isDisabled = false;
    isShowMoreBox = false;
    imageUrl = '';
    isChangeSearch = false;
    notificationOffButton = false;
    renameChat = '';
    GetInfo();
    print('챗룸 start');

    print(widget.chatInfo.toString());
    rId = widget.chatInfo['rId'].toString();
    myProfile = widget.chatInfo['nowProfile'];
    print(myProfile.myNickname);
    List<Profile> withUser = widget.chatInfo['withUser'];
    withUser.forEach((element) {
      toUid.add(element.uid);
    });
    print('보내는사람 UID');
    print(toUid);
    //GetInfo();
    userList = widget.chatInfo['withUser'];
    userList.forEach((element) {
      user[element.pid] = element;
    });
    user = Map.fromIterable(userList, key: (e) => e.pid, value: (e) => e);

    loadImageList();
    super.initState();

    if (widget.chatInfo['type'] == 'voice') {
      startTime('voice');
    } else if (widget.chatInfo['type'] == 'video') {
      startTime('video');
    }

    textEditingController.addListener(() {
      setState(() {
        // 채팅 입력란
        _getChangeButton = textEditingController.text.length > 0;
      });
    });

    searchEditingController.addListener(() {
      setState(() {
        // 채팅 검색란
        searchClearButton = searchEditingController.text.length > 0;
      });
    });

    roomRenameController.addListener(() {
      setState(() {
        // 채팅 검색란
        roomRenameButton = roomRenameController.text.length > 0;
      });
    });
  }

  Future<void> GetInfo() async {
    prefs = await SharedPreferences.getInstance();

    translate = prefs.getBool('translate') ?? true;
    notificationOffButton = prefs.getBool('push_bool') ?? true;
    Firestore.instance.collection('Room').document(rId).get().then((value) {
      totals = value.data['user'].length;
      print("몇명있냐${value.data['user'].length}");

      //print(value.data['diabled'].toString());
      if (value.data['diabled'] != null) {
        if (value.data['diabled'] == 'true') {
          setState(() {
            isDisabled = true;
          });
        }
      }
      if (widget.chatInfo['withUser'].length == 0) {
        setState(() {
          isDisabled = true;
        });
      } else if (widget.chatInfo['withUser'].first.pid == null) {
        setState(() {
          isDisabled = true;
        });
      }
    });

    //uid = prefs.getString('uid') ?? '';
    //print('uid $uid');
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = Video Call ,3 = Voice Call, Other = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      textEditingController.clearComposing();
      textEditingController.selection = TextSelection.collapsed(offset: 0);
      //textEditingController.clear();

      searchEditingController.clear();
    }
    print('챗방');
    print(toUid);
    print(rId);
    var documentReference = Firestore.instance
        .collection('Room')
        .document(rId)
        .collection('Message')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    //if(content.trim().length <= 0 || type == 5) {
    if (content.trim().length <= 0) {
      print('fail. no text');
    } else {
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'uidFrom': uid,
            'idFrom': myProfile.myPid,
            'idTo': toUid,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'locale': context.locale.languageCode.toString()
          },
        );
      }).then((value) {
        Firestore.instance
            .collection('Room')
            .document(rId)
            .updateData({'actionTime': DateTime.now(), 'lastMessage': content});
      });

      onUpdateRomm("", 1);
      getRoomInfo();
    }

    //  listScrollController.animateTo(
    //     0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void onUpdateRomm(String content, int type) {
    print('챗방');
    print(toUid);
    print(rId);
    var documentReference = Firestore.instance
        .collection('Room')
        .document(rId)
        .collection('ReadInfo')
        .document(myProfile.myPid.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        {
          'date': "${DateTime.now().millisecondsSinceEpoch.toString()}",
        },
      );
    }).then((value) {
      vm = 0;
    });

    //  listScrollController.animateTo(
    //     0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadImage();
    }
  }

  Future<File> getPicture() async {
    File anyFile = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: [
        'bmp',
        'jpeg',
        'jpg',
        'png',
        'tif',
        'tiff',
        'tga',
        'ai',
        'eps',
        'psd',
        'BMP',
        'JPEG',
        'JPG',
        'PNG',
        'TIF',
        'TIFF',
        'TGA',
        'AI',
        'EPS',
        'PSD',
      ],
    );
    print(anyFile.path.toString());
    return anyFile;
  }

  Future<File> getFile() async {
    File anyFile = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: [
        'txt',
        'log',
        'odt',
        'snb',
        'TXT',
        'LOG',
        'ODT',
        'SNB',
        'csv',
        'xls',
        'xlsx',
        'xml',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'pub',
        'hwp',
        'show',
        'pdf',
        'pages',
        'numbers',
        'key',
        'keynote',
        'odf',
        'ods',
        'odp',
        'tsv',
        'CSV',
        'XLS',
        'XLSX',
        'XML',
        'DOC',
        'DOCX',
        'PPT',
        'PPTX',
        'PUB',
        'HWP',
        'SHOW',
        'PDF',
        'PAGES',
        'NUMBERS',
        'KEY',
        'KEYNOTE',
        'ODF',
        'ODS',
        'ODP',
        'TSV',
        'bmp',
        'jpeg',
        'jpg',
        'png',
        'tif',
        'tiff',
        'tga',
        'ai',
        'eps',
        'psd',
        'BMP',
        'JPEG',
        'JPG',
        'PNG',
        'TIF',
        'TIFF',
        'TGA',
        'AI',
        'EPS',
        'PSD',
        '3gp',
        'avi',
        'mov',
        'mp4',
        'mpeg',
        'mpg',
        'wmv',
        'm4v',
        'flv',
        'ts',
        'ogv',
        '3GP',
        'AVI',
        'MOV',
        'MP4',
        'MPEG',
        'MPG',
        'WMV',
        'M4V',
        'FLV',
        'TS',
        'OGV',
        'm4a',
        'mp3',
        'ogg',
        'wav',
        'wma',
        'flac',
        'aac',
        'tta',
        'tak',
        'M4A',
        'MP3',
        'OGG',
        'WAV',
        'WMA',
        'FLAC',
        'AAC',
        'TTA',
        'TAK',
        'epub',
        'mobi',
        'EPUB',
        'MOBI',
        'zip',
        '7z',
        'rar',
        'alz',
        'egg',
        'ZIP',
        '7Z',
        'RAR',
        'ALZ',
        'EGG',
        'pat',
        'abr',
        'PAT',
        'ABR',
        'ttf',
        'otf',
        'TTF',
        'OTF',
      ],
    );
    print(anyFile.path.toString());
    return anyFile;
  }

  Future getCamera() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadImage();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;

      if (isShowSticker) {
        isShowMoreBox = false;
      }
    });
  }

  void getMoreBox() {
    focusNode.unfocus();
    setState(() {
      isShowMoreBox = !isShowMoreBox;

      if (isShowMoreBox) {
        isShowSticker = false;
      }
    });
  }

  void getChangeSearch() {
    focusNode.unfocus();
    setState(() {
      isChangeSearch = !isChangeSearch;
    });
  }

  void getNotification() {
    focusNode.unfocus();
    prefs.setBool('push_bool', !notificationOffButton);
    setState(() {
      notificationOffButton = !notificationOffButton;

      if (notificationOffButton) {
        Fluttertoast.showToast(
          msg: '채팅방 알림이 해제되었습니다'.tr(),
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
            msg: '채팅방 알림이 설정되었습니다'.tr(),
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white);
      }
    });
  }

  void getTranslate() {
    focusNode.unfocus();
    prefs.setBool('translate', !translate);
    setState(() {
      translate = !translate;

      if (translate) {
        showLangBox(context);
        Fluttertoast.showToast(
          msg: '번역 기능이 설정되었습니다'.tr(),
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black.withOpacity(0.7),
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
            msg: '번역 기능이 해제되었습니다'.tr(),
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white);
      }
    });
  }

  void exitRoom(var context) {
    print('Disabled Procesxsing $rId');
    print('현재프로필');
    print(widget.chatInfo['nowProfile'].myPid);
    //Firestore.instance.collection('Room').document(rId).updateData({'diabled':'true'});
    Firestore.instance.collection('Room').document(rId).get().then((value) {
      List<String> updateUser = List<String>.from(value['user'].toList());
      List<String> exitUsers = List<String>.from(value['exitUser'].toList());
      if (updateUser.length < 3) {
        Firestore.instance
            .collection('Profile')
            .document(userList.first.pid)
            .collection('firend')
            .document(widget.chatInfo['nowProfile'].myPid)
            .updateData({'chatOn': null});
        Firestore.instance
            .collection('Profile')
            .document(widget.chatInfo['nowProfile'].myPid)
            .collection('firend')
            .document(userList.first.pid)
            .updateData({'chatOn': null});
      }
      exitUsers.add(Provider.of<nowProfile>(context, listen: false).getMyProfile().myNickname);
      Firestore.instance
          .collection('Room')
          .document(rId)
          .updateData({'exitUser': exitUsers});
      updateUser.remove(widget.chatInfo['nowProfile'].myPid);
      Firestore.instance
        .collection('Room')
        .document(rId)
        .updateData({'user': updateUser});
      print('user $updateUser');
      Navigator.pop(this.context);
    });
  }

  void renameRoom() {
    renameChat = roomRenameController.text;
    Firestore.instance
        .collection('Room')
        .document(rId)
        .get()
        .then((value) async {
      if (renameChat != '') {
        Firestore.instance
            .collection('Room')
            .document(rId)
            .collection('user')
            .document(pid)
            .updateData({'title': renameChat});
        var titleData = await Firestore.instance
            .collection('Room')
            .document(rId)
            .collection('user')
            .document(pid)
            .snapshots()
            .listen((DocumentSnapshot ds) {
          chatTitle = ds.data['title'];
        });
//        chatTitle = titleData;
      } else {
        var titleData = await Firestore.instance
            .collection('Room')
            .document(rId)
            .collection('user')
            .document(pid)
            .snapshots()
            .listen((DocumentSnapshot ds) {
          chatTitle = ds.data['title'];
        });
//        chatTitle = titleData;
      }
    });
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
          ),
        ),
      );
    } else if (type == 'voice') {
      print(widget.chatInfo.toString());

      print('------uid $uid');
      print('-----idfrom ${myProfile.myPid}');
      print('----idTo $toUid');
      Map endMsg = {
        'uidFrom': uid,
        'idFrom': myProfile.myPid,
        'idTo': toUid,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': '通話終了',
        'type': 0,
        'locale': context.locale.languageCode.toString()
      };
      widget.chatInfo['endMsg'] = endMsg;
      await Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => voiceCallPage(
            chatInfo: widget.chatInfo,
            channelName: rId,
            role: ClientRole.Broadcaster,
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

  Future<void> _handleStorage() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.storage], //Android: External Storage / iOS: Nothing
    );
  }

  Future uploadImage() async {
    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child('${myProfile.myPid}/')
        .child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: '이미지 파일이 아닙니다'.tr());
    });
  }

  Future uploadPicture(File file) async {
    String fileName = path.basename(file.path);

    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(myProfile.myPid.toString() + '/' + fileName);
    StorageUploadTask uploadTask = reference.putFile(file);
    uploadTask.events.listen((event) {
      //여기기
      print('------upload file--------');

      double res = event.snapshot.bytesTransferred / 1024.0;
      double res2 = event.snapshot.totalByteCount / 1024.0;
      setState(() {
        progressbar = true;
        taskProgressNum = res / res2;
      });
    });
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      fileNames = fileName;
      setState(() {
        progressbar = false;
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: '이미지 파일이 아닙니다.'.tr());
    });
  }

  Future uploadFile(File file) async {
    String fileName = path.basename(file.path);

    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(myProfile.myPid.toString() + '/' + fileName);
    StorageUploadTask uploadTask = reference.putFile(file);
    uploadTask.events.listen((event) {
      print('------upload file--------');

      double res = event.snapshot.bytesTransferred / 1024.0;
      double res2 = event.snapshot.totalByteCount / 1024.0;
      setState(() {
        progressbar = true;
        taskProgressNum = res / res2;
      });
    });
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      fileNames = fileName;
      setState(() {
        progressbar = false;
        isLoading = false;
        onSendMessage(imageUrl, 6);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: '이미지 파일이 아닙니다.'.tr());
    });
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == myProfile.myPid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != myProfile.myPid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  String stripQueryStringAndHashFromPath(url) {
    return url.split("?")[0];
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //Android Path
        : await getApplicationDocumentsDirectory(); //iOS Path
    print(directory.path);
    return directory.path;
  }

  Future<String> dirCreator() async {
    String localPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'files';
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<void> download(String fileurl, String filename) async {
    //dirCreator();
    print('-------Download-------');
    _handleStorage();
    String localPath =
        await _findLocalPath() + Platform.pathSeparator + 'PapuconDownload';
    final savedDir = Platform.isIOS
        ? Directory(localPath)
        : Directory('storage/emulated/0/PapuconDownload');
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    final taskId = FlutterDownloader.enqueue(
      url: fileurl,
      savedDir: savedDir.path,
      fileName: filename,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  @override
  Widget build(BuildContext context) {
    print("갱신");
    List<String> chatTitleList = List<String>();
    widget.chatInfo['withUser'].forEach((element) {
      print('타이틀: ${element.nickname}');

      chatTitleList.add(element.nickname.toString());
    });

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Scaffold(
          appBar: changeSearchBtn(),
          drawer: Container(
            width: MediaQuery.of(context).size.width / 1.75,
            child: Drawer(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: widget.chatInfo['withUser'].length,
                    itemBuilder: (context, index) {
                      Profile profile = widget.chatInfo['withUser'][index];
                      return ListTile(
                          leading: (profile.photoUrl == null)
                              ? CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/img/noface.png'),
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(profile.photoUrl),
                                ),
                          title: Text(profile.nickname));
                    })),
          ),
          body: Center(
              child: Stack(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFf2f3f6),
              ),
              child: Column(
                children: <Widget>[
                  buildListMessage(),
                  Visibility(
                    //upload profress bar
                    //child: Text(taskProgressNum.toString())
                    visible: progressbar,
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width,
                      lineHeight: 8.0,
                      percent: taskProgressNum,
                      linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: MyColors.primaryColor,
                    ),
                  ),

                  !isDisabled ? buildInput() : Container(),
                  isShowSticker ? buildSticker() : Container(), // Sticker
                  isShowMoreBox ? chatRoomPlusBox() : Container(), // PlusBox
                ],
              ),
            ),
            buildLoading(),
          ]))),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Material(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFf5f6f7),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                  child: changeMoreBoxButton(),
                ),
                color: Colors.white,
              ),
              // Edit text
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(right: 8.0, top: 9.0, bottom: 9.0),
                  padding: EdgeInsets.only(left: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 0.5, color: Colors.black.withAlpha(26)),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x19000000),
                      )
                    ],
                  ),
                  child: Container(
                    width: 280.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: TextField(
                              maxLines: 10,
                              minLines: 1,
                              maxLength: 1000,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(fontSize: 14.0),
                              controller: textEditingController,
                              decoration: InputDecoration(
                                  counterText: '',
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: '메세지를 입력하세요'.tr(),
                                  hintStyle: TextStyle(
                                      color: Colors.black.withAlpha(26)),
                                  errorMaxLines: null),
                              focusNode: focusNode,
                              onTap: () {
                                isShowMoreBox = false;
                                isShowSticker = false;
                              },
                            ),
                          ),
                        ),
                        changeEmojiButton(),
                      ],
                    ),
                  ),
                ),
              ),
              // Button send message
              Material(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFf5f6f7),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                  child: getChangeSendBtn(),
                ),
                color: Colors.white,
              ),
            ],
          ),
          width: double.infinity,
          decoration: BoxDecoration(color: Color(0xFFf5f6f7)),
        ),
//    chatRoomPlusBox(),
      ],
    );
  }

  void getRoomInfo() {
    Firestore.instance
        .collection('Room')
        .document(rId)
        .collection('ReadInfo')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((value) => [
              totals_snap = value,
              //vm = 1,
              if (vm == 0)
                {
                  vm = 1,
                  this.setState(() {
                    platform.invokeMethod('noti', rId.toString());
                  }),
                }
            ]);
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('Room')
            .document(rId)
            .collection('Message')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(MyColors.primaryColor)));
          } else {
            listMessage = snapshot.data.documents;

            if (vm == 1) {
              onUpdateRomm("갱신", 1);

              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    buildItem(index, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
                reverse: true,
                controller: listScrollController,
              );
            } else {
              getRoomInfo();
              getLangInfo();
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    buildItem(index, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
                reverse: true,
                controller: listScrollController,
              );
            }
          }
        },
      ),
    );
  }

  Widget buildListMessage2() {
    return Flexible(
      child: StreamBuilder(),
    );
  }

  Widget buildFileMessage(String fileurl, bool RightMessage) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.0),
            topLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
          boxShadow: [
            BoxShadow(
                offset: Offset(-1, -1), color: Colors.white, blurRadius: 1),
            BoxShadow(
                offset: Offset(1, 1),
                color: Colors.black.withOpacity(0.2),
                blurRadius: 1)
          ]),
      margin: EdgeInsets.only(left: 10, top: 3, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8.0),
          topLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    print("Container was tapped");
                    print(fileurl);
                    download(
                        fileurl,
                        path.basename(stripQueryStringAndHashFromPath(
                            Uri.decodeComponent(fileurl))));
                  },
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 150.0),
                    margin: EdgeInsets.only(),
                    padding: EdgeInsets.all(10),
                    color: (RightMessage) ? Color(0xFFe8e8e7) : Colors.white,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.file_download,
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            path.basename(stripQueryStringAndHashFromPath(
                                Uri.decodeComponent(fileurl))),
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
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
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    isTranslate.add(false);
    translateText.add(null);
    // 작업중

    int vcount = totals;
    int ts = int.parse(document.data['timestamp']);

    try {
      totals_snap.documents.forEach((doc) {
        int tx = int.parse(doc.data['date']);
        //print(doc.data.toString());
        if (ts < tx) {
          vcount--;
        }
      });
    } catch (error) {}

    print("R:" + vcount.toString());
    String vcountString = "${vcount}";
    if (vcount == totals) {
      print("같은데?");
      vcount--;
      vcountString = "${vcount}";
    }
    if (vcount <= 0) vcountString = "";
    if (document['idFrom'] == myProfile.myPid) {
      // Right (my message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                // time
                document['type'] == 5
                    ? Container()
                    // :isRightMessageLeft(index)
                    : Container(
                        height: 30,
                        child: Stack(children: <Widget>[
                          Container(
                            width: 39,
                            child: Text(
                              vcountString.toString(),
                              style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                            margin: EdgeInsets.only(top: 3),
                          ),
                          Container(
                            child: Text(
                              '      ' +
                                  DateFormat('kk:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(document['timestamp']))),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 9.0),
                            ),
                            margin: EdgeInsets.only(top: 20),
                          ),
                        ]),
                        // child: Text(
                        //   'Right   ' + DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                        //   style: TextStyle(color: Colors.grey, fontSize: 9.0),
                        // ),
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                      ),

                document['type'] == 6
                    ? buildFileMessage(document['content'],
                        (document['idFrom'] == myProfile.myPid))
                    : Container(),

                document['type'] == 0
                    // Text
                    ? MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onLongPress: () async {
                          await showDialog(
                              context: this.context,
                              child: SimpleDialog(
                                children: <Widget>[
                                  SimpleDialogOption(
                                    child: Text('복사하기').tr(),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: document['content']));
                                      Navigator.pop(this.context);
                                      Fluttertoast.showToast(
                                        msg: '복사했습니다.'.tr(),
                                        gravity: ToastGravity.TOP,
                                        backgroundColor:
                                            Colors.black.withOpacity(0.7),
                                        textColor: Colors.white,
                                      );
                                    },
                                  ),
                                  /*
                            SimpleDialogOption(
                              child: Text('전달하기'),
                              onPressed: () {
                                Navigator.pop(this.context);
                              },
                            ),
                            SimpleDialogOption(
                              child: Text('보관함에 저장하기'),
                              onPressed: () {
                                Navigator.pop(this.context);
                              },
                            ),

                            */
                                ],
                              ));
                        },
                        child: Container(
                          child: Text(document['content'],
                              style: TextStyle(
                                  color: Colors.black,
                                  height: 1.2,
                                  fontSize: 14.0)),
                          padding: EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                          margin: isLastMessageRight(index)
                              ? null
                              : EdgeInsets.only(bottom: 6.0),
                          constraints: BoxConstraints(maxWidth: 250.0),
                          decoration: BoxDecoration(
                              color: Color(0xFFe8e8e7),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25.0),
                                topLeft: Radius.circular(25.0),
                                bottomLeft: Radius.circular(25.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(1, 1),
                                    color: Colors.white,
                                    blurRadius: 1),
                                BoxShadow(
                                    offset: Offset(-1, -1),
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 1)
                              ]),
                        ),
                      )
                    : document['type'] == 1
                        // Image
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          MyColors.primaryColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onLongPress: () async {
                                await showDialog(
                                    context: this.context,
                                    child: SimpleDialog(
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          child: Text('다운로드').tr(),
                                          onPressed: () async {
                                            var mimes = path
                                                .basename(
                                                    stripQueryStringAndHashFromPath(
                                                        Uri.decodeComponent(
                                                            document[
                                                                'content'])))
                                                .split('.');
                                            download(
                                                document['content'],
                                                DateTime.now()
                                                        .millisecondsSinceEpoch
                                                        .toString() +
                                                    '.' +
                                                    mimes[mimes.length - 1]);
                                            Navigator.pop(this.context);
                                            Fluttertoast.showToast(
                                              msg: '디바이스에 저장했습니다.'.tr(),
                                              gravity: ToastGravity.TOP,
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.7),
                                              textColor: Colors.white,
                                            );
                                          },
                                        ),
//                              SimpleDialogOption(
//                                child: Text('전달하기').tr(),
//                                onPressed: () {
//                                  Navigator.pop(this.context);
//                                },
//                              ),
//                              SimpleDialogOption(
//                                child: Text('보관함에 저장하기').tr(),
//                                onPressed: () {
//                                  Navigator.pop(this.context);
//                                },
//                              ),
                                      ],
                                    ));
                              },
                              onPressed: () {
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document['content'],
                                            time: document['timestamp'],
                                            idFrom: Provider.of<nowProfile>(
                                                    context,
                                                    listen: false)
                                                .getMyProfile()
                                                .myNickname)));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(right: 10.0, bottom: 6.0),
                          )
                        // Sticker
                        : document['type'] == 2
                            ? Container(
                                color: Colors.transparent,
                                child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 10.0, 20.0, 10.0),
                                    margin: EdgeInsets.only(bottom: 6.0),
                                    decoration: BoxDecoration(
                                        color: Color(0xFFe8e8e7),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(14.0),
                                          topLeft: Radius.circular(14.0),
                                          bottomLeft: Radius.circular(14.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(1, 1),
                                              color: Colors.white,
                                              blurRadius: 1),
                                          BoxShadow(
                                              offset: Offset(-1, -1),
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 1)
                                        ]),
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.call,
                                                  color: Color(0xb3000000),
                                                  size: 18.0),
                                              SizedBox(width: 6.0),
                                              Text('음성통화 연결중').tr(),
                                              SizedBox(width: 20.0),
                                              Text('...'),
                                              //                                      RaisedButton(
                                              //                                        child: Text('전화 받기'),
                                              //                                        onPressed: () =>onJoin('voice',widget.chatInfo['rId']),
                                              //                                      )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              )
                            : document['type'] == 3
                                ? Container(
                                    color: Colors.transparent,
                                    child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 10.0, 20.0, 10.0),
                                        margin: EdgeInsets.only(bottom: 6.0),
                                        decoration: BoxDecoration(
                                            color: Color(0xFFe8e8e7),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(14.0),
                                              topLeft: Radius.circular(14.0),
                                              bottomLeft: Radius.circular(14.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: Offset(1, 1),
                                                  color: Colors.white,
                                                  blurRadius: 1),
                                              BoxShadow(
                                                  offset: Offset(-1, -1),
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 1)
                                            ]),
                                        child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.videocam,
                                                      color: Color(0xb3000000),
                                                      size: 18.0),
                                                  SizedBox(width: 6.0),
                                                  Text('영상통화 연결중').tr(),
                                                  SizedBox(width: 20.0),
                                                  Text('...'),
//                              RaisedButton(
//                                child: Text('취소'),
//                                onPressed: () =>onJoin('video',widget.chatInfo['rId']),
//                              )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )),
                                  )
                                : document['type'] == 4
                                    ? Container(
                                        child: Image.asset(
                                          'assets/images/${document['content']}.gif',
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                        ),
                                        margin: EdgeInsets.only(
                                            bottom: isLastMessageRight(index)
                                                ? 0.0
                                                : 6.0,
                                            right: 10.0),
                                      )
                                    : document['type'] == 5 //나가기
                                        ? Expanded(
                                            child: Container(
                                                height: 30,
                                                color: Colors.white,
                                                child: Center(
                                                    child: Text(
                                                        myProfile.myNickname +
                                                            '님이 나갔습니다.'.tr()))))
                                        : Container(),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      );
    } else {
      if (totals == 2) {
        vcount--;
        vcount--;
        vcountString = "${vcount}";
      } else {
        vcount--;
        vcountString = "${vcount}";
      }
      if (vcount <= 0) vcountString = "";

      Firestore.instance.collection('Room').document(rId).get().then((value) {
        exitUserN.remove(value.data['exitUser'][index].toString());
        return exitUserN.add(value.data['exitUser'][index].toString());
      });

      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 55, top: 5, bottom: 4),
                child: (user[document['idFrom']].toString() == 'null' ||
                        document['type'] == 5)
                    ? Container()
                    : Text(user[document['idFrom']].nickname,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.0,
                            color: Colors.black54))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // isLastMessageLeft(index)
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(300),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(2, 2),
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4),
                        BoxShadow(
                            offset: Offset(-2, -2),
                            color: Colors.white,
                            blurRadius: 4)
                      ]),
                  child: Material(
                    child: (document['type'] == 5)
                        ? Container()
                        : (user[document['idFrom']].toString() != 'null')
                            ? (user[document['idFrom']].photoUrl == null)
                                ? Container(
                                    width: 35,
                                    height: 35,
                                    child: CircleAvatar(
                                        foregroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/img/noface.png')),
                                  )
                                : CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                MyColors.primaryColor),
                                      ),
                                      width: 35.0,
                                      height: 35.0,
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                    imageUrl: img.getThumb(
                                        user[document['idFrom']].photoUrl),
                                    width: 35.0,
                                    height: 35.0,
                                    fit: BoxFit.cover,
                                  )
                            : CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/img/noface.png')),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  margin: EdgeInsets.only(bottom: 10),
                ),

                //     : Container(width: 35.0),
                document['type'] == 6
                    ? buildFileMessage(document['content'],
                        (document['idFrom'] == myProfile.myPid))
                    : Container(),

                document['type'] == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MaterialButton(
                              minWidth: 0,
                              padding: EdgeInsets.all(0.0),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onLongPress: () async {
                                await showDialog(
                                    context: this.context,
                                    child: SimpleDialog(
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          child: Text('복사하기').tr(),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: document['content']));
                                            Navigator.pop(this.context);
                                            Fluttertoast.showToast(
                                              msg: '복사했습니다.'.tr(),
                                              gravity: ToastGravity.TOP,
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.7),
                                              textColor: Colors.white,
                                            );
                                          },
                                        ),
//                                  SimpleDialogOption(
//                                    child: Text('전달하기').tr(),
//                                    onPressed: () {
//                                      Navigator.pop(this.context);
//                                    },
//                                  ),
//                                  SimpleDialogOption(
//                                    child: Text('보관함에 저장하기').tr(),
//                                    onPressed: () {
//                                      Navigator.pop(this.context);
//                                    },
//                                  ),
                                      ],
                                    ));
                              },
                              child: Container(
                                child: (
                                        translate == true)
                                    ? Column(children: <Widget>[
                                        Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                                          decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey)),
                                          ),
                                          child: Text(document['content'],
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                        Visibility(
                                          visible: !isTranslate[index],
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.translate,
                                                color:
                                                    MyColors.primaryColorLight,
                                              ),
                                              onPressed: () {
                                                print(
                                                    'from:${document['locale']}, to: ${context.locale.languageCode.toString()}');
                                                isTranslate[index] =
                                                    !isTranslate[index];
                                                translator
                                                    .translate(
                                                        document['content'],
                                                        from:
                                                            local_from,
                                                        to: local_to,)
                                                    .then((result) {
                                                  setState(() {
                                                    translateText[index] =
                                                        result.toString();
                                                  });
                                                  print(
                                                      "Source: ${document['content']}\nTranslated: $result");
                                                });
                                              }),
                                        ),
                                        (translateText[index] == null)
                                            ? SizedBox.shrink()
                                            : Text(translateText[index])
                                      ])
                                    : Text(document['content'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0)),
                                padding:
                                    EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                                constraints: BoxConstraints(maxWidth: 250.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(14.0),
                                      topLeft: Radius.circular(14.0),
                                      bottomRight: Radius.circular(14.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(-1, -1),
                                          color: Colors.white,
                                          blurRadius: 2),
                                      BoxShadow(
                                          offset: Offset(1, 1),
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 2)
                                    ]),
                                margin:
                                    EdgeInsets.only(left: 10.0, bottom: 6.0),
                              ))
                        ],
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          MyColors.primaryColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onLongPress: () async {
                                await showDialog(
                                    context: this.context,
                                    child: SimpleDialog(
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          child: Text('다운로드').tr(),
                                          onPressed: () async {
                                            download(
                                                document['content'],
                                                path.basename(
                                                    stripQueryStringAndHashFromPath(
                                                        Uri.decodeComponent(
                                                            document[
                                                                'content']))));
                                            Navigator.pop(this.context);
                                            Fluttertoast.showToast(
                                              msg: '디바이스에 저장했습니다.'.tr(),
                                              gravity: ToastGravity.TOP,
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.7),
                                              textColor: Colors.white,
                                            );
                                          },
                                        ),
                                        SimpleDialogOption(
                                          child: Text('전달하기').tr(),
                                          onPressed: () {
                                            Navigator.pop(this.context);
                                          },
                                        ),
                                        SimpleDialogOption(
                                          child: Text('보관함에 저장하기').tr(),
                                          onPressed: () {
                                            Navigator.pop(this.context);
                                          },
                                        ),
                                      ],
                                    ));
                              },
                              onPressed: () {
                                var usernickname = '알수없음'.tr();
                                if (user[document['idFrom']].toString() !=
                                    'null')
                                  usernickname =
                                      user[document['idFrom']].nickname;
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document['content'],
                                            time: document['timestamp'],
                                            idFrom: usernickname)));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0, bottom: 6.0),
                          )
                        : document['type'] == 2
                            ? Container(
                                color: Colors.transparent,
                                child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        17.0, 10.0, 20.0, 0.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(14.0),
                                          topLeft: Radius.circular(14.0),
                                          bottomRight: Radius.circular(14.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(-1, -1),
                                              color: Colors.white,
                                              blurRadius: 2),
                                          BoxShadow(
                                              offset: Offset(1, 1),
                                              color: Colors.black
                                                  .withOpacity(0.15),
                                              blurRadius: 2)
                                        ]),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.call,
                                                  color: Color(0xb3000000),
                                                  size: 18.0),
                                              SizedBox(width: 6.0),
                                              Text('음성통화 요청').tr(),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 10.0,
                                                height: 10,
                                              ),
                                              // FlatButton(
                                              //   textColor: Color(0xff65D31E),
                                              //   child: Text('수신하기').tr(),
                                              //   onPressed: () => onJoin('voice', widget.chatInfo['rId']),
                                              // ),
//                              FlatButton(
//                                textColor: Color(0xffD50000),
//                                child: Text('거절하기'),
//                                onPressed: () =>onJoin('voice',widget.chatInfo['rId']),
//                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                                margin:
                                    EdgeInsets.only(left: 10.0, bottom: 6.0),
                              )
                            : document['type'] == 3
                                ? Container(
                                    color: Colors.transparent,
                                    child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                            17.0, 10.0, 20.0, 0.0),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(14.0),
                                              topLeft: Radius.circular(14.0),
                                              bottomRight:
                                                  Radius.circular(14.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: Offset(-1, -1),
                                                  color: Colors.white,
                                                  blurRadius: 2),
                                              BoxShadow(
                                                  offset: Offset(1, 1),
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 2)
                                            ]),
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.videocam,
                                                      color: Color(0xb3000000),
                                                      size: 18.0),
                                                  SizedBox(width: 6.0),
                                                  Text('영상통화 요청').tr(),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width: 10.0, height: 10),
                                                  // FlatButton(
                                                  //   textColor: Color(0xff65D31E),
                                                  //   child: Text('수신하기').tr(),
                                                  //   onPressed: () => onJoin('video', widget.chatInfo['rId']),
                                                  // ),
//                              FlatButton(
//                                textColor: Color(0xffD50000),
//                                child: Text('거절하기'),
//                                onPressed: () =>onJoin('voice',widget.chatInfo['rId']),
//                              ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )),
                                    margin: EdgeInsets.only(
                                        left: 10.0, bottom: 6.0),
                                  )
                                : document['type'] == 4
                                    ? Container(
                                      child: Image.asset(
                                        'assets/images/${document['content']}.gif',
                                        width: 100.0,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                      margin: EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                        bottom: 6.0
                                      ),
                                    )
                                    : document['type'] == 5 //나가기
                                      ? Expanded(
                                        child: Container(
                                          height: 30,
                                          color: Colors.white,
                                          child: Center(
                                            child: (user[document['idFrom']].toString() != 'null')
                                              ? Text(user[document['idFrom']].nickname.toString() + '님이 나갔습니다.'.tr())
                                              : Text('${exitUserN[index]} 님이 나갔습니다.').tr()
                                          )
                                        )
                                      )
                                      : Container(),
                document['type'] == 5
                    ? Container()
                    // Time
                    // :isLastMessageLeft(index)
                    : Container(
                        height: 30,
                        child: Stack(children: <Widget>[
                          Container(
                            width: 39,
                            child: Text(
                              vcountString.toString(),
                              style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                            margin: EdgeInsets.only(top: 3, left: 12),
                          ),
                          Container(
                            child: Text(
                              '   ' +
                                  DateFormat('kk:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(document['timestamp']))),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 9.0),
                              textAlign: TextAlign.left,
                            ),
                            margin: EdgeInsets.only(top: 20),
                          ),
                        ]),
                        // child: Text(
                        //   'Right   ' + DateFormat('kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                        //   style: TextStyle(color: Colors.grey, fontSize: 9.0),
                        // ),
                        margin: EdgeInsets.only(right: 8.0, bottom: 8.0),
                      ),
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  Widget buildSticker() {
    return Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () => onSendMessage('Picon01', 4),
                  child: Image.asset(
                    'assets/images/Picon01.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon02', 4),
                  child: Image.asset(
                    'assets/images/Picon02.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon03', 4),
                  child: Image.asset(
                    'assets/images/Picon03.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () => onSendMessage('Picon04', 4),
                  child: Image.asset(
                    'assets/images/Picon04.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon05', 4),
                  child: Image.asset(
                    'assets/images/Picon05.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon06', 4),
                  child: Image.asset(
                    'assets/images/Picon06.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () => onSendMessage('Picon07', 4),
                  child: Image.asset(
                    'assets/images/Picon07.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon08', 4),
                  child: Image.asset(
                    'assets/images/Picon08.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon09', 4),
                  child: Image.asset(
                    'assets/images/Picon09.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () => onSendMessage('Picon10', 4),
                  child: Image.asset(
                    'assets/images/Picon10.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon11', 4),
                  child: Image.asset(
                    'assets/images/Picon11.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton(
                  onPressed: () => onSendMessage('Picon12', 4),
                  child: Image.asset(
                    'assets/images/Picon12.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            SizedBox(
              height: 10,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget chatRoomPlusBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Color(0xFFf2f3f6),
        border: Border(
            top: BorderSide(width: 0.5, color: Colors.black.withAlpha(25))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.circular(24.0),
                  color: Color(0xFFf2f3f6),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Color(0xFFf2f3f6),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4),
                              BoxShadow(
                                  offset: Offset(-2, -2),
                                  color: Colors.white,
                                  blurRadius: 4)
                            ]),
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: IconButton(
                          icon: Icon(Icons.image, color: Color(0xFFff926f)),
                          onPressed: () {
                            // getPicture().then((value) {
                            //   uploadPicture(value);
                            // });
                            //요기요
                            showAlertDialog(context);
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text('앨범', style: TextStyle(fontSize: 11.0)).tr()
                    ],
                  ),
                ),
                Material(
                  borderRadius: BorderRadius.circular(24.0),
                  color: Color(0xFFf2f3f6),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Color(0xFFf2f3f6),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4),
                              BoxShadow(
                                  offset: Offset(-2, -2),
                                  color: Colors.white,
                                  blurRadius: 4)
                            ]),
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: IconButton(
                          icon:
                              Icon(Icons.camera_alt, color: Color(0xFF58d2fd)),
                          onPressed: () {
                            getCamera();
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text('카메라', style: TextStyle(fontSize: 11.0)).tr()
                    ],
                  ),
                ),
                Material(
                  borderRadius: BorderRadius.circular(24.0),
                  color: Color(0xFFf2f3f6),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: Color(0xFFf2f3f6),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(2, 2),
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4),
                              BoxShadow(
                                  offset: Offset(-2, -2),
                                  color: Colors.white,
                                  blurRadius: 4)
                            ]),
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: IconButton(
                          icon:
                              Icon(Icons.attach_file, color: Color(0xFFf186ff)),
                          onPressed: () {
                            print("File 다운로드");
                            getFile().then((value) {
                              print(value.toString());
                              uploadFile(value);
                            });
                            //uploadFile(filePick);
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text('파일', style: TextStyle(fontSize: 11.0)).tr()
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[],
            ),
          ),
        ],
      ),
    );
  }

  Widget getChangeSendBtn() {
    //if(_getChangeButton) {
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: () {
        onSendMessage(textEditingController.text, 0);
      },
      color: Color(0xFFd0393e),
    );
//    } else {
//      return IconButton(
//        icon: Icon(MdiIcons.microphoneOutline),
//        iconSize: 26,
//        onPressed: () {},
//        color: Colors.black.withOpacity(0.3),
//      );
//    }
  }

  Widget changeEmojiButton() {
    if (!isShowSticker) {
      return IconButton(
        icon: Icon(Icons.face),
        onPressed: getSticker,
        color: Colors.black.withOpacity(0.3),
        padding: EdgeInsets.all(0.0),
      );
    }
    return IconButton(
      icon: Icon(Icons.face),
      onPressed: getSticker,
      color: MyColors.primaryColor,
      padding: EdgeInsets.all(0.0),
    );
  }

  Widget changeMoreBoxButton() {
    if (!isShowMoreBox) {
      return IconButton(
        icon: Icon(Icons.add),
        onPressed: getMoreBox,
        color: Colors.black.withOpacity(0.3),
        iconSize: 26,
      );
    }
    return IconButton(
      icon: Icon(Icons.close),
      onPressed: getMoreBox,
      color: Colors.black.withOpacity(0.3),
      iconSize: 26,
    );
  }

  Widget changeSearchBtn() {
    if (!isChangeSearch) {
      return AppBar(
        elevation: 0.0,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                0.1,
                0.4,
                0.7
              ],
                  colors: [
                Color(0xFFf2f3f6),
                Color(0xFFf2f3f6),
                Color(0xFFf2f3f6).withOpacity(0.8),
              ])),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage(menuNum: 1)),
                  (Route<dynamic> route) => false
          ),
        ),
        title: appBarNames(),
        actions: <Widget>[
          /*  IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: getChangeSearch,
          ),*/
          IconButton(
            icon: Icon(
              Icons.call,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              onSendMessage("音声通話".tr(), 2); //음성 통화
              Map<String, dynamic> chatInfo = widget.chatInfo;
              onJoin('voice', widget.chatInfo['rId']);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              print(widget.chatInfo['rId']);
              onSendMessage("ビデオ通話".tr(), 3); //영상 통화
              Map<String, dynamic> chatInfo = widget.chatInfo;
              onJoin('video', widget.chatInfo['rId']);
            },
          ),
          IconButton(
            icon: Icon(Icons.translate, color: Colors.black, size: 20,),
            onPressed: () {
              getTranslate();
            },
          ),
          settingButton(),
        ],
      );
    }
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black.withOpacity(0.7)),
        onPressed: getChangeSearch,
      ),
      backgroundColor: MyColors.primaryColor,
      title: Container(
        child: TextField(
          controller: searchEditingController,
          decoration: InputDecoration(
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: '대화 내용 검색'.tr(),
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
            errorMaxLines: null,
            suffixIcon: getSearchTextClearButton(),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search, color: MyColors.primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget getSearchTextClearButton() {
    if (!searchClearButton) {
      return null;
    }
    return Container(
        child: IconButton(
      onPressed: () => searchEditingController.clear(),
      icon: Icon(Icons.cancel, color: Colors.black.withOpacity(0.7)),
    ));
  }

  Widget settingButton() {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Colors.black,
        size: 20,
      ),
      onSelected: (value) {
        //  1 = 알림 끄기, 2 = 배경화면 설정, 3 = 대화상대 초대하기, 4 = 대화 내보내기, 5 = 채팅방 이름 설정, 6 = 채팅방 나가기
        if (value == 1) {
          getNotification();
        }
//        else if (value == 5) {
//          renameThisRoom();
//        }
        else if (value == 2) {
          exitRoom(context);
          onSendMessage('メンバーが退出しました。', 5); //tr()나중에
        } else if (value == 3) {
          getTranslate();
        }
      },
      itemBuilder: (context) => [
//        PopupMenuItem(
//          value: 1,
//          child: changeNotification(),
//        ),
        PopupMenuItem(
          value: 3,
          child: changeTranslate(),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('채팅방 나가기'.tr(),
                  style:
                      TextStyle(color: MyColors.primaryColor, fontSize: 15.0))
              .tr(),
        ),
      ],
      offset: Offset(0, 20),
    );
  }

  Widget changeNotification() {
    if (!notificationOffButton) {
      return Row(
        children: <Widget>[
          Container(
            width: 135.0,
            child: Text('알림 끄기',
                    style: TextStyle(fontSize: 15, color: Colors.black))
                .tr(),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 3.0),
            child: IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.notifications,
                  color: Colors.black.withOpacity(0.7)),
              iconSize: 22,
            ),
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        Container(
          width: 135.0,
          child:
              Text('알림 켜기', style: TextStyle(fontSize: 15, color: Colors.black))
                  .tr(),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 3.0),
          child: IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(Icons.notifications_off,
                color: Colors.black.withOpacity(0.7)),
            iconSize: 22,
          ),
        ),
      ],
    );
  }

  Widget changeTranslate() {
    if (translate) {
      return Row(
        children: <Widget>[
          Container(
            width: 135.0,
            child: Text('번역 끄기',
                    style: TextStyle(fontSize: 15, color: Colors.black))
                .tr(),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 3.0),
            child: IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(MdiIcons.alphabeticalVariant,
                  color: Colors.black.withOpacity(0.7)),
              iconSize: 22,
            ),
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        Container(
          width: 135.0,
          child:
              Text('번역 켜기', style: TextStyle(fontSize: 15, color: Colors.black))
                  .tr(),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 3.0),
          child: IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(Icons.translate, color: Colors.black.withOpacity(0.7)),
            iconSize: 22,
          ),
        ),
      ],
    );
  }

  Future<Widget> renameThisRoom() async {
    return await showDialog(
        context: context,
        child: SimpleDialog(
          title:
              Text('채팅방 이름 설정', style: TextStyle(fontWeight: FontWeight.bold))
                  .tr(),
          children: <Widget>[
            Stack(
              children: <Widget>[
                StreamBuilder(
                  stream: Firestore.instance
                      .collection('Room')
                      .document(rId)
                      .collection('user')
                      .document(pid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        margin: EdgeInsets.only(bottom: 30.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.black.withOpacity(1.0)),
                            ),
                            suffixIcon: MaterialButton(
                              minWidth: 0,
                              padding: EdgeInsets.all(0.0),
                              child: Icon(Icons.cancel,
                                  color: Colors.black.withOpacity(0.5)),
                              onPressed: () {
                                roomRenameController.clear();
                              },
                            ),
                          ),
                          maxLength: 20,
                          maxLengthEnforced: true,
                          controller: roomRenameController
                            ..text = roomRenameController.text == ''
                                ? snapshot.data['title']
                                : chatTitle,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "이름을 입력해주세요".tr();
                            }
                          },
                        ),
                      );
                    } else {
                      print(snapshot.hasData);
                      listMessage = snapshot.data.documents;

                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(index, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                        reverse: true,
                        controller: listScrollController,
                      );
                    }
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  child: Text('취소'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  textColor: MyColors.primaryColor,
                  child: Text('저장'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    renameRoom();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ));
  }

  Widget appBarNames() {
    List<String> chatTitleList = List<String>();
    widget.chatInfo['withUser'].forEach((element) {
      print('타이틀2: ${element.nickname}');

      if (element.pid != myProfile.myPid)
        chatTitleList.add(element.nickname.toString());
    });
    return Text(chatTitleList.join(', '),
        style: TextStyle(color: Colors.black));
    /*
    return StreamBuilder(
      stream: Firestore.instance
          .collection('Room')
          .document(rId)
          .collection('user')
          .document(pid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data['title'],
            style: TextStyle(color: Colors.black),
          );
        } else {
          print(snapshot.hasData);
          listMessage = snapshot.data.documents;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
            itemCount: snapshot.data.documents.length,
            reverse: true,
            controller: listScrollController,
          );
        }
      },
    );*/
  }

  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List allImage = [];
  List allNameList = new List();

  Future<void> loadImageList() async {
    var allImageTemp;
    allImageTemp = await FlutterGallaryPlugin.getAllImages;
    print("call ${allImageTemp.length}");

    setState(() {
      this.allImage =
          Platform.isIOS ? allImageTemp : allImageTemp['URIList'] as List;
      this.allNameList = allImageTemp['DISPLAY_NAME'] as List;
      this.allImage = this.allImage.reversed.toList();
      this.allNameList = this.allNameList.reversed.toList();
    });
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              contentPadding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(
                builder: (context) {
                  // Get available height and width of the build area of this widget. Make a choice depending on the size.
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;

                  return Container(
                      height: height - 200,
                      width: width,
                      margin: EdgeInsets.only(top: 10),
                      child: Container(
                        child: Stack(
                          children: <Widget>[
                            Text('  Gallery',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            _buildGrid(),
                          ],
                        ),
                      )
                      //_buildGrid(),

                      );
                },
              ),
            ));
  }

  Widget _buildGrid() {
    return Container(
        margin: EdgeInsets.only(top: 40),
        child: GridView.extent(
            maxCrossAxisExtent: 130,
            padding: const EdgeInsets.all(0),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: _buildGridTileList(allImage.length)));
  }

  List<Container> _buildGridTileList(int count) {
    return List<Container>.generate(
        count,
        (int index) => Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(allImage[index].toString()),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {
                uploadPicture(File(allImage[index].toString()));
                Navigator.of(context).pop();
              },
            )));
  }

  void showLangBox(BuildContext context) async {
    String result = await showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          contentPadding: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.all(
                  Radius.circular(10.0))),
          content: Builder(
            builder: (context) {
              // Get available height and width of the build area of this widget. Make a choice depending on the size.
              return Container(
                height:200,
                width: 110,
                child: Column(
                  children: <Widget>[
                    Container(
                      width:300,
                      height:40,
                      padding: EdgeInsets.only(top:5),
                      child: Text("  번역 설정",textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black54, fontSize: 18,fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return FlatButton(onPressed:(){
                                    LangUpdate("언어변경",items_code[index] );
                                    local_to = items_code[index];
                                    Navigator.pop(this.context);
                                  },
                                      child: Text(items[index]));
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
    );
  }
  void getLangInfo(){
    Firestore.instance
        .collection('Room')
        .document(rId)
        .collection('Lang')
        .document(myProfile.myPid.toString())
        .get()
        .then((DocumentSnapshot value) =>
    [
      local_to = value.data['to'] ?? "auto",
    ]);
  }
  void LangUpdate(String content, String lang) {
    var documentReference = Firestore.instance
        .collection('Room')
        .document(rId)
        .collection('Lang')
        .document(myProfile.myPid.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        {
          'to': "${lang}",
        },
      );
    }).then((value) {
      vm=0;
    });
  }
}

