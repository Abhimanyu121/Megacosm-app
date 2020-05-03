import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:sacco/network_info.dart';
import 'package:sacco/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
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
              //Image.asset("assets/logoblue.png"),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _mnemonic,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  maxLines: null,
                  validator: (val) => (val.isEmpty||val.split(" ").length==24)
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
                  autovalidate: false,
                  validator: (val) => (val.isEmpty||val.split(" ").length==24)
                      ? null
                      : 'Invalid Password',
                  decoration: InputDecoration(
                    hintText: "Enter Your Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: ()async{
                  var str =_mnemonic.text;
                  if(str.split(" ").length !=24 ){
                    Toast.show("Invalid Phrase", context, duration: Toast.LENGTH_LONG);
                    return;
                  }
                  setState(() {
                    loading =true;
                  });
                  final cryptor = new PlatformStringCryptor();
                  final password = _password.text;
                  final String salt = await cryptor.generateSalt();
                  final String key = await cryptor.generateKeyFromPassword(password, salt);
                  var  networkInfo = NetworkInfo( bech32Hrp: "bluzelle", lcdUrl: "http://testnet.public.bluzelle.com:1317", defaultTokenDenom: "ubnt");
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
                child: Text("Continue",style: TextStyle(color: Colors.white),),
              )

            ],
          ),
        ),
      ),
    );
  }
}