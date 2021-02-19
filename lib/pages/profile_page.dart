import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:papucon/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  final Profile currentProfile;
  ProfilePage({Key key, @required this.currentProfile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isChildScrollEnabled = false;
  bool _ClearButton = false;

  Future readID() {
    String uid = LoginStore().getUserId() as String;
    print(uid);
  }

  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;

  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String backgroundUrl = '';

  bool isLoading = false;
  bool isNickname = false;
  bool imageLoader = false;

  int fileSize;
  int flagCount = 0;

  File avatarImageFile;
  File backgroundImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  final validatorFrom = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      if (widget.currentProfile != null)
        isNickname = true;
      else
        isNickname = false;
    });
    print('테스트 : ${widget.currentProfile.nickname.toString()}');
    //if(Provider.of<nowProfile>(context, listen: false).getMyProfile()!=null)    appBloc.updateTitle("친구 - "+Provider.of<nowProfile>(context, listen: false).getMyProfile().myNickname);
    super.initState();
    if (widget.currentProfile != null) readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = widget.currentProfile.nickname ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';
    if (widget.currentProfile.pid.toString() != 'null')
      backgroundUrl = prefs.getString('backgroundUrl') ?? '';
    if (widget.currentProfile != null) {
      photoUrl = widget.currentProfile.photoUrl;
      backgroundUrl = widget.currentProfile.backgroundUrl;
    }
    // print(id +"+"+ nickname+"+"+ aboutMe +"+"+ group+"+"+photoUrl);
    print('사진 : $photoUrl');
    // Force refresh input
    setState(() {
      if (widget.currentProfile != null) {
        controllerNickname =
            TextEditingController(text: widget.currentProfile.nickname);
        controllerAboutMe =
            TextEditingController(text: widget.currentProfile.aboutme);
      }
    });
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    imageLoader = true;  // return loading when importing image

    String fileName = id;
    DateTime now = DateTime.now();
    StorageReference reference = FirebaseStorage.instance.ref().child(
        'Profile/' + widget.currentProfile.uid + now.toString()); //fileName
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    uploadTask.events.listen((event) {
      print('------upload file--------');

      fileSize = event.snapshot.bytesTransferred;
      if (fileSize > 10485760) {
        avatarImageFile = null;
      }
    });
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
          setState(() {
            if (fileSize <= 10485760) {
              imageLoader = false;
              photoUrl = downloadUrl;
            } else {
              imageLoader = false;
              photoUrl = null;
              Fluttertoast.showToast(
                  msg: '이미지 용량이 너무 큽니다.'.tr(),
                  backgroundColor: MyColors.primaryColor,
                  textColor: Colors.white);
            }
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: '이파일은 이미지가 아닙니다.'.tr());
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: '이파일은 이미지가 아닙니다.'.tr());
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  Future getBackgrounImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        backgroundImageFile = image;
        isLoading = true;
      });
    }
    uploadBackgroundFile();
  }

  Future uploadBackgroundFile() async {
    imageLoader = true;  // return loading when importing image

    String fileName = id;
    DateTime now = DateTime.now();
    StorageReference reference = FirebaseStorage.instance.ref().child(
        'Profile/' + widget.currentProfile.uid + now.toString()); //fileName
    StorageUploadTask uploadTask = reference.putFile(backgroundImageFile);
    uploadTask.events.listen((event) {
      print('------upload file--------');

      fileSize = event.snapshot.bytesTransferred;
      if (fileSize > 10485760) {
        backgroundImageFile = null;
      }
    });
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
          setState(() {
            if (fileSize <= 10485760) {
              imageLoader = false;
              backgroundUrl = downloadUrl;
            } else {
              imageLoader = false;
              backgroundUrl = null;
              Fluttertoast.showToast(
                  msg: '이미지 용량이 너무 큽니다.'.tr(),
                  backgroundColor: MyColors.primaryColor,
                  textColor: Colors.white);
            }
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: '이파일은 이미지가 아닙니다.'.tr());
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: '이파일은 이미지가 아닙니다.'.tr());
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleCreateData(String uid) {
    flagCount = 1;
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    //photoUrl = prefs.getString('photoUrl');
    print('사진주소 $photoUrl');
    var _idGenerate = nickname + '#' + randomNumeric(4);

    final collProfil = Firestore.instance.collection('Profile');
    DocumentReference docProfile = collProfil.document();

    var pid = docProfile.documentID;
    print("pid " + pid);
    var _profileData = {
      'nickname': nickname,
      'pid': pid,
      'uid': uid,
      'id': _idGenerate,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl,
      'backgroundUrl': backgroundUrl,
      'createTime': FieldValue.serverTimestamp()
    };

    docProfile.setData(_profileData).then((data) async {
      Firestore.instance
          .collection('Users')
          .document(uid)
          .collection('profile')
          .document(pid)
          .setData({
        'pid': pid,
        'uid': uid,
        'nickname': nickname.trim(),
        'createTime': FieldValue.serverTimestamp()
      });

      Firestore.instance
          .collection('Downloads')
          .where('uid', isEqualTo: uid)
          .getDocuments()
          .then((value) {
        if (value.documents.length == 0) {
          Firestore.instance
              .collection('Downloads')
              .document(uid)
              .setData({'uid': uid, 'volume': 0});

          Firestore.instance
              .collection('Downloads')
              .document(uid)
              .collection('storages')
              .document('keepfile')
              .setData({'file': 'i am saver'});
        }
      });

      await prefs.setString('uid', uid);
      await prefs.setString('nickname', nickname.trim());
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);
      await prefs.setString('backgroundUrl', backgroundUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "업데이트가 완료 되었습니다".tr()); //Update success
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

//프로필 저장
  void handleUpdateData(String uid) {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
      nickname = controllerNickname.text;
      aboutMe = controllerAboutMe.text;
    });

    //photoUrl = prefs.getString('photoUrl');
    print('사진주소');
    print(photoUrl);
    var _idGenerate = controllerNickname.text.trim() + '#' + randomNumeric(4);

    final collProfil = Firestore.instance.collection('Profile');
    DocumentReference docProfile =
        collProfil.document(widget.currentProfile.pid);

    var pid = docProfile.documentID;
    print('프로필 아이디 확인');
    print(widget.currentProfile.pid);
    var _profileData = {
      'nickname': nickname.trim(),
      'pid': pid,
      'uid': uid,
      'id': _idGenerate,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl,
      'backgroundUrl': backgroundUrl,
      'updateTime': FieldValue.serverTimestamp()
    };

    docProfile.updateData(_profileData).then((data) async {
      Firestore.instance
          .collection('Users')
          .document(uid)
          .collection('profile')
          .document(pid)
          .updateData({
        'pid': pid,
        'uid': uid,
        'nickname': nickname.trim(),
        'updateTime': FieldValue.serverTimestamp()
      });

      Firestore.instance
          .collection('Downloads')
          .where('uid', isEqualTo: uid)
          .getDocuments()
          .then((value) {
        if (value.documents.length == 0) {
          Firestore.instance
              .collection('Downloads')
              .document(uid)
              .setData({'uid': uid, 'volume': 0});
        }
      });

      await prefs.setString('uid', uid);
      await prefs.setString('nickname', nickname.trim());
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('photoUrl', photoUrl);
      await prefs.setString('backgroundUrl', backgroundUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "업데이트가 완료 되었습니다".tr());
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget buildForm(BuildContext context) {
    aboutMe = '';
    return /* Container(
      //alignment: Alignment.topCenter,
      height: MediaQuery.of(context).size.height / 3.0 - 10,
      child:  */
        Form(
      key: validatorFrom,
      //      key: _SignInFormKey,
      //Turn on automatic check input, preferably manually check it yourself, or every time you modify your child's TextFormField, other TextFormFields will also be checked and it doesn't feel very good
      //        autovalidate: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(1, 1), color: Colors.white, blurRadius: 1),
                  BoxShadow(
                      offset: Offset(-1, -1),
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 1)
                ]),
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
            ),
            child: Neumorphic(
              style: NeumorphicStyle(
                border: NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                shadowDarkColor: Colors.black.withOpacity(0.5),
                shadowLightColor: Colors.white,
                depth: 0,
                intensity: 0.7,
                color: Color(0xFFfafafa),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, focusNodeNickname, focusNodeAboutMe);
                  },
                  //Relevant Focus
                  //  focusNode: emailFocusNode,
//                    onEditingComplete: () {
                  // if (focusScopeNode == null) {
                  //   focusScopeNode = FocusScope.of(context);
                  // }
                  // focusScopeNode.requestFocus(passwordFocusNode);
//                    },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '이름(필수)'.tr(),
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                    hintText: '예) 신짱구'.tr(),
                    hintStyle: TextStyle(color: Colors.black, height: 2),
//                      focusedBorder: UnderlineInputBorder(
//                        borderSide: BorderSide(color: Colors.black),
//                      ),
//                      enabledBorder: UnderlineInputBorder(
//                        borderSide: BorderSide(color: Colors.black),
//                      ),
                  ),
                  controller: controllerNickname,
                  style: TextStyle(fontSize: 17, color: Colors.black),
                  onChanged: (value) async {
                    // print(await loginStore.getUserId());

                    nickname = value.trim();
                    print(nickname);
                  },

//                    focusNode: focusNodeNickname,
                  //Verification
                  validator: (value) {
                    if (value.isEmpty || value.trim() == '') {
                      return "이름은 필수입니다".tr();
                    }
                    return null;
                  },
                  onSaved: (value) {
                    print('저장됫구먼');
                    nickname = value.trim();
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(1, 1), color: Colors.white, blurRadius: 1),
                  BoxShadow(
                      offset: Offset(-1, -1),
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 1)
                ]),
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Neumorphic(
              style: NeumorphicStyle(
                border: NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                shadowDarkColor: Colors.black.withOpacity(0.5),
                shadowLightColor: Colors.white,
                depth: 0,
                intensity: 0.7,
                color: Color(0xFFfafafa),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                  ],
                  focusNode: focusNodeAboutMe,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: '상태 메세지'.tr(),
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                    hintText: '예) 더워요...'.tr(),
                    hintStyle: TextStyle(color: Colors.black, height: 2),
//                      enabledBorder: UnderlineInputBorder(
//                        borderSide: BorderSide(color: Colors.black),
//                      ),
                  ),
                  //Enter password, need to be displayed with *****
                  //obscureText: !isShowPassWord,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  controller: controllerAboutMe,
                  onChanged: (value) {
                    aboutMe = value;
                  },
                  onSaved: (value) {},
                ),
              ),
            ),
          ),
        ],
      ),
      /* ), */
    );
  }

  Widget buildPhoto(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(65.0),
          color: Color(0xFFfafafa),
          boxShadow: [
            BoxShadow(
              color: Color(0x80d6d6d6),
              blurRadius: 3,
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            (avatarImageFile == null)
                ? (photoUrl != null)
                    ? Material(
                      child: InkWell(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(color: Color(0xffffbec4)),
                            child: Icon(
                              Icons.account_circle,
                              size: 40.0,
                              color: Colors.black.withOpacity(0.2),
                            ),
                            width: 130.0,
                            height: 130.0,
                          ),
                          imageUrl: photoUrl,
                          width: 130.0,
                          height: 130.0,
                          fit: BoxFit.cover,
                        ),
                        onTap: getImage,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(65.0)),
                      clipBehavior: Clip.hardEdge,
                    )
                    : Container(
                        width: 130.0,
                        height: 130.0,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Icon(
                            Icons.face,
                            size: 50.0,
                            color: Color(0xFF000000).withOpacity(0.2),
                          ),
                          onTap: getImage,
                        ),
                      )
                : imageLoader == true ?
                  Container(
                    width: 130.0,
                    height: 130.0,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(65.0)),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                      ),
                    ),
                  )
                  : Material(
                    child: Image.file(
                      avatarImageFile,
                      width: 130.0,
                      height: 130.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(65.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
            Positioned(
              top: avatarImageFile == null ? 95.0 : 95.0,
              left: avatarImageFile == null ? 95.0 : 95.0,
              child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(width: 0.5, color: Color(0x4a979797))),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    onPressed: getImage,
                    padding: EdgeInsets.all(0.0),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.grey,
                    iconSize: 20.0,
                  )),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(builder: (_, loginStore, __) {
      var getUser = loginStore.getUserId();
      return SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Container(
//            padding: const EdgeInsets.only(top: 23.0),
          child: Scaffold(
//          resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              elevation: 0.0,
              brightness: Brightness.light,
              centerTitle: true,
              title: Text(
                '프로필',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ).tr(),
              backgroundColor: Color(0xFFf2f3f6),
            ),
            body: /* Center(
                child:  */
                Container(
              color: Color(0xFFf2f3f6),
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                reverse: false,
                child: Container(
                  color: Color(0xFFf2f3f6),
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child:
                      /* Stack(alignment: Alignment.topCenter, children: <
                            Widget>[ */
                      Column(
                    children: [
                      //const SizedBox(height: 88.0),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Neumorphic(
                          style: NeumorphicStyle(
                            border: NeumorphicBorder(width: 0.5, color: Color(0xFFf0f0f0)),
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(22)),
                            shadowDarkColor: Colors.black.withOpacity(0.5),
                            shadowLightColor: Colors.white,
                            depth: 3,
                            intensity: 0.7,
                            color: Color(0xFFf2f3f6),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 2.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                              image: (backgroundImageFile == null)
                                  ? DecorationImage(
                                    image: AssetImage("assets/img/papucon_prof.png"),
                                    fit: BoxFit.cover
                                  )
                                  : null,
                            ),
                            alignment: const Alignment(0.0, 0.0),
                            child: Stack(
                              children: [
                                (backgroundImageFile == null)
                                  ? (backgroundUrl != null)
                                    ? Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20)
                                            ),
                                            color: Color(0xFFffffff),
                                          ),
                                          child: Icon(
                                            Icons.face,
                                            size: 0.0,
                                            color: Colors.black.withOpacity(0.2),
                                          ),
                                        ),
                                        imageUrl: backgroundUrl,
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      clipBehavior: Clip.hardEdge,
                                    )
                                    : Container(
                                      child: Icon(
                                        Icons.account_circle,
                                        color: MyColors.primaryColorLight,
                                        size: 0.0,
                                      ),
                                    )
                                    : Material(
                                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
                                      child: imageLoader == true ?
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height,
                                          child: const Loading(),
                                        )
                                        : Image.file(
                                          backgroundImageFile,
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height,
                                          fit: BoxFit.cover,
                                        ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                Align(
                                  child: buildPhoto(context),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    margin: EdgeInsets.only(top: 20, right: 40),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color(0x4a979797)
                                      )
                                    ),
                                    child: FlatButton(
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 20.0,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      padding: EdgeInsets.all(5.0),
                                      shape: CircleBorder(),
                                      onPressed: () {
                                        getBackgrounImage();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      buildForm(context),
                      Expanded(
                        child: Container(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              decoration: BoxDecoration(
                                //                                  color: Color(0xFF1a1a1a),
                                color: Color(0xFFd0393e),
                              ),
                              child: FlatButton(
                                onPressed: () async => {
                                  if (validatorFrom.currentState.validate()) {
                                    if (widget.currentProfile.nickname != null) {
                                      handleUpdateData(await loginStore.getUserId())
                                    } else {
                                      if (flagCount == 0) {
                                        handleCreateData(await loginStore.getUserId()),
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return Loading();
                                          }
                                        )
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      isNickname
                                          ? Text('확인'.tr(),
                                              style: TextStyle(
                                                  color: Colors.white))
                                          : Text('프로필 생성'.tr(),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  //                        Align(
                  //                          alignment: Alignment.topRight,
                  //                          child: Container(
                  //                            width: 30,
                  //                            height: 30,
                  //                            margin: EdgeInsets.only(top: 20, right: 40),
                  //                            decoration: BoxDecoration(
                  //                                color: Colors.white.withOpacity(0.7),
                  //                                borderRadius: BorderRadius.circular(20),
                  //                                border: Border.all(
                  //                                    width: 0.5, color: Color(0x4a979797))),
                  //                            child: FlatButton(
                  //                              child: Icon(
                  //                                Icons.camera_alt,
                  //                                size: 20.0,
                  //                                color: Colors.black.withOpacity(0.5),
                  //                              ),
                  //                              padding: EdgeInsets.all(5.0),
                  //                              shape: CircleBorder(),
                  //                              onPressed: () {
                  //                                getBackgrounImage();
                  //                              },
                  //                            ),
                  //                          ),
                  //                        ),
                  //                  Container(
                  //                    height: MediaQuery.of(context).size.height / 2,
                  //                    decoration: BoxDecoration(
                  //                      color: Colors.black.withOpacity(0.2),
                  //                      borderRadius: BorderRadius.only(
                  //                        bottomLeft: Radius.circular(20),
                  //                        bottomRight: Radius.circular(20)
                  //                      ),
                  //                    ),
                  //                  ),
                  //                          Align(
                  //                            child: buildPhoto(context),
                  //                          ),

                  /* ]) */
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
