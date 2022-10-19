import 'package:balapp/utils/prefs_inherited.dart';
import 'package:http/http.dart' as http;

Future<bool> isLocalServerConnected(context) async {
  dynamic result;
  try {
    result = await http
        .get(Uri.parse(
        "http://${InheritedPreferences.of(context)?.prefs.getString("localServer")}/testConnection"))
        .timeout(const Duration(seconds: 3), onTimeout: () => http.Response("Timeout", 400));
  } catch (e) {
    return false;
  }
  if (result.statusCode >= 200 && result.statusCode < 299 && result.body == "connection established") {
    // ignore: use_build_context_synchronously
    return true;
  } else {
    return false;
  }
}