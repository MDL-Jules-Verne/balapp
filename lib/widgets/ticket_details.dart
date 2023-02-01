import 'package:balapp/consts.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketDetails extends StatelessWidget {
  const TicketDetails(this.ticket, {Key? key,}) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IntExtDisplay(ticket),
        SizedBox(width: 6.w,),
        NomPrenomDisplay(ticket),
        SizedBox(width: 4.h,),
        Text("#${ticket.id}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),)
      ],
    );
  }
}

class TicketDetailsMedium extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailsMedium(this.ticket, {Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NomPrenomDisplay(ticket),
        SalleId(ticket),
        ColorDisplay(ticket)

      ],
    );
  }
}

class TicketDetailsExtended extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailsExtended(this.ticket, {Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IntExtDisplay(ticket),
            SizedBox(
              width: 6.w,
            ),
            NomPrenomDisplay(ticket),
            SizedBox(
              width: 4.h,
            ),
            Text(
              ticket.nom.isEmpty ? "" : ticket.niveau + ticket.classe.toString(),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Entered:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text(ticket.hasEntered ? "Oui" : "Non", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))
              ]),
            ),
            SalleId(ticket),
            ColorDisplay(ticket),
          ],
        )
      ],
    );
  }
}

class SalleId extends StatelessWidget {
  const SalleId(this.ticket, {Key? key, }) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sector ${ticket.salle}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "#${ticket.id}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ColorDisplay extends StatelessWidget {
  const ColorDisplay(this.ticket, {Key? key, }) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 0,
      fit: FlexFit.loose,
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        width: 80,
        // height: 32,

        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 8,
              cornerSmoothing: 1,
            ),
          ),
          color: kGreen,
        ),
        child: Center(
          child: Text(
            ticket.couleur.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class IntExtDisplay extends StatelessWidget {
  const IntExtDisplay(this.ticket, {Key? key, }) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
      width: 48,
      height: 32,
      decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 7,
              cornerSmoothing: 1,
            ),
          ),
          color: ticket.prenom == ""
              ? Colors.grey
              : ticket.externe
              ? kPurple
              : kGreen),
      child: Center(
        child: Text(
          ticket.prenom == ""
              ? "?"
              : ticket.externe
              ? "EXT"
              : "INT",
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class NomPrenomDisplay extends StatelessWidget {
  const NomPrenomDisplay(this.ticket, {Key? key}) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ticket.nom.isEmpty ? "Non vendu" : ticket.nom.toUpperCase(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            ticket.nom.isEmpty ? " " : toFirstCharUpperCase(ticket.prenom),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          )
        ],
      ),
    );
  }
}
