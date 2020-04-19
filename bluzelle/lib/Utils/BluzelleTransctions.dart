import 'package:sacco/sacco.dart';

class BluzelleTransactions {
  static sendTokens()async {
    final networkInfo = NetworkInfo( bech32Hrp: "bluzelle", lcdUrl: "http://testnet.public.bluzelle.com:1317", defaultTokenDenom: "ubnt");
    var seed = "around buzz diagram captain obtain detail salon mango muffin brother morning jeans display attend knife carry green dwarf vendor hungry fan route pumpkin car";
    final mnemonic = seed.split(" ");
    final wallet = Wallet.derive(mnemonic,  networkInfo);
    var seed2 = "core fatigue rabbit trust soft country kitten energy punch little case mutual old mimic erupt interest voice inner category stand voice speed patient era";
    final mnemonic2 = seed2.split(" ");
    final wallet2 = Wallet.derive(mnemonic2,  networkInfo);
    final message = StdMsg(
      type: "cosmos-sdk/MsgSend",
      value: {
        "from_address": wallet.bech32Address,
        "to_address": wallet2.bech32Address,
        "amount": [
          {"denom": "ubnt", "amount": "100000000"}
        ],
      },
    );
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message],
    fee: StdFee(gas: "2000000", amount: [StdCoin(denom: "ubnt",amount: "20000000")])
    );
    print(stdTx);

    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);
    final result = await TxSender.broadcastStdTx(
      wallet: wallet,
      stdTx: signedStdTx,
    );
    if (result.success) {
      print("Tx send successfully. Hash: ${result.hash}");
    } else {
      print("Tx send error: ${result.error.errorMessage}");
    }
  }
}