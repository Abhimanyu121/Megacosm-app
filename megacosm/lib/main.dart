
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megacosm/Screens/AboutBluzelle.dart';
import 'package:megacosm/Screens/RecoveryPhrase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants.dart';
import 'Screens/ConfirmVote.dart';
import 'Screens/DelegationInfo.dart';
import 'Screens/Home.dart';
import 'Screens/Login.dart';
import 'Screens/NewNetwork.dart';
import 'Screens/NewProposal.dart';
import 'Screens/NewProposalConfirmation.dart';
import 'Screens/NewProposalTx.dart';
import 'Screens/NewStake.dart';
import 'Screens/NewStakeConfirmation.dart';
import 'Screens/ProposalDepositConfirm.dart';
import 'Screens/ProposalDepositTx.dart';
import 'Screens/ProposalDetails.dart';
import 'Screens/RedelegationAmount.dart';
import 'Screens/RedelegationSelection.dart';
import 'Screens/RedelegationTx.dart';
import 'Screens/RedlegationConfirmation.dart';
import 'Screens/SendToken.dart';
import 'Screens/SendTokenConfirm.dart';
import 'Screens/SendTokenTx.dart';
import 'Screens/SetUndelegationAmount.dart';
import 'Screens/TransactionNewStake.dart';
import 'Screens/UndelegateConfirmation.dart';
import 'Screens/VoteTx.dart';
import 'Screens/WithdrawConfirmation.dart';
import 'Screens/WithdrawSuccess.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  Widget initialRoute = Login();
  _getPrefs()async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var mn =pref.getString(mnemonic);
    if(mn!=null){
      setState(() {
        initialRoute =Home();
      });
    }

  }
  @override
  void initState() {
    _getPrefs();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

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
        Login.routeName :(context) => Login(),
        SendTokenTx.routeName:(context) => SendTokenTx(),
        SendTokenConfirm.routeName:(context) => SendTokenConfirm(),
        SendTokens.routeName:(context) => SendTokens(),
        NewNetwork.routeName:(context) => NewNetwork(),
        RecoveryPhrase.routeName:(context) => RecoveryPhrase(),
        AboutBluzelle.routeName:(context) => AboutBluzelle()
      },
      title: 'Flutter Demo',
      theme: ThemeData(
      primarySwatch: Colors.blue,
      textTheme: AppTheme.textTheme,
      platform: TargetPlatform.iOS,

    ),
      home: initialRoute,
    );

  }
}
//around buzz diagram captain obtain detail salon mango muffin brother morning jeans display attend knife carry green dwarf vendor hungry fan route pumpkin car
