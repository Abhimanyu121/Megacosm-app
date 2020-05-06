import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/Models/BalanceWrapper.dart';
import 'package:megacosm/Models/CurrentDelegationWrapper.dart';
import 'package:megacosm/Models/DelegationInfo.dart';
import 'package:megacosm/Models/RelegationSelection.dart';
import 'package:megacosm/Models/ToWithdrawConfirmation.dart';
import 'package:megacosm/Utils/ApiWrapper.dart';
import 'package:megacosm/Utils/AmountOps.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
import 'RedelegationSelection.dart';
import 'SetUndelegationAmount.dart';
import 'WithdrawConfirmation.dart';
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
  String bal = "0";
  String stake = "0";
  var denom = "";
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      delegatorAddress = prefs.getString("address");
    });
    Response resp = await ApiWarpper.delegationInfo(prefs.getString("address"),args.address);
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    print(json);
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    denom = (nw[0].denom).substring(1).toUpperCase();
    BalanceWrapper model = new BalanceWrapper.fromJson(json);
    Response resp2 = await ApiWarpper.delegatedAmount(prefs.getString("address"),args.address);
    String body2 = utf8.decode(resp2.bodyBytes);
    final json2 = jsonDecode(body2);
    print(json2);
    CurrentDelegationWrapper model2 = new CurrentDelegationWrapper.fromJson(json2);
    setState(() {
      balance = true;
      if(model.result.isEmpty){
        bal = "0.0";
      }
      else{
        bal = BalOperations.toBNT(model.result[0].amount);
      }

      stake = BalOperations.toBNT( model2.result.balance.amount.toString());
    });
  }
  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      _getAddress();
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
        body: placingOrder?_loader():ListView(
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
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Delegator Address: ", style: TextStyle(color: Colors.black,)),
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
                    Text("Validator address: ", style: TextStyle(color: Colors.black,)),
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
                    Text(args.commission, style: TextStyle(color: Colors.grey,))
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
                    Text(BalOperations.seperator(bal) +" $denom", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

                      await Navigator.pushNamed(
                        context,
                        WithdrawConfirmation.routeName,
                        arguments: ToWithdrawConfirmation(
                            name: args.name,
                            address: args.address,
                            commission: args.commission,
                            amount: bal
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

                      await Navigator.pushNamed(
                        context,
                        SetUndelegationAmount.routeName,
                        arguments: ToWithdrawConfirmation(
                            name: args.name,
                            address: args.address,
                            commission: args.commission,
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
        )
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