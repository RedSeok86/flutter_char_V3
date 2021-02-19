import 'package:flutter/material.dart';
import 'package:papucon/widgets/bubble_bottom_bar_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:papucon/pages/home_page.dart';
import 'package:papucon/pages/profile_page.dart';
import 'package:papucon/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:papucon/pages/storageBox.dart';



//not impornt
class BottomNav extends StatefulWidget{

  @override
  _BottomNavState createState()=> _BottomNavState();

}

class _BottomNavState extends State<BottomNav>{
  int currentIndex=0;

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  BubbleBottomBar(
      opacity: .2,
      currentIndex: currentIndex,
      onTap: changePage,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      //fabLocation: BubbleBottomBarFabLocation.end, //new
      hasNotch: true, //new
      hasInk: true, //new, gives a cute ink effect
      inkColor: Colors.black12, //optional, uses theme color if not specified
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: Colors.red,
            icon: SvgPicture.asset("assets/img/home_on.svg", color: Colors.black, width: 25, height: 25),//Image.asset("assets/img/home_on.svg", width: 25, height: 25),
            activeIcon: SvgPicture.asset("assets/img/home_on.svg", color: MyColors.primaryColor, width: 35, height: 35),
            title: Text("Home")),
        BubbleBottomBarItem(
            backgroundColor: Colors.deepPurple,
            icon: SvgPicture.asset("assets/img/chat_on.svg", color: Colors.black, width: 25, height: 25),//Image.asset("assets/img/home_on.svg", width: 25, height: 25),
            activeIcon: SvgPicture.asset("assets/img/chat_on.svg", color: Colors.deepPurple, width: 35, height: 35),
            title: Text("Chat")),
        BubbleBottomBarItem(
            backgroundColor: Colors.indigo,
            icon: SvgPicture.asset("assets/img/storage_on.svg", color: Colors.black, width: 25, height: 25),//Image.asset("assets/img/home_on.svg", width: 25, height: 25),
            activeIcon: SvgPicture.asset("assets/img/storage_on.svg", color: Colors.deepPurple, width: 35, height: 35),
            title: Text("Inbox")),
        BubbleBottomBarItem(backgroundColor: Colors.green,
            icon: SvgPicture.asset("assets/img/set_on.svg", color: Colors.black, width: 25, height: 25),//Image.asset("assets/img/home_on.svg", width: 25, height: 25),
            activeIcon: SvgPicture.asset("assets/img/set_on.svg", color: Colors.green, width: 35, height: 35),
            title: Text("Setting"))
      ],
      );
    /*
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) => [HomePage(), ProfilePage(),StorageBox(),],
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Chat'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.inboxMultiple ),
            title: Text('Inbox'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Setting'),
          )
        ],
        showSelectedLabels: false, //text remove
        showUnselectedLabels: false, //text remove
        selectedItemColor: MyColors.primaryColor,
        unselectedItemColor: Color.fromARGB(200, 179, 179, 179)
    );

     */
  }
}