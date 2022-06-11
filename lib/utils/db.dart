import 'package:flutter/material.dart';

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



  bool isIdInDb(String id) {
    return value.any((element) => element[idIndex] == id);
  }

  int findTicketIndex(String id){
    return value.indexWhere((element) => element[idIndex] == id);
  }

  void registerTicket(String id, {required String firstName, required String lastName, required bool isExternal}){
    int index = findTicketIndex(id);
    if(index == -1) return;
    value[index][nomIndex] = lastName;
    value[index][prenomIndex] = firstName;
    value[index][externeIndex] = isExternal;
    debugPrint(value.toString());
  }

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
  }
}

class TicketUsableState {
  TicketUsableState(this.isUsable, {reason}){
    // ignore: prefer_initializing_formals
    this.reason = reason;
  }
  late final String? reason;
  final bool isUsable;
}