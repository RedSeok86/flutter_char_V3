import 'package:flutter/material.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({Key key}) : super(key: key);

  @override
  TermsAndConditionsState createState() => TermsAndConditionsState();
}

class TermsAndConditionsState extends State<TermsAndConditions> {
  bool isLoadings = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFf2f3f6),
      padding: EdgeInsets.only(top: 23.0),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text('이용 약관',
                  style:
                      TextStyle(color: Colors.black, fontSize: 23, height: 1))
              .tr(),
          toolbarHeight: 60,
          backgroundColor: Color(0xFFf2f3f6),
          elevation: 0.0,
          bottom: PreferredSize(
            child: SizedBox(height: 10),
          ),
          bottomOpacity: 0.1,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: Stack(
          children: <Widget>[
            WebView(
              initialUrl:
                  'http://papucon.com/bbs/content.php?co_id=provision&device=mobile',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (finish) {
                setState(() {
                  isLoadings = false;
                });
              },
            ),
            isLoadings ? Center(child: Loading()) : Stack(),
          ],
        ),
      ),
    );
  }
}