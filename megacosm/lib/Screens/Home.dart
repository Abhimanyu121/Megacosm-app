
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:bluzelle/DBUtils/DBHelper.dart';
import 'package:bluzelle/Utils/TransactionsWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
import 'AboutBluzelle.dart';
import 'NetworkList.dart';
import 'Login.dart';
import 'PoposalsScreen.dart';
import 'Stats.dart';
import 'ValidatorListTab.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  var currentIndex=0;
  Stats stats;
  ValidatorListTab vList;
  ProposalListTab pList;
  TabController _controller;
  SwtichNetwork swtichNetwork;

  void tabChange(int index){

    _controller.animateTo(index);
    if (index ==0){
      stats.toTop();
    }
  }
  @override
  void initState() {
    _controller = new TabController(length: 4, vsync: this);
    _controller.addListener((){
      setState(() {
        currentIndex = _controller.index;
      });
    });
    stats = new Stats();
    vList = new ValidatorListTab();
    pList = new ProposalListTab();
    swtichNetwork = new SwtichNetwork(refetch: refresh,);
  }
  refresh(){
    try{
      swtichNetwork.refresh();
    }catch(e){

    }
    try{
      vList.refresh();
    }catch(e){

    }
    try{
      pList.refresh();
    }catch(e){

    }
    try{
      stats.refresh();
    }catch(e){

    }

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
            IconButton(
              tooltip: "About Bluzelle",
              icon: Image.asset('ico.png',color: Colors.black87,),
              onPressed: (){
                Navigator.pushNamed(context, AboutBluzelle.routeName);
              },
            ),
            HeaderTitle(first: currentIndex==0?"User":currentIndex==1?"Validator":currentIndex==2?"Proposal":"Network", second: currentIndex==0?"Dashboard":currentIndex==1?"List":currentIndex==2?"List":"List",),

            IconButton(
              onPressed: ()async{
                String str = await asyncInputDialog(context);
                if(str=="logout"){
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  final cryptor = new PlatformStringCryptor();
                  String enc= prefs.getString("mnemonic");
                  var seed = "";
                  var salt = prefs.getString("salt");
                  bool status =true;
                  do{
                    String password = await Transactions.asyncInputDialog(context, status);
                    if(password =="cancel"){
                      //return "cancel";
                    }else {
                      final String key = await cryptor.generateKeyFromPassword(password, salt);
                      try {
                        final String decrypted = await cryptor.decrypt(enc, key);
                        seed = decrypted;
                        status = true;// - A string to encrypt.
                        await Clipboard.setData(ClipboardData(text: seed));
                        Toast.show("Mnemonic Copied", context, duration: Toast.LENGTH_LONG);
                        final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                        var ac= await database.networkDao.allNetworks();
                        await database.networkDao.deleteNetworks(ac);
                        await prefs.setString(mnemonic, null);
                        Navigator.popAndPushNamed(context, Login.routeName);
                      } on MacMismatchException {
                        status =false;
                      }
                    }
                  }while(!status);

                }else{
                  return;
                }

              },
              tooltip: "Logout",
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.black87,
                size: 18,
              ),
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
              color: currentIndex==0?Colors.transparent:Colors.grey
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: TabBarView(
            controller: _controller,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              stats,
              vList,
              pList,
              swtichNetwork,
            ],

          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        backgroundColor: Colors.red,
        onPressed: () {
          if(currentIndex ==0){
            stats.refresh();
          }else if(currentIndex==1){
            vList.refresh();
          }else if(currentIndex==2){
            pList.refresh();
          }
          else if(currentIndex==3){
            swtichNetwork.refresh();
          }
        },
      ),
      bottomNavigationBar: BubbleBottomBar(
        backgroundColor: white,
        opacity: 1,
        fabLocation: BubbleBottomBarFabLocation.end,
        onTap: tabChange,
        currentIndex: currentIndex,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        elevation: 2, //new
        hasNotch: true, //new
        hasInk: true ,//new, gives a cute ink effect
        inkColor: white ,//optional, uses theme color if not specified
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.dashboard, color: Colors.black,), activeIcon: Icon(Icons.dashboard, color: Colors.black,), title: Text("Home", style: TextStyle(color: Colors.black), overflow: TextOverflow.fade,)),
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.account_balance, color: Colors.black,), activeIcon: Icon(Icons.account_balance, color: Colors.black,), title: Text("Validators", style: TextStyle(color: Colors.black),overflow: TextOverflow.fade, softWrap: true,)),
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.menu, color: Colors.black,), activeIcon: Icon(Icons.menu, color: Colors.black,), title: Text("Proposals", style: TextStyle(color: Colors.black),overflow: TextOverflow.fade, )),
          BubbleBottomBarItem(backgroundColor: activeTabColor, icon: Icon(Icons.device_hub, color: Colors.black,), activeIcon: Icon(Icons.device_hub, color: Colors.black,), title: Text("Networks", style: TextStyle(color: Colors.black),overflow: TextOverflow.fade, softWrap: true,))
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  static Future<String> asyncInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        TextEditingController _password = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 1,
          backgroundColor: nearlyWhite,
          title: Text('Are you sure?'),
          content:  Text("After you logout you will need to enter your mnemonic againg to get access to this account. Mnemonic will be copied on logout, please store it securely.",style: TextStyle(color: Colors.red),),
          actions: <Widget>[
            FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop("cancel");
                }
            ),
            FlatButton(
                child: Text("Logout"),
                onPressed: () async {
                  Navigator.of(context).pop("logout");
                }),

          ],
        );
      },
    );
  }


}
