import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:easy_localization/easy_localization.dart';

class FullPhoto extends StatelessWidget {
  final String url;
  final String time;
  final String idFrom;

  FullPhoto({Key key, @required this.url, this.time, this.idFrom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Scaffold(
//      appBar: AppBar(
//        backgroundColor: MyColors.primaryColor,
//        title: Column(
//          children: <Widget>[
//            Container(
//              alignment: Alignment.topLeft,
//              child: Text(
//                Provider.of<nowProfile>(context, listen: false).getMyProfile().myNickname,
//                style: TextStyle(color: Colors.white, fontSize: 15.0,),
//              ),
//            ),
//            Container(
//              alignment: Alignment.topLeft,
//              child: Text(
//                '2020/07/03',
//                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.0),
//              ),
//            ),
//          ],
//        ),
//      ),
        body: FullPhotoScreen(url: url, time: time, idFrom: idFrom),
      ),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;
  final String time;
  final String idFrom;

  FullPhotoScreen({Key key, @required this.url, this.time, this.idFrom})
      : super(key: key);

  @override
  State createState() =>
      FullPhotoScreenState(url: url, time: time, idFrom: idFrom);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;
  final String time;
  final String idFrom;

  bool touchShowHideBtn;
  bool touchShowHideBtnCopy;

  FullPhotoScreenState({Key key, @required this.url, this.time, this.idFrom});

  @override
  void initState() {
    touchShowHideBtn = false;
    touchShowHideBtnCopy = false;

    super.initState();
  }

  void createChat(String myPid, String pid) {
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
    });
  }

  void getChangeButton() {
    setState(() {
      touchShowHideBtn = !touchShowHideBtn;
      touchShowHideBtnCopy = !touchShowHideBtnCopy;
    });
  }

  Future<void> _handleStorage() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.storage],
    );
  }

  String stripQueryStringAndHashFromPath(url) {
    return url.split("?")[0];
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //Android Path
        : await getApplicationDocumentsDirectory(); //iOS Path
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
    _handleStorage();
    String localPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'PapuconDownload';
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
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Colors.black.withOpacity(0.7), //or set color with: Color(0xFF0000FF)
    ));

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: statusBarHeight),
          child: PhotoView(
              maxScale: 1.0,
              minScale: 0.1,
              onTapDown: (context, details, controllerValue) {
                getChangeButton();
              },
              imageProvider: NetworkImage(url)),
        ),
        touchShowHideBtn ? Container() : changedTouchButton(),
        touchShowHideBtnCopy ? Container() : changedTouchButtonCopy(),
      ],
    );
  }

  Widget changedTouchButton() {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    if (!touchShowHideBtnCopy) {
      return Align(
        alignment: Alignment(0.0, -1.0),
        child: Container(
          height: 56.0,
          margin: EdgeInsets.only(top: statusBarHeight),
          decoration: BoxDecoration(color: Colors.black.withAlpha(128)),
          child: Row(
            children: <Widget>[
              Container(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
//                        Provider.of<nowProfile>(context, listen: false).getMyProfile().myNickname,
                        idFrom,
                        style: TextStyle(color: Colors.white, fontSize: 15.0)),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 5.0,
                    ),
                    child: Text(
                      DateFormat('yyyy/MM/dd').format(
                          DateTime.fromMillisecondsSinceEpoch(int.parse(time))),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 9.0,
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
    return Align(
      alignment: Alignment(0.0, 1.0),
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(color: Colors.black.withAlpha(128)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[],
        ),
      ),
    );
  }

  Widget changedTouchButtonCopy() {
    if (!touchShowHideBtnCopy) {
      return Align(
        alignment: Alignment(0.0, 1.0),
        child: Container(
          height: 48.0,
          decoration: BoxDecoration(color: Colors.black.withAlpha(128)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.save_alt, color: Colors.white),
                onPressed: () async {
                  try {
                    var mimes = url.split('.');
                    var mimes2 = mimes[mimes.length - 1].split('?');
                    download(
                        url,
                        path.basename(stripQueryStringAndHashFromPath(
                            Uri.decodeComponent(DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString() +
                                '.' +
                                mimes2[0]))));
                    Fluttertoast.showToast(
                        msg: '디바이스에 저장했습니다.'.tr(), gravity: ToastGravity.TOP);
                  } on PlatformException catch (error) {
                    print(error);
                  }
                },
              ),
//              IconButton(
//                icon: Icon(Icons.reply, color: Colors.white),
//              ),
//              IconButton(
//                icon: Icon(MdiIcons.inboxMultiple, color: Colors.white),
//              ),
            ],
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment(0.0, 1.0),
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(color: Colors.black.withAlpha(128)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[],
        ),
      ),
    );
  }
}
