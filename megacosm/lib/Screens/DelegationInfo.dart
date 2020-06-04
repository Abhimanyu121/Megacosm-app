import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:bluzelle/DBUtils/DBHelper.dart';
import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/CurrentDelegationWrapper.dart';
import 'package:bluzelle/Models/DelegationInfo.dart';
import 'package:bluzelle/Models/RelegationSelection.dart';
import 'package:bluzelle/Models/ToWithdrawConfirmation.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Utils/AmountOps.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants.dart';
import 'RedelegationSelection.dart';
import 'SetUndelegationAmount.dart';
import 'WithdrawConfirmation.dart';
import 'package:http/http.dart' as http;
class DelegationInfo extends StatefulWidget{
  static const routeName = '/delegationInfo';
  @override
  DelegationInfoState createState() => new DelegationInfoState();
}
class DelegationInfoState extends State<DelegationInfo>{
  String delegatorAddress="";
  bool placingOrder = true;
  bool balance = false;
  DelegationInfoModel args;
  String reward = "0";
  String stake = "0";
  var denom = "";
  var str="";
  var url ="";
  var bal = "0.0";
  var image= false;
  var identity ="";
  var gas =0.0;
  Future<void>_getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gas = double.parse(prefs.getString("gas"));

    setState(() {
      delegatorAddress = prefs.getString("address");
    });

