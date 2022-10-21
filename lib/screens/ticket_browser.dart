import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketBrowser extends StatefulWidget {
  const TicketBrowser({Key? key}) : super(key: key);

  @override
  State<TicketBrowser> createState() => _TicketBrowserState();
}

class _TicketBrowserState extends State<TicketBrowser> {
  SearchOptions searchOptions = SearchOptions(searchBy: "none", query: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(100.w, 6.5.h),
        child: AppBar(
          title: const Text("All tickets"),
          actions: [
            IconButton(
                onPressed: () async {
                  searchOptions = await showSearchDialog(context) ?? searchOptions;
                  setState(() {});
                },
                icon: const Icon(Icons.search))
          ],
        ),
      ),
      body: Column(
        children: [
          if (searchOptions.searchBy != "none")
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .5.h),
              decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    ),
                  ]),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text(
                  "Searching for ${searchOptions.query} in ${searchOptions.searchBy}",
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                    onPressed: () => setState(() => searchOptions = SearchOptions(searchBy: "none", query: "")),
                    icon: const Icon(Icons.clear, color: Colors.white,))
              ]),
            ),
          Consumer<DatabaseHolder>(
            builder: (context, db, _) {
              List<List<String>> items = db.noHeaderValue;
              if (searchOptions.searchBy != "none") {
                int indexToSearch = db.header.indexOf(searchOptions.searchBy);
                items = db.noHeaderValue
                    .where((element) => element[indexToSearch].startsWith(searchOptions.query))
                    .toList();
              }

              return SizedBox(
                height: searchOptions.searchBy == "none" ? 90.h : 83.5.h,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      color: Colors.black,
                      width: 100.w,
                      height: 2,
                    );
                  },
                  itemBuilder: (context, index) {
                    List ticket = items[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ticket[db.prenomIndex] + " " + ticket[db.nomIndex]),
                          Text(ticket[db.idIndex].toString())
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchOptions {
  final String searchBy;
  final String query;

  SearchOptions({required this.searchBy, required this.query});

  @override
  String toString() {
    return "SearchOptions(searchBy: $searchBy, query: $query)";
  }
}
