import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/Models/ValidatorList.dart';
import 'package:megacosm/Utils/ApiWrapper.dart';
import 'package:megacosm/Widgets/ValidatorCard.dart';

import '../Constants.dart';
class ValidatorListTab extends StatefulWidget {
  Function refresh;
  @override
  ValidatorListState createState() => ValidatorListState();
}

class ValidatorListState extends State<ValidatorListTab> with
    AutomaticKeepAliveClientMixin{
  var _loadList;
  @override
  void initState() {
    _loadList = ApiWarpper.getValidatorList();
    super.initState();
    widget.refresh =(){
      setState(() {
        _loadList = ApiWarpper.getValidatorList();
      });
    };
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height*0.02,
        ),
        FutureBuilder(
          future: _loadList,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
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
              String body = utf8.decode(snapshot.data.bodyBytes);
              final json = jsonDecode(body);
              ValidatorList model = new ValidatorList.fromJson(json);
              return Expanded(
                child: ListView.builder(
                  cacheExtent: 100,
                  itemCount: model.result.length,
                  itemBuilder: (BuildContext ctx, int index ){

                    return ValidatorCard(
                      commission: model.result[index].commission.commission_rates.rate,
                      name: model.result[index].description.moniker,
                      address: model.result[index].operator_address,
                      details: model.result[index].description.details,
                      website: model.result[index].description.website,
                      security_contract: model.result[index].description.security_contact,
                      identity: model.result[index].description.identity,
                    );
                  },
                ),
              );
            }
          },
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>true;
}