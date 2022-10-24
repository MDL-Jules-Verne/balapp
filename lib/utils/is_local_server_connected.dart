import 'dart:ffi';

import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/prefs_inherited.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

Future<bool> isLocalServerConnected(BuildContext context) async {
  DoubleResponse result;
  try {
    result = await httpCall("/testConnection", HttpMethod.get, context.read<DatabaseHolder>().localServer, runNetworkCall: false)
        .timeout(const Duration(seconds: 3), onTimeout: () => DoubleResponse(localResponse: Response("Timeout", 400), networkResponse: null));
  } catch (e,s) {
    print(e);
    return false;
  }
  if (result.localResponse!.statusCode >= 200 && result.localResponse!.statusCode < 299 && result.localResponse!.body == "connection established local") {
    // ignore: use_build_context_synchronously
    return true;
  } else {
    return false;
  }
}