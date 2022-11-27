import 'package:balapp/utils/ticket.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DatabaseHolder extends ChangeNotifier {
  List<Ticket> db = [];
  Stream wsStream;
  String dbPath;
  String apiUrl;
  String scannerName;
  late bool isWebsocketOpen;
  late List<Ticket> lastScanned;
  int retryLimit = 3;

  // TODO: this ?
  // late List<Ticket> lastScannedGlobal;

  DatabaseHolder(List value, WebSocketChannel ws, this.wsStream, this.dbPath, this.apiUrl, this.scannerName) {
    isWebsocketOpen = ws.closeCode == null;
    wsStream?.listen((message) {
      print(message);
    }, onDone: (){
      isWebsocketOpen = false;
      notifyListeners();
    }, onError: (err){
      isWebsocketOpen = false;
      notifyListeners();
      /*if(retryLimit > 0){
        ws = WebSocketChannel.connect(Uri.parse('ws://$apiUrl'));
        channel.sink.add('Hello!');
        retryLimit --;
      }*/
    });
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
    lastScanned = db.where((Ticket e)=>e.whoEntered == scannerName).toList();
    lastScanned.sort((a,b)=> b.timestamps["registered"].compareTo(a.timestamps["registered"]));
  }
}
