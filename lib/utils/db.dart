import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const listToCsv = ListToCsvConverter();

class DatabaseHolder extends ChangeNotifier {
  late String scannerName;

  String? localServer;

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

  late Function rebuildApp;

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

  void setLocalSever(ip) {
    localServer = ip;
  }

  void setScannerName(ip) {
    scannerName = ip;
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

  void markTicketAsUsed(int ticketIndex) {
    value[ticketIndex][hasEnteredIndex] = "true";
    // Wait for pop anim before update
    Future.delayed(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
    writeToStorage();
  }

  /// Returns index of the ticket having this ticketId
  int findTicketIndex(String ticketId) {
    return value.indexWhere((element) => element[idIndex] == ticketId);
  }

  /// Adds data to an empty ticket
  void registerTicket(
    String id,
    String scannerName, {
    required String firstName,
    required String lastName,
    required bool isExternal,
  }) {
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
  List<List<String>> get noHeaderValue {
    return value.sublist(1);
  }

  /// Returns the db's value as without the header row
  List<String> get header {
    return value[0];
  }

  /// Instantiates a DatabaseHolder from the parsed csv value
  DatabaseHolder(this.value, this.scannerName, this.rebuildApp, this.localServer) {
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
  late final bool externe;
  late final String id;
  late final String whoEntered;
  late final String couleur;
  late final String prenom;
  late final String nom;
  late final bool hasEntered;
  late final int salle;
  late final int? registeredTimestamp;
  late final int? enteredTimestamp;
  late final int? leaveTimestamp;

  Map toJson() {
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
  // This is used in TicketWithIndex
  Ticket.fromTicket(Ticket ticket){
    externe = ticket.externe;
    id = ticket.id;
    whoEntered = ticket.whoEntered;
    couleur = ticket.couleur;
    prenom = ticket.prenom;
    nom = ticket.nom;
    hasEntered = ticket.hasEntered;
    salle = ticket.salle;
    registeredTimestamp = ticket.registeredTimestamp;
    enteredTimestamp = ticket.enteredTimestamp;
    leaveTimestamp = ticket.leaveTimestamp;
  }
  Ticket(
      {required this.whoEntered,
      required this.externe,
      required this.id,
      required this.couleur,
      required this.prenom,
      required this.nom,
      required this.hasEntered,
      required this.salle,
      required this.registeredTimestamp,
      required this.enteredTimestamp,
      required this.leaveTimestamp,
      });
}

class TicketWithIndex extends Ticket {
  late final int index;

  TicketWithIndex.fromTicket(Ticket ticket, this.index) : super.fromTicket(ticket);

  TicketWithIndex(
      {required super.whoEntered,
      required super.externe,
      required super.id,
      required super.couleur,
      required super.prenom,
      required super.nom,
      required super.hasEntered,
      required super.salle,
      required super.registeredTimestamp,
      required super.enteredTimestamp,
      required super.leaveTimestamp, required this.index});
}
