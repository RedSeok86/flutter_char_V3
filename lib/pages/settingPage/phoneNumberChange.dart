import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/pages/settingPage/phoneNumberChanAfter.dart';
import 'package:provider/provider.dart';
import 'package:papucon/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';

class phoneNumberChange extends StatefulWidget {
  const phoneNumberChange({Key key}) : super(key: key);

  @override
  _phoneNumberChangeState createState() => _phoneNumberChangeState();
}
class _phoneNumberChangeState extends State<phoneNumberChange> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('전화번호 변경').tr(),
              backgroundColor: MyColors.primaryColor,
              elevation: 0.0,
            ),
            body: Form(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 100, 25, 0),
                child: Form(
                  child: Column(
                    children: <Widget>[
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
                              Text('전화번호 변경', style: TextStyle(color: Colors.white),).tr(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Column(

                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('papucon에 등록된 전화번호를 변경합니다.', style: TextStyle(fontSize: 16),).tr(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('계속하려면 아래 버튼을 탭하세요.',style: TextStyle(fontSize: 16),).tr(),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 220), //<---320 수정할껏
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
                              Text('전화번호 변경', style: TextStyle(color: Colors.white),).tr(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: ListTile(
                          title: Text('확인페이지',style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: (){
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => phoneNumberChanAfter()));
                          },
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
