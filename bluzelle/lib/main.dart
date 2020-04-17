import 'package:bluzelle/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sacco/sacco.dart';
import 'Screens/Home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  _setPrefs()async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("mnemonic","around buzz diagram captain obtain detail salon mango muffin brother morning jeans display attend knife carry green dwarf vendor hungry fan route pumpkin car");
    final networkInfo = NetworkInfo( bech32Hrp: "bluzelle", lcdUrl: "");
    var seed = "around buzz diagram captain obtain detail salon mango muffin brother morning jeans display attend knife carry green dwarf vendor hungry fan route pumpkin car";
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    print(wallet.bech32Address);
    print(wallet.toJson());
  }

  @override
  Widget build(BuildContext context) {
    _setPrefs();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: notWhite, // navigation bar color
        statusBarColor: notWhite,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarDividerColor: background,
        systemNavigationBarIconBrightness: Brightness.dark// status bar color
    ));
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: AppTheme.fontName)
        ) ,
        brightness: Brightness.light,
        scaffoldBackgroundColor: notWhite,
      ),
      home: Home(),
    );
  }
}

