import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:papucon/theme.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class storageImageSelect extends StatefulWidget {
  @override
  _storageImageSelectState createState() => _storageImageSelectState();
}

class _storageImageSelectState extends State<storageImageSelect> {

  bool isChangeSearch;

  final FocusNode focusNode = FocusNode();

  void getChangeSearch(){
    focusNode.unfocus();
    setState(() {
      isChangeSearch = !isChangeSearch;
    });
  }

  @override
  void initState(){
    isChangeSearch = false;
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<LoginStore>(builder: (_, loginStore, __) {
      return Scaffold(
        appBar: E_appBar(),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15,30,15,0),
                child: Container(
                  width: 380,
                  height: 450,
                  color: Colors.blue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15,40,15,0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height:80,
                      color: Colors.greenAccent ,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                      ),
                    ),
                    Container(
                      width: 80,
                      height:80,
                      color: Colors.greenAccent ,
                      child: IconButton(
                        icon: Icon(Icons.file_download),
                      ),
                    ),
                    Container(
                      width: 80,
                      height:80,
                      color: Colors.greenAccent ,
                      child: IconButton(
                        icon: Icon(Icons.share),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }



  Widget E_appBar() {
    if(!isChangeSearch){
      return AppBar(
        backgroundColor: MyColors.primaryColor,

        actions: <Widget>[
          E_morevert(),
        ],
      );
    }
    return AppBar(
      backgroundColor: Colors.white,
      title: Container(
        child: TextField(
          decoration: InputDecoration(
              focusedErrorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: '검색 내용을 입력하세요'.tr(),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search , color: Colors.black),
          onPressed: (){},
        ),
      ],
    );
  }
  Widget E_morevert(){
    return  IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: (){
        showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black.withAlpha(1),
            transitionDuration: Duration(milliseconds: 100),
            pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
              return Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 60,
                    margin: EdgeInsets.only(
                      top: 68.0,
                      right: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 0,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Material(
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: ListTile(
                                title: Text('보관함 비우기', style: TextStyle(fontSize: 20)).tr(),
                                onTap: (){
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
        );
      },
    );
  }


}