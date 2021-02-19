import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:easy_localization/easy_localization.dart';

class settingFriend extends StatefulWidget {
  const settingFriend({Key key}) : super(key: key);

  @override
  _settingFriendState createState() => _settingFriendState();
}

class _settingFriendState extends State<settingFriend> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(builder: (_, loginStore, __) {
      return Scaffold(
        appBar: AppBar(
          title: Text('친구').tr(),
          backgroundColor: MyColors.primaryColor,
          elevation: 10.0,
        ),
        body: Container(
//                    height: MediaQuery.of(context).size.height/5.0,
//                    color: Colors.white,
          child: ListView(
            //scrollDirection: Axis.vertical,
            children: <Widget>[
              ListTile(
                title: Text('프로필별 차단 친구 관리',
                        style: TextStyle(fontWeight: FontWeight.bold))
                    .tr(),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      );
    });
  }
}
