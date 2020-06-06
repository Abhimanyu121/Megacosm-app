import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bluzelle/Models/Validator.dart';
import 'package:bluzelle/Models/ValidatorList.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Widgets/ValidatorCard.dart';

import '../Constants.dart';
import '../Constants.dart';
class ValidatorListTab extends StatefulWidget {
  Function refresh;
  @override
  ValidatorListState createState() => ValidatorListState();
}

class ValidatorListState extends State<ValidatorListTab> with
    AutomaticKeepAliveClientMixin{
  bool loaded = false;
  bool sort = false;
  bool error = false;
  bool loading = true;
  bool searching =false;
  List valList;
  var orignal;
  bool asc = true;
  int ct=0;
  TextEditingController search = TextEditingController();
  _getData()async {
    setState(() {
      loading =true;
    });
    var resp = await ApiWrapper.getValidatorList();
    if(resp.statusCode != 200){
      setState(() {
        error = true;
        loading = false;
      });
      return;
    }
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    ValidatorList model = new ValidatorList.fromJson(json);
    var ls = model.result;
    if(sort){
      ls.sort(nameComp);
    }
    else{
      ls.sort(mySortComparison);
    }
    setState(() {
      valList = ls;
      orignal = ls;
      loading =false;

    });
  }
  _getWithoutLoader()async {

    var resp = await ApiWrapper.getValidatorList();
    if(resp.statusCode != 200){
      setState(() {
        error = true;
        loading = false;
      });
      return;
    }
    String body = utf8.decode(resp.bodyBytes);
    final json = jsonDecode(body);
    ValidatorList model = new ValidatorList.fromJson(json);
    var ls = model.result;
    if(sort){
      ls.sort(nameComp);
    }
    else{
      ls.sort(mySortComparison);
    }
    if(!asc){
     var  rev= ls.reversed.toList();
     setState(() {
       orignal = ls;
       valList =rev;
     });
    }
    else{
      setState(() {
        orignal = ls;
        valList =ls;
      });
    }
    return;
  }
  @override
  void initState() {
    super.initState();
    _getData();
    widget.refresh =(){
      _getData();
    };
    infiniteLoop();
    search.addListener(_search);
  }
  @override
  Widget build(BuildContext context) {
    return loading? Padding(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height*0.3,
            ),
            Center(child: SpinKitCubeGrid(size:50, color: appTheme)),
          ],
        )
    ):error? Padding(
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
        )):RefreshIndicator(
          onRefresh: _refresh,
            child: ListView(
              cacheExtent: 6000,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0,10,8,5),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.79,
                    height:MediaQuery.of(context).size.height*0.06 ,
                    child: TextFormField(
                      autovalidate: false,
                      validator: false?null:null,
                      controller: search,
                      decoration: InputDecoration(
                        hintText: "Search Validator",
                        contentPadding: EdgeInsets.all(5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          borderSide: BorderSide(color: Colors.blue,style: BorderStyle.none,),

                        ),
                        prefixIcon: search.text==""?IconButton(icon: Icon(Icons.search), color: Colors.black87,):IconButton(icon:Icon(Icons.cancel), color: Colors.black87, onPressed: (){
                          search.text = "";
                          FocusScope.of(context).requestFocus(FocusNode());

                        },),

                      ),
                    ),
                  ),
                ),
                searching?Container():Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,10,8,25),
                      child: OutlineButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: SizedBox(width:MediaQuery.of(context).size.width*0.5,
                            child: Center(child: Text(sort?"SORT BY STAKE":"SORT BY NAME"))),
                        onPressed: (){
                          if(sort){
                            setState(() {
                              ct++;
                              sort = false;
                              asc= true;
                            });
                            srt();
                          }
                          else{
                            setState(() {
                              ct ++;
                              sort = true;
                              asc =true;
                            });
                            srt();
                          }
                        },

                        borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,10,8,25),
                      child: OutlineButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: SizedBox(width:MediaQuery.of(context).size.width*0.1,
                            child: Center(child: Icon(asc?Icons.arrow_downward:Icons.arrow_upward))),
                        onPressed: (){
                          if(asc){
                            setState(() {
                             asc = false;
                             ct++;
                             valList = valList.reversed.toList();
                            });
                          }
                          else{
                            setState(() {
                             asc = true;
                             ct++;
                             valList = valList.reversed.toList();
                            });
                            srt();
                          }
                        },

                        borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                      ),
                    ),
                  ],
                ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              cacheExtent: 1000,
              itemCount: valList.length,
              itemBuilder: (BuildContext ctx, int index ){

                return ValidatorCard(
                  commission: valList[index].commission.commission_rates.rate,
                  name: valList[index].description.moniker,
                  address: valList[index].operator_address,
                  details: valList[index].description.details,
                  website: valList[index].description.website,
                  security_contract: valList[index].description.security_contact,
                  identity: valList[index].description.identity,
                  stake: valList[index].delegator_shares,
                  ct: ct,
                );
              },
            )

            ],
          ),
    );
  }
  int mySortComparison(Validator a, Validator b) {
    final propertyA = double.parse(a.delegator_shares);
    final propertyB = double.parse(b.delegator_shares);
    if (propertyA < propertyB) {
      return 1;
    } else if (propertyA > propertyB) {
      return -1;
    } else {
      return 0;
    }
  }
  srt(){
    var ls = orignal;
    if(sort){
      ls.sort(nameComp);
    }
    else{
      ls.sort(mySortComparison);
    }
    setState(() {
      valList = ls;
    });
  }
  int nameComp(Validator a, Validator b) {
    final String propertyA = a.description.moniker.toLowerCase();
    final String propertyB = b.description.moniker.toLowerCase();
    return propertyA.compareTo(propertyB);
  }
  Future<void> _refresh() async  {
    await _getWithoutLoader();
  }
  infiniteLoop(){

      new Timer.periodic(Duration(seconds: 30), (Timer t){
        if(mounted){
          setState(() {
            _getWithoutLoader();
          });
        }
      });

  }
  _search(){
    if(search.text==""){
      setState(() {
        ct++;
        searching =false;
        valList = orignal;
      });
      return;
    }
    valList = orignal;
    List<Validator> ls = valList;
    setState(() {
      searching =true;
      ct++;
      valList = ls.where(_searchCond).toList();
    });


  }
  bool _searchCond(Validator va){
    var str = va.description.moniker;
    return str.contains(search.text);
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>true;
}



