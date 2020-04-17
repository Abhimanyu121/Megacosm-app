import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ValidatorCard extends StatelessWidget{
  final String name;
  final String commission;
  final String address;
  ValidatorCard({this.commission, this.address, this.name});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0,5,10,10),
        child: Container(
          width: MediaQuery.of(context).size.width*0.92,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                  color: Colors.grey
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: _circle(name.substring(0,1), context) ,
                title: Text(name),
                subtitle: Text(address),
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