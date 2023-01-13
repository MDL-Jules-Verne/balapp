import 'package:balapp/consts.dart';
import 'package:balapp/screens/settings.dart';
import 'package:balapp/widgets/custom_icon_button.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<ButtonDetails> buttons;
  int selectedButton = 1;

  @override
  void initState() {
    super.initState();
    buttons = [
      ButtonDetails(
          onTap: () {
            Navigator.pushNamed(context, "/scanner");
          },
          icon: Icons.qr_code_scanner),
      ButtonDetails(
          onTap: () {
            setState(() {
              selectedButton = 1;
            });
          },
          icon: Icons.home_outlined),
      ButtonDetails(
          onTap: () {
            setState(() {
              selectedButton = 2;
            });
          },
          icon: Icons.settings),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhite,
        body: selectedButton == 1 ? Container() : const Settings(),
        bottomNavigationBar: BottomNavbar(
          buttons: buttons,
          selectedButton: selectedButton,
        ));
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
              borderRadius: SmoothBorderRadius.vertical(top: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1)))),
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
