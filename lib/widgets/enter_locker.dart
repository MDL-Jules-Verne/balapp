import 'dart:async';
import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/register_ticket.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'horizontal_line.dart';

typedef StrToVoidFn = void Function(String?);

class EnterLocker extends StatefulWidget {
  const EnterLocker(this.ticketId, this.dismiss, {Key? key, required this.db}) : super(key: key);
  final String ticketId;
  final DatabaseHolder db;
  final void Function() dismiss;

  @override
  State<EnterLocker> createState() => _EnterLockerState();
}

class _EnterLockerState extends State<EnterLocker> {
  String? error;
  String? fatalError;
  bool fatalErrorNeedDismiss = true;
  String? fatalErrorDetails;
  Ticket? ticket;
  String? littleError;
  List<int> allowedLockers = [];
  Map<String, List<Cloth>> clothMap = {};

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
      if (ticket == null) return;
      // ignore: use_build_context_synchronously
      allowedLockers = ModalRoute.of(context)!.settings.arguments as List<int>;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ticket != null) {
      clothMap = {
        "Sac": ticket!.clothes.where((e) => e.clothType == "Sac").toList(),
        "Vetement": ticket!.clothes.where((e) => e.clothType == "Vetement").toList(),
        "Relou": ticket!.clothes.where((e) => e.clothType == "Relou").toList()
      };
    }
    print(clothMap);
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
                  ? Column(children: [
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
                                  borderRadius: SmoothBorderRadius.vertical(
                                      top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1))),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /*Text(
                                  fatalError!,
                                  style: bodyTitle.apply(color: kRed),
                                ),*/
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
                                  child: Text(
                                    fatalErrorDetails ?? "",
                                    style: body,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
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
                            const Text(
                              "Il y a...",
                              style: h3,
                            ),
                            IconButton(onPressed: widget.dismiss, icon: const Icon(Icons.clear))
                          ],
                        ),
                        for (String type in ["Sac", "Vetement", "Relou"])
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Text("$type:", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                const SizedBox(
                                  width: 10,
                                ),
                                if (clothMap[type]!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    decoration: ShapeDecoration(
                                      color: kBlack,
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 15,
                                          cornerSmoothing: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        for (Cloth i in clothMap[type]!)
                                          MiniCloth(
                                            ticket: ticket!,
                                            setLittleError: (String? error) => setState(() => littleError = error),
                                            removeCloth: (int index) => setState(() => ticket!.clothes.removeAt(index)),
                                            cloth: i,
                                            db: widget.db,
                                          )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        if (littleError != null)
                          Text(
                            littleError!,
                            style: bodyTitle.apply(color: kRed),
                          ),
                        const SizedBox(height: 20),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (String type in ["Sac", "Vetement", "Relou"])
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (!widget.db.isOfflineMode) {
                                        Response res =
                                            await httpCall("/clothes/add", HttpMethod.post, widget.db.apiUrl as Uri,
                                                body: jsonEncode({
                                                  "id": ticket!.id,
                                                  "forceLockerNumber": allowedLockers,
                                                  "clothType": type,
                                                }));
                                        if (res.statusCode >= 200 && res.statusCode < 299) {
                                          print(res.body);
                                          setState(() {
                                            ticket!.clothes.add(Cloth.fromJson(jsonDecode(res.body)));
                                            littleError = null;
                                          });
                                          /*int i = widget.db.db.indexWhere((element) => element.id == ticket!.id);

                            widget.db.editAndSaveTicket(ticket!, i);*/
                                        } else {
                                          setState(() {
                                            littleError = res.body;
                                          });
                                        }
                                      } else {
                                        List<Locker> max;
                                        List<Locker> lockers = widget.db.getLockers();
                                        print(lockers);
                                        return;
                                        if (type == "Vetement") {
                                          max = lockers.where((e) => allowedLockers.contains(e.idNumber)).toList();
                                          if (max.isEmpty) {
                                            max = lockers.where((e) => allowedLockers.contains(e.idNumber - 4)).toList();
                                          }
                                        } else if (type == "Relou") {
                                          max = lockers.where((e) => allowedLockers.contains(e.idNumber)).toList();
                                        } else if (type == "Sac") {
                                          max = lockers.where((e) => e.idNumber == 4).toList();
                                          if (max[0] == null) {
                                            max = lockers.where((e) => [5, 6, 7].contains(e.idNumber)).toList();
                                            if (max.isEmpty) {
                                              max = lockers.where((e) => [1, 2, 3].contains(e.idNumber)).toList();
                                            }
                                          }
                                        }
                                        setState(() {
                                          // ticket!.clothes.add();
                                          littleError = null;
                                        });
                                      }
                                      // TODO offline mode
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: 15,
                                            cornerSmoothing: 1,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: kBlack),
                                    child: Text(type),
                                  )
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TextButton(
                              onPressed: () {
                                widget.dismiss();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                                alignment: Alignment.topCenter,
                                textStyle:
                                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: "Inter"),
                                foregroundColor: kBlack,
                              ),
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
    );
  }
}

class MiniCloth extends StatelessWidget {
  const MiniCloth({
    Key? key,
    required this.cloth,
    required this.ticket,
    required this.db,
    required this.setLittleError,
    required this.removeCloth,
    this.isDisabled = false,
  }) : super(key: key);
  final Cloth cloth;
  final DatabaseHolder db;
  final Ticket ticket;
  final bool isDisabled;
  final Function(String?) setLittleError;
  final Function(int) removeCloth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: kWhite,
              backgroundColor: kBlack,
              minimumSize: const Size(50, 15),
              textStyle: bodyBold,
              elevation: 4),
          onPressed: isDisabled
              ? null
              : () async {
                  if (!db.isOfflineMode) {
                    Response res = await httpCall("/clothes/remove", HttpMethod.post, db.apiUrl!,
                        body: jsonEncode({
                          "id": ticket.id,
                          "cloth": cloth.toJson(),
                        }));
                    if (res.statusCode >= 200 && res.statusCode < 299) {
                      int index = ticket.clothes.indexWhere((e) =>
                      e.idNumber == cloth.idNumber && e.clothType == cloth.clothType && e.place == cloth.place);
                      removeCloth(index);
                      setLittleError(null);
                    } else {
                      setLittleError(res.body);
                    }
                  }else {
                    int index = ticket.clothes.indexWhere((e) =>
                    e.idNumber == cloth.idNumber && e.clothType == cloth.clothType && e.place == cloth.place);
                    removeCloth(index);
                    int i = db.db.indexWhere((element) => element.id == ticket.id);
                    db.editAndSaveTicket(ticket, i);
                  }
                },
          child: Text(cloth.toCode()),
        ),
        const VerticalLine(
          width: 1,
          color: kWhite,
        ),
      ],
    );
  }
}
