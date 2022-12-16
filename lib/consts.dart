import 'package:flutter/material.dart';

const Color kPurple = Color(0xFF8140C1);
const Color kPurpleLight = Color(0xFFC2A4E2);
const Color kGreen = Color(0xFF69C140);
const Color kGreenLight = Color(0xFF8BDC65);
const Color kRed = Color(0xFFEF3737);
const Color kBlack = Color(0xFF332A22);
const Color kWhite = Color(0xFFF2F2F2);

const int kCodesLength = 4;
const TextStyle h3 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
const TextStyle h2 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -.4);
const TextStyle bodyTitle = TextStyle(fontSize: 19, fontWeight: FontWeight.w600,letterSpacing: -.1 );
const TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.w500,  );

const Map<String, String> postHeaders = {
  "content-type": "application/json",
  "accept": "application/json",
};

String toFirstCharUpperCase(String str){
  return str.substring(0,1).toUpperCase() + str.substring(1);
}

const List<Widget> fakeWidgetArray = [SizedBox()];
