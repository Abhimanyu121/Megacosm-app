
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';

import '../Constants.dart';
class RecoveryPhrase extends StatefulWidget{
  static const routeName = '/recoveryPhrase';
  @override
  RecoveryPhraseState createState() => new RecoveryPhraseState();
}
class RecoveryPhraseState extends State<RecoveryPhrase>{
  String delegatorAddress="";
  bool loading = true;
  String args;
  String bal = "0";

  @override
  void initState() {
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
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
            title: HeaderTitle(first: "Recovery", second: "Phrase",)
        ),
        body: loading?_loader():ListView(
          cacheExtent: 100,
          children: <Widget>[

            Padding(
                padding: const EdgeInsets.fromLTRB(30,8,8,8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Phrase  ", style: TextStyle(color: Colors.black,)),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: ()async{
                            await Clipboard.setData(ClipboardData(text: args));
                          },
                        )
                      ],
                    ),
                    SelectableText(args, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),


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