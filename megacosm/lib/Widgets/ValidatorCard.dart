
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bluzelle/Models/HomeToNewStake.dart';
import 'package:bluzelle/Screens/NewStake.dart';
import 'package:bluzelle/Utils/AmountOps.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:http/http.dart'as http;
import 'package:transparent_image/transparent_image.dart';
class ValidatorCard extends StatefulWidget{
  final String name;
  final String commission;
  final String address;
  final String identity;
  final String website;
  final String security_contract;
  final String details;
  final String stake;
  final int ct;
  ValidatorCard({this.commission, this.address, this.name,this.website,this.identity, this.details, this.security_contract, this.stake, this.ct});

  @override
  _ValidatorCardState createState() => _ValidatorCardState();
}

class _ValidatorCardState extends State<ValidatorCard> {
  bool loading =true;
  bool loaded = false;
  String url;
  int ct=-1;
  _getPicture()async {
    setState(() {
      loading = true;
    });
    var id = widget.identity;
    var resp = await http.get("https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=$id&fields=pictures");
    var js = jsonDecode(resp.body);
    if(js["them"]==null){
      setState(() {
        loading =true;
        loaded = true;
      });
      return;
    }
    var url = js["them"][0]["pictures"]["primary"]["url"];
    setState(() {
      this.url= url;
      loading = false;
    });
    loaded = true;
  }

  @override
  void initState() {
    _getPicture();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

      if(loaded){
        loaded = false;
      }
      else{
        if(ct!= widget.ct){
          _getPicture();
          ct = widget.ct;
        }
      }

    var stake = BalOperations.seperator(BalOperations.toBNT( widget.stake));
    var intCom = double.parse(widget.commission);
    var str = intCom.toStringAsFixed(5);
    return Center(
      child: FlatButton(
        onPressed: (){
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.pushNamed(
            context,
            NewStake.routeName,
            arguments: HomeToNewStake(
              name: widget.name,
              address: widget.address,
              commission: str,
              identity: widget.identity,
              website: widget.website,
              security_contract: widget.security_contract,
              details: widget.details
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
                    leading: loading?_circle(widget.name.substring(0,1), context):_circleImg(url, context) ,
                    title: Text(widget.name),
                    subtitle: Text("Commission : $str\nStakes: $stake BNT"),
                    isThreeLine: true,
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
  _circleImg(String url, BuildContext ctx){
    return Container(
      width: MediaQuery.of(ctx).size.width *0.12,
      height: 100,
      child: Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: FadeInImage.memoryNetwork(
                image:url,
              placeholder: kTransparentImage,
              imageScale: 0.1,
            )
        ),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
}
//https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=90CD37EB27E242B9&fields=pictures