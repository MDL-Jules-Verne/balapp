import 'package:balapp/consts.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketDetails extends StatelessWidget {
  final Ticket ticket;

  const TicketDetails(
    this.ticket, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
          width: 14.w,
          height: 4.h,
          decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1,
                ),
              ),
              color: ticket.externe ? kPurple : kGreen),
          child: Center(
            child: Text(
              ticket.externe ? "EXT" : "INT",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 6.w,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ticket.nom.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                toFirstCharUpperCase(ticket.prenom),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              )
            ],
          ),
        ),
        SizedBox(width: 4.h,),
        Text("#${ticket.id}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),)
      ],
    );
  }
}
