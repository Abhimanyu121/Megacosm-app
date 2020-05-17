import 'package:http/http.dart' as http;
import 'package:megacosm/DBUtils/DBHelper.dart';

class ApiWrapper{
  static Future<http.Response> getValidatorList() async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/staking/validators";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> getBalance(String address) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/bank/balances/"+address;
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> getPool() async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/staking/pool";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> getDelegations(String address) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/staking/delegators/$address/validators";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> delegationInfo(String delAddress, String valAddress) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/distribution/delegators/$delAddress/rewards/$valAddress";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> delegatedAmount(String delAddress, String valAddress) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/staking/delegators/$delAddress/delegations/$valAddress";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> proposalList() async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/gov/proposals";
    var resp = await http.get(url);
    return resp;
  }
  static Future<http.Response> castedVote(String id, String address) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var url = baseUrl+"/gov/proposals/$id/votes/$address";
    var resp = await http.get(url);
    return resp;
  }
  static String explorerLinkBuilder(String hash)  {
    String url= "http://bigdipper.testnet.public.bluzelle.com:3000/transactions/$hash";
    return url;
  }
  static Future<bool> checkUrl(String url)async{
    var _url = url+"/node_info";

    try{
      var resp = await http.get(_url);
      print(resp.body);
      if(resp.statusCode==200){
        return true;
      }
      else{
        return false;
      }
    }
    catch(e){
      return false;
    }

  }

}