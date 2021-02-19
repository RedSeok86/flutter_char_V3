import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class ComingSoon extends StatefulWidget {
  ComingSoon({Key key}) : super(key: key);

  @override
  ComingSoonState createState() => ComingSoonState();
}

class ComingSoonState extends State<ComingSoon> {
  double zeheight = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
        backgroundColor: Color(0xFFf2f3f6),
        appBar: AppBar(
          brightness: Brightness.light,
          centerTitle: false,
          title: Text(
              '보관함',
              style: TextStyle(color: Colors.black, fontSize: 26, height: 0.5)
          ).tr(),
          toolbarHeight: 60,
          backgroundColor: Color(0xFFf2f3f6),
//          backgroundColor: Colors.amber,
          elevation: 0.0,
          bottom: PreferredSize(
            child: SizedBox(
              height: 10,
            ),
          ),
          bottomOpacity: 0.1,
        ),
        body: PreferredSize(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 40,
                margin: EdgeInsets.only(left: 20, right: 20, top: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(19.0),
                    topRight: Radius.circular(19.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3, 3),
                      blurRadius: 6
                    ),
                    BoxShadow(
                      color: Colors.white12,
                      offset: Offset(-3, -3),
                      blurRadius: 6
                    )
                  ]
                ),
                child: Center(
                  child: Text('Coming Soon').tr(),
                )
            )
          ],
        ),
      ),
    );
  }
}
