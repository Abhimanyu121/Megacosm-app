
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/DBUtils/NetworkModel.dart';
import 'package:megacosm/Screens/NewNetwork.dart';
import 'package:megacosm/Widgets/NetworkCard.dart';

import '../Constants.dart';

class SwtichNetwork extends StatefulWidget{
  final Function refetch;
  Function refresh;

  SwtichNetwork({Key key, this.refetch}) : super(key: key);
  @override
  _SwtichNetworkState createState() => _SwtichNetworkState();
}

class _SwtichNetworkState extends State<SwtichNetwork> {
  Future future;
  bool loaded = false;
  Future<List<Network>>getNetwork()async{
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    List<Network> nw = await database.networkDao.allNetworks();
    return nw;
  }
  refresh(){
    setState(() {
      future = getNetwork();
    });
  }
  @override
  void initState() {
    widget.refresh = refresh;
    future = getNetwork();
    infiniteLoop();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0,10,8,25),
          child: OutlineButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              child: SizedBox(width:MediaQuery.of(context).size.width*0.7,
                  child: Center(child: Text("ADD NEW NETWORK"))),
              onPressed: ()async {
                await Navigator.pushNamed(context, NewNetwork.routeName);
                refresh();
              },

              borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
            ),
        ),
        FutureBuilder(
          future: future,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting&&loaded ==false) {
              return Padding(
                padding: EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.3,
                    ),
                    Center(child: SpinKitCubeGrid(size:50, color: appTheme)),
                  ],
                ),
              );
            } else if (snapshot.error != null) {
              print(snapshot.error);
              return Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.3,
                      ),
                      Center(
                        child: Text('Something went wrong :('),
                      ),
                    ],
                  ));
            }else {

              return Expanded(
                child: ListView.builder(
                  cacheExtent: 100,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext ctx, int index ){

                    return NetworkCard(
                      refresh: widget.refetch,
                      nwrk: snapshot.data[index],
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
  infiniteLoop(){

    new Timer.periodic(Duration(seconds: 30), (Timer t) => setState((){
      future = getNetwork();
    }));



  }
}