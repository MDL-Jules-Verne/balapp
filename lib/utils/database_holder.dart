import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DatabaseHolder extends ChangeNotifier {
  List<Ticket> db = [];
  BuildContext context;
  int reconnectTries = 5;
  late Stream wsStream;
  late Stream timeout;
  String dbPath;
  late WebSocketChannel ws;
  late Uri apiUrl;
  String scannerName;
  late bool isWebsocketOpen;
  late List<Ticket> lastScanned;
  int retryLimit = 3;

  // TODO: this ?
  // late List<Ticket> lastScannedGlobal;
  void resetDb(
    List value,
    Uri apiUrl,
  ) {
    this.apiUrl = Uri.parse('$apiUrl');
    //todo this and constructor should not be separate code
    //TODO: change this shit for a ping-pong
    ws = WebSocketChannel.connect(this.apiUrl);
    wsStream = ws.stream.asBroadcastStream();
    isWebsocketOpen = ws.closeCode == null;
    listenToStream();
    db = [];
    for (var e in value) {
      db.add(Ticket(
        prenom: e["prenom"],
        nom: e["nom"],
        timestamps: e["timestamps"],
        id: e["id"],
        hasEntered: e["hasEntered"],
        whoEntered: e["whoEntered"],
        couleur: e["couleur"],
        externe: e["externe"],
        salle: e["salle"],
      ));
    }
    lastScanned = db.where((Ticket e) => e.whoEntered == scannerName).toList();
    lastScanned.sort((a, b) => b.timestamps["registered"].compareTo(a.timestamps["registered"]));
    isWebsocketOpen = true;
    notifyListeners();
  }

  void tryReconnect() async {
      List? wsData = await connectToServer(context, false, uri: apiUrl, setError: (e)=>print(e));
      if(wsData != null) resetDb(wsData[2], wsData[0]);
      // try again if this fails
  }
  void setContext(BuildContext context){
    this.context = context;
  }
  void listenToStream(){
    wsStream.listen((message) async {
      if (message == "testConnection") {
        ws.sink.add("testConnection");
      }
    }, onDone: () {
      print("done");
      isWebsocketOpen = false;
      tryReconnect();
      notifyListeners();
    }, onError: (err) {
      print(err);
      isWebsocketOpen = false;
      tryReconnect();
      notifyListeners();
      /*if(retryLimit > 0){
        ws = WebSocketChannel.connect(Uri.parse('ws://$apiUrl'));
        channel.sink.add('Hello!');
        retryLimit --;
      }*/
    });
    wsStream.timeout(const Duration(milliseconds: kDebugMode? 12000: 1500), onTimeout: (_) {
      ws.sink.close();
      tryReconnect();
      print("clear3");
      isWebsocketOpen = false;
      notifyListeners();
    });
  }

  Future<void> writeAllToDisk() async {
    await File("$dbPath/db.json").writeAsString(jsonEncode(db.map((e)=>e.toJson()).toList()));
  }

  DatabaseHolder(List value, this.dbPath, this.apiUrl, this.scannerName, this.context) {
    ws = WebSocketChannel.connect(apiUrl);
    wsStream = ws.stream.asBroadcastStream();
    isWebsocketOpen = ws.closeCode == null;
    listenToStream();
    for (var e in value) {
      db.add(Ticket(
        prenom: e["prenom"],
        nom: e["nom"],
        timestamps: e["timestamps"],
        id: e["id"],
        hasEntered: e["hasEntered"],
        whoEntered: e["whoEntered"],
        couleur: e["couleur"],
        externe: e["externe"],
        salle: e["salle"],
      ));
    }
    lastScanned = db.where((Ticket e) => e.whoEntered == scannerName).toList();
    lastScanned.sort((a, b) => b.timestamps["registered"].compareTo(a.timestamps["registered"]));
    writeAllToDisk();
  }
}
