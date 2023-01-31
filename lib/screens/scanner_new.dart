import 'dart:async';
import 'dart:ui';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/init_future.dart';
import 'package:balapp/widgets/confirm_enter.dart';
import 'package:balapp/widgets/custom_icons_menu.dart';
import 'package:balapp/widgets/register_ticket.dart';
import 'package:balapp/widgets/scan_history.dart';
import 'package:balapp/widgets/search_mini.dart';
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
  SearchBy? overrideSearchBy;
  String? overrideSearchString;
  double scannerSize = 100.h - 36.3.h + 35

  /*Rounded corner size*/;

  bool showSearchPanel = true;
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
      maskRect =
          Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (kDebugMode) scanControl.stop();
    });
  }

  void dismissAll() {
    scanControl.start();
    setState(() {
      showSearchPanel = false;
      currentTicket = null;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (isLightOn) scanControl.toggleTorch();
    });
  }

  void dismissSearch() {
    if (currentTicket == null) {
      dismissAll();
    } else {
      setState(() {
        showSearchPanel = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHolder>(builder: (context, DatabaseHolder db, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        // appBar: PreferredSize(preferredSize: Size(0,0), child: AppBar(),),//CustomAppBar(scannerName: db.scannerName),
        body: SizedBox(
          // width: 100.w,
          height: 100.h,
          child: Stack(
            children: [
              if (isCameraOpen == true || !kDebugMode)
                SizedBox(
                  height: scannerSize,
                  child: MobileScanner(
                      controller: scanControl,
                      allowDuplicates: true,
                      onDetect: (barcode, args) async {
                        if (lastScan.add(const Duration(milliseconds: 600))
                            .isAfter(DateTime.now())) return;
                        if (barcode.rawValue == null) return;

                        final String code = barcode.rawValue!;
                        lastScan = DateTime.now();
                        if (code.runtimeType != String ||
                            code.length != kCodesLength) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text("Impossible de lire le qrCode")));
                          return;
                        }

                        List<Offset> offsets = barcode.corners!.map((e) =>
                            e.translate(-40, -40)).toList();
                        int pointsInRect = 0;
                        for (Offset i in offsets) {
                          if (maskRect.contains(i)) pointsInRect++;
                        }
                        if (pointsInRect < 3) return;
                        //TODO: handle what to do with ticket here (e.g. launch a page with ticket info)
                        if (showSearchPanel == true)  {
                          if(code == overrideSearchString) return;
                          setState((){
                            overrideSearchBy = SearchBy.id;
                            overrideSearchString = code;
                          });
                        } else {
                          setState(() {
                            currentTicket = code;
                            scanControl.stop();
                          });
                        }
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
                showSearchPanel: () {
                  if (showSearchPanel == true) {
                    dismissSearch();
                  } else {
                    setState(() {
                      showSearchPanel = true;
                    });
                  }
                },
              ),

              Positioned(
                bottom: 0,
                child: ClipSmoothRect(
                  radius: const SmoothBorderRadius.vertical(
                    top: SmoothRadius(
                      cornerRadius: 26,
                      cornerSmoothing: 1,
                    ),
                  ),
                  child: Container(
                    color: kWhite,
                    height: 35.h,
                    width: 100.w,
                    child: ScanHistory(tickets: db.lastScanned),
                  ),
                ),
              ),
              // if(offsets.isNotEmpty)Positioned.fill(child: CustomPaint(size: Size(100.w, 100.h,), painter: QrCodePainter(offsets, squareColor),)),
              if (db.appMode == AppMode.bal && currentTicket != null)
                Positioned(
                  bottom: 0,
                  child: ConfirmEnterTicket(
                    ticketId: currentTicket!,
                    apiUrl: db.apiUrl,
                    dismiss: dismissAll,
                    scannerName: db.scannerName,
                  ),
                ),
              if (db.appMode == AppMode.buy && currentTicket != null)
                Positioned(bottom: 0,
                    child: RegisterTicket(
                        currentTicket!, db.apiUrl, dismissAll)),
              if (showSearchPanel)
                Positioned.fill(
                  top: 13.h,
                  child: GestureDetector(
                    onTap: () {
                      dismissSearch();
                    },
                  ),
                ),
              if (showSearchPanel)
                Positioned(
                  bottom: 0,
                  child: SearchMini(
                    searchBy: overrideSearchBy,
                    searchText: overrideSearchString,
                    dismiss: dismissSearch,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class ScanMask extends StatelessWidget {
  const ScanMask({Key? key, required this.maskKey, required this.scannerSize})
      : super(key: key);
  final GlobalKey maskKey;
  final double scannerSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: IgnorePointer(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6.0,
            sigmaY: 6.0,
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
