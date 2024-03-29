import 'dart:convert';
import 'dart:io';

import 'package:balapp/consts.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:balapp/widgets/dialogs/name_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<InitData?> initApp(
  BuildContext context,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.clear();
  String? name = prefs.getString("scannerName");

  if (name == null) {
    while (name == null) {
      name = await showNameDialog(context, prefs);
    }
  }

  /*// Load db if it has been downloaded
  List<List<String>>? db;
  String path = (await getApplicationDocumentsDirectory()).path;
  bool fileExists = await File('$path/db.csv').exists();
  if (fileExists) {
    String actualDb = await File('$path/db.csv').readAsString();
    db = await readCsv(actualDb);
  }*/
  // Connect webSocket
  String path = (await getApplicationDocumentsDirectory()).path;
  bool fileExists = await File('$path/db.json').exists();
  // 0: uri, 1: appmode, 2: db, 3: channel, 4: broadcast

  List localDb;

  if (!fileExists) {
    String dbStr = await rootBundle.loadString('assets/db.json');
    await File('$path/db.json').writeAsString(dbStr);
    localDb = jsonDecode(dbStr);
  } else {
    localDb = jsonDecode(await File('$path/db.json').readAsString());
  }
  bool hasUnsavedData = localDb.any((element) => element["isNotSync"] == true);
  List? data;
  String? serverUrl = prefs.getString("serverUrl");
  print("serverUrl: $serverUrl");
  if (serverUrl != null && !hasUnsavedData) {
    try {
      data = await connectToServer(context, false, uri: Uri.parse(serverUrl), setError: (err) => print(err))
          .timeout(const Duration(seconds: 3), onTimeout: () => null);
    } on Exception catch (e, s) {
      // print(e)
      // print(s);
    }
  }
  while (data == null && !hasUnsavedData) {
    data = await showConnectDialog(context);
  }
  if (hasUnsavedData || data == null || data.isEmpty) {
    AppMode appMode = AppMode.getByString(prefs.getString("appMode") ?? "buy") ?? AppMode.buy;
    return InitData(
      appMode: appMode,
      hasUnsavedData: hasUnsavedData == true,
      db: localDb,
      scannerName: name,
      dbPath: path,
    );
  }
  return InitData(scannerName: name, db: data[2], appMode: data[1], dbPath: path, apiUrl: data[0], hasUnsavedData: false);
}

class InitData {
  String scannerName;
  bool hasUnsavedData;
  AppMode appMode;
  List db;
  String dbPath;
  Uri? apiUrl;

  InitData({required this.scannerName, required this.db, required this.appMode, required this.dbPath, required this.hasUnsavedData, this.apiUrl});
}

enum AppMode {
  buy("buy"),
  bal("bal"),
  ;

  const AppMode(this.value);

  final String value;

  @override
  String toString() {
    return toFirstCharUpperCase("Mode: $value");
  }

  static AppMode? getByString(String str) {
    for (AppMode status in AppMode.values) {
      if (status.value == str) {
        return status;
      }
    }
    return null;
  }
}

Future<List<List<String>>> readCsv(String file) async {
  // Assume EOL is CRLF
  List<String> rows = file.split("\r\n");

  // Adapt if EOL is LF
  if (rows.length <= 1) {
    rows = file.split("\n");
  }

  List<List<String>> output = [];
  for (String row in rows) {
    output.add(row.split(","));
  }
  if (output.last.length <= 1) {
    output.removeLast();
  }
  return output;
}
