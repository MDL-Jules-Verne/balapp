import 'package:balapp/consts.dart';
import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Future showValidateDialog(BuildContext context, TicketWithIndex ticket, DatabaseHolder db) async {
  return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text("Ticket ${ticket.id} scanné"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TicketDetails(ticket),
                SizedBox(
                  height: 2.h,
                ),
                Text("Enregistré par ${ticket.whoEntered}"),
                SizedBox(
                  height: 4.h,
                ),
                SizedBox(
                  height: 7.5.h,
                  width: 60.w,
                  child: ElevatedButton(
                      onPressed: () {
                        db.markTicketAsUsed(ticket.index);
                        //TODO: local network call
                        Navigator.pop(context);
                        var scaffoldMessenger = ScaffoldMessenger.of(context);
                        Future.delayed(const Duration(seconds: 4), () => scaffoldMessenger.hideCurrentMaterialBanner());
                        scaffoldMessenger.showMaterialBanner(const MaterialBanner(
                          content: Text(
                            "Success",
                            style: TextStyle(color: Colors.green),
                          ),
                          leading: Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          actions: fakeWidgetArray,
                        ));
                      },
                      child: const Text(
                        "Enregistrer l'entrée",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                )
              ],
            ),
            actions: [],
          ));
}

Future showErrorValidateDialog(
    BuildContext context, String title, String description, ValidateErrorReasons reason) async {
  return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(description)],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("D'accord"),
              )
            ],
          ));
}

enum ValidateErrorReasons { notFound, alreadyEntered, notBought }
