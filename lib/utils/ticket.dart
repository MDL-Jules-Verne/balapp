class Ticket {
  late bool externe;
  late final String id;
  late String whoEntered;
  late final String couleur;
  late String prenom;
  late String nom;
  late bool hasEntered;
  late final String salle;
  late Map timestamps;
  late String whoScanned;
  late int classe;
  late String niveau;
  bool? isNotSync;

  @override
  String toString() {
    return "Ticket(${toJson()})";
  }

  Map toJson() {
    return {
      "id": id,
      "salle": salle,
      "couleur": couleur,
      "prenom": prenom,
      "nom": nom,
      "externe": externe,
      "classe": classe,
      "niveau": niveau,
      "isNotSync": isNotSync,
      "hasEntered": hasEntered,
      "whoEntered": whoEntered,
      "whoScanned": whoScanned,
      "timestamps": timestamps
    };
  }

  Ticket.fromJson(Map json) {
    externe = json["externe"] ?? false;
    id = json["id"];
    isNotSync = json["isNotSync"];
    whoEntered = json["whoEntered"] ?? "";
    whoScanned = json["whoScanned"] ?? "";
    couleur = json["couleur"];
    prenom = json["prenom"] ?? "";
    nom = json["nom"] ?? "";
    hasEntered = json["hasEntered"] ?? false;
    salle = json["salle"];
    classe = json["classe"];
    niveau = json["niveau"] ?? "";
    timestamps = json["timestamps"] ??
        {
          "registered": 0,
          "entered": 0,
          "leave": 0,
        };
  }

  /// This is used in TicketWithIndex
  /*Ticket.fromTicket(Ticket ticket) {
    externe = ticket.externe;
    id = ticket.id;
    whoEntered = ticket.whoEntered;
    whoScanned = ticket.whoScanned;
    couleur = ticket.couleur;
    prenom = ticket.prenom;
    classe = ticket.classe;
    niveau = ticket.niveau;
    nom = ticket.nom;
    hasEntered = ticket.hasEntered;
    salle = ticket.salle;
    timestamps = ticket.timestamps;
  }*/

  Ticket({
    required this.whoEntered,
    required this.whoScanned,
    required this.externe,
    required this.id,
    required this.couleur,
    required this.prenom,
    required this.nom,
    required this.hasEntered,
    required this.classe,
    required this.niveau,
    required this.salle,
    required this.timestamps,
    this.isNotSync
  });
}

/*
class TicketWithIndex extends Ticket {
  late final int index;

  TicketWithIndex.fromTicket(Ticket ticket, this.index)
      : super.fromTicket(ticket);

  TicketWithIndex(
      {required super.whoEntered,
      required super.externe,
      required super.classe,
      required super.niveau,
      required super.whoScanned,
      required super.id,
      required super.couleur,
      required super.prenom,
      required super.nom,
      required super.hasEntered,
      required super.salle,
      required super.timestamps,
      required this.index});
}
*/
