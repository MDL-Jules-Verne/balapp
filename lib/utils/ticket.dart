class Ticket {
  late final bool externe;
  late final String id;
  late final String whoEntered;
  late final String couleur;
  late final String prenom;
  late final String nom;
  late final bool hasEntered;
  late final int salle;
  late final Map timestamps;

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
      "timestamps": timestamps
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
    timestamps = ticket.timestamps;
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
        required this.timestamps,
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
        required super.timestamps, required this.index});
}
