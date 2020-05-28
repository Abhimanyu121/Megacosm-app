
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bluzelle/Models/NewProposalModel.dart';
import 'package:bluzelle/Utils/AmountOps.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants.dart';
class NewProposalTx extends StatefulWidget{
  static const routeName = '/newProposalTx';

  @override
  NewProposalTxState createState() => new NewProposalTxState();
}
class NewProposalTxState extends State<NewProposalTx>{
  bool placingOrder = true;
  NewProposalModel args;

  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
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
            actionsIconTheme: IconThemeData(color:Colors.black),
            iconTheme: IconThemeData(color:Colors.black),
            title: HeaderTitle(first: "Transaction", second: "Successful",)
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
                    Text("Title", style: TextStyle(color: Colors.black,)),
                    Text(args.title, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Description ", style: TextStyle(color: Colors.black,)),
                    Text(args.description, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Deposit ", style: TextStyle(color: Colors.black,)),
                    Text(BalOperations.seperator(args.stake)+" BNT", style: TextStyle(color: Colors.grey,))
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

                        )),
                        SizedBox(height: MediaQuery.of(context).size.height*0.06,child: IconButton(
                            onPressed: ()async{
                              String url = await ApiWrapper.explorerLinkBuilder(args.tx);
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                Toast.show("Invalid URL", context);
                              }
                            },
                            icon: Icon(Icons.open_in_new,
                              color: Colors.black,
                            )

                        )),
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
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
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