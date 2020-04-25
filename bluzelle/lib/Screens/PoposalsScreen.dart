import 'dart:convert';
import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Models/ProposalListModel.dart';
import 'package:bluzelle/Models/ProposalListModel.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/Proposal.dart';
import 'package:bluzelle/Widgets/ValidatorCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class ProposalListTab extends StatefulWidget {

  @override
  ProposalListState createState() => ProposalListState();
}

class ProposalListState extends State<ProposalListTab> with
    AutomaticKeepAliveClientMixin {
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
          future: BluzelleWrapper.proposalList(),
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
              ProposalListModel model = new ProposalListModel.fromJson(json);
              if(model.result.length==0){
                return Center(
                  child: Text("No Proposals So far")
                );
              }
              return Expanded(
                child: ListView.builder(
                  cacheExtent: 100,
                  itemCount: model.result.length,
                  itemBuilder: (BuildContext ctx, int index ){

                    return ProposalsWidget(
                      model: model.result[index],
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