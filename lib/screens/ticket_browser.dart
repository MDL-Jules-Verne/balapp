import 'package:balapp/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketBrowser extends StatelessWidget {
  const TicketBrowser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseHolder>(
        builder: (context, db, _) {
          return ListView.builder(
            itemCount: db.noHeaderValue.length,
            itemBuilder: (context, index) {
              List ticket = db.noHeaderValue[index];
              return Container(
                decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(width: 1, color: Colors.black))),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ticket[db.prenomIndex] + " " + ticket[db.nomIndex]),
                    Text(ticket[db.idIndex].toString())
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
