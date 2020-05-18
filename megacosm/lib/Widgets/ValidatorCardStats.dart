
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megacosm/Models/DelegationInfo.dart';
import 'package:megacosm/Screens/DelegationInfo.dart';
import 'package:megacosm/Utils/ColorRandminator.dart';
import 'package:http/http.dart'as http;
class ValidatorCardStats extends StatefulWidget{
  final String name;
  final String commission;
  final String address;
  final String identity;
  ValidatorCardStats({this.commission, this.address, this.name, this.identity});

  @override
  _ValidatorCardStatsState createState() => _ValidatorCardStatsState();
}

class _ValidatorCardStatsState extends State<ValidatorCardStats> {
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
    var commission = double.parse(widget.commission);
    String str = commission.toStringAsFixed(5);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0,5,5,5),
        child: FlatButton(
          onPressed: (){
            Navigator.pushNamed(
              context,
              DelegationInfo.routeName,
              arguments: DelegationInfoModel(
                  name: widget.name,
                  address: widget.address,
                  commission: str,
                  identity: widget.identity
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
                      subtitle: Text("Commission: $str"),
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
      child: Center(child: ClipRRect(
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