import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/browseTickets");
        },
        child: const Icon(Icons.manage_search),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              MobileScanner(
                  allowDuplicates: false,
                  onDetect: (barcode, args) {
                    if (barcode.rawValue == null) {
                      debugPrint('Failed to scan Barcode');
                    } else {
                      final String code = barcode.rawValue!;
                      debugPrint('Barcode found! $code');
                      //TODO: go to page only with valid barcode
                      // Navigator.of(context).popAndPushNamed("/registerTicket", arguments: code);
                      // Navigator.of(context).pushNamed("/registerTicket", arguments: code);
                    }
                  }),

              // Placeholder image when in dev mode to save battery
              /*Image.network(
                "https://2.bp.blogspot.com/-iod_5KRHY5Y/XPJ2SDw842I/AAAAAAAA7B4/nzszlRz0jjccxO0y5xKCcjM7ipIpTpZgACLcBGAs/s2340/Wallpapers_Xiaomi_Mi9_003.jpg",
              ),*/

              Positioned(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(0.23),
                    child: SizedBox(
                      height: 100.h,
                      width: 100.w,
                      child: Center(
                        child: ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 38,
                            cornerSmoothing: 1,
                          ),
                          child: Container(
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
            ],
          ),
        ],
      ),
    );
  }
}