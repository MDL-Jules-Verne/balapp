import 'dart:async';
import 'dart:ui';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/widgets/custom_icons_menu.dart';
import 'package:balapp/widgets/register_ticket.dart';
import 'package:balapp/widgets/scan_history.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pixel_perfect/pixel_perfect.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ScannerNew extends StatefulWidget {
  const ScannerNew({Key? key}) : super(key: key);

  @override
  State<ScannerNew> createState() => _ScannerNewState();
}

class _ScannerNewState extends State<ScannerNew> {
  bool isCameraOpen = false;
  String? currentTicket;
  DateTime lastScan = DateTime.now();
  GlobalKey maskKey = GlobalKey();
  Rect maskRect = Rect.fromLTWH(0, 0, 0, 0);
  double historySize = 36.3.h;
  double  scannerSize = 100.h - 36.3.h + 35 /*Rounded corner size*/;

  bool isLightOn = false;

  void setLightState(bool state) {
    isLightOn = state;
  }

  MobileScannerController scanControl = MobileScannerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BuildContext? context = maskKey.currentContext;
      if (context == null) {
        throw Exception("Key not found");
      }
      RenderBox box = context.findRenderObject() as RenderBox;

      Offset offset = box.localToGlobal(Offset.zero);
      maskRect = Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      scanControl.stop();
    });
  }

  void finishEnter() {
    scanControl.start();
    setState(() {
      currentTicket = null;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (isLightOn) scanControl.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PixelPerfect(
      assetPath: 'assets/Scan.png',
      scale: 1,
      initBottom: 50,
      offset: Offset.zero,
      initOpacity: 0.0,
      child: Consumer<DatabaseHolder>(builder: (context, db, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          // appBar: PreferredSize(preferredSize: Size(0,0), child: AppBar(),),//CustomAppBar(scannerName: db.scannerName),
          body: SizedBox(
            // width: 100.w,
            height: 100.h,
            child: Stack(
              children: [
                if (isCameraOpen == true && kDebugMode)
                  SizedBox(
                    height: scannerSize,
                    child: MobileScanner(
                        controller: scanControl,
                        allowDuplicates: true,
                        onDetect: (barcode, args) async {
                          if (lastScan.add(const Duration(seconds: 2)).isAfter(DateTime.now())) return;
                          if (barcode.rawValue == null) return;

                          final String code = barcode.rawValue!;
                          if (code.runtimeType != String || code.length != kCodesLength) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text("Impossible de lire le qrCode")));
                            return;
                          }

                          lastScan = DateTime.now();
                          List<Offset> offsets = barcode.corners!.map((e) => e.translate(-40, -40)).toList();
                          int pointsInRect = 0;
                          for (Offset i in offsets) {
                            if (maskRect.contains(i)) pointsInRect++;
                          }
                          if (pointsInRect < 2) return;

                          setState(() {
                            currentTicket = code;
                            scanControl.stop();
                          });
                        }),
                  )
                else
                  Container(
                    height: scannerSize,
                    width: 100.w,
                    color: kBlack,
                    child: Center(
                        child: ElevatedButton(
                      onPressed: () {
                        scanControl.start();
                        setState(() {
                          isCameraOpen = true;
                        });
                      },
                      child: Text("Activate camera"),
                    )),
                  ),
                ScanMask(
                  maskKey: maskKey,
                  scannerSize: scannerSize,
                ),
                CustomIconsMenu(
                  setLightState: setLightState,
                  db: db,
                  scanControl: scanControl,
                ),
                Positioned(
                  bottom: 0,
                  child: ClipSmoothRect(
                      radius: const SmoothBorderRadius.only(
                        topLeft: SmoothRadius(
                          cornerRadius: 26,
                          cornerSmoothing: 1,
                        ),
                        topRight: SmoothRadius(
                          cornerRadius: 26,
                          cornerSmoothing: 1,
                        ),
                      ),
                      child: Container(
                          color: kWhite, height: 35.h, width: 100.w, child: ScanHistory(tickets: db.lastScanned))),
                ),
                if (currentTicket != null)
                  Positioned(bottom: 0, child: RegisterTicket(currentTicket!, db.apiUrl, finishEnter)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ScanMask extends StatelessWidget {
  const ScanMask({Key? key, required this.maskKey, required this.scannerSize}) : super(key: key);
  final GlobalKey maskKey;
  final double scannerSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: IgnorePointer(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Container(
            color: Colors.white.withOpacity(0.23),
            child: SizedBox(
              height: scannerSize,
              width: 100.w,
              child: Center(
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 38,
                    cornerSmoothing: 1,
                  ),
                  child: Container(
                    key: maskKey,
                    // margin: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 30.h),
                    width: 290,
                    height: 290,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.clear,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
