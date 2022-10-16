import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const listToCsv = ListToCsvConverter();

class DatabaseHolder extends ChangeNotifier {
  /// List of lists, each representing a ticket
  List<List<String>> value;

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

  /// Index of the hasEnteredIndex property in the lists
  late int hasEnteredIndex;

  /// Index of the registeredTimestamp property in the lists
  late int registeredTimestampIndex;

  /// Index of the enteredTimestamp property in the lists
  late int enteredTimestampIndex;

  /// Index of the leaveTimestamp property in the lists
  late int leaveTimestampIndex;

  /// Index of the whoEntered property in the lists
  late int whoEnteredIndex;

  /// Where to store the db file on fs
  String? dbPath;

  /// Last scanned tickets to be shown on the scan history thing
  List<Ticket> lastScanned = [];

  /// Return ticket as ticket object, parsing into correct types as well, for easier use
  Ticket returnTicketAsClass(List ticketAsList) {
    return Ticket(
      prenom: ticketAsList[prenomIndex],
      nom: ticketAsList[nomIndex],
      registeredTimestamp: int.tryParse(ticketAsList[registeredTimestampIndex]),
      enteredTimestamp: int.tryParse(ticketAsList[enteredTimestampIndex]),
      leaveTimestamp: int.tryParse(ticketAsList[leaveTimestampIndex]),
      id: ticketAsList[idIndex],
      hasEntered: ticketAsList[hasEnteredIndex] == "true",
      whoEntered: ticketAsList[whoEnteredIndex],
      couleur: ticketAsList[couleurIndex],
      externe: ticketAsList[externeIndex] == "true",
      salle: int.parse(ticketAsList[salleIndex]),
    );
  }

  /// Write the current state of the DB to storage
  void writeToStorage() async {
    dbPath ??= (await getApplicationDocumentsDirectory()).path;
    await File('$dbPath/db.csv').writeAsString(listToCsv.convert(value));
  }

  /// Returns whether a ticket id is in the database
  bool isIdInDb(String ticketId) {
    return value.any((element) => element[idIndex] == ticketId);
  }

  /// Returns index of the ticket having this ticketId
  int findTicketIndex(String ticketId) {
    return value.indexWhere((element) {
      return element[idIndex] == ticketId;
    });
  }

  /// Adds data to an empty ticket
  void registerTicket(String id, String scannerName, {required String firstName, required String lastName, required bool isExternal,}) {
    int index = findTicketIndex(id);
    if (index == -1) return;
    value[index][nomIndex] = lastName;
    value[index][prenomIndex] = firstName;
    value[index][externeIndex] = "$isExternal";
    value[index][whoEnteredIndex] = scannerName;
    value[index][registeredTimestampIndex] = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
    lastScanned.insert(0, returnTicketAsClass(value[index]));
    // Wait for pop anim before update
    Future.delayed(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
    writeToStorage();
  }

  void resetTicket(String id) {
    int ticketIndex = findTicketIndex(id);
    List<String> ticket = value[ticketIndex];
    ticket = [ticket[salleIndex], ticket[couleurIndex], "", "", "", "", "", "", "", ticket[idIndex]];
    value[ticketIndex] = ticket;
    lastScanned.removeWhere((element) => element.id == id);
    Future.delayed(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
    writeToStorage();
  }

  /// Returns if the ticket is usable and why
  TicketUsableState isUsable(String id) {
    int index = findTicketIndex(id);
    if (index == -1) return TicketUsableState(false, reason: "QR code invalide");
    return TicketUsableState(value[index][prenomIndex].isEmpty,
        reason: "Billet déjà attribué à ${value[index][prenomIndex]} ${value[index][nomIndex]}");
  }

  /// Returns the db's value as without the header row
  List<List> get noHeaderValue {
    return value.sublist(1);
  }

  /// Instantiates a DatabaseHolder from the parsed csv value
  DatabaseHolder(this.value, String scannerName) {
    idIndex = value[0].indexOf("id");
    salleIndex = value[0].indexOf("salle");
    couleurIndex = value[0].indexOf("couleur");
    prenomIndex = value[0].indexOf("prenom");
    nomIndex = value[0].indexOf("nom");
    hasEnteredIndex = value[0].indexOf("hasEntered");
    registeredTimestampIndex = value[0].indexOf("registeredTimestamp");
    enteredTimestampIndex = value[0].indexOf("enteredTimestamp");
    leaveTimestampIndex = value[0].indexOf("leaveTimestamp");
    externeIndex = value[0].indexOf("externe");
    whoEnteredIndex = value[0].indexOf("whoEntered");
    getApplicationDocumentsDirectory().then((value) {
      dbPath = value.path;
    });
    // find last scanned
    var temp = List.from(noHeaderValue.where((e) {
        return e[registeredTimestampIndex].length > 1 && scannerName == e[whoEnteredIndex];
    }));
    temp.sort((a, b) => int.parse(b[registeredTimestampIndex]) - int.parse(a[registeredTimestampIndex]));
    // add only tickets scanned by this phone
    for (List<String> item in temp) {
      lastScanned.add(returnTicketAsClass(item));
    }
  }
}

/// Clearer way to see usability of a ticket
class TicketUsableState {
  TicketUsableState(this.isUsable, {reason}) {
    // ignore: prefer_initializing_formals
    this.reason = reason;
  }

  /// Reason why the ticket is unusable
  late final String? reason;

  /// If the ticket is usable or not
  final bool isUsable;
}

/// Better representation of a ticket, easier to use than the list
class Ticket {
  final bool externe;
  final String id;
  final String whoEntered;
  final String couleur;
  final String prenom;
  final String nom;
  final bool hasEntered;
  final int salle;
  final int? registeredTimestamp;
  final int? enteredTimestamp;
  final int? leaveTimestamp;

  Map toJson(){
    return {
      "id": id,
      "salle": salle,
      "couleur": couleur,
      "prenom": prenom,
      "nom": nom,
      "externe": externe,
      "hasEntered": hasEntered,
      "whoEntered": whoEntered,
      "timestamps": {
        "registered": registeredTimestamp ?? 0,
        "entered": enteredTimestamp ?? 0,
        "leave": leaveTimestamp ?? 0,
      }
    };
  }

  Ticket(
      {required this.whoEntered,required this.externe,
      required this.id,
      required this.couleur,
      required this.prenom,
      required this.nom,
      required this.hasEntered,
      required this.salle,
      required this.registeredTimestamp,
      required this.enteredTimestamp,
      required this.leaveTimestamp});
}
