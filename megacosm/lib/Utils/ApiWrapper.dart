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
  static Future<String> explorerLinkBuilder(String hash) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var start = 0;

    while (start < baseUrl.length) {
      if(baseUrl[start]+baseUrl[start+1]=="//"){
        baseUrl=baseUrl.substring(0,start+1)+"explorer."+baseUrl.substring((start+2));
      }
      else if(baseUrl[start]+baseUrl[start+1]+baseUrl[start+2]+baseUrl[start+3]==".com"){
        baseUrl=baseUrl.substring(0,start+4)+":3000";
        break;
      }
     start++;
    }
    String url= "$baseUrl/transactions/$hash";
    return url;
  }
  static Future<String> expValidatorLinkBuilder(String hash) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var start = 0;

    while (start < baseUrl.length) {
      if(baseUrl[start]+baseUrl[start+1]=="//"){
        baseUrl=baseUrl.substring(0,start+1)+"explorer."+baseUrl.substring((start+2));
      }
      else if(baseUrl[start]+baseUrl[start+1]+baseUrl[start+2]+baseUrl[start+3]==".com"){
        baseUrl=baseUrl.substring(0,start+4)+":3000";
        break;
      }
      start++;
    }
    String url= "$baseUrl/validator/$hash";
    return url;
  }
  static Future<String> expAccountLinkBuilder(String hash) async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var start = 0;

    while (start < baseUrl.length) {
      if(baseUrl[start]+baseUrl[start+1]=="//"){
        baseUrl=baseUrl.substring(0,start+1)+"explorer."+baseUrl.substring((start+2));
      }
      else if(baseUrl[start]+baseUrl[start+1]+baseUrl[start+2]+baseUrl[start+3]==".com"){
        baseUrl=baseUrl.substring(0,start+4)+":3000";
        break;
      }
      start++;
    }
    String url= "$baseUrl/account/$hash";
    return url;
  }
  static Future<String> explink() async {
    final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    var nw = await database.networkDao.findActiveNetwork();
    String baseUrl = nw[0].url;
    var start = 0;

    while (start < baseUrl.length) {
      if(baseUrl[start]+baseUrl[start+1]=="//"){
        baseUrl=baseUrl.substring(0,start+1)+"explorer."+baseUrl.substring((start+2));
      }
      else if(baseUrl[start]+baseUrl[start+1]+baseUrl[start+2]+baseUrl[start+3]==".com"){
        baseUrl=baseUrl.substring(0,start+4)+":3000";
        break;
      }
      start++;
    }
    String url= "$baseUrl/";
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