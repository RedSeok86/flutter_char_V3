import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:papucon/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';
class phnumChnage extends StatefulWidget {
  const phnumChnage({Key key}) : super(key: key);

  @override
  _phnumChnageState createState() => _phnumChnageState();
}
class _phnumChnageState extends State<phnumChnage> {
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
                padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '인증번호'.tr(),
                        ),
                      ),
                      SizedBox(height: 15.0),
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
                              Text('전화번호 번경', style: TextStyle(color: Colors.white),).tr(),
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
