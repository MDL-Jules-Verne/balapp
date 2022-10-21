import 'dart:convert';
import 'dart:ui';

import 'package:balapp/screens/settings.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

const Color kGreen = Color(0xFF69C140);
const Color kPurple = Color(0xFF8140C1);
const apiUrl = "http://192.168.1.38:2000";
const Map<String, String> postHeaders = {
  "content-type": "application/json",
  "accept": "application/json",
};
saveTickets(BuildContext context) async {
  var db = context.read<DatabaseHolder>();
  var res = await httpCall("/upload/addTickets", HttpMethod.post, db.localServer,
      body: jsonEncode(db.lastScanned.map((e) => e.toJson()).toList()));
  // ignore: use_build_context_synchronously
  showSuccessSnackBar(context, res, successMessage: "Bases synchronisées");
}