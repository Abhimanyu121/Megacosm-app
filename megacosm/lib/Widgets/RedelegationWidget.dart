
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megacosm/Models/RedelegationAmountModel.dart';
import 'package:megacosm/Models/RelegationSelection.dart';
import 'package:megacosm/Screens/RedelegationAmount.dart';
import 'package:megacosm/Utils/AmountOps.dart';
import 'package:megacosm/Utils/ColorRandminator.dart';
import 'package:http/http.dart'as http;
class RedelegationCard extends StatefulWidget{
  final String name;
  final String commission;
  final String address;
  final String identity;
  final String website;
  final String security_contract;
  final String details;
  final String shares;
  final RedelegationSelectionModel srcInfo;
  RedelegationCard({this.commission, this.address, this.name, this.srcInfo, this.identity, this.website, this.security_contract, this.details, this.shares});

  @override
  _RedelegationCardState createState() => _RedelegationCardState();
}

class _RedelegationCardState extends State<RedelegationCard> {
  bool loading = true;
  String url;

  _getPicture()async {
    var id = widget.identity;
    var resp = await http.get("https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=$id&fields=pictures");
    var js = jsonDecode(resp.body);
    if(js["them"]==null){
      return;
    }
    var url = js["them"][0]["pictures"]["primary"]["url"];
    setState(() {
      this.url= url;
      loading = false;
    });
  }
  @override
  void initState() {
    _getPicture();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var stake = BalOperations.toBNT( widget.shares);
    var intCom = double.parse(widget.commission);
    var str = intCom.toStringAsFixed(5);
    print("widget:"+widget.srcInfo.delegatorAddress);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0,5,5,5),
        child: FlatButton(
          onPressed: (){
            Navigator.popAndPushNamed(
              context,
              RedelegationAmount.routeName,
              arguments: RedelegationAmountModel(
                  srcAddress: widget.srcInfo.srcAddress,
                  srcName: widget.srcInfo.name,
                  delegatorAddress: widget.srcInfo.delegatorAddress,
                  desCommission: str,
                  destAddress: widget.address,
                  destName: widget.name,
                  identity: widget.identity,
                  website: widget.website,
                  security_contract: widget.security_contract,
                  details: widget.details,
                  totalAmount: widget.srcInfo.amount
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width*0.92,
            child: Container(

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: loading?_circle(widget.name.substring(0,1), context):_circleImg(url, context) ,
                  title: Text(widget.name),
                  subtitle: Text("Commission : $str\nStakes: $stake"),
                  isThreeLine: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _circle(String str, BuildContext ctx){
    return Container(
      width: MediaQuery.of(ctx).size.width *0.12,
      height: 100,
      child: Center(
        child: Text(str),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
  _circleImg(String url, BuildContext ctx){
    return Container(
      width: MediaQuery.of(ctx).size.width *0.12,
      height: 100,
      child: Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(url)),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
}