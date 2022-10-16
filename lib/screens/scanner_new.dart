import 'dart:convert';
import 'dart:io';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/db.dart';
import 'package:balapp/utils/prefs_inherited.dart';
import 'package:balapp/widgets/nameDialog.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ScannerNew extends StatefulWidget {
  const ScannerNew({Key? key}) : super(key: key);

  @override
  State<ScannerNew> createState() => _ScannerNewState();
}

class _ScannerNewState extends State<ScannerNew> {
  bool isCameraOpen = false;
  String scannerName = "";

  @override
  void initState() {
    Future.delayed(const Duration(), () async {
      setState(() {
        scannerName = InheritedPreferences.of(context)?.prefs.getString("scannerName") ?? "";
        isCameraOpen = InheritedPreferences.of(context)?.prefs.getBool("isCameraOpen") ?? false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scannerSize = 60.h;
    double topBarSize = 6.5.h;
    double historySize = 100.h - scannerSize - topBarSize + 20 /*Rounded corner size*/;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(100.w, topBarSize),
        child: AppBar(
          title: Text(scannerName),
          actions: [
            IconButton(
              onPressed: () async {
                //TODO: add db to send
                var path = context.read<DatabaseHolder>().dbPath;
                await File('$path/db.csv').delete();
              },
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () async {
                //TODO: add db to send
                var lastScanned = context.read<DatabaseHolder>().lastScanned;
                var res = await http.post(Uri.parse("$apiUrl/upload/addTickets"),
                    headers: {
                      "content-type": "application/json",
                      "accept": "application/json",
                    },
                    body: jsonEncode(lastScanned.map((e) => e.toJson()).toList()));
                debugPrint(res.body);
              },
              icon: const Icon(Icons.save),
            ),
            IconButton(
              onPressed: () async {
                //TODO: add db to send
                var data = context.read<DatabaseHolder>();
                var res = await http.post(Uri.parse("$apiUrl/upload/initDb"),
                    headers: {
                      "content-type": "application/json",
                      "accept": "application/json",
                    },
                    body: jsonEncode({"data": data.noHeaderValue, "firstLine": data.value[0]}));
                debugPrint(res.body);
              },
              icon: const Icon(Icons.cloud_upload),
            ),
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: IconButton(
                  onPressed: () async {
                    setState(() {
                      isCameraOpen = !isCameraOpen;
                    });
                    await InheritedPreferences.of(context)?.prefs.setBool('isCameraOpen', isCameraOpen);
                  },
                  icon: const Icon(
                    Icons.swap_horiz_outlined,
                    size: 26,
                  )),
            )
          ],
        ),
      ),
      body: SizedBox(
        width: 100.w,
        height: scannerSize + historySize,
        child: Stack(
          children: [
            if (isCameraOpen == true)
              SizedBox(
                height: scannerSize,
                child: MobileScanner(
                    allowDuplicates: false,
                    onDetect: (barcode, args) {
                      if (barcode.rawValue == null) {
                        debugPrint('Failed to scan Barcode');
                      } else {
                        final String code = barcode.rawValue!;
                        debugPrint('Barcode found! $code');
                        //TODO: go to page only with valid barcode
                        Navigator.of(context).popAndPushNamed("/registerTicket", arguments: code);
                        // Navigator.of(context).pushNamed("/registerTicket", arguments: code);
                      }
                    }),
              )
            else
              SizedBox(
                height: scannerSize,
                child: Container(
                  color: Colors.pinkAccent,
                  child: const Center(),
                ),
              ),
            Positioned(
              bottom: 0,
              child: ClipSmoothRect(
                radius: const SmoothBorderRadius.only(
                  topLeft: SmoothRadius(
                    cornerRadius: 30,
                    cornerSmoothing: 1,
                  ),
                  topRight: SmoothRadius(
                    cornerRadius: 30,
                    cornerSmoothing: 1,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  height: historySize,
                  width: 100.w,
                  padding: EdgeInsets.fromLTRB(8.w, 3.h, 8.w, 0),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text(
                      "Scan history",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Consumer<DatabaseHolder>(builder: (context, db, _) {
                      if (db.lastScanned.isEmpty) {
                        return Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 10.h),
                            child: const Center(
                              child: Text(
                                "No tickets scanned from this phone for now",
                                style: TextStyle(fontSize: 16, color: Colors.black38),
                              ),
                            ),
                          ),
                        );
                      }
                      return Flexible(
                        flex: 1,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: db.lastScanned.length,
                            itemBuilder: (context, i) {
                              return TicketDetails(db.lastScanned[i]);
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return SizedBox(
                                height: 2.h,
                              );
                            },
                          );
                        }),
                      );
                    })
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
