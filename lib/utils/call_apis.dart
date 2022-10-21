import 'package:balapp/consts.dart';
import 'package:http/http.dart' as http;

Future<DoubleResponse> httpCall(String path, HttpMethod method, String? localServer,
    {String? body, bool runLocalCall = true, bool runNetworkCall = true}) async {
  Future<http.Response>? localCall;
  Future<http.Response>? networkCall;

  if (!runLocalCall && !runNetworkCall) throw ArgumentError("Either runLocalCall or runNetworkCall must be true");

  if (localServer == null || Uri.tryParse("http://$localServer") == null) {
    localCall = Future(() => http.Response("Invalid host", 400));
    runLocalCall = false;
  }

  if (method == HttpMethod.get) {
    if (runLocalCall) localCall = http.get(Uri.parse("http://$localServer/local$path"));
    if (runNetworkCall) networkCall = http.get(Uri.parse("$apiUrl$path"));
  } else if (method == HttpMethod.post) {
    if (runLocalCall) localCall = http.post(Uri.parse("http://$localServer/local$path"), headers: postHeaders, body: body);
    if (runNetworkCall) networkCall = http.post(Uri.parse("$apiUrl$path"), headers: postHeaders, body: body);
  } else {
    throw UnsupportedError("This method is not currently supported");
  }
  http.Response? networkResponse = await networkCall;
  http.Response? localResponse = await localCall;
  return DoubleResponse(localResponse: localResponse, networkResponse: networkResponse);
}

CallSuccess tellCallSuccess(http.Response? call) {
  return call == null
      ? CallSuccess.notFired
      : call.statusCode >= 200 && call.statusCode < 299
          ? CallSuccess.success
          : CallSuccess.fail;
}

class DoubleResponse {
  final http.Response? localResponse;
  final http.Response? networkResponse;

  @override
  String toString() {
    return "DoubleResponse(localResponse status code: ${localResponse?.statusCode}, networkResponse status code: ${networkResponse?.statusCode})";
  }

  DoubleResponse({required this.localResponse, required this.networkResponse});
}

enum CallSuccess { fail, success, notFired }

enum HttpMethod { get, post }
