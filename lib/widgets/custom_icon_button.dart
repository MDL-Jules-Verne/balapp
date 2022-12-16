import 'package:balapp/consts.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {Key? key,
      required this.icon,
      required this.onTap,
      this.paddingSizeDelta = 0,
      this.iconSize = 30,
      this.paddingWidthDelta = 0,
      this.customPadding,
      this.margin = EdgeInsets.zero,
      this.backgroundColor = kWhite,
      this.iconColor = kBlack})
      : super(key: key);
  final IconData icon;
  final EdgeInsets margin;
  final double paddingSizeDelta;
  final Color backgroundColor;
  final EdgeInsets? customPadding;
  final Color iconColor;
  final double paddingWidthDelta;
  final Function()? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    var padding = EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h);
    return Container(
      margin: margin,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 16,
          cornerSmoothing: 1,
        ),
        child: SizedBox(
          height: 60 + paddingSizeDelta + iconSize - 30,
          width: 60 + paddingWidthDelta + paddingSizeDelta + iconSize - 30,
          child: Material(
            color: backgroundColor,
            child: InkWell(
                splashColor: const Color(0xFFCCCCCC),
                onTap: onTap,
                child: Container(
                  padding: customPadding ?? padding,
                  // color: kWhite,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: iconSize,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
