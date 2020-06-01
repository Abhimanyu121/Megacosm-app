import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:http/http.dart';
import 'package:bluzelle/DBUtils/DBHelper.dart';
import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/BondedNotBondedWrapper.dart';
import 'package:bluzelle/Models/Validator.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Screens/RecoveryPhrase.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Utils/AmountOps.dart';
import 'package:bluzelle/Utils/HexColor.dart';
import 'package:bluzelle/Utils/TransactionsWrapper.dart';
import 'package:bluzelle/Widgets/CurvePainter.dart';
import 'package:bluzelle/Widgets/ValidatorCardStats.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants.dart';
import 'SendToken.dart';

class Stats extends StatefulWidget{
  Function refresh;
  Function toTop;
  @override
  StatsState createState() => StatsState();
}
class StatsState extends State<Stats>with AutomaticKeepAliveClientMixin{
  ScrollController controller = ScrollController();
  String balance = "123";
  String unbondedStake = "123";
  String bondedStake = "321";
  bool loading = false;
  bool error = false;
  String denom="";
  String address;
  ValidatorList valList;
  getInfo()async {
    setState(() {
      error =false;
      loading = true;
    });
    try{
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
      } else if (connectivityResult == ConnectivityResult.wifi) {
      }
      else {
        setState(() {
          print("here");
          error =true;
        });
        return ;
      }
      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      var nw = await database.networkDao.findActiveNetwork();
      denom = (nw[0].denom).substring(1).toUpperCase();
      Response pools = await ApiWrapper.getPool();
      String body = utf8.decode(pools.bodyBytes);
      final json = jsonDecode(body);
      BondedNotBondedWrapper model = new BondedNotBondedWrapper.fromJson(json);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String address = prefs.getString("address");
      print(address);
      Response balModel = await ApiWrapper.getBalance(address);
      String body1 = utf8.decode(balModel.bodyBytes);
      final json1 = jsonDecode(body1);
      Response delegations = await ApiWrapper.getDelegations(address);
      String delBody = utf8.decode(delegations.bodyBytes);
      final delJson = jsonDecode(delBody);
      BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
      valList = ValidatorList.fromJson(delJson);
      var ls = valList.result;
      ls.sort(mySortComparison);
      bondedStake = BalOperations.toBNT(model.result.bonded_tokens);
      unbondedStake = BalOperations.toBNT(model.result.not_bonded_tokens);
      if(balanceWrapper.result.isEmpty){
        balance = "0.0";
      }else {
        balance = BalOperations.toBNT(balanceWrapper.result[0].amount);
      }
      setState(() {
        loading = false;
        this.address = address;
        error= false;
      });
    }catch(e){
      setState(() {
        print(e.toString());
        error = true;
        loading = false;
      });
    }

  }
  _curveAngle(){
    double bstake= double.parse(bondedStake);
    double ustake = double.parse(unbondedStake);
    int sum = (bstake+ustake).toInt();
    if (sum ==0){
      return 0;
    }
    double maticDiff = (sum - ustake.toInt())/sum;
    double  angle = (360.0*maticDiff);
    print(angle);
    return angle;
  }

  @override
  void initState() {
    try {
      getInfo().then((){

      });
    } catch(e){
      setState(() {
        error = true;
      });
    }
    widget.refresh = (){
      try {
        getInfo();
      } catch(e){
        setState(() {
          error = true;
        });
      }
    };
    widget.toTop=scrollToTop;
    infiniteLoop();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading==true?Center(
      child: SpinKitCubeGrid(size:50, color: appTheme),
    ):error?Center(
      child: Text("Something went wrong :(\nCheck your internet and your network settings"),
    ):ListView(
      controller: controller,
      cacheExtent: 1000,
      children: <Widget>[
        Card(
          elevation: 0,
          color: nearlyWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Container(
            width: MediaQuery.of(context).size.width*0.9,
            //height: MediaQuery.of(context).size.height*0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.black,
                Colors.black87
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),

            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0,5,5,35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16,5,5,4),
                        child: Text("Account",style: TextStyle(fontSize:25,color: Colors.white70, fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16,5,5,4),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                            width: MediaQuery.of(context).size.width*0.2,
                            child: Image.asset("logo.png"))
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Text("Balance: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Text(BalOperations.seperator(balance)+" $denom", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,8,0),
                          child: Row(
                            children: <Widget>[
                              Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                              SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                                onPressed: ()async{
                                  Toast.show("Address Copied", context);
                                  await Clipboard.setData(ClipboardData(text: address));
                                },
                                  icon: Icon(Icons.content_copy,
                                    color: Colors.white70,
                                  )

                              )),
                              SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                                  onPressed: ()async{
                                    String url = await ApiWrapper.expAccountLinkBuilder(address);
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      Toast.show("Invalid URL", context);
                                    }
                                  },
                                  icon: Icon(Icons.open_in_new,
                                    color: Colors.white70,
                                  )

                              ))
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.8,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0,0,8,0),
                            child: Text(address, textAlign: TextAlign.start , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5,20,5,0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width* 0.34,
                                child: OutlineButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children:<Widget>[Text("SEND",style: TextStyle(fontSize:15,color: Colors.white70, fontWeight: FontWeight.bold),),
                                      Text("$denom",style: TextStyle(fontSize:15,color: Colors.white70, fontWeight: FontWeight.bold),)
                                    ] ),
                                  ),
                                  onPressed: (){
                                    Navigator.pushNamed(context, SendTokens.routeName,);
                                  },

                                  borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width* 0.34,
                                child: OutlineButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children:<Widget>[Text("SHOW",style: TextStyle(fontSize:15,color: Colors.white70, fontWeight: FontWeight.bold),),
                                          Text("QR",style: TextStyle(fontSize:15,color: Colors.white70, fontWeight: FontWeight.bold),)
                                        ] ),
                                  ),
                                  onPressed: (){
                                    asyncInputDialog(context);
                                  },

                                  borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                                ),
                              ),

                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 6),
                          child: OutlineButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width*0.81,
                                  height: MediaQuery.of(context).size.width*0.1,
                                  child: Center(child: Text("SHOW MNEMONIC",style: TextStyle(fontSize:15,color: Colors.white70, fontWeight: FontWeight.bold),))),
                            ),
                            onPressed: ()async {
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
                                    Navigator.pushNamed(context, RecoveryPhrase.routeName, arguments: seed);
                                  } on MacMismatchException {
                                    status =false;
                                  }
                                }
                              }while(!status);

                            },

                            borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Card(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            //height: MediaQuery.of(context).size.height*0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                HexColor("#00264d"),
                HexColor("#003366"),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)),

            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0,8,5,15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16,20,5,6),
                        child: Text("Staking Pools",style: TextStyle(fontSize:25,color: Colors.white70, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),

                  SizedBox(
                  //  height: MediaQuery.of(context).size.height*0.25,
                    width: MediaQuery.of(context).size.width*0.83,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 30),
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                  child: Text("Bonded Stake: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,8,15),
                                  child: Text(BalOperations.seperator(bondedStake)+" $denom", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                  child: Text("Unbonded Stake: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white70)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,8,0),
                                  child: Text(BalOperations.seperator(unbondedStake) +" $denom", overflow: TextOverflow.ellipsis , textAlign: TextAlign.start , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                          CustomPaint(
                            painter: CurvePainter(
                                colors: [
                                  Colors.greenAccent,
                                  Colors.green,
                                  Colors.lightGreen
                                ],
                                angle: _curveAngle()
                            ),
                            child: SizedBox(
                              width: 108,
                              height: 108,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),

        SizedBox(
          height: MediaQuery.of(context).size.height*0.02,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16,5,5,10),
          child: Text("Delegations",style: TextStyle(fontSize:25,color: grey, fontWeight: FontWeight.bold),),
        ),
        valList.result.length==0?Padding(
          padding: const EdgeInsets.fromLTRB(16,25,15,16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Text("No Delegations",style: TextStyle(fontSize:20,color: grey, fontWeight: FontWeight.normal),)),
            ],
          ),
        ):SizedBox(height: 0,),
        ListView.builder(
          cacheExtent: 1000,
            itemCount: valList.result.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index){
              return ValidatorCardStats(address: valList.result[index].operator_address,name: valList.result[index].description.moniker,commission: valList.result[index].commission.commission_rates.max_rate,identity: valList.result[index].description.identity,);
            }
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
  Future<String> asyncInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        TextEditingController _password = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 1,
          backgroundColor: nearlyWhite,
          title: Text('Scan to recieve $denom'),
          content:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height:MediaQuery.of(context).size.height*0.3,width: MediaQuery.of(context).size.width*0.5,child:QrImage(
                data: address,
                version: QrVersions.auto,
                size: 200.0,
              ),),
            ],
          ) ,
          actions: <Widget>[
            FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop("Close");
                }
            ),


          ],
        );
      },
    );
  }
  int mySortComparison(Validator a, Validator b) {
    final propertyA = double.parse(a.delegator_shares);
    final propertyB = double.parse(b.delegator_shares);
    if (propertyA < propertyB) {
      return 1;
    } else if (propertyA > propertyB) {
      return -1;
    } else {
      return 0;
    }
  }

  scrollToTop(){
    controller.animateTo(0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),);
  }
  _refresh()async {
    
    try{
      print("refreshing");
      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      var nw = await database.networkDao.findActiveNetwork();
      denom = (nw[0].denom).substring(1).toUpperCase();
      Response pools = await ApiWrapper.getPool();
      String body = utf8.decode(pools.bodyBytes);
      final json = jsonDecode(body);
      BondedNotBondedWrapper model = new BondedNotBondedWrapper.fromJson(json);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String address = prefs.getString("address");
      print(address);
      Response balModel = await ApiWrapper.getBalance(address);
      String body1 = utf8.decode(balModel.bodyBytes);
      final json1 = jsonDecode(body1);
      Response delegations = await ApiWrapper.getDelegations(address);
      String delBody = utf8.decode(delegations.bodyBytes);
      final delJson = jsonDecode(delBody);
      BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
      valList = ValidatorList.fromJson(delJson);
      var ls = valList.result;
      ls.sort(mySortComparison);
      bondedStake = BalOperations.toBNT(model.result.bonded_tokens);
      unbondedStake = BalOperations.toBNT(model.result.not_bonded_tokens);
      if(balanceWrapper.result.isEmpty){
        balance = "0.0";
      }else {
        balance = BalOperations.toBNT(balanceWrapper.result[0].amount);
      }

      setState(() {
        loading = false;
        this.address = address;
      });
    }catch(e){
      setState(() {
        print(e.toString());

        loading = false;
      });
    }

  }
  infiniteLoop(){
    new Timer.periodic(Duration(seconds: 30), (Timer t){
      if(mounted){
        _refresh();
      }
    });

  }
}