import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bluzelle/DBUtils/NetworkModel.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants.dart';
class NetworkInformation extends StatefulWidget{
  static const routeName = '/networkInfo';
  @override
  NetworkInformationState createState() => new NetworkInformationState();
}
class NetworkInformationState extends State<NetworkInformation> {
  String delegatorAddress = "";
  bool loading = true;
  Network args;
  var gas = "";
  var exp ="";
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      args = ModalRoute
          .of(context)
          .settings
          .arguments;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      gas =
          prefs.getString("gas") + " ${args.denom.substring(1).toUpperCase()}";
      exp = await ApiWrapper.explink();
      setState(() {
        loading = false;
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
            title: HeaderTitle(first: "Network", second: "Details",)
        ),
        body: loading ? _loader() : ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Network ", style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8,),
                    child: Text("Information", style: TextStyle(color: appTheme,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                  ),

                ],
              ),
            ),


            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Network Nickname: ",
                        style: TextStyle(color: Colors.black,)),
                    Text(args.nick, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Network Name: ",
                        style: TextStyle(fontSize: 17, color: Colors.black)),

                    Text(args.name, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Network URL: ",
                        style: TextStyle(fontSize: 17, color: Colors.black)),

                    Text(args.url, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Denom:",
                        style: TextStyle(fontSize: 17, color: Colors.black)),

                    Text(args.denom, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Gas:",
                        style: TextStyle(fontSize: 17, color: Colors.black)),

                    Text(gas, style: TextStyle(color: Colors.grey,)),
                    Row(
                      children: <Widget>[
                        Text("BlockExplorer URL: ",
                            style: TextStyle(fontSize: 17, color: Colors.black)),

                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.06, child: IconButton(
                            onPressed: () async {

                              if (await canLaunch(exp)) {
                                await launch(exp);
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
                    Text(exp, style: TextStyle(color: Colors.grey,))
                  ],
                )
            ),

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