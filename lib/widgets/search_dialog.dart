import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../screens/ticket_browser.dart';

Future<SearchOptions?> showSearchDialog(
  BuildContext context,
) async {
  String searchBy = "prenom";
  TextEditingController controller = TextEditingController();
  return await showDialog<SearchOptions>(
      context: context,
      builder: (_) => AlertDialog(
            title: const Text("Search for a ticket"),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2.h,),
                    Text("Chercher par:"),
                    DropdownButton<String>(
                          value: searchBy,
                            items: <List<String>>[
                              ['Id','id'],
                              ['Salle', 'salle'],
                              ['Couleur', 'couleur'],
                              ['Nom','nom'],
                              ['Prenom', 'prenom'],
                              ['whoEntered', 'Nom du scanneur'],
                            ].map<DropdownMenuItem<String>>((List<String> value) {

                              return DropdownMenuItem<String>(
                                value: value[1],
                                child: Text(
                                  value[0],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState((){
                                searchBy = newValue ?? "prenom";
                              });
                            }),
                    SizedBox(height: 2.h,),
                    CustomTextInput(controller: controller, label: "Rechercher", showTopLabel: false, disableFormatter: searchBy == "id")
                  ],
                );
              }
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context, SearchOptions(searchBy: searchBy, query: controller.text));
              }, child: const Text("Lancer la recherche"))
            ],
          ));
}
