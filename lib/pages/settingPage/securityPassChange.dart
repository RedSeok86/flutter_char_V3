import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';

class securityPassChange extends StatefulWidget {
  const securityPassChange({Key key}) : super(key: key);

  @override
  _securityPassChangeyState createState() => _securityPassChangeyState();
}
class _securityPassChangeyState extends State<securityPassChange> {

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
            body: Card(
                child: Column(

                ),
            ),
          );
        }
    );
  }
}
