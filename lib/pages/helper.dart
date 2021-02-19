import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:papucon/model/model.dart';
import 'package:papucon/pages/profile_page.dart';
import 'package:easy_localization/easy_localization.dart';
class Helper extends StatefulWidget {
  final Profile  currentProfile;
  Helper({Key key, @required this.currentProfile}) : super(key: key);
  _HelperState createState() => _HelperState();

}

class _HelperState extends State<Helper> {

  PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  Widget buildButton(){
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return
      FlatButton(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text('SKIP',style: TextStyle(fontSize: 18,color: Colors.grey),),
        ),
        onPressed:(){
          Profile emptyProfile= Profile(widget.currentProfile.uid,null,null,null,null,null,null);
          Navigator.push(context,MaterialPageRoute(builder: (context) => ProfilePage(currentProfile: emptyProfile)),);
        } ,
      );
  }
  @override
  Widget build(BuildContext context) {
    //Device locale ja_JP
    //Device locale ko_KR
//      if(context.locale.languageCode.toString() == "ja" || context.locale.languageCode.toString() == "JP"){
        return WillPopScope(
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  color: Color(0xFFf2f3f6),//배경
                  child: Stack(
                    children: <Widget>[
                      (context.locale.languageCode.toString() == "ja" || context.locale.languageCode.toString() == "JP") ?
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuide_J1.png', height: MediaQuery.of(context).size.height/1.2),
                      ) : Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuideK_1.png', height: MediaQuery.of(context).size.height/1.2),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          color: Color(0xFF232330),
                          width: 500,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('프로필별 친구,지인, 회사동료 등 원하는대로',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('분류할 수 있어 내 새생활을 보호할 수 있어요!',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('프로필별로 친구에게 초대장을 보내요.',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Text('상대방이 친구수락을 하면, 대화를 시작할 수 있어요!',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 500,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                color: Color(0x801a1a1a),
                                borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.white,
                          width: 500,
                          height: 5,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFd0393e),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 500,
                        height: 100,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                                    child: buildButton(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),//1번 컨테이너 끝
                Container(
                  color: Color(0xFFf2f3f6),
                  child: Stack(
                    children: <Widget>[
                      (context.locale.languageCode.toString() == "ja" || context.locale.languageCode.toString() == "JP") ?
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuide_J2.png', height: MediaQuery.of(context).size.height/1.2),
                      ) : Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuideK_2.png', height: MediaQuery.of(context).size.height/1.2),
                      ),
                      Align(
                        //2번
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          color: Color(0xFF232330),
                          width: 500,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('Papucon의 특별한 기능!', style: TextStyle(
                                        fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('프로필 사진을 누르면 온라인상태를 변경할수 있어요!',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('(온라인,오프라인,다른용무 중)'.tr(), style: TextStyle(
                                        fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('이름을 누르면',
                                      style: TextStyle(
                                        fontSize: 13, color: Colors.white, ),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('내 프로필 사진을 확인 할 수 있어요!',
                                      style: TextStyle(
                                        fontSize: 13, color: Colors.white, ),).tr(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 500,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x801a1a1a),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x801a1a1a),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.white,
                          width: 500,
                          height: 5,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFd0393e),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 500,
                        height: 100,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 40 , 0, 0),
                                    child: buildButton(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),//2번 컨테이너 끝
                //3번 컨테이너 시작
                Container(
                  color: Color(0xFFf2f3f6),
                  child: Stack(
                    children: <Widget>[
                      (context.locale.languageCode.toString() == "ja" || context.locale.languageCode.toString() == "JP") ?
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuide_J3.png', height: MediaQuery.of(context).size.height/1.2),
                      ) : Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuideK_3.png', height: MediaQuery.of(context).size.height/1.2),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          color: Color(0xFF232330),
                          width: 500,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('Papucon의 특별한 기능!', style: TextStyle(
                                        fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('보관함! 언제 어디서든 사진이나 문서를 손쉽게 정리해요!',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('파일 종류별로 저장공간을 확인하고',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Text('효율적으로 사용할 수 있어요!', style: TextStyle(
                                        fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 500,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x801a1a1a),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x801a1a1a),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.white,
                          width: 500,
                          height: 5,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFd0393e),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 500,
                        height: 100,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 40 , 0, 0),
                                    child: buildButton(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),//3번 컨테이너 끝
                //4번 컨테이너 시작
                Container(
                  color: Color(0xFFf2f3f6),
                  child: Stack(
                    children: <Widget>[
                      (context.locale.languageCode.toString() == "ja" || context.locale.languageCode.toString() == "JP") ?
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuide_J4.png', height: MediaQuery.of(context).size.height/1.2),
                      ) : Container(
                        margin: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Image.asset('assets/guideImages/startGuideK_4.png', height: MediaQuery.of(context).size.height/1.2),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          color: Color(0xFF232330),
                          width: 500,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('', style: TextStyle(
                                        fontSize: 15, color: Colors.white),),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('', style: TextStyle(
                                        fontSize: 13, color: Colors.white),),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 55),
                                    child: Text('이메일을 등록하면 언제든지 로그인 할수 있어요!',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),).tr(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Text('', style: TextStyle(
                                        fontSize: 13, color: Colors.white),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 500,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 35,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0x801a1a1a),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: (){
                                    _pageController.previousPage(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.white,
                          width: 500,
                          height: 5,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFffffff),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 5,
                                    color: Color(0xFFd0393e),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(bottom: 50),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(70)),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFFe02c56),
                                  Color(0xFFe63d0c),
                                ],
                              ),
                            ),
                            child: SizedBox(width: MediaQuery.of(context).size.width / 1.2,
                              child: RaisedButton(
                                elevation: 0.0,
                                color: Colors.transparent,
                                child: Text('프로필 만들기'.tr(), style: TextStyle(
                                    fontSize: 20, color: Colors.white),).tr(),
                                onPressed: () {
                                  Profile emptyProfile= Profile(widget.currentProfile.uid,null,null,null,null,null,null);
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => ProfilePage(currentProfile: emptyProfile)),);
                                },
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 500,
                        height: 100,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 40 , 0, 0),
                                    child: buildButton(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),//4번 컨테이너 끝
              ],
            ),
          ),
          onWillPop: () async {
            return false;
          },
        );
  }
}





