import 'package:bluzelle/Models/Proposal.dart';
import 'package:bluzelle/Utils/ColorRandminator.dart';
import 'package:flutter/material.dart';

class ProposalsWidget extends StatelessWidget{
  final Proposal model;
  ProposalsWidget({this.model});
  @override
  Widget build(BuildContext context) {
    String deposit = model.total_deposit[0].amount;
    String yes = model.final_tally_result.yes;
    String no = model.final_tally_result.no;
    String no_with_veto = model.final_tally_result.no_with_veto;
    String abstain = model.final_tally_result.abstain;
    String status = model.proposal_status;
    return Container(
      width: MediaQuery.of(context).size.width*0.92,
      child: Container(

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: _circle(model.proposal_type.substring(0,1), context) ,
            title: Text(model.title),
            subtitle: Text("Deposit : $deposit Status: $status"),
            isThreeLine: true,
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