import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const listToCsv = ListToCsvConverter();
class DatabaseHolder extends ChangeNotifier {

  /// List of lists, each representing a ticket
  List<List> value;

  /// Index of the ID property in the lists
  late int idIndex;

  /// Index of the salle property in the lists
  late int salleIndex;

  /// Index of the couleur property in the lists
  late int couleurIndex;

  /// Index of the prenom property in the lists
  late int prenomIndex;

  /// Index of the nom property in the lists
  late int nomIndex;

  /// Index of the externe property in the lists
  late int externeIndex;

  /// Where to store the db file on fs
  String? dbPath;

  void writeToStorage() async {
    dbPath ??= (await getApplicationDocumentsDirectory()).path;
    print(listToCsv.convert(value));
    print('$dbPath/db.csv');
    await File('$dbPath/db.csv').writeAsString(listToCsv.convert(value));
  }

  bool isIdInDb(String ticketId) {
    return value.any((element) => element[idIndex] == ticketId);
  }

  int findTicketIndex(String ticketId){
    return value.indexWhere((element) => element[idIndex] == ticketId);
  }

  /// Adds data to an empty ticket
  void registerTicket(String id, {required String firstName, required String lastName, required bool isExternal}){
    int index = findTicketIndex(id);
    if(index == -1) return;
    value[index][nomIndex] = lastName;
    value[index][prenomIndex] = firstName;
    value[index][externeIndex] = isExternal;
    writeToStorage();
  }

  /// Returns if the ticket is usable and why
  TicketUsableState isUsable(String id){
    int index = findTicketIndex(id);
    if(index == -1) return TicketUsableState(false, reason: "QR code invalide");
    return TicketUsableState(value[index][prenomIndex].length == 0, reason: "Billet déjà attribué à ${value[index][prenomIndex]} ${value[index][nomIndex]}");
  }

  DatabaseHolder(this.value){
    idIndex = value[0].indexOf("id");
    salleIndex = value[0].indexOf("salle");
    couleurIndex = value[0].indexOf("couleur");
    prenomIndex = value[0].indexOf("prenom");
    nomIndex = value[0].indexOf("nom");
    externeIndex = value[0].indexOf("externe");
    getApplicationDocumentsDirectory().then((value){
      dbPath = value.path;
    });
  }
}

class TicketUsableState {
  TicketUsableState(this.isUsable, {reason}){
    // ignore: prefer_initializing_formals
    this.reason = reason;
  }

  /// Reason why the ticket is unusable
  late final String? reason;
  /// If the ticket is usable or not
  final bool isUsable;
}