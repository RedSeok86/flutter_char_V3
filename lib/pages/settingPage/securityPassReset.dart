import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';

class securityPassReset extends StatefulWidget {
  const securityPassReset({Key key}) : super(key: key);

  @override
  __securityPassResetState createState() => __securityPassResetState();
}
class __securityPassResetState extends State<securityPassReset> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('비밀번호 재설정').tr(),
              backgroundColor: MyColors.primaryColor,
              elevation: 0.0,
            ),
            body: Card(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 70),
                        child: Row(
                          children: <Widget>[
                            Text('새로운 비밀번호를 입력해주세요.',style: TextStyle(
                              fontSize: 20.0 ,
                              fontWeight: FontWeight.bold
                            ),).tr(),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 30),
                            ),
                            Text('비밀번호').tr(),
                          ],
                        ),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: '비밀번호(8~32자리)'.tr(),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: '비밀번호 재입력'.tr(),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: Text('• 다른사이트에서 사용하는 것과 동일하거나 쉬운 비밀번호는 사용하지 마세요.').tr(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: Text('• 비밀번호는 8~32자의 영문 대소문자, 숫자, 특수문자를 조합하여 설정해주세요').tr(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                        child: Row(
                          children: <Widget>[
                              Text('• 안전한 계정 사용을 위해 비밀번호는 주기적으로 변경해주세요').tr(),
                            ],
                          ),
                      ),
                      RaisedButton(
                        onPressed: (){

                        },
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
                              Text('확인', style: TextStyle(color: Colors.white,fontSize: 18),).tr(),
                            ],
                          ),
                        ),
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
