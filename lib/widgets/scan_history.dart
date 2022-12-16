import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ScanHistory extends StatelessWidget {
  const ScanHistory({Key? key, required this.tickets}) : super(key: key);
  final List<Ticket> tickets;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 28, 4.h, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Scan history", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          const SizedBox(height: 20),
          SizedBox(
            height: 22.h,
            child: tickets.isNotEmpty ? ListView.separated(
              padding: EdgeInsets.zero ,
              // shrinkWrap: true,
              itemCount: tickets.length,
              separatorBuilder: (BuildContext context, int index){
                return const SizedBox(height: 18,); // Should be 4.h
                // return Container();
              },
              itemBuilder: (context, index){
                return TicketDetails(tickets[index]);
              },
            ) : const Text(
              "No tickets scanned from this phone for now",
              style: TextStyle(fontSize: 16, color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}
