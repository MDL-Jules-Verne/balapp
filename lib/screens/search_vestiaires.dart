import 'dart:async';
import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/horizontal_line.dart';
import 'package:balapp/widgets/liste_vestiaires.dart';
import 'package:balapp/widgets/searchBar.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:pixel_perfect/pixel_perfect.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchVestiaires extends StatefulWidget {
  const SearchVestiaires({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchVestiaires> createState() => _SearchVestiairesState();
}

class _SearchVestiairesState extends State<SearchVestiaires> {
  SearchBy searchBy = SearchBy.global;
  String searchText = "";
  TextEditingController controller = TextEditingController();
  List<Ticket> searchResults = [];
  bool isLoading = true;
  bool isDrinks = false;
  List<Ticket> selectedTickets = [];
  bool showUnregisteredTickets = false;
  late DatabaseHolder db;

  void updateSearch(List<Ticket> newList) {
    setState(() {
      searchResults = newList;
    });
  }

  @override
  void initState() {
    super.initState();
    db = context.read<DatabaseHolder>();
    Timer.run(() async {
      if (!db.isOfflineMode) await db.reDownloadDb();
      setState(() {
        searchResults =
            searchAlgorithm(controller.text == "" ? SearchBy.none : searchBy, List.from(db.db), controller.text);
        if (showUnregisteredTickets == false) searchResults.removeWhere((element) => element.prenom == "");
        isLoading = false;
      });
    });
  }

  void removeTicketFromSelected(int index) {
    setState(() {
      selectedTickets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ColoredBox(
        color: kWhite,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(30, 6.h, 18, 24),
              child: Column(
                children: [
                  Consumer<DatabaseHolder>(builder: (context, db, _) {
                    return SearchBar(
                      searchBy: searchBy,
                      searchText: searchText,
                      updateSearch: updateSearch,
                      controller: controller,
                      db: db,
                      showUnregisteredTicketsCheckbox: true,
                    );
                  }),
                  Row(
                    children: [
                      Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: isDrinks,
                        onChanged: (bool? value) {
                          setState(() {
                            isDrinks = value!;
                          });
                        },
                      ),
                      Text("Mode boissons")
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (isLoading) const CircularProgressIndicator(),
                  SizedBox(
                    height: isDrinks ? 70.h : 40.h,
                    child: Consumer<DatabaseHolder>(builder: (context, db, _) {
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 18,
                              cornerSmoothing: 1,
                            ),
                            child: Material(
                              color: kWhite,
                              child: InkWell(
                                onTap: isDrinks ? null : () async {
                                  if (selectedTickets.any((Ticket element) => element.id == searchResults[index].id)) {
                                    return;
                                  }
                                  setState(() {
                                    selectedTickets.add(searchResults[index]);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  child: isDrinks ? TicketDetailsBar(searchResults[index]) : TicketDetailsExtended(searchResults[index]),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            child: HorizontalLine(
                              color: kBlack.withOpacity(.3),
                            ),
                          );
                        },
                        itemCount: searchResults.length,
                      );
                    }),
                  )
                ],
              ),
            ),
            Positioned(
              right: 25,
              bottom: isDrinks ? 10.h + 50: 35.h + 50 + 26,
              child: Container(
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 16,
                      cornerSmoothing: 1,
                    ),
                  ),
                  shadows: const [BoxShadow(offset: Offset(1, 3), color: Color(0x44332A22), blurRadius: 16)],
                  color: kBlack,
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 1,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: kWhite.withOpacity(0.4),
                      onTap: () async {
                        var code = await Navigator.pushNamed<dynamic>(context, "/scannerFullScreen");
                        if (code is String) {
                          setState(() {
                            searchText = code;
                            searchBy = SearchBy.id;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(19, 9, 19, 9),
                        /*decoration: ShapeDecoration(
                          // color: kBlack,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 16,
                              cornerSmoothing: 1,
                            ),
                          ),
                        ),*/
                        child: Row(
                          /*mainAxisAlignment: MainAxisAlignment.spaceAround,*/
                          children: [
                            const Icon(Icons.qr_code_scanner_rounded, color: kWhite, size: 28),
                            const SizedBox(
                              width: 9,
                            ),
                            Text("Scan", style: bodyBold.apply(color: kWhite, fontWeightDelta: -1))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if(!isDrinks)Positioned(
                bottom: 50, child: ListeVestiaires(tickets: selectedTickets, removeTicket: removeTicketFromSelected, db: db)),
          ],
        ),
      ),
    );
  }
}