    Response resp = await ApiWrapper.delegationInfo(prefs.getString("address"),args.address);
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    print(json);
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    _getPicture();
    denom = (nw[0].denom).substring(1).toUpperCase();
    BalanceWrapper model = new BalanceWrapper.fromJson(json);
    Response resp2 = await ApiWrapper.delegatedAmount(prefs.getString("address"),args.address);
    String body2 = utf8.decode(resp2.bodyBytes);
    final json2 = jsonDecode(body2);
    print(json2);
    CurrentDelegationWrapper model2 = new CurrentDelegationWrapper.fromJson(json2);
    Response balModel = await ApiWrapper.getBalance(prefs.getString("address"));
    String body1 = utf8.decode(balModel.bodyBytes);
    final json1 = jsonDecode(body1);
    BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
    setState(() {
      balance = true;
      if(model.result.isEmpty){
        reward = "0.0";

      }
      else{
        reward = BalOperations.toBNT(model.result[0].amount);
        bal = BalOperations.toBNT(balanceWrapper.result[0].amount);
      }

      stake = BalOperations.toBNT( model2.result.balance.amount.toString());
    });
  }
  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      var intCom = double.parse(args.commission);
      str = intCom.toStringAsFixed(5);
      _getAddress().then((val){
        infiniteLoop();
      });
      setState(() {
        placingOrder= false;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: nearlyWhite,
        appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: nearlyWhite,
            actionsIconTheme: IconThemeData(color:Colors.black),
            iconTheme: IconThemeData(color:Colors.black),
            title: HeaderTitle(first: "Validator", second: "Information",)
        ),
        body: placingOrder?_loader():RefreshIndicator(
          onRefresh: _getAddress,
          child: ListView(
            cacheExtent: 100,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16,8,8,8),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Delegation", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                      child: Text("Details", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  image?_circleImg(url, context):_circle(args.name.substring(0,1).toUpperCase(), context)
                ],
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30,8,8,8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Delegator Address: ", style: TextStyle(color: Colors.black,)),
                          SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                              onPressed: ()async{
                                String url = await ApiWrapper.expAccountLinkBuilder(delegatorAddress);
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  Toast.show("Invalid URL", context);
                                }
                              },
                              icon: Icon(Icons.open_in_new,
                                color: Colors.black,
                              )

                          ))
                        ],
                      ),
                      Text(delegatorAddress, style: TextStyle(color: Colors.grey,))
                    ],
                  )
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30,8,8,8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Validator Name: ", style: TextStyle(color: Colors.black,)),
                      Text(args.name, style: TextStyle(color: Colors.grey,))
                    ],
                  )
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30,8,8,8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Validator address: ", style: TextStyle(color: Colors.black,)),
                          SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                              onPressed: ()async{
                                String url = await ApiWrapper.expValidatorLinkBuilder(args.address);
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  Toast.show("Invalid URL", context);
                                }
                              },
                              icon: Icon(Icons.open_in_new,
                                color: Colors.black,
                              )

                          ))
                        ],
                      ),
                      Text(args.address, style: TextStyle(color: Colors.grey,))
                    ],
                  )
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30,8,8,8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Commission: ", style: TextStyle(color: Colors.black,)),
                      Text(str, style: TextStyle(color: Colors.grey,))
                    ],
                  )
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30,8,8,8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Staked Amount", style: TextStyle(color: Colors.black,)),
                      Text(BalOperations.seperator(stake)+ " $denom", style: TextStyle(color: Colors.grey,))
                    ],
                  )
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(30,8,8,8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Rewards", style: TextStyle(color: Colors.black,)),
                      Text(BalOperations.seperator(reward) +" $denom", style: TextStyle(color: Colors.grey,))
                    ],
                  )
              ),


              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: ()async {
                        if(!balance){
                          Toast.show("Please wait",context, duration: Toast.LENGTH_LONG);
                          return;
                        }
                        if(double.parse(bal)<gas){
                          Toast.show("Insufficent Balance",context);
                          return;
                        }
                        await Navigator.pushNamed(
                          context,
                          WithdrawConfirmation.routeName,
                          arguments: ToWithdrawConfirmation(
                              name: args.name,
                              address: args.address,
                              commission: str,
                              amount: reward
                          ),
                        );
                        setState(() {
                          _getAddress();
                        });
                      },
                      padding: EdgeInsets.all(12),
                      color: appTheme,
                      child:Text('Withdraw Reward', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: ()async {
                        if(!balance){
                          Toast.show("Please wait",context, duration: Toast.LENGTH_LONG);
                          return;
                        }
                        if(double.parse(bal)<gas){
                          print(gas);
                          print(double.parse(bal));
                          Toast.show("Insufficent Balance",context);
                          return;
                        }

                        await Navigator.pushNamed(
                          context,
                          SetUndelegationAmount.routeName,
                          arguments: ToWithdrawConfirmation(
                              name: args.name,
                              address: args.address,
                              commission: str,
                              amount: stake
                          ),
                        );
                        setState(() {
                          _getAddress();
                        });
                      },
                      padding: EdgeInsets.all(12),
                      color: appTheme,
                      child:Text('Undelegate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: ()async {
                        if(!balance){
                          Toast.show("Please wait",context, duration: Toast.LENGTH_LONG);
                          return;
                        }
                        if(double.parse(bal)<gas){
                          Toast.show("Insufficent Balance",context);
                          return;
                        }
                        await Navigator.pushNamed(
                          context,
                          RedelegationSelection.routeName,
                          arguments: RedelegationSelectionModel(
                              name: args.name,
                              srcAddress: args.address,
                              delegatorAddress: delegatorAddress,
                              amount: stake
                          ),
                        );
                        setState(() {
                          _getAddress();
                        });
                      },
                      padding: EdgeInsets.all(12),
                      color: appTheme,
                      child:Text('Redelegate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
  _circle(String str, BuildContext ctx){
    return Container(
      width: MediaQuery.of(ctx).size.width *0.32,
      height: 150,
      child: Center(
        child: Text(str,style: TextStyle(fontSize: 30),),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
  _circleImg(String url, BuildContext ctx){
    return Container(
      // width: MediaQuery.of(ctx).size.width *0.12,
      height: 150,
      child: Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(url)),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
  _getPicture()async {
    var id = args.identity;
    var resp = await http.get("https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=$id&fields=pictures");
    var js = jsonDecode(resp.body);
    if(js["them"]==null){
      return;
    }
    var url = js["them"][0]["pictures"]["primary"]["url"];
    setState(() {
      this.url= url;
      image = true;
    });
  }
  infiniteLoop(){
    new Timer.periodic(Duration(seconds: 30), (Timer t){
      if(mounted){
        _getAddress();
      }
    });

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