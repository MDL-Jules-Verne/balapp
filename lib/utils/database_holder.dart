import 'package:balapp_new/utils/ticket.dart';
import 'package:flutter/material.dart';

class DatabaseHolder extends ChangeNotifier{
  List<Ticket> db = [];

  DatabaseHolder(List value) {
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

