class Ticket {
  late bool externe;
  late final String id;
  late String whoEntered;
  late String prenom;
  late String nom;
  late bool hasEntered;
  late Map timestamps;
  late String whoScanned;
  late int classe;
  late String niveau;
  bool? isNotSync;
  late bool hasTakenFreeDrink;
  late List<Cloth> clothes;

  @override
  String toString() {
    return "Ticket(${toJson()})";
  }

  Map toJson() {
    return {
      "id": id,
      "prenom": prenom,
      "nom": nom,
      "externe": externe,
      "classe": classe,
      "niveau": niveau,
      "isNotSync": isNotSync,
      "hasEntered": hasEntered,
      "whoEntered": whoEntered,
      "whoScanned": whoScanned,
      "timestamps": timestamps,
      "hasTakenFreeDrink": hasTakenFreeDrink,
      "clothes": clothes.map<Map>((Cloth e) => e.toJson()).toList(),
    };
  }

  Ticket.fromJson(Map json) {
    externe = json["externe"] ?? false;
    id = json["id"];
    isNotSync = json["isNotSync"];
    whoEntered = json["whoEntered"] ?? "";
    whoScanned = json["whoScanned"] ?? "";
    prenom = json["prenom"] ?? "";
    nom = json["nom"] ?? "";
    hasEntered = json["hasEntered"] ?? false;
    classe = json["classe"] ?? 0;
    niveau = json["niveau"] ?? "";
    hasTakenFreeDrink = json["hasTakenFreeDrink"] ?? false;
    timestamps = json["timestamps"] ??
        {
          "registered": 0,
          "entered": 0,
          "leave": 0,
        };
    clothes = (json["clothes"] ?? []).map<Cloth>((e) => Cloth.fromJson(e)).toList();
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

  /// HARDCODED LOL
  String clothesString() {
    String returnString = "";
    int nbOfBags = clothes.where((e) => e.clothType == "Sac").length;
    int nbOfClothes = clothes.where((e) => e.clothType == "Vetement").length;
    int nbOfRelou = clothes.where((e) => e.clothType == "Relou").length;

    if (nbOfBags > 0) returnString += "Sacs: $nbOfBags, ";
    if (nbOfClothes > 0) returnString += "V: $nbOfClothes, ";
    if (nbOfRelou > 0) returnString += "R: $nbOfRelou, ";
    if(returnString.isEmpty) returnString = "Aucun";
    return returnString;
  }

  Ticket(
      {required this.whoEntered,
      required this.whoScanned,
      required this.externe,
      required this.id,
      required this.prenom,
      required this.nom,
      required this.hasEntered,
      required this.classe,
      required this.niveau,
      required this.hasTakenFreeDrink,
      required this.timestamps,
      this.isNotSync});
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
class Cloth {
  late String clothType;
  late int idNumber;
  late int place;

  Cloth({required this.clothType, required this.idNumber, required this.place});

  Cloth.fromJson(Map json) {
    if (json["clothType"] == null || json["idNumber"] == null || json["place"] == null) {
      throw Exception("Clothe is not parsable");
    }
    clothType = json["clothType"];
    idNumber = json["idNumber"];
    place = json["place"];
  }

  String toCode() {
    return "$idNumber${clothType[0]}${place < 10 ? "0" : ""}$place";
  }

  Map toJson() {
    return {"clothType": clothType, "idNumber": idNumber, "place": place};
  }

  @override
  String toString() {
    return "Cloth(${toJson()})";
  }
}

const String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
