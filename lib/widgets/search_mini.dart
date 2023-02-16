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
  const SearchMini({Key? key, required this.dismiss, this.searchBy, this.searchText, required this.loadTicket}) : super(key: key);

  final SearchBy? searchBy;
  final String? searchText;
  final void Function(String) loadTicket;
  final void Function() dismiss;

  @override
  State<SearchMini> createState() => _SearchMiniState();
}

class _SearchMiniState extends State<SearchMini> {
  TextEditingController controller = TextEditingController();
  String oldSearchText = "";
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHolder>(builder: (context, DatabaseHolder db, _){
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
            height: 31.h+108,
            width: 100.w,
            padding: const EdgeInsets.fromLTRB(28, 15, 16, 8),
            child: Column(
              children: [
                Consumer<SearchData>(
                  builder: (context, searchData, _) {
                    if(searchData.searchText != oldSearchText) {
                      controller.text = searchData.searchText;
                      oldSearchText = searchData.searchText;
                    }
                    return SearchBar(
                      searchBy: searchData.searchBy,
                      searchText: searchData.searchText,
                      updateSearch: searchData.updateSearch,
                      controller: controller,
                      db:db
                    );
                  }
                ),
                if(false) const CircularProgressIndicator(),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Consumer<SearchData>(
                    builder: (context, searchData, _) {
                      if(searchData.loading){
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: searchData.searchResults.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 30,); // Should be 4.h
                          // return Container();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              widget.loadTicket(searchData.searchResults[index].id);
                            },
                            child: TicketDetailsExtended(
                              searchData.searchResults[index],
                            ),
                          );
                        },
                      );
                    }
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
