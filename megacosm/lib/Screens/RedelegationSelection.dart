import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bluzelle/Models/RelegationSelection.dart';
import 'package:bluzelle/Models/Validator.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:bluzelle/Widgets/RedelegationWidget.dart';

import '../Constants.dart';
class RedelegationSelection extends StatefulWidget{
  static const routeName = '/redelegationSelection';
  @override
  RedelegationSelectionState createState() => new RedelegationSelectionState();
}
class RedelegationSelectionState extends State<RedelegationSelection>{

  RedelegationSelectionModel args;
  Future future;
  bool loaded = false;
  @override
  void initState() {
    future = ApiWrapper.getValidatorList();
    Future.delayed(Duration.zero,() {
      args = ModalRoute.of(context).settings.arguments;
      print(args.delegatorAddress);
      infiniteLoop();

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
            title: HeaderTitle(first: "Redelegate", second: "Stake",)
        ),
        body:RefreshIndicator(
          onRefresh: refresh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16,8,8,8),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Select", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,8,8,8,),
                      child: Text("Validator", style: TextStyle(color: appTheme, fontWeight: FontWeight.bold, fontSize: 20),),
                    ),

                  ],
                ),
              ),
              FutureBuilder(
                future: future,
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting&&loaded==false) {
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
                    loaded = true;
                    String body = utf8.decode(snapshot.data.bodyBytes);
                    final json = jsonDecode(body);
                    ValidatorList model = new ValidatorList.fromJson(json);
                    var ls = model.result;
                    ls.sort(mySortComparison);
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        cacheExtent: 1000,
                        itemCount: ls.length,
                        itemBuilder: (BuildContext ctx, int index ){
                          if(ls[index].operator_address==args.srcAddress){
                            return SizedBox(
                              height: 0,
                            );
                          }
                          return RedelegationCard(
                            commission: ls[index].commission.commission_rates.rate,
                            name: ls[index].description.moniker,
                            address: ls[index].operator_address,
                            srcInfo: args,
                            details: ls[index].description.details,
                            website: ls[index].description.website,
                            security_contract: ls[index].description.security_contact,
                            identity: ls[index].description.identity,
                            shares: ls[index].delegator_shares
                          );
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        )
    );
  }
  Future<void> refresh()async {
    await Future.delayed(Duration(microseconds: 1));
    setState(() {

    });
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
  infiniteLoop(){
    new Timer.periodic(Duration(seconds: 30), (Timer t){
      if(mounted){
        refresh();
      }
    });

  }

}