import 'package:balapp/consts.dart';
import 'package:flutter/material.dart';

class QrCodePainter extends CustomPainter{
  List<Offset> offsets;
  Color squareColor;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = squareColor;
    Path path = Path();
    path.addPolygon(offsets, true);
    canvas.drawPath(path, paint);
    //use clipPath on a square colored container
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) {
    // TODO: implement shouldRepaint
    return offsets == oldDelegate.offsets || squareColor != oldDelegate.squareColor;
  }

  QrCodePainter(this.offsets, this.squareColor);
}