import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:provider/provider.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/loader_hud.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //TextEditingController phoneController = TextEditingController();

  String dropdownValue = 'One';

  static List<CountryModel> _dropdownItems = new List();
  final formKey = new GlobalKey<FormState>();

  var controller = new MaskedTextController(mask: '000-0000-0000');
  CountryModel _dropdownValue;
  String _errorText;
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dropdownItems.clear();

      _dropdownItems.add(CountryModel(country: 'JP +81', countryCode: '+81'));
      _dropdownItems.add(CountryModel(country: 'KR +82', countryCode: '+82'));
      _dropdownValue = _dropdownItems[0];
      phoneController.text = _dropdownValue.countryCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Observer(
          builder: (_) => LoaderHUD(
            inAsyncCall: loginStore.isLoginLoading,
            child: Scaffold(
              backgroundColor: Colors.white,
              key: loginStore.loginScaffoldKey,
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: <Widget>[
                        Container(
//                          flex: 2,
                          margin: EdgeInsets.only(top: 100.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 100, horizontal: 90),
                                child: SvgPicture.asset("assets/img/papusp_suptitle.svg",
                                    color: Color(0xFFd2201d), width: 180),
                                //papusp2.svg
                              ),
                            ],
                          ),
                        ),
                        Container(
//                          flex: 1,
                          margin: EdgeInsets.only(top: 70.0),
                          child: Column(
                            children: <Widget>[
                              Container(
//                              color: Color.fromARGB(255, 250, 250, 250),
                                margin: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 8.0,
                                    bottom: 5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Color(0xffe1e1e1)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
//                                shape: RoundedRectangleBorder(
//                                    side: BorderSide(color: Color.fromARGB(225, 225, 225, 225), width: 1.0),
//                                    borderRadius: BorderRadius.circular(8.0)
//                                    ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    //_buildCountry(),
                                    _buildPhonefiled(),
                                  ],
                                ),
                              ),
                              /*
                              Container(
                                height: 40,
                                constraints: const BoxConstraints(
                                  maxWidth: 500
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: CupertinoTextField(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(4))
                                  ),
                                  controller: phoneController,
                                  clearButtonMode: OverlayVisibilityMode.editing,
                                  keyboardType: TextInputType.phone,
                                  maxLines: 1,
                                  placeholder: '+82...',
                                ),
                              ),
                              */

                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                constraints: BoxConstraints(maxWidth: 500),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(70)),
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
                                  elevation: 0.0,
                                  onPressed: () {
                                    if (phoneController.text.isNotEmpty) {
                                      print(_dropdownValue.countryCode
                                              .toString() +
                                          controller.text.toString());
                                      loginStore.getCodeWithPhoneNumber(
                                          context,
                                          _dropdownValue.countryCode.toString(),
                                          controller.text.toString());
                                    } else {
                                      loginStore.loginScaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          '휴대폰 번호를 입력해주세요',
                                          style: TextStyle(color: Colors.white),
                                        ).tr(),
                                      ));
                                    }
                                  },
                                  color: Colors.transparent,
//                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text('다음',
                                                style: TextStyle(
                                                    color: Colors.white))
                                            .tr(),
                                        /*
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                            color: MyColors.primaryColorLight,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        )*/
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

/*
  Widget _buildCountry() {
    return FormField(
      builder: (FormFieldState state) {
        return DropdownButtonHideUnderline(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              InputDecorator(
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Choose Country',
                  //prefixIcon: Icon(Icons.location_on),
                  //labelText:  _dropdownValue == null ? 'Where are you from' : 'From',
                  errorText: _errorText,
                ),
                isEmpty: _dropdownValue == null,
                child: DropdownButton<CountryModel>(
                  value: _dropdownValue,
                  isDense: true,
                  onChanged: (CountryModel newValue) {
                    print('value change1');
                    print(newValue.countryCode.toString());
                    setState(() {
                      _dropdownValue = newValue;
                      phoneController.text = _dropdownValue.countryCode;
                    });
                  },
                  items: _dropdownItems.map((CountryModel value) {
                    return DropdownMenuItem<CountryModel>(
                      value: value,
                      child: Text(value.country),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
*/
  Widget _buildPhonefiled() {
    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownButtonHideUnderline(
            child: Column(
              children: <Widget>[
                InputDecorator(
                  decoration: InputDecoration(
                    filled: false,
                    hintText: 'Choose Country',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 4.5),
                    //prefixIcon: Icon(Icons.location_on),
                    //labelText:_dropdownValue == null ? 'Where are you from' : 'From',
                    errorText: _errorText,
                  ),
                  isEmpty: _dropdownValue == null,
                  child: DropdownButton<CountryModel>(
                    value: _dropdownValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black38),
                    /*
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),*/
                    onChanged: (CountryModel newValue) {
                      print('value change1');
                      print(newValue.countryCode.toString());
                      setState(() {
                        _dropdownValue = newValue;
                      });
                    },
                    items: _dropdownItems.map((CountryModel value) {
                      return DropdownMenuItem<CountryModel>(
                        value: value,
                        child: Text(value.country),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
          flex: 2,
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: '휴대폰 번호를 입력해주세요.'.tr()),
            onSaved: (String value) {
              print("세이브");
              print(value);
            },
          ),
          flex: 5,
        ),
      ],
    );
  }
}

class CountryModel {
  String country = '';
  String countryCode = '';

  CountryModel({
    this.country,
    this.countryCode,
  });
}
