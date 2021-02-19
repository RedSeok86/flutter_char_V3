import 'package:flutter/material.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactToUs extends StatefulWidget {
  const ContactToUs({Key key}) : super(key: key);

  @override
  ContactToUsState createState() => ContactToUsState();
}

class ContactToUsState extends State<ContactToUs> {
  bool isLoadings = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFf2f3f6),
      padding: EdgeInsets.only(top: 23.0),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text('문의하기',
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
                  'http://papucon.com/bbs/write.php?bo_table=inquiry&device=mobile',
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
