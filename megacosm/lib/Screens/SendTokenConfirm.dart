
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/Models/SendTokenModel.dart';
import 'package:megacosm/Utils/AmountOps.dart';
import 'package:megacosm/Utils/ApiWrapper.dart';
import 'package:megacosm/Utils/TransactionsWrapper.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants.dart';
import 'SendTokenTx.dart';
class SendTokenConfirm extends StatefulWidget{
  static const routeName = '/sendTokenConfirm';
  @override
  SendTokenConfirmsState createState() => new SendTokenConfirmsState();
}
class SendTokenConfirmsState extends State<SendTokenConfirm> {
  String delegatorAddress = "";
  bool placingOrder = true;
  bool addr = false;
  SendTokenModel args;

  var denom="";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      var nw = await database.networkDao.findActiveNetwork();
      denom = (nw[0].denom).substring(1).toUpperCase();
      args = ModalRoute
          .of(context)
          .settings
          .arguments;
      setState(() {
        placingOrder = false;
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
            actionsIconTheme: IconThemeData(color: Colors.black),
            iconTheme: IconThemeData(color: Colors.black),
            title: HeaderTitle(first: "Transfer", second: " $denom",)
        ),
        body: placingOrder ? _loader() : ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Confirm", style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8,),
                    child: Text("Transfer", style: TextStyle(color: appTheme,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                  )
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Your address: ",
                            style: TextStyle(color: Colors.black,)),
                        SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                            onPressed: ()async{
                              String url = await ApiWrapper.expAccountLinkBuilder(args.sAddress);
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
                    Text(
                        args.sAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Receiver Address ",
                            style: TextStyle(color: Colors.black,)),
                        SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                            onPressed: ()async{
                              String url = await ApiWrapper.expAccountLinkBuilder(args.dAddress);
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
                    Text(args.dAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Your Balance",
                        style: TextStyle(color: Colors.black,)),
                    Text(BalOperations.seperator(args.balance)+" $denom", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        "Amount to Transfer: ", style: TextStyle(color: Colors.black,)),
                    Text(BalOperations.seperator(args.amount)+ " $denom", style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () async {
                  setState(() {
                    placingOrder = true;
                  });
                  String tx = await Transactions.sendTokens(args.dAddress, args.amount, context);
                  if(tx =="cancel"){
                    setState(() {
                      placingOrder = false;

                    });
                    return;
                  }
                  print(tx);
                  Navigator.popAndPushNamed(
                    context,
                    SendTokenTx.routeName,
                    arguments: SendTokenModel(
                      amount: args.amount,
                      balance: args.balance,
                      dAddress: args.dAddress,
                      sAddress: args.sAddress,
                      tx: tx,
                    )
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child: Text('Make Transaction', style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
    );
  }

  _loader() {
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }
}