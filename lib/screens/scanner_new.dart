import 'dart:async';
import 'dart:ui';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/widgets/register_ticket.dart';
import 'package:balapp/widgets/scan_history.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pixel_perfect/pixel_perfect.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../widgets/custom_icon_button.dart';

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
  double scannerSize = 100.h - 36.3.h + 20 /*Rounded corner size*/;

  bool isLightOn = false;

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
    Future.delayed(const Duration(milliseconds: 1000), (){
      scanControl.stop();
    });
  }

  void finishEnter() {
    scanControl.start();
    setState(() {
      currentTicket = null;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if(isLightOn) scanControl.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PixelPerfect(
        assetPath: 'assets/Scan.png', // path to your asset image
        // scale: 1, // scale value (optional)
        initBottom: 20, //  default bottom distance (optional)
        offset: Offset.zero, // default image offset (optional)
        initOpacity: 0.0, // init opacity value (optional)
      child: Consumer<DatabaseHolder>(builder: (context, db, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          // appBar: PreferredSize(preferredSize: Size(0,0), child: AppBar(),),//CustomAppBar(scannerName: db.scannerName),
          body: SizedBox(
            // width: 100.w,
            height: 100.h,
            child: Stack(
              children: [
                if (isCameraOpen == true)
                  SizedBox(
                    height: scannerSize,
                    child: MobileScanner(
                        controller: scanControl,
                        allowDuplicates: true,
                        onDetect: (barcode, args) async {
                          if (lastScan.add(const Duration(seconds: 2)).isAfter(DateTime.now())) return;
                          if (barcode.rawValue == null) {
                            return debugPrint('Failed to scan Barcode');
                          }

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
                            // isCameraOpen = false;
                            currentTicket = code;
                            scanControl.stop();
                          });
                          debugPrint('Barcode found! $code');
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
                Positioned(
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
                ),
                Positioned(
                    top: 5.5.h,
                    left: 3.h,
                    right: 3.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 18,
                            cornerSmoothing: 1,
                          ),
                          child: Container(
                            color: kWhite,
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Row(
                              children: [
                                CustomIconButton(
                                    backgroundColor: db.isWebsocketOpen ? kWhite : kRed,
                                    iconColor: db.isWebsocketOpen ? kGreen : kWhite,
                                    paddingSizeDelta: - 8,
                                    icon: db.isWebsocketOpen ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                                    onTap: () {}),
                                Padding(
                                  padding: EdgeInsets.only(top: 0),
                                  child: CustomIconButton(
                                      paddingSizeDelta: - 8, icon: Icons.search, onTap: () {}),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 0),
                                  child: ValueListenableBuilder(
                                      valueListenable: scanControl.torchState,
                                      builder: (context, state, _) {
                                        return CustomIconButton(
                                            paddingSizeDelta: - 8,
                                            icon: Icons.highlight,
                                            iconColor: state == TorchState.on ? kGreenLight : kBlack,
                                            onTap: () async {
                                              scanControl.toggleTorch();

                                              if (state == TorchState.on) {
                                                isLightOn = false;
                                              } else {
                                                isLightOn = true;
                                              }
                                            });
                                      }),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
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
                          color: kWhite,
                          height: 36.3.h,
                          width: 100.w,
                          child: ScanHistory(tickets: db.lastScanned))),
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
