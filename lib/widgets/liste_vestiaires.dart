import 'package:balapp/consts.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ListeVestiaires extends StatelessWidget {
  const ListeVestiaires({Key? key, required this.tickets, required this.removeTicket}) : super(key: key);
  final List<Ticket> tickets;
  final void Function(int) removeTicket;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
          shadows: [BoxShadow(offset: Offset(0, -1), color: Color(0x44332A22), blurRadius: 16)],
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.vertical(
              top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1),
            ),
          )),
      height: 35.h,
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(onPressed: () {
                  int nbOfTickets = tickets.length +1 -1; // Copy the length
                  for (int i = 0; i<nbOfTickets; i++) {
                    removeTicket(0);
                  }
                }, icon: const Icon(Icons.delete), label: const Text("Clear")),
                IconButton(onPressed: () {}, icon: const Icon(Icons.open_in_full))
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              height: 25.h,
              child: tickets.isNotEmpty
                  ? ListView.separated(
                      padding: EdgeInsets.zero,
                      // shrinkWrap: true,
                      itemCount: tickets.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 18,
                        ); // Should be 4.h
                        // return Container();
                      },
                      itemBuilder: (context, index) {
                        return ClipSmoothRect(
                            radius: SmoothBorderRadius(
                            cornerRadius: 18,
                            cornerSmoothing: 1,
                        ),
                        child: Material(
                          color:Colors.transparent,
                          child: InkWell(
                            onTap: (){
                              removeTicket(index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                              child: TicketDetailsMedium(tickets[index]),
                            ),
                          ),
                        ),);
                      },
                    )
                  : const Text(
                      "No tickets selected",
                      style: TextStyle(fontSize: 16, color: Colors.black38),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
