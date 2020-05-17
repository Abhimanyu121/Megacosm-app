
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/Models/SendTokenModel.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class SendTokenTx extends StatefulWidget{
  static const routeName = '/sendTokenTx';
  @override
  SendTokenTxState createState() => new SendTokenTxState();
}
class SendTokenTxState extends State<SendTokenTx>{
  String delegatorAddress="";
  bool loading = true;
  SendTokenModel args;
  String bal = "0";
  String denom ="";
  @override
  void initState() {
    Future.delayed(Duration.zero,() async {
      args = ModalRoute.of(context).settings.arguments;
      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      var nw = await database.networkDao.findActiveNetwork();
      denom = (nw[0].denom).substring(1).toUpperCase();
      setState(() {
        loading =false;
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
            title: HeaderTitle(first: "Transfer", second: "Transaction",)
        ),
        body: loading?_loader():ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16,8,8,8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Transaction ", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                    child: Text("Details", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8,),
                    child: Icon(Icons.check_circle, color:Colors.green),
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
                    Text("From  ", style: TextStyle(color: Colors.black,)),
                    Text(args.sAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("To: ", style: TextStyle(color: Colors.black,)),
                    Text(args.dAddress, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Amount: ", style: TextStyle(color: Colors.black,)),
                    Text(args.amount+" $denom", style: TextStyle(color: Colors.grey,))
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
                        Text("Transaction Hash: ", style: TextStyle( fontSize: 17, color: Colors.black)),
                        SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                            onPressed: ()async{
                              Toast.show("Hash Copied", context);
                              await Clipboard.setData(ClipboardData(text: args.tx));
                            },
                            icon: Icon(Icons.content_copy,
                              color: Colors.black,
                            )

                        ))
                      ],
                    ),
                    Text(args.tx, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: ()async{
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
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