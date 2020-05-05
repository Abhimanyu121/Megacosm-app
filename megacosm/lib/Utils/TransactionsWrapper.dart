import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:megacosm/Constants.dart';
import 'package:megacosm/DBUtils/DBHelper.dart';
import 'package:sacco/sacco.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
class Transactions {

  static sendTokens(String addr, String amount, BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
      type: "cosmos-sdk/MsgSend",
      value: {
        "from_address": wallet.bech32Address,
        "to_address": addr,
        "amount": [
          {"denom": nw[0].denom, "amount": _stake.toString()}
        ],
      },
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
    fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")])
    );
    print(stdTx);

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return result.hash;
    } else {
      print("Tx send error: ${result.error.errorMessage}"
      );
      return result.error.errorMessage;
    }

  }
  static Future<String> sendDelegation(String amount, String validator,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
      type: "cosmos-sdk/MsgDelegate",
      value: {
        "amount": {
          "amount": _stake.toString(),
          "denom": nw[0].denom
        },
        "delegator_address": wallet.bech32Address,
        "validator_address": validator
      },
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>withdrawReward(String delegator, String validator,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
      type: "cosmos-sdk/MsgWithdrawDelegationReward",
      value: {
        "delegator_address": wallet.bech32Address,
        "validator_address": validator
      }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>undelegate(String delegator, String validator, String amount,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
        type: "cosmos-sdk/MsgUndelegate",
        value: {
          "amount": {
            "amount": _stake.toString(),
            "denom": nw[0].denom
          },
          "delegator_address": delegator,
          "validator_address": validator
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>redelegate(String srcValidator, String destValidator, String delegator,String amount,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    int _stake = (1000000*double.parse(amount)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
        type: "cosmos-sdk/MsgBeginRedelegate",
        value:{
          "amount": {
            "amount": _stake.toString(),
            "denom": nw[0].denom
          },
          "delegator_address": delegator,
          "validator_dst_address": destValidator,
          "validator_src_address": srcValidator
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")])
    );
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>newProposal(String description, String title, String stake,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    int _stake = (1000000*double.parse(stake)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
        type: "cosmos-sdk/MsgSubmitProposal",
        value:{
          "content": {
            "type": "cosmos-sdk/TextProposal",
            "value": {
              "title": title,
              "description": description
            }
          },
          "initial_deposit": [
            {
              "amount": _stake.toString(),
              "denom": nw[0].denom
            }
          ],
          "proposer": wallet.bech32Address
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
        fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")]),

    );

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx,);
    print(signedStdTx.toJson());
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>proposalDeposit(String id, String stake,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    int _stake = (1000000*double.parse(stake)).toInt();
    SharedPreferences prefs = await SharedPreferences.getInstance();
final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
        type: "cosmos-sdk/MsgDeposit",
        value:{
          "amount": [
            {
              "amount":_stake.toString() ,
              "denom": nw[0].denom
            }
          ],
          "depositor": wallet.bech32Address,
          "proposal_id": id
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
      fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")]),

    );

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx,);
    print(signedStdTx.toJson());
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String>vote(String id, String vote,BuildContext context)async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw =await database.networkDao.findActiveNetwork();
    var  networkInfo = NetworkInfo(bech32Hrp: nw[0].name, lcdUrl: nw[0].url, defaultTokenDenom: nw[0].denom);

    SharedPreferences prefs = await SharedPreferences.getInstance();
final cryptor = new PlatformStringCryptor();
    String enc= prefs.getString("mnemonic");
    var seed = "";
    var salt = prefs.getString("salt");
    bool status =true;
    do{
      String password = await asyncInputDialog(context, status);
      if(password =="cancel"){
        return "cancel";
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
    final message = StdMsg(
        type: "cosmos-sdk/MsgVote",
        value: {
          "option": vote,	// Yes, No, NowithVeto, Abstain
          "proposal_id": id,
          "voter": wallet.bech32Address
        }
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
      fee: StdFee(gas: "2000000", amount: [StdCoin(denom: nw[0].denom,amount: "20000000")]),

    );

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx,);
    print(signedStdTx.toJson());
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
      return(result.hash);
    } else {
      print("Tx send error: ${result.error.errorMessage}");
      return result.error.errorMessage;
    }
  }
  static Future<String> asyncInputDialog(BuildContext context, bool status) async {
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
}
