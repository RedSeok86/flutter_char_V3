import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papucon/pages/settingPage/helps/privacy/privacy_policy.dart';
import 'package:papucon/pages/settingPage/helps/terms/terms.dart';
import 'package:papucon/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  //var EasyLocalization context.locale = Locale('en', 'US');
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
//                  WebView(
//                    initialUrl: ,
//                    javascriptMode: JavascriptMode.unrestricted,
//                  ),
                  Text('환영합니다!', style: TextStyle(fontSize: 45)).tr(),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height / 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    child: Text('개인정보처리방침', style:TextStyle(color: MyColors.primaryColor, fontSize: 15, fontWeight: FontWeight.bold)).tr(),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                    },
                  ),
                  Text('을 확인해보세요', style: TextStyle(fontSize: 15)).tr(),
                ],
              ),
              SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    child: Text('이용약관', style:TextStyle(color: MyColors.primaryColor, fontSize: 15, fontWeight: FontWeight.bold)).tr(),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditions()));},
                  ),
                  Text('에 동의하면',style: TextStyle(fontSize: 15)).tr(),
                ],
              ),
              SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('동의하고 계속하기를 탭하세요.').tr(),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height / 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(70)),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFFe02c56),
                          Color(0xFFe63d0c),
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 1.3,
                    height: MediaQuery.of(context).size.height / 13,
                    margin: EdgeInsets.only(top: 100.0),
                    child: RaisedButton(
                      elevation: 0.0,
//                      disabledColor: Color(0xffd0393e),//add this to your code
                      color: Colors.transparent,
                      child: Text('동의하고 계속하기', style: TextStyle(fontSize: 18, color: Colors.white)).tr(),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()),(Route<dynamic> route) => false);
                      },
                      highlightElevation:  0.0,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
//                      hoverColor:Colors.transparent,
                    ),
                  ),
                ],
              ),
              //Container(height: MediaQuery.of(context).size.height/25,),
//              Container(
//                child: Divider(
//                  height: 4,
//                  indent: 15,
//                  endIndent: 15,
//                  thickness: 2,
//                ),
//              ),
              //Container(height: MediaQuery.of(context).size.height/25,),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Text('이미 계정이 있으신가요?'),
//                  Text(' 로그인하기',style: TextStyle(fontWeight: FontWeight.bold),),
//
//                ],
//              ),
            ],
          ),
        ),
      ),
    );
  }
}
