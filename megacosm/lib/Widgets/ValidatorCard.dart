
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megacosm/Models/HomeToNewStake.dart';
import 'package:megacosm/Screens/NewStake.dart';
import 'package:megacosm/Utils/ColorRandminator.dart';

class ValidatorCard extends StatelessWidget{
  final String name;
  final String commission;
  final String address;
  final String identity;
  final String website;
  final String security_contract;
  final String details;
  ValidatorCard({this.commission, this.address, this.name,this.website,this.identity, this.details, this.security_contract});
  @override
  Widget build(BuildContext context) {
    var intCom = double.parse(commission);
    var str = intCom.toStringAsFixed(5);
    return Center(
      child: FlatButton(
        onPressed: (){
          Navigator.pushNamed(
            context,
            NewStake.routeName,
            arguments: HomeToNewStake(
              name: name,
              address: address,
              commission: str,
              identity: identity,
              website: website,
              security_contract: security_contract,
              details: details
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width*0.92,
          child: Container(

            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: _circle(name.substring(0,1), context) ,
                    title: Text(name),
                    subtitle: Text("Commission : $str"),
                    isThreeLine: false,
                  ),

                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
                  child: Divider(
                    thickness: 1,
                  ),
                )
              ],
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