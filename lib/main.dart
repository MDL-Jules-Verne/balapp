import 'package:balapp/screens/registerTicket.dart';
import 'package:balapp/screens/scanner.dart';
import 'package:balapp/screens/ticket_browser.dart';
import 'package:balapp/utils/db.dart';
import 'package:balapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return FutureBuilder<List<List>>(
            future: readAndParseDb(),
            builder: (context, AsyncSnapshot<List> db) {
              if(!db.hasData || db.data == null) return const CircularProgressIndicator();

              return ChangeNotifierProvider<DatabaseHolder>(
                create: (_) => DatabaseHolder(db.data as List<List>),
                child: MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                  ),

                  initialRoute: "/",
                  routes: {
                    "/": (_) => const ScannerScreen(), // Route with different tabs for checking, validating and retrieving ticket data
                    "/checkTicket": (_) => const Scaffold(), // Route to go when validating a ticket
                    "/registerTicket": (_) => const SafeArea(child: TicketRegister()), // Route to go when buying a ticket
                    "/browseTickets": (_) => const SafeArea(child: TicketBrowser()),
                  },
                ),
              );
            }
          );
        }
      ),
    );
  }
}
