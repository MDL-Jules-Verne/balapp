import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/ticket.dart';
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
  SearchBy searchBy = SearchBy.prenom;
  TextEditingController controller = TextEditingController();
  List<Ticket> searchResults = [];
  List<Ticket> selectedTickets = [];
  bool showUnregisteredTickets = false;

  void updateSearch(List<Ticket> newList) {
    setState(() {
      searchResults = newList;
    });
  }

  @override
  void initState() {
    super.initState();
    searchResults = searchAlgorithm(
        controller.text == "" ? SearchBy.none : searchBy, context.read<DatabaseHolder>().db, controller.text);
    if (showUnregisteredTickets == false) searchResults.removeWhere((element) => element.prenom == "");
    Future.delayed(const Duration(milliseconds: 0), () {
      context.read<DatabaseHolder>().reDownloadDb();
    });
  }

  void removeTicketFromSelected(int index) {
    setState(() {
      selectedTickets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PixelPerfect(
      offset: const Offset(0, -15),
      initBottom: 100,
      initOpacity: 0,
      assetPath: 'assets/Vestiaires.png',
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
                      updateSearch: updateSearch,
                      controller: controller,
                      db: db,
                      showUnregisteredTicketsCheckbox: true,
                    );
                  }),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 60.h,
                    child: ListView.separated(
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
                              onTap: () {
                                if (selectedTickets.any((Ticket element) => element.id == searchResults[index].id)) {
                                  return;
                                }
                                setState(() {
                                  selectedTickets.add(searchResults[index]);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                child: TicketDetailsExtended(searchResults[index]),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, int index) {
                        return const SizedBox(height: 5);
                      },
                      itemCount: searchResults.length,
                    ),
                  )
                ],
              ),
            ),
            Positioned(
                bottom: 50, child: ListeVestiaires(tickets: selectedTickets, removeTicket: removeTicketFromSelected))
          ],
        ),
      ),
    );
  }
}
