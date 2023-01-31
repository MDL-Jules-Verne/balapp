import 'dart:async';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchMini extends StatefulWidget {
  const SearchMini({Key? key, required this.dismiss, this.searchBy, this.searchText}) : super(key: key);

  final SearchBy? searchBy;
  final String? searchText;
  final void Function() dismiss;

  @override
  State<SearchMini> createState() => _SearchMiniState();
}

class _SearchMiniState extends State<SearchMini> {
  TextEditingController controller = TextEditingController();
  SearchBy searchBy = SearchBy.prenom;
  SearchBy? oldSearchBy;
  String? oldSearchText;
  List<Ticket> searchResults = [];
  String dropdownSearchBy = "Toutes";
  @override
  void initState(){
    print("initState");
    oldSearchBy = widget.searchBy;
    oldSearchText = widget.searchText;
    searchBy = widget.searchBy ?? searchBy;
    controller.text = widget.searchText ?? "";
    searchResults = searchAlgorithm(widget.searchBy != null ? searchBy : SearchBy.none, context.read<DatabaseHolder>().db, controller.text);
    Future.delayed(const Duration(milliseconds: 5000),(){
      context.read<DatabaseHolder>().reDownloadDb();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHolder>(builder: (context, DatabaseHolder db, _) {
      print(db.db.length);
      if(oldSearchBy != widget.searchBy || oldSearchText != widget.searchText) {
        oldSearchBy = widget.searchBy;
        oldSearchText = widget.searchText;
        searchBy = widget.searchBy ?? searchBy;
        controller.text = widget.searchText ?? controller.text;
        Timer.run((){
          setState((){
            searchResults = searchAlgorithm(
                controller.text == "" ? SearchBy.none : searchBy,
                List<Ticket>.from(db.db),
                controller.text
            );
          });
        });
      }
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
          color: kWhite,
          height: 38.h,
          width: 100.w,
          padding: const EdgeInsets.fromLTRB(28, 15, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(searchBy.isDropdown == false) SizedBox(
                    width: 30.w,
                    child: CustomTextInput(
                      callback: (String? text) {
                        setState((){
                          searchResults = searchAlgorithm(
                              controller.text == "" ? SearchBy.none : searchBy,
                              List<Ticket>.from(db.db),
                              controller.text
                          );
                        });
                      },
                      controller: controller,
                      formatter: const [],
                      fontSize: 20,
                      padding: const EdgeInsets.fromLTRB(2, 0, 12, 0),
                    ),
                  ),
                  if(searchBy.isDropdown == true)
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
                                setState((){
                                  dropdownSearchBy = searchKey;
                                  // doesn't work yet
                                  searchResults = searchAlgorithm(
                                      dropdownSearchBy == "Toutes" ? SearchBy.none : searchBy,
                                      List<Ticket>.from(db.db),
                                      dropdownSearchBy
                                  );
                                });
                              }),
                          const Icon(
                            Icons.expand_more,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
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
                                SearchBy.salle,
                                SearchBy.couleur,
                              ])
                                DropdownMenuItem<SearchBy>(
                                  value: searchKey,
                                  child:
                                      Text(searchKey.value, style: bodyTitle),
                                ),
                            ],
                            iconSize: 0,
                            value: searchBy,
                            underline: const SizedBox(),
                            // style: const TextStyle(decoration: TextDecoration.none),
                            onChanged: (SearchBy? searchKey) {
                              if (searchKey == null) return;
                              if(searchKey == SearchBy.couleur || searchKey == SearchBy.salle) dropdownSearchBy = "Toutes";
                              setState(() {
                                searchBy = searchKey;
                                if(searchBy.isDropdown == true) {
                                  searchResults = searchAlgorithm(
                                    dropdownSearchBy == "Toutes" ? SearchBy.none : searchBy,
                                    List<Ticket>.from(db.db),
                                    dropdownSearchBy
                                );
                                } else {
                                  searchResults = searchAlgorithm(
                                      controller.text == "" ? SearchBy.none : searchBy,
                                      List<Ticket>.from(db.db),
                                      controller.text
                                  );
                                }
                              });
                            })
                      ],
                    ),
                  )
                ],
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  separatorBuilder: (BuildContext context, int index){
                    return const SizedBox(height: 10,); // Should be 4.h
                    // return Container();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return TicketDetails(
                      searchResults[index],
                      // TODO: implement isExpanded for more info
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
