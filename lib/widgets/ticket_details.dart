import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'enter_locker.dart';

class TicketDetails extends StatelessWidget {
  const TicketDetails(
    this.ticket, {
    Key? key,
  }) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          "#${ticket.id}",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}

class TicketDetailsMedium extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsMedium(
    this.ticket, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NomPrenomDisplay(ticket),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: ShapeDecoration(
                color: kBlack,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 15,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  for (Cloth i in ticket.clothes)
                    MiniCloth(
                      ticket: ticket,
                      setLittleError: (String? error) => null,
                      removeCloth: (int index) => null,
                      cloth: i,
                      db: context.read<DatabaseHolder>(),
                    )
                ],
              ),
            )

          ],
        ),
      ],
    );
  }
}

class TicketDetailsExtended extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsExtended(
    this.ticket, {
    Key? key,
  }) : super(key: key);

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
              ticket.niveau.isEmpty ? "" : ticket.niveau + ticket.classe.toString(),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Entered:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text(ticket.hasEntered ? "Oui" : "Non",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))
              ]),
            ),
            SalleId(ticket),
            // ColorDisplay(ticket),
            Text(
              "#${ticket.id}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            )
          ],
        )
      ],
    );
  }
}

class TicketDetailsBar extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsBar(
    this.ticket, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NomPrenomDisplay(ticket),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Entered:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text(ticket.hasEntered ? "Oui" : "Non",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))
              ]),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("Boisson gratuite prise: "),
                StatefulBuilder(builder: (context, setState) {
                  return Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: ticket.hasTakenFreeDrink,
                    onChanged: (bool? value) async {
                      DatabaseHolder db = context.read<DatabaseHolder>();
                      setState(() {
                        ticket.hasTakenFreeDrink = !ticket.hasTakenFreeDrink;
                      });
                      if (!db.isOfflineMode) {
                        await httpCall("/freeDrink", HttpMethod.post, db.apiUrl as Uri,
                            body: jsonEncode({"id": ticket.id, "hasTakenFreeDrink": ticket.hasTakenFreeDrink}));
                      } else {
                        print("test");
                        int i = db.db.indexWhere((element) => element.id == ticket.id);
                        db.editAndSaveTicket(ticket, i);
                      }
                    },
                  );
                }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "#${ticket.id}",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            )
          ],
        )
      ],
    );
  }
}

class SalleId extends StatelessWidget {
  const SalleId(
    this.ticket, {
    Key? key,
  }) : super(key: key);
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vestiaires:",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            ticket.clothesString(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ColorDisplay extends StatelessWidget {
  const ColorDisplay(
    this.ticket, {
    Key? key,
  }) : super(key: key);
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
          color: stringToColor[ticket.couleur],
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
  const IntExtDisplay(
    this.ticket, {
    Key? key,
  }) : super(key: key);
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
