import 'package:balapp/consts.dart';
import 'package:http/http.dart' as http;

Future<http.Response> httpCall(String path, HttpMethod method, String? localServer, {String? body}) async {

  Future<http.Response>? localCall;

  if (method == HttpMethod.get) {
    localCall = http.get(Uri.parse("http://$localServer$path"));
  } else if (method == HttpMethod.post) {
    localCall = http.post(Uri.parse("http://$localServer$path"), headers: postHeaders, body: body);
  } else {
    throw UnsupportedError("This method is not currently supported");
  }
  http.Response? localResponse = await localCall;
  return localResponse;
}

enum HttpMethod { get, post }
