import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/DBUtils/NetworkModel.dart';
import 'package:megacosm/Utils/ApiWrapper.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class NewNetwork extends StatefulWidget{
  static const routeName = '/newNetwork';
  @override
  NewNetworkState createState() => new NewNetworkState();
}
class NewNetworkState extends State<NewNetwork>{
  TextEditingController _denom = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _nick = TextEditingController();
  TextEditingController _url = TextEditingController();
  bool fetching  = false;
  RegExp regex = new RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    caseSensitive: false,
    multiLine: false,
  );

  @override
  void initState() {
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: nearlyWhite,
        appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: nearlyWhite,
            actionsIconTheme: IconThemeData(color:Colors.black),
            iconTheme: IconThemeData(color:Colors.black),
            title: HeaderTitle(first: "New", second: "Network",)
        ),
        body:fetching?_loader(): Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            cacheExtent: 100,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _nick,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=2)?null:"Invalid Nickname",
                  decoration: InputDecoration(
                    hintText: "Network Nick Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _name,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=4)?null:"Invalid Name",
                  decoration: InputDecoration(
                    hintText: "Network Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||regex.firstMatch(val)!=null)?null:"Invalid URL",
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Network URL",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _denom,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=4)?null:"Invalid Denom",
                  decoration: InputDecoration(
                    hintText: "Default Token",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Please make sure you enter correct details or app will act abnoramlly"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: ()async{
                    if(_denom.text.length<4&&_nick.text.isEmpty&&_url.text.length<4&&_name.text.length<4){
                      Toast.show("Invalid Network Details", context);
                      return;
                    }

                    var exp = regex.firstMatch(_url.text);
                    if(exp==null){
                      Toast.show("Invalid URL", context);
                      return;
                    }
                    setState(() {
                      fetching= true;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                    var url = _url.text;
                    if(url.endsWith("/")){
                      url = url.substring(0, url.length-1);
                    }
                    print(url);
                    if(!url.startsWith("http")){
                      url = "http://"+url;
                    }
                    print(url);
                    if(await ApiWarpper.checkUrl(url)){
                      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                      await database.networkDao.insertNetwork(Network(_name.text,url,_denom.text,_nick.text,false));

                      Navigator.pop(context);
                      return;
                    }
                    else{
                      setState(() {
                        fetching =false;
                      });

                      Toast.show("Invalid URL", context);
                    }

                  },
                  padding: EdgeInsets.all(12),
                  color: appTheme,
                  child:Text('Add Network', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
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