import 'dart:convert';
import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Models/ProposalListModel.dart';
import 'package:bluzelle/Utils/BluzelleWrapper.dart';
import 'package:bluzelle/Widgets/Proposal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class ProposalListTab extends StatefulWidget {

  @override
  ProposalListState createState() => ProposalListState();
}

class ProposalListState extends State<ProposalListTab> with
    AutomaticKeepAliveClientMixin {

    var _loadingData;
 @override
 void initState() {
   _loadingData = BluzelleWrapper.proposalList();
    super.initState();
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
          future: _loadingData,
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
              ProposalListModel model = new ProposalListModel.fromJson(dummy);
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
var dummy ={
    "height":"2312", "result":[
    {
      "proposal_id": 0,
      "title": "string",
      "description": "string",
      "proposal_type": "string",
      "proposal_status": "deposit",
      "final_tally_result": {
        "yes": "0.0000000000",
        "abstain": "0.0000000000",
        "no": "0.0000000000",
        "no_with_veto": "0.0000000000"
      },
      "submit_time": "string",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "50"
        }
      ],
      "voting_start_time": "string"
    },
    {
      "proposal_id": 1,
      "title": "string",
      "description": "string",
      "proposal_type": "string",
      "proposal_status": "voting",
      "final_tally_result": {
        "yes": "0.0000000000",
        "abstain": "0.0000000000",
        "no": "0.0000000000",
        "no_with_veto": "0.0000000000"
      },
      "submit_time": "string",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "50"
        }
      ],
      "voting_start_time": "string"
    },
    {
      "proposal_id": 2,
      "title": "string",
      "description": "string",
      "proposal_type": "string",
      "proposal_status": "done",
      "final_tally_result": {
        "yes": "0.0000000000",
        "abstain": "0.0000000000",
        "no": "0.0000000000",
        "no_with_veto": "0.0000000000"
      },
      "submit_time": "string",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "50"
        }
      ],
      "voting_start_time": "string"
    }
  ]
};
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>true;
}