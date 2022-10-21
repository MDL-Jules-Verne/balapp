import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({Key? key, this.height=1, this.color=Colors.black}) : super(key: key);
  final int height;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 1,
      color: color,
    );
  }
}
