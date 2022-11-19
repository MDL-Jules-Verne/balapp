import 'dart:ui';

import 'package:balapp/consts.dart';
import 'package:balapp/utils/call_apis.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/widgets/qr_code_corners.dart';
import 'package:balapp/widgets/register_ticket.dart';
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
  String? currentTicket = "XADB";
  DateTime lastScan = DateTime.now();
  List<Offset>? offsets;
  GlobalKey maskKey = GlobalKey();
  Color squareColor = kGreen;
  Rect maskRect = Rect.fromLTWH(0, 0, 0, 0);

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BuildContext? context = maskKey.currentContext;
      if(context == null) {
        throw Exception("Key not found");
      }
      RenderBox box = context.findRenderObject() as RenderBox;

      Offset offset = box.localToGlobal(Offset.zero);
      maskRect = Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    double historySize = 36.3.h;
    double scannerSize = 100.h - historySize + 20 /*Rounded corner size*/;
    return Consumer<DatabaseHolder>(builder: (context, db, _) {
      return Scaffold(
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
                      allowDuplicates: true,
                      onDetect: (barcode, args) async  {
                        if (lastScan.add(const Duration(milliseconds: 32)).isAfter(DateTime.now())) return;
                        lastScan = DateTime.now();
                        if (barcode.rawValue == null) {
                          debugPrint('Failed to scan Barcode');
                        } else {

                          final String code = barcode.rawValue!;
                          // debugPrint('Barcode found! $code');
                          // await httpCall("/ticketRegistration/ticketInfo/$code", HttpMethod.get, db.apiUrl);
                          offsets = barcode.corners!.map((e)=>e.translate(-40,-40)).toList();



                          int pointsInRect = 0;
                          for (Offset i in offsets!){
                            if(maskRect.contains(i)) pointsInRect++;
                          }
                          print(pointsInRect);

                          /*if(pointsInRect == 4) {
                            squareColor = kGreen;
                          } else if(pointsInRect == 3) {
                            squareColor = kGreenLight;
                          } else if(pointsInRect == 2) {
                            squareColor = kPurpleLight;
                          } else if(pointsInRect == 1) {
                            squareColor = kPurple;
                          } else if(pointsInRect == 0) {
                            squareColor = kRed;
                          }*/
                          if(pointsInRect < 2) return;
                          setState(() {
                            isCameraOpen = false;
                            currentTicket = code;
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
                top: 4.h,
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
                        padding: EdgeInsets.symmetric(vertical: 0.3.h, horizontal: 2.w),
                        child: Row(
                          children: [
                            CustomIconButton(
                                backgroundColor: db.isWebsocketOpen ? kWhite : kRed,
                                iconColor: db.isWebsocketOpen ? kGreen : kWhite,
                                paddingSizeDelta: -1,
                                paddingWidthDelta: -0.5,
                                icon: db.isWebsocketOpen ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                                onTap: () {}),
                            SizedBox(
                              width: 1.w,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0.4.h),
                              child: CustomIconButton(
                                  paddingSizeDelta: -1, paddingWidthDelta: -0.5, icon: Icons.search, onTap: () {}),
                            ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 0.25.h),
                              child: CustomIconButton(
                                  paddingSizeDelta: -1,
                                  paddingWidthDelta: -0.5,
                                  icon: Icons.highlight,
                                  onTap: () {}),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
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
                        color: kWhite,
                        height: 36.3.h,
                        width: 100.w,
                        child: Container() /*ScanHistory(tickets: db.lastScanned)*/)),
              ),
              if (currentTicket != null) const Positioned(bottom: 0, child: RegisterTicket()),
              // Positioned.fromRect(rect: maskRect, child: IgnorePointer(child: Container(color: Colors.amber.withOpacity(0.5),))),
              if(offsets != null)Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    size: Size(100.w, 100.h),
                    painter: QrCodePainter(offsets!, squareColor)
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
