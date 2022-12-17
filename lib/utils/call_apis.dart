import 'package:balapp/consts.dart';
import 'package:http/http.dart' as http;

Future<http.Response> httpCall(String path, HttpMethod method, Uri localServer, {String? body}) async {

  Future<http.Response>? localCall;
  if (method == HttpMethod.get) {
    print(localServer.replace(scheme:"http", path: path).toString());
    localCall = http.get(localServer.replace(scheme:"http", path: path));
  } else if (method == HttpMethod.post) {
    localCall = http.post(localServer.replace(scheme:"http", path: path), headers: postHeaders, body: body);
  } else {
    throw UnsupportedError("This method is not currently supported");
  }
  http.Response? localResponse = await localCall;
  return localResponse;
}

enum HttpMethod { get, post }
