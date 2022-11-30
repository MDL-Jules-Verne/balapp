import 'dart:async';

import 'package:balapp/screens/scanner_new.dart';
import 'package:balapp/screens/settings.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/init_future.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(ResponsiveSizer(
    builder: (context, _  ,__) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      return const MyApp();
    }
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirstTime = true;
  bool hasRunFirstTime = false;
  InitData? userData;


  @override
  Widget build(BuildContext context) {
    if (isFirstTime) {
      return MaterialApp(
        theme: ThemeData(
            fontFamily: "Inter",

            // primarySwatch: Colors.blue,
            useMaterial3: true),
        home: Builder(
          builder: (
            context,
          ) {
            if (!hasRunFirstTime) {
              hasRunFirstTime = true;
              Timer.run(() async {
                InitData? data = await initApp(context);
                if (data != null) {
                  setState(() {
                    userData = data;
                    isFirstTime = false;
                  });
                }
              });
            }
            return Container();
          },
        ),
      );
    }
    return Builder(
      builder: (context) {
        DatabaseHolder db = DatabaseHolder(userData!.db, userData!.dbPath, userData!.apiUrl, userData!.scannerName, context);
        return ChangeNotifierProvider<DatabaseHolder>.value(
          value: db,
          child: MaterialApp(
            theme: ThemeData(
                fontFamily: "Inter",
                useMaterial3: true),
            initialRoute: "/scanner",
            routes: {
              "/scanner": (_) => Builder(
                builder: (context) {
                  context.read<DatabaseHolder>().setContext(context);
                  return const ScannerNew();
                }
              ),
              "/settings": (_) => Builder(
                builder: (context) {
                  context.read<DatabaseHolder>().setContext(context);
                  return const Settings();
                }
              ),
            },
          ),
        );
      },
    );
  }
}
