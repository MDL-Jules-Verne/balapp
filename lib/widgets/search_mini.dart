import 'dart:async';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:balapp/widgets/searchBar.dart';
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
  void initState() {
    print("initState");
    oldSearchBy = widget.searchBy;
    oldSearchText = widget.searchText;
    searchBy = widget.searchBy ?? searchBy;
    controller.text = widget.searchText ?? "";
    searchResults = searchAlgorithm(widget.searchBy != null ? searchBy : SearchBy.none, context
        .read<DatabaseHolder>()
        .db, controller.text);
    Future.delayed(const Duration(milliseconds: 0), () {
      context.read<DatabaseHolder>().reDownloadDb();
    });
    super.initState();
  }

  void updateSearch(List<Ticket> newList) {
    setState(() {
      searchResults = newList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHolder>(builder: (context, DatabaseHolder db, _){
      print(db.db.length);
      if (oldSearchBy != widget.searchBy || oldSearchText != widget.searchText) {
        oldSearchBy = widget.searchBy;
        oldSearchText = widget.searchText;
        searchBy = widget.searchBy ?? searchBy;
        controller.text = widget.searchText ?? controller.text;
        Timer.run(() {
          updateSearch(searchAlgorithm(
              controller.text == "" ? SearchBy.none : searchBy,
              List<Ticket>.from(db.db),
              controller.text
          ));
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
            height: 45.h,
            width: 100.w,
            padding: const EdgeInsets.fromLTRB(28, 15, 16, 8),
            child: Column(
              children: [
                SearchBar(
                  searchBy: searchBy,
                  updateSearch: updateSearch,
                  controller: controller,
                  db:db
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 30,); // Should be 4.h
                      // return Container();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return TicketDetailsExtended(
                        searchResults[index],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
  }
