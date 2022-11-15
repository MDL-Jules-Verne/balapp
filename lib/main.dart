import 'dart:async';

import 'package:balapp_new/utils/database_holder.dart';
import 'package:balapp_new/utils/init_future.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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
      //Changer pour un futureBuilder pour se co et load le nom
      builder: (context) {
        DatabaseHolder db = DatabaseHolder(userData!.db);
        return ChangeNotifierProvider<DatabaseHolder>.value(
          value: db,
          child: MaterialApp(
            theme: ThemeData(
                fontFamily: "Inter",

                // primarySwatch: Colors.blue,
                useMaterial3: true),
            home: Scaffold(
              body: ListView.builder(itemBuilder: (context, index) {
                return ListTile(
                  title: Text(db.db[index].id),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
