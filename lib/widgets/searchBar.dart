import 'dart:async';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchBar extends StatefulWidget {
  SearchBar({Key? key, required this.searchBy, required this.updateSearch, required this.controller, required this.db, this.showUnregisteredTicketsCheckbox = false, this.searchText})
      : super(key: key);
  final Function(List<Ticket>) updateSearch;
  final SearchBy searchBy;
  final String? searchText;
  final bool showUnregisteredTicketsCheckbox;
  final TextEditingController controller;
  final DatabaseHolder db;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late SearchBy searchBy;
  late bool showUnregisteredTickets;
  SearchBy? oldSearchBy;
  String? oldSearchText;
  @override
  void initState() {
    oldSearchBy = widget.searchBy;
    oldSearchText = widget.searchText;
    showUnregisteredTickets = !widget.showUnregisteredTicketsCheckbox;
    searchBy = widget.searchBy;
  }

  @override
  Widget build(BuildContext context) {

    if (oldSearchBy != widget.searchBy || oldSearchText != widget.searchText) {
      Timer.run(() {
        setState(() {
          oldSearchBy = widget.searchBy;
          oldSearchText = widget.searchText;
          searchBy = widget.searchBy;
          widget.controller.text = widget.searchText ?? "";
          showUnregisteredTickets = true;
        });
        widget.updateSearch(searchAlgorithm(
            widget.controller.text == "" ? SearchBy.none : searchBy,
            List<Ticket>.from(context.read<DatabaseHolder>().db),
            widget.controller.text,
            showUnregisteredTickets
        ));
      });
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (searchBy.isDropdown == false)
              SizedBox(
                width: 30.w,
                child: CustomTextInput(
                  callback: (String? text) {
                    widget.updateSearch(searchAlgorithm(widget.controller.text == "" ? SearchBy.none : searchBy,
                        List<Ticket>.from(widget.db.db), widget.controller.text, showUnregisteredTickets));
                  },
                  controller: widget.controller,
                  formatter: const [],
                  fontSize: 20,
                  padding: const EdgeInsets.fromLTRB(2, 0, 12, 0),
                ),
              ),
            /*if(searchBy.isDropdown == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                            items: [
                              for (String searchKey in (searchBy.keyValue == "salle" ? salleValues : couleurValues) + ["Toutes"])
                                DropdownMenuItem<String>(
                                  value: searchKey,
                                  child:
                                  Text(searchKey, style: bodyTitle),
                                ),
                            ],
                            iconSize: 0,
                            value: dropdownSearchBy,
                            underline: const SizedBox(),
                            // style: const TextStyle(decoration: TextDecoration.none),
                            onChanged: (String? searchKey) {
                              if(searchKey == null) return;
                              updateSearch(searchAlgorithm(
                                  dropdownSearchBy == "Toutes" ? SearchBy.none : searchBy,
                                  List<Ticket>.from(db.db),
                                  dropdownSearchBy
                              ));
                              setState((){
                                dropdownSearchBy = searchKey;
                              });
                            }),
                        const Icon(
                          Icons.expand_more,
                          size: 32,
                        ),
                      ],
                    ),
                  ),*/
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.expand_more,
                    size: 32,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  DropdownButton<SearchBy>(
                      items: [
                        for (SearchBy searchKey in const [
                          SearchBy.prenom,
                          SearchBy.id,
                          SearchBy.nom,
                          SearchBy.vendeur,
                          SearchBy.scanneur,
                          // SearchBy.salle,
                          // SearchBy.couleur,
                        ])
                          DropdownMenuItem<SearchBy>(
                            value: searchKey,
                            child: Text(searchKey.value, style: bodyTitle),
                          ),
                      ],
                      iconSize: 0,
                      value: searchBy,
                      underline: const SizedBox(),
                      // style: const TextStyle(decoration: TextDecoration.none),
                      onChanged: (SearchBy? searchKey) {
                        if (searchKey == null) return;
                        // if(searchKey == SearchBy.couleur || searchKey == SearchBy.salle) dropdownSearchBy = "Toutes";

                        setState(() {
                          searchBy = searchKey;
                          /*if(searchBy.isDropdown == true) {
                                    updateSearch(searchAlgorithm(
                                        dropdownSearchBy == "Toutes" ? SearchBy.none : searchBy,
                                        List<Ticket>.from(db.db),
                                        dropdownSearchBy
                                    ));
                                  } else {
                                    updateSearch(searchAlgorithm(
                                        controller.text == "" ? SearchBy.none : searchBy,
                                        List<Ticket>.from(db.db),
                                        controller.text
                                    ));
                                  }*/
                        });
                        widget.updateSearch(searchAlgorithm(widget.controller.text == "" ? SearchBy.none : searchBy,
                            List<Ticket>.from(widget.db.db), widget.controller.text, showUnregisteredTickets));
                      })
                ],
              ),
            )
          ],
        ),
        if(widget.showUnregisteredTicketsCheckbox) Row(
          children: [
            Checkbox(
              visualDensity: VisualDensity.compact,
              value: showUnregisteredTickets,
              onChanged: (bool? value) {
                setState(() {
                  showUnregisteredTickets = value!;
                  print(showUnregisteredTickets);
                  widget.updateSearch(searchAlgorithm(widget.controller.text == "" ? SearchBy.none : searchBy, List<Ticket>.from(widget.db.db), widget.controller.text, showUnregisteredTickets));
                });
              },
            ),
            Text("Montrer les tickets non vendus")
          ],
        )
      ],
    );
  }
}
