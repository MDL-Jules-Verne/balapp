import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/app_bar.dart';
import 'package:balapp/widgets/ticket_details.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool isCameraOpen = false;

  @override
  Widget build(BuildContext context) {
    double scannerSize = 60.h;
    double topBarSize = 6.5.h;
    double historySize = 100.h - scannerSize - topBarSize + 20 /*Rounded corner size*/;
    return Consumer<DatabaseHolder>(builder: (context, db, _) {
      return Scaffold(
        appBar: CustomAppBar(scannerName: db.scannerName),
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
                          Navigator.of(context).pushNamed("/registerTicket", arguments: code);
                          setState(() => isCameraOpen = false);
                        }
                      }),
                )
              else
                SizedBox(
                  height: scannerSize,
                  child: Container(
                    color: Colors.pinkAccent,
                    child: Center(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(fixedSize: Size(50.w, 6.h)),
                      onPressed: () {
                        setState(() => isCameraOpen = true);
                        // InheritedPreferences.of(context)?.prefs.setString("isCameraOpen", "true");
                      },
                      child: const Text(
                        "Activate camera",
                        style: TextStyle(fontSize: 19),
                      ),
                    )),
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
    });
  }
}
