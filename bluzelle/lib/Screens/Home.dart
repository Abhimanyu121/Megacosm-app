import 'dart:convert';

import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Screens/PoposalsScreen.dart';
import 'package:bluzelle/Screens/ValidatorListTab.dart';
import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'Stats.dart';

class Home extends StatefulWidget {

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  var currentIndex=0;

  TabController _controller;
  void tabChange(int index){

    _controller.animateTo(index);
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
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Stats(),
              ValidatorListTab(),
              ProposalListTab(),
              ValidatorListTab(),
            ],

          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: currentIndex==2?FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: ()async {
          var str = await _newProposal(context);
          if(str !="cancel"){
            setState(() {

            });
          }
        },
      ):null,
      bottomNavigationBar: BubbleBottomBar(
        backgroundColor: white,
        opacity: 1,
        fabLocation: currentIndex==2?BubbleBottomBarFabLocation.end:null,
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
  Future<String> _newProposal(BuildContext context) async {
    String balance = "";
    bool _loading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("address");
    Response balModel = await BluzelleWrapper.getBalance(address);
    String body1 = utf8.decode(balModel.bodyBytes);
    final json1 = jsonDecode(body1);
    BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
    setState(() {
      _loading = false;
      balance = balanceWrapper.result[0].amount;
    });
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        TextEditingController _amount = TextEditingController();
        TextEditingController _title = TextEditingController();
        TextEditingController _description = TextEditingController();
        return AlertDialog(
          title: Text('Write Proposal and amount to Stake'),
          content: _loading?_loader(): Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  autovalidate: false,
                  validator: (val) => val.isEmpty
                      ? null
                      : 'Invalid Amount.',
                  decoration: InputDecoration(
                    hintText: 'Proposal Title',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                  ),
                  controller: _title,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  autovalidate: false,
                  validator: (val) => val.isEmpty
                      ? null
                      : 'Invalid Amount.',
                  decoration: InputDecoration(
                    hintText: 'Proposal Description',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                  ),
                  controller: _description,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  autovalidate: true,
                  validator: (val) =>(val==""?true: BigInt.parse(val)<=BigInt.parse(balance))
                      ? null
                      : 'Invalid Amount.',
                  decoration: InputDecoration(
                    hintText: 'Enter Amount to deposit',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                  ),
                  controller: _amount,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop("cancel");
                }
            ),
            FlatButton(
                child: Text("Confirm"),
                onPressed: () async {
                  if(BigInt.parse(_amount.text)<=BigInt.parse(balance))
                  {
                    var tx =await BluzelleTransactions.newProposal(_description.text, _title.text, _amount.text);
                    Toast.show("Transaction Hash: $tx", context, duration: Toast.LENGTH_LONG);
                    Navigator.of(context).pop(tx);
                  }
                  else{
                    Toast.show("Invalid Amount", context, duration: Toast.LENGTH_LONG);
                  }
                }),

          ],
        );
      },
    );
  }
  _loader(){
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }

}
