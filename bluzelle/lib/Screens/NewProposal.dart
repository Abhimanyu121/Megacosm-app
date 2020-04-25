import 'dart:convert';

import 'package:bluzelle/Models/BalanceWrapper.dart';
import 'package:bluzelle/Models/NewProposalModel.dart';
import 'package:bluzelle/Models/RedelegatorConfirmation.dart';
import 'package:bluzelle/Screens/RedlegationConfirmation.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class NewProposal extends StatefulWidget{
  static const routeName = '/newProposal';
  @override
  NewProposalState createState() => new NewProposalState();
}
class NewProposalState extends State<NewProposal>{
  TextEditingController _amount = TextEditingController();
  bool fetching  = true;
  String balance = "";
  _getBalance()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("address");
    Response balModel = await BluzelleWrapper.getBalance(address);
    String body1 = utf8.decode(balModel.bodyBytes);
    final json1 = jsonDecode(body1);
    BalanceWrapper balanceWrapper =  BalanceWrapper.fromJson(json1);
    setState(() {
      fetching = false;
      balance = balanceWrapper.result[0].amount;
    });
  }
  @override
  void initState() {
    _loader();
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
            title: HeaderTitle(first: "New", second: "Proposal",)
        ),
        body:fetching?_loader(): ListView(
          cacheExtent: 100,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8,8,8,8),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.text,
                autovalidate: false,
                decoration: InputDecoration(
                  hintText: "Proposal Title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8,8,8,8),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.text,
                autovalidate: false,
                decoration: InputDecoration(
                  hintText: "Proposal Content",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8,8,8,8),
              child: TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                autovalidate: true,
                validator: (val) => (val!=""?BigInt.parse(val)<=BigInt.parse(balance):true)
                    ? null
                    : 'Invalid amount',
                decoration: InputDecoration(
                  hintText: "Amount to stake for Proposal",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: (){
                  if(BigInt.parse(_amount.text)>BigInt.parse(balance)||balance==""){
                    Toast.show("Invalid Input", context,);
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    RedelegationConfirmation.routeName,
                    arguments: NewProposalModel(

                    )
                  );
                },
                padding: EdgeInsets.all(12),
                color: appTheme,
                child:Text('Redelegate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
    );
  }

  _loader(){
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }
}