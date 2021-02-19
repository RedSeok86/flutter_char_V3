import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

class FullPhotoProfile extends StatelessWidget {
  final String url;

  FullPhotoProfile({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FullPhotoScreenView(url: url),
    );
  }
}

class FullPhotoScreenView extends StatefulWidget {
  final String url;

  FullPhotoScreenView({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenViewState(url: url);
}

class FullPhotoScreenViewState extends State<FullPhotoScreenView> {
  final String url;

  bool touchShowHideBtn;
  bool touchShowHideBtnCopy;

  FullPhotoScreenViewState({Key key, @required this.url});

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

  @override
  Widget build(BuildContext context) {

    double statusBarHeight = MediaQuery.of(context).padding.top;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black.withOpacity(0.7), //or set color with: Color(0xFF0000FF)
    ));

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              top: statusBarHeight
          ),
          child: PhotoView(
              maxScale: 1.0,
              minScale: 0.1,
              onTapDown: (context, details, controllerValue) {
                getChangeButton();
              },
              imageProvider: NetworkImage(url)
          ),
        ),
        touchShowHideBtn ? Container() : changedTouchButton(),
      ],
    );
  }

  Widget changedTouchButton() {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    if(!touchShowHideBtnCopy) {
      return Align(
        alignment: Alignment(0.0, -1.0),
        child: Container(
          height: 56.0,
          margin: EdgeInsets.only(
              top: statusBarHeight
          ),
          decoration: BoxDecoration(
              color: Colors.black.withAlpha(128)
          ),
          child: Row(
            children: <Widget>[
              Container(
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  iconSize: 35.0,
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
                        '',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0
                        )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 5.0,
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
        decoration: BoxDecoration(
            color: Colors.black.withAlpha(128)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

          ],
        ),
      ),
    );
  }

}
