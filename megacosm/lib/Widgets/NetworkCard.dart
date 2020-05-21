
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:megacosm/Constants.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/DBUtils/NetworkModel.dart';
import 'package:megacosm/Utils/ColorRandminator.dart';
import 'package:sacco/sacco.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class NetworkCard extends StatelessWidget{
  final Network nwrk;
  final Function refresh;
  NetworkCard({this.nwrk, this.refresh});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width*0.92,
        child: Container(

          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: _circle(nwrk.nick.substring(0,1), context,nwrk.active) ,
                  title: Text(nwrk.nick),
                  isThreeLine: true,
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0,10,0,0),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        nwrk.active?OutlineButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Center(child: Text("ACTIVE")),
                          onPressed: (){
                          },

                          borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                        ):OutlineButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Center(child: Text("SET ACTIVE")),
                          onPressed: ()async{
                            final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                            var active =await  database.networkDao.findActiveNetwork();
                            var newActive = Network(nwrk.name,nwrk.url,nwrk.denom,nwrk.nick,true);
                            var changedActive = Network(active[0].name,active[0].url,active[0].denom,active[0].nick,false);
                            var ls = [newActive,changedActive];
                            var  networkInfo = NetworkInfo(bech32Hrp: newActive.name, lcdUrl: newActive.url, defaultTokenDenom: newActive.denom);

                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            final cryptor = new PlatformStringCryptor();
                            String enc= prefs.getString("mnemonic");
                            var seed = "";
                            var salt = prefs.getString("salt");
                            bool status =true;
                            do{
                              String password = await _asyncInputDialog(context, status);
                              if(password =="cancel"){
                                return;
                              }else {
                                final String key = await cryptor.generateKeyFromPassword(password, salt);
                                try {
                                  final String decrypted = await cryptor.decrypt(enc, key);
                                  seed = decrypted;
                                  status = true;// - A string to encrypt.
                                } on MacMismatchException {
                                  status =false;
                                }
                              }
                            }while(!status);

                            final mnemonic = seed.split(" ");
                            final wallet = Wallet.derive(mnemonic,  networkInfo);
                            await database.networkDao.updateNetwork(ls);
                            await prefs.setString(prefAddress, wallet.bech32Address);
                            refresh();
                          },

                          borderSide: BorderSide(color: Colors.green,style: BorderStyle.solid),
                        ),
                        OutlineButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Center(child: Text("DELETE NETWORK")),
                          onPressed: ()async {
                            if(nwrk.active){
                              Toast.show("Please Change Active Network", context);
                              return;
                            }
                            final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                            var nw = await database.networkDao.allNetworks();
                            if(nw.length ==1){
                              Toast.show("Can not delete last network.", context);
                              return;
                            }
                            database.networkDao.deleteNetworks([nwrk]);
                            refresh();
                          },
                          borderSide: BorderSide(color: Colors.red,style: BorderStyle.solid),
                        ),
                        nwrk.active?OutlineButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Center(child: Text("GAS FEE")),
                          onPressed: ()async {
                            var denom ="";
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            var currentFee = prefs.getString("gas");
                            final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                            var nw = await database.networkDao.findActiveNetwork();
                            denom = (nw[0].denom).substring(1).toUpperCase();
                            var newFee=await _feeDialog(context, currentFee, denom);
                            if(newFee == "cancel"){
                              return;
                            }
                            else{
                              prefs.setString("gas",newFee);
                            }

                          },

                          borderSide: BorderSide(color: Colors.blue,style: BorderStyle.solid),
                        ):SizedBox(
                          height: 0,
                          width: 0,
                        )
                      ],
                    ),
                  ),
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
    );
  }
  _circle(String str, BuildContext ctx, bool active){
    return Container(
      width: MediaQuery.of(ctx).size.width *0.12,
      height: 100,
      child: Center(
        child: active?Icon(Icons.done):Text(str),
      ),
      decoration: BoxDecoration(
          color: ColorRandominator.getColor() ,
          shape: BoxShape.circle
      ),
    );
  }
  static Future<String> _asyncInputDialog(BuildContext context, bool status) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        TextEditingController _password = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 1,
          backgroundColor: nearlyWhite,
          title: Text('Enter Password'),
          content:  TextFormField(
            keyboardType: TextInputType.text,
            autovalidate: true,
            obscureText: true,
            validator: (val) => status
                ? null
                : 'Invalid Pasword.',
            decoration: InputDecoration(
              hintText: 'Enter Password',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
            ),
            controller: _password,
          ),
          actions: <Widget>[
            FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop("cancel");
                }
            ),
            FlatButton(
                child: Text("Confirm"),
                onPressed: () async {
                  if(_password.text.length>1)
                  {
                    Navigator.of(context).pop(_password.text);
                  }
                  else{
                    Toast.show("Invalid Password", context, duration: Toast.LENGTH_LONG);
                  }
                }),

          ],
        );
      },
    );
  }
  static Future<String> _feeDialog(BuildContext context, String fee, String denom) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        TextEditingController _fee = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 1,
          backgroundColor: nearlyWhite,
          title: Text('Change Transaction Fee'),
          content:  SizedBox(
            width: MediaQuery.of(context).size.width*0.6,
            height: 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:10.0),
                    child: Text("Current Fee: $fee $denom"),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.5,
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    autovalidate: true,
                    obscureText: false,
                    validator: (val) => (val.isEmpty||double.parse(val)>=2.0)
                        ? null
                        : 'Fee should be greater than 2.0 $denom.',
                    decoration: InputDecoration(
                      hintText: 'New Fee',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                    ),
                    controller: _fee,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop("cancel");
                }
            ),
            FlatButton(
                child: Text("Confirm"),
                onPressed: () async {
                  if(_fee.text.isNotEmpty&&double.parse(_fee.text)>=2.0)
                  {
                    Navigator.of(context).pop(_fee.text);
                  }
                  else{
                    Toast.show("Invalid Fee", context, duration: Toast.LENGTH_LONG);
                  }
                }),

          ],
        );
      },
    );
  }
}