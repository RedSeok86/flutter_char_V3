import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:papucon/pages/home_page.dart';
import 'package:papucon/pages/profile_page.dart';
import 'package:papucon/pages/login_page.dart';
import 'package:papucon/pages/otp_page.dart';
import 'package:papucon/model/model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papucon/pages/helper.dart';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
part 'login_store.g.dart';

class LoginStore = LoginStoreBase with _$LoginStore;

abstract class LoginStoreBase with Store {
  //SharedPreferences prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String actualCode;

  @observable
  bool isLoginLoading = false;
  @observable
  bool isOtpLoading = false;

  @observable
  GlobalKey<ScaffoldState> loginScaffoldKey = GlobalKey<ScaffoldState>();
  @observable
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();

  @observable
  FirebaseUser firebaseUser;

  @action
  Future<bool> isAlreadyAuthenticated() async {
    firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      return true;
    } else {
      return false;
    }
  }

  @action
  Future<String> getUserId() async {
    firebaseUser = await _auth.currentUser();
    //log("로그"+firebaseUser.uid);
    return firebaseUser.uid;
  }

  @action
  Future<List> getUserProfile() async {
    var map = Map();
    firebaseUser = await _auth.currentUser();
    Stream<QuerySnapshot> productRef = Firestore.instance
        .collection('Users')
        .document(firebaseUser.uid.toString())
        .collection('profile')
        .snapshots();
    print("초기화");

    List<String> productName = [];
    productRef.forEach((field) {
      field.documents.asMap().forEach((index, data) {
        print("저장");
        print(field.documents[index].data["nickname"]);
        productName.add(field.documents[index].data["nickname"]);
      });
    });

    return productName;
  }

  @action
  Future<void> getCodeWithPhoneNumber(
      BuildContext context, String countryCode, String phoneNumber) async {
    isLoginLoading = true;
    print("번호");
    print(countryCode + phoneNumber);
    await _auth.verifyPhoneNumber(
        phoneNumber: countryCode + phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential auth) async {
          await _auth.signInWithCredential(auth).then((AuthResult value) {
            if (value != null && value.user != null) {
              print('인증 성공');
              onAuthenticationSuccessful(context, value);
            } else {
              loginScaffoldKey.currentState.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text(
                  '잘못된 코드를 입력하셨습니다',
                  style: TextStyle(color: Colors.white),
                ).tr(),
              ));
            }
          }).catchError((error) {
            loginScaffoldKey.currentState.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(
                '잠시 후 다시 시도 해 주세요',
                style: TextStyle(color: Colors.white),
              ).tr(),
            ));
          });
        },
        verificationFailed: (AuthException authException) {
          print('Error message: ' + authException.message);
          loginScaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              '휴대폰 번호를 잘못 입력하였습니다. [+지역코드][휴대폰 번호]',
              style: TextStyle(color: Colors.white),
            ).tr(),
          ));
          isLoginLoading = false;
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          actualCode = verificationId;
          isLoginLoading = false;
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const OtpPage()));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          actualCode = verificationId;
        });
  }

  @action
  Future<void> validateOtpAndLogin(BuildContext context, String smsCode) async {
    isOtpLoading = true;
    final AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: actualCode, smsCode: smsCode);

    await _auth.signInWithCredential(_authCredential).catchError((error) {
      isOtpLoading = false;
      otpScaffoldKey.currentState.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          '인증 코드가 잘못되었습니다.',
          style: TextStyle(color: Colors.white),
        ).tr(),
      ));
    }).then((AuthResult authResult) {
      if (authResult != null && authResult.user != null) {
        print('인증 성공');
        onAuthenticationSuccessful(context, authResult);
      }
    });
  }

  Future<void> onAuthenticationSuccessful(
      BuildContext context, AuthResult result) async {
    isLoginLoading = true;
    isOtpLoading = true;

    firebaseUser = result.user;
    var get_uid = firebaseUser.uid;
    Provider.of<storeUID>(context, listen: false).setUID(get_uid);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('uid', get_uid);
    print('uid체크');
    print(get_uid);

    try {
      Firestore.instance
          .collection('Users')
          .document(firebaseUser.uid)
          .collection('profile')
          .getDocuments()
          .then((doc) {
        //     print('존재하냐?: ${doc.documents.first}');
        if (doc.documents.length != 0) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomePage()),
              (Route<dynamic> route) => false);
        } else {
          Profile emptyProfile =
              Profile(get_uid, null, null, null, null, null, null);
          //원본Profile emptyProfile= Profile(get_uid,null,null,null,null,null,null,null);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) => Helper(currentProfile: emptyProfile)),
              (Route<dynamic> route) => false);
        }
      });
    } catch (e) {
      print('에러라굿');
    }
    //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (Route<dynamic> route) => false);

    isLoginLoading = false;
    isOtpLoading = false;
  }

  @action
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    firebaseUser = null;
    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (Route<dynamic> route) => false);
  }
}
