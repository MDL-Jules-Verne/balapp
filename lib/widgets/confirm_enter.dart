import 'dart:async';
import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/register_ticket.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ConfirmEnterTicket extends StatefulWidget {
  const ConfirmEnterTicket(
      {Key? key, required this.ticketId, required this.apiUrl, required this.dismiss, required this.scannerName})
      : super(key: key);

  final Uri? apiUrl;
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

  void setFatalError(String? fatalError) {
    setState(() {
      this.fatalError = fatalError;
    });
  }

  void setFatalErrorDetails(String? fatalError) {
    setState(() {
      this.fatalError = fatalError;
    });
  }

  @override
  void initState() {
    super.initState();
    Timer.run(() async {
      DatabaseHolder db = context.read<DatabaseHolder>();
      ticket = await loadTicket(widget.ticketId, setFatalError, setFatalErrorDetails, db);

      if (ticket?.nom == "") {
        setState(() {
          fatalError = "Ticket non vendu";
          fatalErrorDetails = "Ce ticket n'a pas été vendu et n'est donc pas valide";
        });
      } else {
        setState(() {});
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
        height: isError ? 42.h: 38.h,
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
                                      : "Ticket valide",
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
                      decoration: ShapeDecoration(
                        color:  kWhite,
                        shape: SmoothRectangleBorder(
                            borderRadius:
                                SmoothBorderRadius.vertical(top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1))),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(31, 18, 33, 15),
                        child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
                          return SingleChildScrollView(
                            child: SizedBox(
                              height: constraints.maxHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //TODO: regroup different scenarios, this shit is unreadable and a mess to edit
                                  if (!isError)
                                    Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kBlack,
                                          elevation: 2,
                                          shape: const SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius.all(
                                              SmoothRadius(cornerRadius: 22, cornerSmoothing: 1),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          DatabaseHolder db = context.read<DatabaseHolder>();
                                          if (!db.isOfflineMode) {
                                            Response result = await httpCall(
                                                "/ticket/editEnterStatus", HttpMethod.post, widget.apiUrl!,
                                                body: jsonEncode({
                                                  "id": widget.ticketId,
                                                  "setEnter": true,
                                                  "scannerName": widget.scannerName
                                                }));
                                            if (result.statusCode < 200 && result.statusCode > 299) {
                                              setState(() {
                                                error = result.body;
                                              });
                                              return;
                                            }
                                          } else {
                                            ticket!.hasEntered = true;
                                            ticket!.whoScanned = widget.scannerName;
                                            print(ticket);
                                            int index = db.db.indexWhere((element) => element.id == ticket!.id);
                                            db.editAndSaveTicket(ticket!, index);
                                          }
                                          int duplicateIndex =
                                              db.lastScanned.indexWhere((Ticket element) => element.id == ticket!.id);
                                          if (duplicateIndex != -1) {
                                            db.lastScanned.removeAt(duplicateIndex);
                                          }
                                          db.lastScanned.insert(0, ticket!);
                                          widget.dismiss();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                                          child: Text("Valider l'entrée", style: h3.apply(color: kWhite),),
                                        ),
                                      ),
                                    ),
                                  if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                    const Text(
                                      alreadyUsedString,
                                      style: body,
                                    ),
                                  if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                    Padding(
                                      padding: const EdgeInsets.only(top:10.0,bottom: 16.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kBlack,
                                          elevation: 2,
                                          shape: const SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius.all(
                                              SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          widget.dismiss();
                                        },
                                        child:  Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                          child: Text("Annuler", style: bodyTitle.apply(color: kWhite),),
                                        ),
                                      ),
                                    ),
                                  if (ticket != null && ticket!.nom != "" && ticket!.hasEntered == true)
                                    TextButton(
                                      onPressed: () {},
                                      onLongPress: () async {
                                        DatabaseHolder db = context.read<DatabaseHolder>();
                                        if (!db.isOfflineMode) {
                                          Response result = await httpCall(
                                              "/ticket/editEnterStatus", HttpMethod.post, widget.apiUrl!,
                                              body: jsonEncode(
                                                  {"id": widget.ticketId, "setEnter": false, "scannerName": ""}));
                                          if (result.statusCode < 200 && result.statusCode > 299) {
                                            setState(() {
                                              error = result.body;
                                            });
                                            return;
                                          }
                                        } else {
                                          ticket!.hasEntered = false;
                                          ticket!.whoScanned = "";
                                          int index = db.db.indexWhere((element) => element.id == ticket!.id);
                                          db.editAndSaveTicket(ticket!, index);
                                        }
                                        int duplicateIndex =
                                            db.lastScanned.indexWhere((Ticket element) => element.id == ticket!.id);
                                        if (duplicateIndex != -1) {
                                          db.lastScanned.removeAt(duplicateIndex);
                                        }
                                        widget.dismiss();
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
                        }),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
