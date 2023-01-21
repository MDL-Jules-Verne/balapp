import 'dart:async';
import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ConfirmEnterTicket extends StatefulWidget {
  const ConfirmEnterTicket({Key? key, required this.ticketId, required this.apiUrl, required this.dismiss, required this.scannerName})
      : super(key: key);

  final Uri apiUrl;
  final void Function() dismiss;
  final String ticketId;
  final String scannerName;

  @override
  State<ConfirmEnterTicket> createState() => _ConfirmEnterTicketState();
}

class _ConfirmEnterTicketState extends State<ConfirmEnterTicket> {
  String? error;
  Ticket? ticket;
  String? fatalError;
  String? fatalErrorDetails;

  bool get isError {
    if (ticket != null) {
      return (ticket!.hasEntered && ticket!.nom != "") || fatalError != null;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.run(() async {
      Response result =
          await httpCall("/ticketRegistration/ticketInfo/${widget.ticketId}", HttpMethod.get, widget.apiUrl);

      if (result.statusCode >= 200 && result.statusCode < 299) {
        Map ticketDecode;
        try {
          ticketDecode = jsonDecode(result.body);
        } catch (e, s) {
          setState(() {
            fatalError = "Unable to parse json response";
            fatalErrorDetails = e as String?;
          });
          return;
        }
        if (ticketDecode["success"] == false) {
          return setState(() {
            fatalError = ticketDecode["res"];
          });
        }
        ticket = Ticket.fromJson(ticketDecode["res"]);
        if(ticket?.nom == "") {
          setState(() {
            fatalError = "Ticket non vendu";
            fatalErrorDetails = "Ce ticket n'a pas été vendu et n'est donc pas valide";
          });
        }else {
          setState(() {

          });
        }

      } else {
        setState(() {
          fatalError = result.statusCode.toString();
          fatalErrorDetails = result.body;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: const SmoothBorderRadius.only(
        topLeft: SmoothRadius(
          cornerRadius: 24,
          cornerSmoothing: 1,
        ),
        topRight: SmoothRadius(
          cornerRadius: 24,
          cornerSmoothing: 1,
        ),
      ),
      child: Container(
        color: error == null && ticket == null && fatalError == null
            ? kWhite
            : isError
                ? kRed
                : kGreen,
        height: 38.h,
        width: 100.w,
        child: error == null && ticket == null && fatalError == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(35, 16, 35, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              isError ? Icons.remove_circle : Icons.check_circle,
                              // color: widget.isAlreadyEntered ? kWhite : kBlack,
                              size: 40,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              fatalError != null
                                  ? "Erreur lors de la lecture"
                                  : ticket!.hasEntered
                                      ? "Ticket déjà utilisé"
                                      : "Ticket disponible",
                              style: bodyTitle,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 30,
                          ),
                          onPressed: () {
                            widget.dismiss();
                          },
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      width: 100.w,
                      decoration: const ShapeDecoration(
                        color: kWhite,
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.all(SmoothRadius(cornerRadius: 24, cornerSmoothing: 1))),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(31, 18, 33, 15),
                        child: LayoutBuilder(
                          builder: (context, BoxConstraints constraints) {
                            return SingleChildScrollView(
                              child:
                               SizedBox(
                                    height: constraints.maxHeight,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        //TODO: regroup different scenarios, this shit is unreadable and a mess to edit
                                        if (!isError)
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                Response result = await httpCall(
                                                    "/ticket/editEnterStatus", HttpMethod.post, widget.apiUrl,
                                                    body: jsonEncode({"id": widget.ticketId, "setEnter": true, "scannerName": widget.scannerName}));
                                                if (result.statusCode >= 200 && result.statusCode < 299) {
                                                  // ignore: use_build_context_synchronously
                                                  DatabaseHolder db = context.read<DatabaseHolder>();
                                                  int duplicateIndex = db.lastScanned.indexWhere((Ticket element) => element.id == ticket!.id);
                                                  if(duplicateIndex != -1){
                                                    db.lastScanned.removeAt(duplicateIndex);
                                                  }
                                                  db.lastScanned.insert(0, ticket!);
                                                  widget.dismiss();

                                                } else {
                                                  setState(() {
                                                    error = result.body;
                                                  });
                                                }
                                              },
                                              child: const Text("Cette personne est entrée"),
                                            ),
                                          ),
                                        if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                          const Text(alreadyUsedString, style: body,),
                                        if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                          const SizedBox(height: 20,),
                                        if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                          ElevatedButton(
                                            onPressed: () {
                                              widget.dismiss();
                                            },
                                            child: const Text("Annuler"),
                                          ),
                                        if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                          TextButton(
                                            onPressed: (){},
                                            onLongPress: () async {
                                              Response result = await httpCall(
                                                  "/ticket/editEnterStatus", HttpMethod.post, widget.apiUrl,
                                                  body: jsonEncode({"id": widget.ticketId, "setEnter": false, "scannerName": ""}));
                                              if (result.statusCode >= 200 && result.statusCode < 299) {
                                                // ignore: use_build_context_synchronously
                                                DatabaseHolder db = context.read<DatabaseHolder>();
                                                widget.dismiss();
                                                int duplicateIndex = db.lastScanned.indexWhere((Ticket element) => element.id == ticket!.id);
                                                if(duplicateIndex != -1){
                                                  db.lastScanned.removeAt(duplicateIndex);
                                                }
                                              } else {
                                                setState(() {
                                                  error = result.body;
                                                });
                                              }
                                            },
                                            child: const Text("Rendre le ticket disponible (appui long)"),
                                          ),
                                        if (fatalError != null)
                                          Text(
                                            fatalError!,
                                            style: bodyTitle.apply(color: kRed),
                                          ),
                                        if (fatalErrorDetails != null)
                                          Text(
                                            fatalErrorDetails!,
                                            style: body,
                                          ),
                                        if (error != null)
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        if (error != null)
                                          Text(
                                            error!,
                                            style: body.apply(color: kRed),
                                          ),
                                      ],
                                    ),


                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
