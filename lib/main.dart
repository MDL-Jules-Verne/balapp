import 'package:balapp/screens/home.dart';
import 'package:balapp/screens/registerTicket.dart';
import 'package:balapp/screens/scanner_new.dart';
import 'package:balapp/screens/settings.dart';
import 'package:balapp/screens/ticket_browser.dart';
import 'package:balapp/utils/db.dart';
import 'package:balapp/utils/prefs_inherited.dart';
import 'package:balapp/utils/utils.dart';
import 'package:balapp/widgets/nameDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  void rebuildAllChildren() {
    setState((){key = UniqueKey();});
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      key: key,
      color: Colors.white,
      child: ResponsiveSizer(builder: (context, orientation, screenType) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, AsyncSnapshot<SharedPreferences> prefs) {

                if (!prefs.hasData || prefs.data == null) return const Center(child: CircularProgressIndicator());
                // prefs.data?.setString("scannerName", "");
                var scannerName = prefs.data?.getString("scannerName") ?? "";
                if (scannerName == "") {
                  var textController = TextEditingController();
                  return MaterialApp(home: nameDialog(context, textController, setState, prefs.data as SharedPreferences));
                }
                return FutureBuilder(
                    future: readAndParseDb(),
                    builder: (context, AsyncSnapshot db) {
                      if (!db.hasData || db.data == null) return const Center(child: CircularProgressIndicator());
                      /*try{
                        var x = DatabaseHolder(db.data as List<List<String>>);
                      }catch(e,s){
                        print(e);
                        print(s);
                      }
                      return Container();*/
                      return InheritedPreferences(prefs.data as SharedPreferences,

                        child: ChangeNotifierProvider<DatabaseHolder>(
                          lazy: false,
                          create: (_) => DatabaseHolder(db.data as List<List<String>>, scannerName, rebuildAllChildren),
                          child: MaterialApp(
                            title: 'Flutter Demo',
                            theme: ThemeData(
                              fontFamily: "Inter",
                              primarySwatch: Colors.blue,
                            ),
                            initialRoute: "/",
                            routes: {
                              "/scanner": (_) => const ScannerNew(),
                              // Route with different tabs for checking, validating and retrieving ticket data
                              "/checkTicket": (_) => const Scaffold(),
                              // Route to go when validating a ticket
                              "/registerTicket": (_) => const TicketRegister(),
                              // Route to go when buying a ticket
                              "/browseTickets": (_) => const TicketBrowser(),
                              "/settings": (_) => const Settings(),
                              "/": (_)=> const Home(),
                            },
                          ),
                        ),
                      );
                    });
              }
            );
          }
        );
      }),
    );
  }
}
