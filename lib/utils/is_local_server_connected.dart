import 'dart:ffi';

import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/prefs_inherited.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

Future<bool> isLocalServerConnected(BuildContext context) async {
  Response result;
  try {
    result = await httpCall("/testConnection", HttpMethod.get, context.read<DatabaseHolder>().localServer)
        .timeout(const Duration(seconds: 3), onTimeout: () => Response("Timeout", 400));
  } catch (e,s) {
    print(e);
    return false;
  }
  if (result.statusCode >= 200 && result.statusCode < 299 && result.body == "connection established") {
    // ignore: use_build_context_synchronously
    return true;
  } else {
    return false;
  }
}