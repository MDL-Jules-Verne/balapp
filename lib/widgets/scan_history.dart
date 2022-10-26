import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ScanHistory extends StatelessWidget {
  const ScanHistory({Key? key, required this.tickets}) : super(key: key);
  final List<Ticket> tickets;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.h, 3.5.h, 4.h, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Scan history", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          SizedBox(height: 2.5.h),
          SizedBox(
            height: 22.2.h,
            child: tickets.isNotEmpty ? ListView.separated(
              // shrinkWrap: true,
              itemCount: tickets.length,
              separatorBuilder: (BuildContext context, int index){
                return SizedBox(height: 3.h,); // Should be 4.h
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
