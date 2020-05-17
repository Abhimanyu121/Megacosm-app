import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/Models/BalanceWrapper.dart';
import 'package:megacosm/Models/HomeToNewStake.dart';
import 'package:megacosm/Models/NewStakeToConfirm.dart';
import 'package:megacosm/Utils/ApiWrapper.dart';
import 'package:megacosm/Utils/AmountOps.dart';
import 'package:megacosm/Utils/ColorRandminator.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart'as http;
import '../Constants.dart';
import 'NewStakeConfirmation.dart';
class NewStake extends StatefulWidget{
  static const routeName = '/newStake';
  @override
  NewStakeState createState() => new NewStakeState();
}
class NewStakeState extends State<NewStake>{
  String delegatorAddress="";
  bool placingOrder = true;
  bool balance = false;
  String bal = "0";
  String url="";
  String denom="";
  bool image= false;
  HomeToNewStake args;
      TextEditingController _amount= new TextEditingController();
  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      delegatorAddress = prefs.getString("address");
    });
    Response resp = await ApiWrapper.getBalance(prefs.getString("address"));
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    denom = (nw[0].denom).substring(1).toUpperCase();
    await _getPicture();
    BalanceWrapper model = new BalanceWrapper.fromJson(json);
    setState(() {
      if(model.result.isEmpty){
        bal ="0";
        placingOrder =false;
      }
      else{
        bal = BalOperations.toBNT(model.result[0].amount);
        placingOrder = false;
      }
    });
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
  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
    });
    _getAddress();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: nearlyWhite,
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          backgroundColor: nearlyWhite,
          actionsIconTheme: IconThemeData(color:Colors.black),
          iconTheme: IconThemeData(color:Colors.black),
          title: HeaderTitle(first: "New", second: "Delegation",)
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
                    child: Text("Validator ", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
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
                    Text("Validator details: ", style: TextStyle(color: Colors.black,)),
                    Text(args.details.isEmpty?"Not Available":args.details, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Validator Identity: ", style: TextStyle(color: Colors.black,)),
                    Text(args.identity.isEmpty?"Not Available":args.identity, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Security Contract: ", style: TextStyle(color: Colors.black,)),
                    Text(args.security_contract.isEmpty?"Not Available":args.security_contract, style: TextStyle(color: Colors.grey,))
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
                        Text("Validator Website: ", style: TextStyle( fontSize: 17, color: Colors.black)),
                        SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                            onPressed: ()async{
                              String url = args.website;
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
                    Text(args.website.isEmpty?"Not Available":args.website, style: TextStyle(color: Colors.grey,))
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
                    Text("Your Balance", style: TextStyle(color: Colors.black,)),
                    Text(BalOperations.seperator(bal) +" $denom", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8,8,8,8),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                autovalidate: true,
                validator: (val) => (val!=""?double.parse(val)<double.parse(bal):true)
                    ? null
                    : 'Please enter a valid amount',
                decoration: InputDecoration(
                  hintText: "Amount to Stake",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Note: If you are already a delegator to this validator, this action will add specified tokens to you existing stake amount"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: (){
                  if(_amount.text==0.toString()){
                    Toast.show("Invalid amount",context, duration: Toast.LENGTH_LONG);
                    return;
                  }

                  Navigator.popAndPushNamed(
                    context,
                    NewStakeConfirmation.routeName,
                    arguments: HomeToNewStakeConfirm(
                        name: args.name,
                        address: args.address,
                        commission: args.commission,
                        amount: _amount.text
                    ),
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Stake', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
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
  _loader(){
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }
}