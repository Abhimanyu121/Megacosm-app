import 'dart:convert';
import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/BondedNotBondedWrapper.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/TopBottomText.dart';
import 'package:bluzelle/Widgets/ValidatorCardStats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart';

class Stats extends StatefulWidget{
  @override
  StatsState createState() => StatsState();
}
class StatsState extends State<Stats>with AutomaticKeepAliveClientMixin{
  String balance = "123";
  String unbondedStake = "123";
  String bondedStake = "321";
  bool loading = true;
  ValidatorList valList;
  _getInfo()async {

    Response pools = await BluzelleWrapper.getPool();
    String body = utf8.decode(pools.bodyBytes);
    final json = jsonDecode(body);
    BondedNotBondedWrapper model = new BondedNotBondedWrapper.fromJson(json);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("address");
    Response balModel = await BluzelleWrapper.getBalance(address);
    String body1 = utf8.decode(balModel.bodyBytes);
    final json1 = jsonDecode(body1);
    Response delegations = await BluzelleWrapper.getDelegations(address);
    String delBody = utf8.decode(delegations.bodyBytes);
    final delJson = jsonDecode(delBody);
    BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
    valList = ValidatorList.fromJson(delJson);
    bondedStake = model.result.bonded_tokens;
    unbondedStake = model.result.not_bonded_tokens;
    balance = balanceWrapper.result[0].amount;
    setState(() {
      loading = false;
    });
  }
  @override
  void initState() {
    _getInfo();
  }
  @override
  Widget build(BuildContext context) {
    return loading==true?Center(
      child: SpinKitCubeGrid(size:50, color: appTheme),
    ):ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,8,0),
                    child: Text(balance, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35, color: appTheme)),
                  ),
                  Text("UNBT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, color: Colors.black)),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height*0.02,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,5,5,10),
          child: Text("Staking Pools",style: TextStyle(fontSize:25,color: grey, fontWeight: FontWeight.bold),),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height*0.02,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height*0.16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TopBottom(first: bondedStake, second: "UBNT",size: 20, weight: FontWeight.bold,),
                  Text("Bonded Stake", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color:grey),)
                ],
              ),
              VerticalDivider(
                thickness: 3,
                color: Colors.blue,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TopBottom(first: unbondedStake, second: "UBNT",size: 20, weight: FontWeight.bold,),
                  Text("Unbonded Stake", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color:grey),)
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,5,5,10),
          child: Text("Delegations",style: TextStyle(fontSize:25,color: grey, fontWeight: FontWeight.bold),),
        ),
        ListView.builder(
            itemCount: valList.result.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index){
              return ValidatorCardStats(address: valList.result[index].operator_address,name: valList.result[index].description.moniker,commission: valList.result[0].commission.commission_rates.max_rate,);
            }
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}