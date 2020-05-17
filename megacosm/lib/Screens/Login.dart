import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:megacosm/DBUtils/NetworkModel.dart';
import 'package:sacco/network_info.dart';
import 'package:sacco/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
import 'Home.dart';

class Login extends StatefulWidget{
  static const routeName  = "/login";

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;
  TextEditingController _mnemonic = TextEditingController();
  TextEditingController _password= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: nearlyWhite,
        elevation: 0,
        brightness: Brightness.light,
      ),
      backgroundColor: nearlyWhite,
      body: loading?Center(
        child: SpinKitCubeGrid(size:50, color: appTheme),
      ):Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logoblue.png"),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _mnemonic,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  maxLines: null,
                  validator: (val) => (val.isEmpty||val.split(" ").length>=12)
                      ? null
                      : 'Invalid Mnemonic',
                  decoration: InputDecoration(
                    hintText: "Enter Your Mnemonic",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _password,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=5)
                      ? null
                      : 'Password Should be atleast 5 Characters',
                  decoration: InputDecoration(
                    hintText: "Enter Your Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: ()async{
                  FocusScope.of(context).requestFocus(FocusNode());
                  var str =_mnemonic.text;
                  var ln =str.split(" ").length;
                  print(ln);
                  print(ln>=11);
                  if(ln<12&& _password.text.length>5){
                    print(str.split(" ").length);
                    Toast.show("Invalid Phrase or Password", context, duration: Toast.LENGTH_LONG);
                    return;
                  }
                  setState(() {
                    loading =true;
                  });
                  await _setDb();
                  final cryptor = new PlatformStringCryptor();
                  final password = _password.text;
                  final String salt = await cryptor.generateSalt();
                  final String key = await cryptor.generateKeyFromPassword(password, salt);
                  final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                  var nw = await database.networkDao.findActiveNetwork();
                  var  networkInfo = NetworkInfo( bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);
                  final String encrypted = await cryptor.encrypt(str, key);
                  final String encrypted2 = await cryptor.encrypt(yo, key);

                  final mn = str.split(" ");
                  final wallet = Wallet.derive(mn,  networkInfo);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString(mnemonic, encrypted);
                  await prefs.setString(known, encrypted2);
                  await prefs.setString("salt",salt);
                  await prefs.setString(prefAddress,wallet.bech32Address);
                  Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (r) => false);
                },
                color: Colors.red,
                child: Text("Continue",style: TextStyle(color: Colors.black),),
              )

            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: !loading? RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Text("Create New Wallet",style: TextStyle(color: Colors.black),),
        color: Colors.red,
        onPressed: ()async {
          var mnemonic = bip39.generateMnemonic();
          _mnemonic.text= mnemonic;
          await Clipboard.setData(ClipboardData(text: mnemonic));
          Toast.show("Mnemonic Copied", context, duration: Toast.LENGTH_LONG);
        },
      ):SizedBox(
        height: 0,
        width: 0,
      ),
    );
  }
  _setDb()async {
    try{
      var networks = await rootBundle.loadString('assets/networks.json');
      var json  = jsonDecode(networks);
      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      var ac= await database.networkDao.allNetworks();
      await database.networkDao.deleteNetworks(ac);
      var ls = json["networks"] as List;
      var nwList = List<Network>();
      for (int i =0;i< ls.length; i ++){
        var nw = Network(ls[i]["name"],ls[i]["url"],ls[i]["denom"],ls[i]["nick"], i==0? true:false);
        nwList.add(nw);
      }
      await database.networkDao.insertNetworkList(nwList);
    }catch(e){
      print(e.toString());
    }


  }
}