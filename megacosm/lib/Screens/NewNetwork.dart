import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/DBUtils/NetworkModel.dart';
import 'package:megacosm/Widgets/HeadingCard.dart';

import '../Constants.dart';
class NewNetwork extends StatefulWidget{
  static const routeName = '/newNetwork';
  @override
  NewNetworkState createState() => new NewNetworkState();
}
class NewNetworkState extends State<NewNetwork>{
  TextEditingController _denom = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _url = TextEditingController();
  bool fetching  = false;

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
                  controller: _name,
                  keyboardType: TextInputType.text,
                  autovalidate: false,
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
                  autovalidate: false,
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
                  autovalidate: false,

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
                    FocusScope.of(context).requestFocus(FocusNode());
                    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                    await database.networkDao.insertNetwork(Network(_name.text,_url.text,_denom.text,false));

                    Navigator.pop(context);
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