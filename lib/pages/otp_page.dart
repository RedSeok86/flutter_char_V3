import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/loader_hud.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key key}) : super(key: key);
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {

  String text = '';
  String authCode = '인증번호';

  void _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
      if(text.length >= 6) {
        text = text.substring(0, 6);
      }
    });
  }

  Widget otpNumberWidget(int position) {
    try {
      return Container(
        height: 56,
        width: 47,
        decoration: BoxDecoration(
          border: Border.all(color: MyColors.primaryColor.withAlpha(100), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(6))
        ),
        child: Center(child: Text(text[position], style: TextStyle(color: Colors.black, fontSize: 24),)),
      );
    } catch (e) {
      return Container(
        height: 56,
        width: 47,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withAlpha(20), width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(6))
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Observer(
          builder: (_) => LoaderHUD(
            inAsyncCall: loginStore.isOtpLoading,
            child: Scaffold(
              backgroundColor: Colors.white,
              key: loginStore.otpScaffoldKey,
              appBar: AppBar(
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: MyColors.primaryColorLight.withAlpha(20),
                    ),
                    child: Icon(Icons.arrow_back_ios, color: MyColors.primaryColor, size: 16),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                elevation: 0,
                backgroundColor: Colors.white,
                brightness: Brightness.light,
              ),
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(top: 70,left: 14),
//                                  child: Text('문자로 전송된 '+ authCode + '를 입력하십시오.', style: TextStyle(color: Colors.black54, fontSize: 26, fontWeight: FontWeight.w500))
                                    child: Text.rich(
                                      TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(text: '문자로 전송된 '.tr(), style: TextStyle(color: Colors.black.withAlpha(70), fontSize: 15, fontWeight: FontWeight.w500)),
                                          TextSpan(text: '인증코드'.tr(), style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                                          TextSpan(text: '를 입력하십시오.'.tr(), style: TextStyle(color: Colors.black.withAlpha(70), fontSize: 15, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    )
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 310,
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      otpNumberWidget(0),
                                      otpNumberWidget(1),
                                      otpNumberWidget(2),
                                      otpNumberWidget(3),
                                      otpNumberWidget(4),
                                      otpNumberWidget(5),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 48,
                            margin: EdgeInsets.only(bottom: 50),
                            constraints: BoxConstraints(
                              maxWidth: 292,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(70)),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFFe02c56),
                                  Color(0xFFe63d0c),
                                ],
                              ),
                            ),
                            child: RaisedButton(
                              highlightElevation:  0.0,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: () {
                                loginStore.validateOtpAndLogin(context, text);
                              },
                              color: Colors.transparent,
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(

//                                  borderRadius: BorderRadius.all(Radius.circular(6))
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('확인', style: TextStyle(color: Colors.white),).tr(),
//                                    Container(
//                                      padding: const EdgeInsets.all(8),
//                                      decoration: BoxDecoration(
//                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
//                                        color: MyColors.primaryColorLight,
//                                      ),
//                                      child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16,),
//                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          NumericKeyboard(
                            onKeyboardTap: _onKeyboardTap,
                            textColor: Colors.black.withAlpha(140),
                            rightIcon: Icon(
                              Icons.backspace,
                              color: MyColors.primaryColor,
                            ),
                            rightButtonFn: () {
                              setState(() {
                                text = text.substring(0, text.length - 1);
                              });
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
