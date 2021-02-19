import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:papucon/widgets/loader_hud.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:easy_localization/easy_localization.dart';

class phoneNumberNewPass extends StatefulWidget {
  const phoneNumberNewPass({Key key}) : super(key: key);

  @override
  _phoneNumberNewPassState createState() => _phoneNumberNewPassState();
}



class _phoneNumberNewPassState extends State<phoneNumberNewPass> {

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
      _dropdownItems.add(CountryModel(country: 'KR +82', countryCode: '+82'));
      _dropdownItems.add(CountryModel(country: 'JP +81', countryCode: '+81'));
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
                  child: Container(
                    height: MediaQuery.of(context).size.height-100,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(25, 100, 25, 0),
                                  child: Flexible(
                                    child: Text('새로운 전화번호를 입력하세요.'.tr() , style: TextStyle(fontSize: 40),).tr(),
                                  ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              Card(
                                color: Color.fromARGB(255, 250, 250, 250),
                                margin: new EdgeInsets.only(
                                    left: 20.0, right: 20.0, top: 8.0, bottom: 5.0),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Color.fromARGB(225, 225, 225, 225), width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    //_buildCountry(),
                                    _buildPhonefiled(),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                constraints: const BoxConstraints(
                                    maxWidth: 500
                                ),
                                child: RaisedButton(
                                  onPressed: () {
                                    if (phoneController.text.isNotEmpty) {

                                      loginStore.getCodeWithPhoneNumber(context, phoneController.text.toString(), controller.text.toString() );
                                    } else {
                                      loginStore.loginScaffoldKey.currentState.showSnackBar(SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          '휴대폰 번호를 입력해주세요',
                                          style: TextStyle(color: Colors.white),
                                        ).tr(),
                                      ));
                                    }
                                  },
                                  color: MyColors.primaryColor,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '다음'.tr(),
                                          style: TextStyle(color: Colors.white),
                                        ).tr(),
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
                    hintText: 'Choose Country'.tr(),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    //prefixIcon: Icon(Icons.location_on),
                    //labelText:_dropdownValue == null ? 'Where are you from' : 'From',
                    errorText: _errorText,
                  ),
                  isEmpty:_dropdownValue == null,
                  child: DropdownButton<CountryModel>(
                    value: _dropdownValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black38),
                    onChanged: (CountryModel newValue) {
                      print('value change1');
                      print(newValue.countryCode.toString());
                      setState(() {
                        _dropdownValue  = newValue;
                      });
                    },
                    items:_dropdownItems.map((CountryModel value) {
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
            decoration: new InputDecoration(

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