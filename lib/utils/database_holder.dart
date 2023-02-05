import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/init_future.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DatabaseHolder extends ChangeNotifier {
  List<Ticket> db = [];
  String scannerName;
  BuildContext context;
  late List<Ticket> lastScanned;
  void Function() restartApp;
  AppMode appMode;

  bool isOfflineMode;
  bool isWebsocketOpen = false;
  String dbPath;

  int reconnectTries = 5;
  late Stream wsStream;
  late Stream timeout;
  StreamSubscription? timeoutStreamSubscription;
  late WebSocketChannel ws;
  Uri? apiUrl;
  int retryLimit = 3;
  bool ignoreNextDisconnect = false;


  // late List<Ticket> lastScannedGlobal;
  void resetDb(
    List value,
    Uri? apiUrl,
      [bool isFromConstructor = false]
  ) {
    if(!isFromConstructor) {
      this.apiUrl = apiUrl;
    }
    if(!isOfflineMode){
      ws = WebSocketChannel.connect(this.apiUrl!);
      wsStream = ws.stream.asBroadcastStream();
      isWebsocketOpen = ws.closeCode == null;
      _listenToStream();
      reconnectTries = 5;
    }
    _repopulateDb(value);
    if(appMode == AppMode.bal){
      lastScanned = db.where((Ticket e) => e.whoScanned == scannerName).toList();
      lastScanned.sort((a, b) => b.timestamps["entered"].compareTo(a.timestamps["entered"]));
    }else if(appMode == AppMode.buy){
      lastScanned = db.where((Ticket e) => e.whoEntered == scannerName).toList();
      // print(lastScanned.where((e)=>e.timestamps[]));
      lastScanned.sort((a, b) => b.timestamps["registered"].compareTo(a.timestamps["registered"]));
    }
    notifyListeners();
    writeAllToDisk();
  }

  void _repopulateDb(List dbAsJson){
    db = [];
    for (var e in dbAsJson) {
      db.add(Ticket.fromJson(e));
    }
  }

  void niceWsClose(){
    ignoreNextDisconnect = true;
    isWebsocketOpen = false;
    timeoutStreamSubscription?.cancel();
    ws.sink.close();
    notifyListeners();
  }

  void tryReconnect() async {
    if(isOfflineMode) throw Exception("Offline mode, cannot try to reconnect");
    niceWsClose();
      List? wsData = await connectToServer(context, false, uri: apiUrl!, setError: (e)=>print(e));
      if(wsData != null) resetDb(wsData[2], wsData[0]);
      // try again if this fails
  }
  void setContext(BuildContext context){
    this.context = context;
  }
  void _listenToStream(){
    wsStream.listen((message) async {
      if (message == "testConnection") {
        ws.sink.add("testConnection");
      }
    }, onDone: () {
      if(ignoreNextDisconnect == true) {
        ignoreNextDisconnect = false;
        return;
      }
      print("done");
      isWebsocketOpen = false;
      notifyListeners();
      tryReconnect();
    }, onError: (err) {
      if(ignoreNextDisconnect == true) {
        ignoreNextDisconnect = false;
        return;
      }
      print(err);
      isWebsocketOpen = false;
      notifyListeners();
      tryReconnect();
      /*if(retryLimit > 0){
        ws = WebSocketChannel.connect(Uri.parse('ws://$apiUrl'));
        channel.sink.add('Hello!');
        retryLimit --;
      }*/
    });
    Stream timeoutStream = wsStream.timeout(const Duration(milliseconds: kDebugMode? 12000: 1500), onTimeout: (_) {
      niceWsClose();
      print("clear3");
      isWebsocketOpen = false;
      notifyListeners();
      tryReconnect();
    });
    timeoutStreamSubscription = timeoutStream.listen((event) { });

  }

  Future<void> writeAllToDisk() async {
    await File("$dbPath/db.json").writeAsString(jsonEncode({"tickets": db.map((e)=>e.toJson()).toList(), "hasUnsavedData": isOfflineMode}));
  }

  DatabaseHolder(List value, this.dbPath, this.apiUrl, this.scannerName, this.context, this.appMode, this.restartApp, this.isOfflineMode) {
    resetDb(value, apiUrl, true);
  }

  Future<void> reDownloadDb() async {
    if(isOfflineMode || apiUrl == null) throw Exception("Offline mode, cannot download database");
    Response result = await httpCall("/downloadDb", HttpMethod.get, apiUrl!);
    if (result.statusCode >= 200 && result.statusCode < 299) {
      List ticketsAsJson = jsonDecode(result.body);
      _repopulateDb(ticketsAsJson);
    } else {
      throw Exception("No connection to server, cannot download DB");
    }
    notifyListeners();
  }
}
