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
      this.paddingWidthDelta = 0,
      this.backgroundColor = kWhite,
      this.iconColor = kBlack})
      : super(key: key);
  final IconData icon;
  final double paddingSizeDelta;
  final Color backgroundColor;
  final Color iconColor;
  final double paddingWidthDelta;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: 16,
        cornerSmoothing: 1,
      ),
      child: SizedBox(
        height: 60 + paddingSizeDelta,
        width: 60 + paddingWidthDelta + paddingSizeDelta,
        child: Material(
          color: backgroundColor,
          child: InkWell(
              splashColor: const Color(0xFFCCCCCC),
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                // color: kWhite,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              )),
        ),
      ),
    );
  }
}
