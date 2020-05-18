import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/Models/Validator.dart';
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
    _loadList = ApiWrapper.getValidatorList();
    super.initState();
    widget.refresh =(){
      setState(() {
        _loadList = ApiWrapper.getValidatorList();
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
              var ls = model.result;
              ls.sort(mySortComparison);
              return Expanded(
                child: ListView.builder(
                  cacheExtent: 1000,
                  itemCount: model.result.length,
                  itemBuilder: (BuildContext ctx, int index ){

                    return ValidatorCard(
                      commission: ls[index].commission.commission_rates.rate,
                      name: ls[index].description.moniker,
                      address: ls[index].operator_address,
                      details: ls[index].description.details,
                      website: ls[index].description.website,
                      security_contract: ls[index].description.security_contact,
                      identity: ls[index].description.identity,
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
  int mySortComparison(Validator a, Validator b) {
    final propertyA = double.parse(a.delegator_shares);
    final propertyB = double.parse(b.delegator_shares);
    if (propertyA < propertyB) {
      return -1;
    } else if (propertyA > propertyB) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>true;
}