import 'dart:convert';

import 'package:balapp/screens/settings.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

const Color kPurple = Color(0xFF8140C1);
const Color kPurpleLight = Color(0x7A8040C1);
const Color kGreen = Color(0xFF69C140);
const Color kGreenLight = Color(0xFF8BDC65);
const Color kRed = Color(0xFFEF3737);
const Color kBlack = Color(0xFF332A22);
const Color kWhite = Color(0xFFF2F2F2);

const apiUrl = "http://192.168.1.38:2000";
const Map<String, String> postHeaders = {
  "content-type": "application/json",
  "accept": "application/json",
};
const List<Widget> fakeWidgetArray = [SizedBox()];

String toFirstCharUpperCase(String str){
  return str.substring(0,1).toUpperCase() + str.substring(1);
}

saveTickets(BuildContext context) async {
  var db = context.read<DatabaseHolder>();
  var res = await httpCall("/upload/addTickets", HttpMethod.post, db.localServer,
      body: jsonEncode(db.lastScanned.map((e) => e.toJson()).toList()));
  // ignore: use_build_context_synchronously
  showSuccessBanner(context, res, successMessage: "Bases synchronisées");
}