import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/pages/settingPage/phoneNumberNewPass.dart';
import 'package:provider/provider.dart';
import 'package:papucon/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';

class phoneNumberChanAfter extends StatefulWidget {
  const phoneNumberChanAfter({Key key}) : super(key: key);

  @override
  _phoneNumberChanAfterState createState() => _phoneNumberChanAfterState();
}

class _phoneNumberChanAfterState extends State<phoneNumberChanAfter> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('비밀번호 확인').tr(),
              backgroundColor: MyColors.primaryColor,
              elevation: 0.0,
            ),
            body: Form(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 70),
                        child: Column(
                          children: <Widget>[
                            Text('회원님의 소중한 정보 보호를 위해 현재 비밀번호를 확인해 주세요',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),).tr(),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: '비밀번호'.tr(),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
                        child: Row(
                          children: <Widget>[
                            Text('비밀번호가 기억나지 않으세요?', style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 15),).tr(),
                          ],
                        ),
                      ),
                      Container(

                        height: 60,
                        child: RaisedButton(
                          onPressed: (){

                          },
                          //color: MyColors.primaryColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('확인', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),).tr(),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                          title: Text(
                              '잠시보는거', style: TextStyle(fontWeight: FontWeight
                              .bold)),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                              context, MaterialPageRoute(
                                builder: (context) => phoneNumberNewPass()),
                            );
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}
