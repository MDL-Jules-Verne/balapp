import 'package:balapp/utils/ticket.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DatabaseHolder extends ChangeNotifier{
  List<Ticket> db = [];
  WebSocketChannel? ws;
  String dbPath;
  String apiUrl;
  late bool isWebsocketOpen;


  DatabaseHolder(List value, this.ws, this.dbPath, this.apiUrl) {
    isWebsocketOpen = ws != null;

    for(var e in value){
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


  }
}

