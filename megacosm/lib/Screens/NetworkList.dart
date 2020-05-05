
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/DBUtils/NetworkModel.dart';

class SwtichNetwork extends StatefulWidget{
  @override
  _SwtichNetworkState createState() => _SwtichNetworkState();
}

class _SwtichNetworkState extends State<SwtichNetwork> {
  _getNetwork()async{
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    List<Network> nw = await database.networkDao.allNetworks();
    print(nw[0].name);
  }
  @override
  void initState() {
    // TODO: implement initState
    _getNetwork();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Wait..")
        ],
      ),
    );
  }
}