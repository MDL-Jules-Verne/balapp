// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:balapp/consts.dart';
import 'package:balapp/screens/search_vestiaires.dart';
import 'package:balapp/screens/settings.dart';
import 'package:balapp/utils/database_holder.dart';
import 'package:balapp/utils/init_future.dart';
import 'package:balapp/widgets/custom_icon_button.dart';
import 'package:balapp/widgets/dialogs/lockersPopup.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../utils/call_apis.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<ButtonDetails> buttons;
  int selectedButton = 2;
  late DatabaseHolder db;

  @override
  void initState() {
    super.initState();
    db = context.read<DatabaseHolder>();
    selectedButton = db.appMode == AppMode.bal ? 2 : 1;
    buttons = [
      ButtonDetails(
          onTap: () {
            Navigator.pushNamed(context, "/scanner");
          },
          icon: Icons.qr_code_scanner_rounded),
      if (db.appMode == AppMode.bal)
        ButtonDetails(
            onTap: () async {
              DatabaseHolder db = context.read<DatabaseHolder>();
              Response result = await httpCall("/clothes/lockersList", HttpMethod.get, db.apiUrl!);
              if (result.statusCode >= 200 && result.statusCode < 299) {
                List<bool>? availableLockers =
                    await showLockerPopup(context, jsonDecode(result.body).map<Map>((e)=>e as Map).toList());
                if (availableLockers == null) return;
                List<int> allowedLockers = [];
                for (int i = 0; i < availableLockers.length; i++) {
                  if (availableLockers[i]) {
                    allowedLockers.add(i + 1);
                  }
                }
                Navigator.pushNamed(context, "/scannerLocker", arguments: allowedLockers);
              } else {
                throw Exception("Bad response from server, cannot get lockers");
              }
              // todo: offline mode
            },
            icon: Icons.checkroom),
      ButtonDetails(
          onTap: () {
            setState(() {
              selectedButton = db.appMode == AppMode.bal ? 2 : 1;
            });
          },
          icon: Icons.home_outlined),
      ButtonDetails(
          onTap: () {
            setState(() {
              selectedButton = db.appMode == AppMode.bal ? 3 : 2;
            });
          },
          icon: Icons.settings),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
         selectedButton == (db.appMode == AppMode.bal ? 2:1) ? const SearchVestiaires() : const Settings(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomNavbar(
            buttons: buttons,
            selectedButton: selectedButton,
          ),
        ),
      ],
    );
  }
}

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({Key? key, required this.buttons, required this.selectedButton}) : super(key: key);
  final List<ButtonDetails> buttons;
  final int selectedButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        color: kWhite,
        shadows: [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -2))],
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.vertical(
            top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 13, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < buttons.length; i++)
            CustomIconButton(
                iconSize: i == 1 ? 43 : 40,
                margin: EdgeInsets.fromLTRB(i == buttons.length - 1 ? 4 : 0, 0, i == 0 ? 4 : 0, 0),
                backgroundColor: i == selectedButton ? kPurpleLight : kWhite,
                paddingSizeDelta: i == 1 ? -21 : -18,
                paddingWidthDelta: 26,
                customPadding: EdgeInsets.zero,
                icon: buttons[i].icon,
                onTap: i == selectedButton ? null : buttons[i].onTap),
        ],
      ),
    );
  }
}

class ButtonDetails {
  void Function() onTap;
  IconData icon;

  ButtonDetails({required this.onTap, required this.icon});
}
