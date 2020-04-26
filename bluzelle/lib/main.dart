import 'package:bluzelle/Constants.dart';
import 'package:bluzelle/Screens/ConfirmVote.dart';
import 'package:bluzelle/Screens/NewProposal.dart';
import 'package:bluzelle/Screens/NewProposalConfirmation.dart';
import 'package:bluzelle/Screens/NewStake.dart';
import 'package:bluzelle/Screens/NewStakeConfirmation.dart';
import 'package:bluzelle/Screens/ProposalDepositConfirm.dart';
import 'package:bluzelle/Screens/ProposalDepositTx.dart';
import 'package:bluzelle/Screens/ProposalDetails.dart';
import 'package:bluzelle/Screens/RedelegationAmount.dart';
import 'package:bluzelle/Screens/RedelegationTx.dart';
import 'package:bluzelle/Screens/RedlegationConfirmation.dart';
import 'package:bluzelle/Screens/UndelegateConfirmation.dart';
import 'package:bluzelle/Screens/VoteTx.dart';
import 'package:bluzelle/Screens/WithdrawSuccess.dart';
import 'package:bluzelle/Utils/BluzelleTransctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sacco/sacco.dart';
import 'Screens/DelegationInfo.dart';
import 'Screens/Home.dart';
import 'Screens/NewProposalTx.dart';
import 'Screens/RedelegationSelection.dart';
import 'Screens/SetUndelegationAmount.dart';
import 'Screens/TransactionNewStake.dart';
import 'Screens/WithdrawConfirmation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  _setPrefs()async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("mnemonic","around buzz diagram captain obtain detail salon mango muffin brother morning jeans display attend knife carry green dwarf vendor hungry fan route pumpkin car");
    final networkInfo = NetworkInfo( bech32Hrp: "bluzelle", lcdUrl: "http://testnet.public.bluzelle.com:1317");
    var seed = "around buzz diagram captain obtain detail salon mango muffin brother morning jeans display attend knife carry green dwarf vendor hungry fan route pumpkin car";
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    //var seed2 = "core fatigue rabbit trust soft country kitten energy punch little case mutual old mimic erupt interest voice inner category stand voice speed patient era";
    //final mnemonic2 = seed2.split(" ");
    //final wallet2 = Wallet.derive(mnemonic2,  networkInfo);
    print("main address");
    print(wallet.bech32Address);
    pref.setString("address", wallet.bech32Address.toString());
    print("my address");
    //print(wallet2.bech32Address);
    //print(wallet2.toJson());
    //BluzelleTransactions.sendTokens();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      routes: {
        Home.routeName : (context) => Home(),
        NewStake.routeName : (context) => NewStake(),
        NewStakeConfirmation.routeName : (context) => NewStakeConfirmation(),
        TransactionNewStake.routeName : (context) => TransactionNewStake(),
        DelegationInfo.routeName : (context) => DelegationInfo(),
        WithdrawConfirmation.routeName : (context) => WithdrawConfirmation(),
        WithdrawSuccess.routeName : (context) => WithdrawSuccess(),
        SetUndelegationAmount.routeName : (context) => SetUndelegationAmount(),
        UndelegateConfirmation.routeName : (context) => UndelegateConfirmation(),
        RedelegationSelection.routeName : (context) => RedelegationSelection(),
        RedelegationAmount.routeName : (context) => RedelegationAmount(),
        RedelegationConfirmation.routeName : (context) => RedelegationConfirmation(),
        RedelegationTx.routeName : (context) => RedelegationTx(),
        NewProposal.routeName : (context) => NewProposal(),
        NewProposalConfirmation.routeName : (context) => NewProposalConfirmation(),
        NewProposalTx.routeName : (context) => NewProposalTx(),
        ProposalInfo.routeName : (context) => ProposalInfo(),
        ProposalDepositConfirm.routeName : (context) => ProposalDepositConfirm(),
        ProposalDepositTx.routeName : (context) => ProposalDepositTx(),
        ConfirmVote.routeName : (context) => ConfirmVote(),
        VoteTx.routeName : (context) => VoteTx(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
      primarySwatch: Colors.blue,
      textTheme: AppTheme.textTheme,
      platform: TargetPlatform.iOS,
    ),
      home: Home(),
    );
  }
}

