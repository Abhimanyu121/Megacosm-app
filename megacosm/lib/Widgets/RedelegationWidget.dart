
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megacosm/Models/RedelegationAmountModel.dart';
import 'package:megacosm/Models/RelegationSelection.dart';
import 'package:megacosm/Screens/RedelegationAmount.dart';
import 'package:megacosm/Utils/ColorRandminator.dart';

class RedelegationCard extends StatelessWidget{
  final String name;
  final String commission;
  final String address;
  final String identity;
  final String website;
  final String security_contract;
  final String details;
  final RedelegationSelectionModel srcInfo;
  RedelegationCard({this.commission, this.address, this.name, this.srcInfo, this.identity, this.website, this.security_contract, this.details});

  @override
  Widget build(BuildContext context) {
    var intCom = double.parse(commission);
    var str = intCom.toStringAsFixed(5);
    print("widget:"+srcInfo.delegatorAddress);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0,5,5,5),
        child: FlatButton(
          onPressed: (){
            Navigator.popAndPushNamed(
              context,
              RedelegationAmount.routeName,
              arguments: RedelegationAmountModel(
                  srcAddress: srcInfo.srcAddress,
                  srcName: srcInfo.name,
                  delegatorAddress: srcInfo.delegatorAddress,
                  desCommission: str,
                  destAddress: address,
                  destName: name,
                  identity: identity,
                  website: website,
                  security_contract: security_contract,
                  details: details,
                  totalAmount: srcInfo.amount
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width*0.92,
            child: Container(

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: _circle(name.substring(0,1), context) ,
                  title: Text(name),
                  subtitle: Text("Commission : $str"),
                  isThreeLine: false,
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
}