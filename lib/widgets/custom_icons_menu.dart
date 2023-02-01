import 'package:balapp/consts.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/widgets/dialogs/connect_dialog.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'custom_icon_button.dart';

class CustomIconsMenu extends StatelessWidget {
  const CustomIconsMenu({Key? key, required this.db, required this.scanControl, required this.setLightState, required this.showSearchPanel}) : super(key: key);
  final DatabaseHolder db;
  final MobileScannerController scanControl;
  final void Function(bool) setLightState;
  final void Function()? showSearchPanel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                        onTap: () async {
                          //[uri, appMode, db, channel, broadcast]
                          db.niceWsClose();
                          List? wsData = await showConnectDialog(context, true, db.apiUrl.authority);
                          if(wsData == null) return;
                          db.resetDb(wsData[2], wsData[0], );
                        }),
                    if(showSearchPanel != null)CustomIconButton(
                        paddingSizeDelta: - 8, icon: Icons.search, onTap: () {
                          showSearchPanel!();
                    }),
                    ValueListenableBuilder(
                        valueListenable: scanControl.torchState,
                        builder: (context, state, _) {
                          return CustomIconButton(
                              paddingSizeDelta: - 8,
                              icon: Icons.highlight,
                              iconColor: state == TorchState.on ? kGreenLight : kBlack,
                              onTap: () async {
                                scanControl.toggleTorch();

                                if (state == TorchState.on) {
                                  setLightState(false);
                                } else {
                                  setLightState(true);
                                }
                              });
                        }),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
