import 'dart:async';
import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:balapp/widgets/horizontal_line.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

typedef StrToVoidFn = void Function(String?);

Future<Ticket?> loadTicket(String ticketId, StrToVoidFn setFatalError,
    StrToVoidFn setFatalErrorDetails, DatabaseHolder db) async {
  if (!db.isOfflineMode && db.apiUrl == null) throw Exception("Cannot use network without a provided apiUrl");
  if (!db.isOfflineMode) {
    Response result = await httpCall("/ticketRegistration/ticketInfo/$ticketId", HttpMethod.get, db.apiUrl!);
    if (result.statusCode < 200 && result.statusCode > 299) {
      setFatalError(result.statusCode.toString());
      setFatalErrorDetails(result.body);
      try {
        Map ticketDecode = jsonDecode(result.body);
        setFatalErrorDetails(ticketDecode["res"]);
        // ignore: empty_catches
      } catch (e) {}
      return null;
    }

    Map ticketDecode;
    try {
      ticketDecode = jsonDecode(result.body);
    } catch (e, s) {
      setFatalError("Unable to parse json response");
      setFatalErrorDetails(e as String?);
      return null;
    }
    if (ticketDecode["success"] == false) {
      setFatalError(ticketDecode["res"]);
    }
    return Ticket.fromJson(ticketDecode["res"]);
  } else {
    return db.db.firstWhere((element) => element.id == ticketId);
  }
}

class RegisterTicket extends StatefulWidget {
  const RegisterTicket(this.ticketId, this.apiUrl, this.dismiss, {Key? key}) : super(key: key);
  final String ticketId;
  final Uri? apiUrl;
  final void Function() dismiss;

  @override
  State<RegisterTicket> createState() => _RegisterTicketState();
}

