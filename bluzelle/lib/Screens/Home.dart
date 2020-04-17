import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Screens/ValidatorListTab.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  var currentIndex=0;

  TabController _controller;
  void tabChange(int index){
    setState(() {
      currentIndex = index;
      _controller.animateTo(index);
    });
  }
  @override
  void initState() {
    _controller = new TabController(length: 4, vsync: this);
    _controller.addListener((){
      setState(() {
        currentIndex = _controller.index;
      });
    });

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: nearlyWhite,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            HeaderTitle(first: "List Of", second: "Validators",),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.power_settings_new,
                    color: Colors.black87,
                    size: 18,
                  ),
                ),
                Text(
                  "Logout",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    letterSpacing: -0.2,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: nearlyWhite,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: nearlyWhite,
            border: Border.all(
              color: Colors.grey
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: TabBarView(
            controller: _controller,
            children: <Widget>[
              ValidatorListTab(),
              ValidatorListTab(),
              ValidatorListTab(),
              ValidatorListTab(),
            ],

          ),
        ),
      ),


      bottomNavigationBar: BubbleBottomBar(
        backgroundColor: white,
        opacity: 1,
        onTap: tabChange,
        currentIndex: currentIndex,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        elevation: 2, //new
        hasNotch: true, //new
        hasInk: true ,//new, gives a cute ink effect
        inkColor: white ,//optional, uses theme color if not specified
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.dashboard, color: Colors.black,), activeIcon: Icon(Icons.dashboard, color: Colors.black,), title: Text("Home", style: TextStyle(color: Colors.black),)),
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.access_time, color: Colors.black,), activeIcon: Icon(Icons.access_time, color: Colors.black,), title: Text("Logs", style: TextStyle(color: Colors.black),)),
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.folder_open, color: Colors.black,), activeIcon: Icon(Icons.folder_open, color: Colors.black,), title: Text("Folders", style: TextStyle(color: Colors.black),)),
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.menu, color: Colors.black,), activeIcon: Icon(Icons.menu, color: Colors.black,), title: Text("Menu", style: TextStyle(color: Colors.black),))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
