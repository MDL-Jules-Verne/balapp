import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({Key? key, this.height=1, this.color=Colors.black}) : super(key: key);
  final double height;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: height,
      color: color,
    );
  }
}

class VerticalLine extends StatelessWidget {
  const VerticalLine({Key? key, this.width=1, this.color=Colors.black}) : super(key: key);
  final double width;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: color,

    );
  }
}