class _RegisterTicketState extends State<RegisterTicket> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String? error;
  String? fatalError;
  String? niveau;
  int? classe;
  bool fatalErrorNeedDismiss = true;
  String? fatalErrorDetails;
  Ticket? ticket;
  bool? isExternal;

  get isReady {
    return isExternal != null &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        (classe != null || isExternal == true) &&
        (niveau != null || isExternal == true);
  }

  void setInternalExternal(bool isExternal) {
    setState(() {
      this.isExternal = isExternal;
    });
  }

  void setFatalError(String? fatalError) {
    setState((){
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
      if (ticket == null) return;
      if (ticket?.nom != "") {
        setState(() {
          fatalError = "Ticket déjà vendu";
          fatalErrorDetails = alreadySoldString;
          fatalErrorNeedDismiss = false;
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
        color: fatalError != null ? kRed : kWhite,
        height: fatalError == null ? 350 : 310,
        width: 100.w,
        child: Padding(
          padding: fatalError == null ? const EdgeInsets.fromLTRB(31, 18, 33, 0) : EdgeInsets.zero,
          child: fatalError == null && ticket == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : fatalError != null
                  ? Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.fromLTRB(35, 11, 35, 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.remove_circle,
                                  // color: widget.isAlreadyEntered ? kWhite : kBlack,
                                  size: 40,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  fatalError ?? "",
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
                            padding: const EdgeInsets.fromLTRB(31, 0, 33, 15),
                            decoration: const ShapeDecoration(
                              color: kWhite,
                              shape: SmoothRectangleBorder(
                                  borderRadius:
                                      SmoothBorderRadius.vertical(top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1))),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /*Text(
                                  fatalError!,
                                  style: bodyTitle.apply(color: kRed),
                                ),*/
                                Padding(
                                  padding: const EdgeInsets.only(top:10.0,bottom: 16.0),
                                  child: Text(
                                    fatalErrorDetails ?? "",
                                    style: body,
                                  ),
                                ),
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
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                        child: Text("Annuler"),
                                      )),
                                ),
                                if (!fatalErrorNeedDismiss)
                                  TextButton(
                                      onLongPress: () {
                                        setState(() {
                                          firstNameController.text = ticket?.prenom ?? "";
                                          lastNameController.text = ticket?.nom ?? "";
                                          classe = ticket?.classe == 0 ? null : ticket?.classe;
                                          niveau = ticket?.niveau == "" ? null :  ticket?.niveau;
                                          isExternal = ticket?.externe;
                                          fatalError = null;
                                          fatalErrorDetails = null;
                                        });
                                      },
                                      onPressed: () {},
                                      child: const Text("Modifier quand même (appui long)"),),
                              ],
                            )),
                      ),
                    ])
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Ticket #${widget.ticketId}",
                              style: h3,
                            ),
                            IconButton(onPressed: widget.dismiss, icon: const Icon(Icons.clear))
                          ],
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        CustomTextInput(
                          callback: (_) {
                            setState(() {});
                          },
                          controller: firstNameController,
                          showLabelText: false,
                          label: 'Prénom',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextInput(
                          callback: (String? input) {
                            setState(() {});
                          },
                          showLabelText: false,
                          controller: lastNameController,
                          label: 'Nom',
                        ),
                        if (error != null)
                          Text(
                            error!,
                            style: const TextStyle(color: kRed, fontSize: 18),
                          ),
                        if (isExternal == false) const SizedBox(height: 10),
                        if (isExternal == false)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 6,
                                fit: FlexFit.tight,
                                child:  DropdownButton<String>(
                                  isExpanded: true,
                                  value: niveau,
                                  items: [
                                    for (String niveauStr in kNiveaux)
                                      DropdownMenuItem<String>(
                                        value: niveauStr,
                                        child: Text(niveauStr, style: bodyTitle),
                                      ),
                                  ],
                                  onChanged: (String? selectedValue) {
                                    if (selectedValue == null) return;
                                    setState(() {
                                      niveau = selectedValue;
                                    });
                                  },
                                  hint: Text(
                                    "Niveau",
                                    style: body.apply(fontSizeFactor: 1.2),
                                  ),
                                  underline: const HorizontalLine(),
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Flexible(
                                flex: 4,
                                fit: FlexFit.tight,
                                child: DropdownButton<int>(
                                  value: classe,
                                  isExpanded: true,
                                  items: [
                                    for (int i = 1; i < 10; i++)
                                      DropdownMenuItem<int>(
                                        value: i,
                                        child: Text("$i", style: bodyTitle),
                                      ),
                                  ],
                                  onChanged: (int? selectedValue) {
                                    if (selectedValue == null) return;
                                    setState(() {
                                      classe = selectedValue;
                                    });
                                  },
                                  hint: Text("Classe", style: body.apply(fontSizeFactor: 1.2)),
                                  underline: const HorizontalLine(),
                                ),
                              )
                            ],
                          ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setInternalExternal(false);
                                  },
                                  child: ClipSmoothRect(
                                    radius: SmoothBorderRadius(
                                      cornerRadius: 9,
                                      cornerSmoothing: 1,
                                    ),
                                    child: Container(
                                      // padding: EdgeInsets.fromLTRB(16, 8, 15, 5),
                                      width: 64,
                                      height: 39,
                                      color: isExternal == false ? kGreen : kGreenLight,
                                      child: const Center(
                                          child: Text(
                                        "INT",
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite),
                                      )),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setInternalExternal(true);
                                  },
                                  child: ClipSmoothRect(
                                    radius: SmoothBorderRadius(
                                      cornerRadius: 9,
                                      cornerSmoothing: 1,
                                    ),
                                    child: Container(
                                      // padding: EdgeInsets.fromLTRB(16, 8, 15, 5),
                                      width: 64,
                                      height: 39,
                                      color: isExternal == true ? kPurple : kPurpleLight,
                                      child: const Center(
                                          child: Text(
                                        "EXT",
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite),
                                      )),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: !isReady
                                          ? null
                                          : () async {
                                              DatabaseHolder db = context.read<DatabaseHolder>();
                                              ticket!.prenom = firstNameController.text;
                                              ticket!.nom = lastNameController.text;
                                              ticket!.externe = isExternal!;
                                              if (isExternal == false) {
                                                ticket!.classe = classe!;
                                                ticket!.niveau = niveau!;
                                              }
                                              ticket!.whoEntered = db.scannerName;
                                              if (!db.isOfflineMode) {
                                                Response result = await httpCall(
                                                    "/ticketRegistration/enterTicket/", HttpMethod.post, widget.apiUrl!,
                                                    body: jsonEncode(ticket!.toJson()));
                                                if (result.statusCode > 299 || result.statusCode < 200) {
                                                  setState(() {
                                                    error = result.body;
                                                  });
                                                  return;
                                                }
                                              } else {
                                                int index = db.db.indexWhere((element) => element.id == ticket!.id);
                                                db.editAndSaveTicket(ticket!, index);
                                              }

                                              int duplicateIndex = db.lastScanned
                                                  .indexWhere((Ticket element) => element.id == ticket!.id);
                                              if (duplicateIndex != -1) {
                                                db.lastScanned.removeAt(duplicateIndex);
                                              }
                                              db.lastScanned.insert(0, ticket!);
                                              widget.dismiss();
                                            },
                                      style: TextButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                                          alignment: Alignment.topCenter,
                                          textStyle: const TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.w800, fontFamily: "Inter"),
                                          foregroundColor: isReady ? kBlack : kBlack.withOpacity(0.5)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.check,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("DONE"),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
