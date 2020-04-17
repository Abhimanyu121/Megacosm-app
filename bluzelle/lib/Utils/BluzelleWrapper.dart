import 'package:http/http.dart' as http;

class BluzelleWrapper{
  static const String baseUrl = "http://testnet.public.bluzelle.com:1317";
  static Future<http.Response> getValidatorList() async {
    const url = baseUrl+"/staking/validators";
    var resp = await http.get(url);
    return resp;
  }
}