import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:provider/provider.dart';
import 'package:papucon/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'home_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  Future readID() {
    String uid = LoginStore().getUserId() as String;
    print(uid);
  }

  TextEditingController controllerNickname;
  TextEditingController controllerAboutMe;
  TextEditingController controllerGroup;

  SharedPreferences prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String group = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();
  final FocusNode focusNodeGroup = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    aboutMe = prefs.getString('aboutMe') ?? '';
    group = prefs.getString('group') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    print(id +"+"+ nickname+"+"+ aboutMe +"+"+ group+"+"+photoUrl);
    controllerNickname = TextEditingController(text: nickname);
    controllerAboutMe = TextEditingController(text: aboutMe);
    controllerGroup = TextEditingController(text: group);
    // Force refresh input
    setState(() {});
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
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child("image");//fileName
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
          photoUrl = downloadUrl;
          await prefs.setString('photoUrl', photoUrl);
          print(downloadUrl);
          /*
          Firestore.instance
              .collection('users')
              .document(id)
              .updateData({
            'profile': {'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl}
          }
          )
              .then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
          */

        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image'.tr());
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image'.tr());
      }
    }, onError: (err) {
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
    print('uid'+uid);
    setState(() {
      isLoading = true;
    });

    photoUrl = prefs.getString('photoUrl');
    print(photoUrl);
    var _idGenerate = nickname + '#' + randomNumeric(4);


    final collProfil = Firestore.instance.collection('Profile');
    DocumentReference docProfile = collProfil.document();

    var pid =docProfile.documentID;
    print("pid "+pid);
    var _profileData=  {

      'nickname': nickname,
      'pid': pid,
      'id': _idGenerate,
      'group': group,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl,
      'createTime': FieldValue.serverTimestamp()
    };
/*
    docProfile.setData(
        _profileData
    ).then((data) {
      //print('hop ${docProfile.documentID}');
      Firestore.instance
          .collection('Users')
          .document(uid)
          .collection('profile')
          .document(pid)
          .setData({
        'pid': pid,
        'uid': uid,
        'nickname':nickname,
        'createTime': FieldValue.serverTimestamp()
      }
      );

    }).catchError((error) {
      print(error);
    });
*/

    docProfile.setData(_profileData).then((data) async {
      Firestore.instance
          .collection('Users')
          .document(uid)
          .collection('profile')
          .document(pid)
          .setData({
        'pid': pid,
        'uid': uid,
        'nickname':nickname,
        'createTime': FieldValue.serverTimestamp()
        }
      );

      await prefs.setString('uid', uid);
      await prefs.setString('nickname', nickname);
      await prefs.setString('aboutMe', aboutMe);
      await prefs.setString('group', group);
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "업데이트가 완료 되었습니다".tr());
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (Route<dynamic> route) => false);
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text('프로필 만들기').tr(),
              backgroundColor: MyColors.primaryColor,
            ),
            body: Container(
              child: Container(
                  constraints: BoxConstraints.expand(),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/img/default_backgroud.jpg'),
                          fit: BoxFit.cover
                      )
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            RawMaterialButton(
                              elevation: 2.0,
                              fillColor: Color.fromARGB(170, 255, 255, 255),
                              child: Icon(
                                Icons.camera_alt,
                                size: 15.0,
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.all(5.0),
                              shape: CircleBorder(),
                            ),RawMaterialButton(
                              elevation: 2.0,
                              fillColor: Color.fromARGB(170, 255, 255, 255),
                              child: Icon(
                                Icons.camera_alt,
                                size: 15.0,
                                color: Colors.black,
                              ),
                              padding: EdgeInsets.all(5.0),
                              shape: CircleBorder(),
                            ),
                          ],
                        ),
                        Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != ''
                                  ? Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: AlwaysStoppedAnimation<
                                              Color>(
                                              MyColors.primaryColorLight),
                                        ),
                                        width: 90.0,
                                        height: 90.0,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                  imageUrl: photoUrl,
                                  width: 90.0,
                                  height: 90.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(
                                    45.0)),
                                clipBehavior: Clip.hardEdge,
                              )
                                  : Icon(
                                Icons.account_circle,
                                size: 90.0,
                                color: MyColors.primaryColorLight,
                              ))
                                  : Material(
                                child: Image.file(
                                  avatarImageFile,
                                  width: 90.0,
                                  height: 90.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(
                                    45.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.face,
                                  color: MyColors.primaryColorLight.withOpacity(
                                      0.5),
                                ),
                                onPressed: getImage,
                                padding: EdgeInsets.all(30.0),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.grey,
                                iconSize: 30.0,
                              ),
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Container(
                                decoration:
                                BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8))
                                    , color: Colors.white.withAlpha(150)
                                ),
                                margin: const EdgeInsets.only(top: 40.0),
                                width: 400,
                                height: 300,
                                /**
                                 * Flutter A Form widget is provided to group input boxes.
                                 * Then do some unified operations, such as input validation, input box reset, and input content save.
                                 */
                                child: Form(
                                  //      key: _SignInFormKey,
                                  //Turn on automatic check input, preferably manually check it yourself, or every time you modify your child's TextFormField, other TextFormFields will also be checked and it doesn't feel very good
//        autovalidate: true,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 25, right: 25, top: 10),
                                          child: TextFormField(
                                            //Relevant Focus
                                            //  focusNode: emailFocusNode,
                                            onEditingComplete: () {
                                              // if (focusScopeNode == null) {
                                              //   focusScopeNode = FocusScope.of(context);
                                              // }
                                              // focusScopeNode.requestFocus(passwordFocusNode);
                                            },
                                            decoration: InputDecoration(
                                              labelText: '이름(필수)'.tr(),
                                              hintText: '신짱구'.tr(),),
                                            controller: controllerNickname,
                                            style: TextStyle(fontSize: 16,
                                                color: Colors.black),
                                            onChanged: (value) async {
                                              print('바꼇대3');
                                              // print(await loginStore.getUserId());

                                              nickname = value;
                                            },
                                            focusNode: focusNodeNickname,
                                            //Verification
                                            /*
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Email can not be empty!";
                                  }
                                },*/
                                            onSaved: (value) {
                                              print('저장됫구먼');
                                              nickname = value;
                                            },
                                          ),
                                        ),
                                      ),
                                      /*
                          Container(
                            height: 1,
                            width: 250,
                            color: Colors.grey[400],
                          ),*/
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 25, right: 25, top: 10),
                                          child: TextFormField(
                                            focusNode: focusNodeAboutMe,
                                            decoration: InputDecoration(
                                              labelText: '상태 메세지'.tr(),
                                              hintText: '더워요...'.tr(),),
                                            //Enter password, need to be displayed with *****
                                            //obscureText: !isShowPassWord,
                                            style: TextStyle(fontSize: 16,
                                                color: Colors.black),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  value.length < 6) {
                                                return "Password'length must longer than 6!";
                                              }
                                            },
                                            controller:controllerAboutMe,
                                            onChanged: (value){
                                              aboutMe = value;
                                            },
                                            onSaved: (value) {},
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only( left: 25, right: 25, top: 10, ),
                                          //padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                          child: TextFormField(

                                            focusNode: focusNodeGroup,
                                            decoration: InputDecoration(

                                              labelText: '그룹명'.tr(),
                                              hintText: '학교 동창들'.tr(),),
                                            controller: controllerGroup,
                                            style: TextStyle(fontSize: 16,
                                                color: Colors.black),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  value.length < 6) {
                                                return "Password'length must longer than 6!";
                                              }
                                            },
                                            onChanged: (value){
                                              group = value;
                                            },
                                            onSaved: (value) {

                                            },

                                          ),
                                        ),
                                      ),
                                      /*
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 10),
                              child: TextFormField(
                                // focusNode: passwordFocusNode,
                                decoration: InputDecoration(labelText: '아이디 검색 여부'),
                                //Enter password, need to be displayed with *****
                                //obscureText: !isShowPassWord,
                                style: TextStyle(fontSize: 16, color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.length < 6) {
                                    return "Password'length must longer than 6!";
                                  }
                                },
                                onSaved: (value) {
                                },
                              ),
                            ),
                          ),*/

                                    ],
                                  ),),
                              ),
                            )
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.all(10.0),
                            child: SizedBox(
                              child: RaisedButton(
                                onPressed: () async => handleUpdateData(await loginStore.getUserId()),
                                color: MyColors.primaryColor,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(7))),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '다음',
                                        style: TextStyle(color: Colors.white),
                                      ).tr(),
                                      /*
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            color: MyColors.primaryColorLight,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        )*/
                                    ],
                                  ),
                                ),
                              ),
                            )
                        )
                      ]
                  )
              ),
            ),
          );
        }
    );
  }
}