import 'dart:convert';
import 'dart:math';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/horizontal_line.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/call_apis.dart';

class ListeVestiaires extends StatefulWidget {
  const ListeVestiaires({Key? key, required this.tickets, required this.removeTicket, required this.db})
      : super(key: key);
  final List<Ticket> tickets;
  final DatabaseHolder db;
  final void Function(int) removeTicket;

  @override
  State<ListeVestiaires> createState() => _ListeVestiairesState();
}

class _ListeVestiairesState extends State<ListeVestiaires> {
  List<bool> ticketState = [];
  bool isExpanded = false;
  late int oldTicketLength;

  @override
  void initState() {
    super.initState();
    oldTicketLength = widget.tickets.length;
    ticketState = [for (int i = 0; i < widget.tickets.length; i++) false];
  }

  @override
  Widget build(BuildContext context) {
    if (oldTicketLength != widget.tickets.length) {
      oldTicketLength = widget.tickets.length;
      ticketState = [for (int i = 0; i < widget.tickets.length; i++) false];
    }
    return Container(
      decoration: const ShapeDecoration(
          shadows: [BoxShadow(offset: Offset(0, -1), color: Color(0x44332A22), blurRadius: 16)],
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.vertical(
              top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1),
            ),
          )),
      height: isExpanded ? 90.h : 25.h + 80,
      width: 100.w,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                    onPressed: () {
                      int nbOfTickets = widget.tickets.length + 1 - 1; // Copy the length
                      for (int i = 0; i < nbOfTickets; i++) {
                        widget.removeTicket(0);
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Clear")),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    icon: Icon(isExpanded ? Icons.close_fullscreen : Icons.open_in_full))
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              height: isExpanded ? 77.h : 24.5.h,
              child: widget.tickets.isNotEmpty
                  ? ListView.separated(
                      padding: EdgeInsets.zero,
                      // shrinkWrap: true,
                      itemCount: widget.tickets.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 18,
                        ); // Should be 4.h
                        // return Container();
                      },
                      itemBuilder: (context, index) {
                        return Opacity(
                          opacity: ticketState[index] == true ? .34 : 1,
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 18,
                              cornerSmoothing: 1,
                            ),
                            child: Material(
                              color: /*ticketState[index] == true ? kBlack.withOpacity(0.2) : */ Colors.transparent,
                              child: InkWell(
                                onLongPress: () {
                                  if (!widget.db.isOfflineMode) {
                                    httpCall("/clothes/setLastRemove", HttpMethod.post, widget.db.apiUrl!,
                                        body: jsonEncode({"id": widget.tickets[index].id}));
                                  } else {
                                    widget.tickets[index].timestamps["leave"] = DateTime.now().millisecondsSinceEpoch;
                                    int i =
                                        widget.db.db.indexWhere((element) => element.id == widget.tickets[index].id);
                                    widget.db.editAndSaveTicket(widget.tickets[index], i);
                                  }
                                  widget.removeTicket(index);
                                },
                                onTap: () {
                                  setState(() {
                                    ticketState[index] = !ticketState[index];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  child: TicketDetailsMedium(widget.tickets[index]),
                                ),
                              ),
                            ),
                          ),
                        );
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
