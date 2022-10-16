import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomTextInput extends StatelessWidget {
  const CustomTextInput({Key? key, required this.controller, required this.label}) : super(key: key);
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zÀ-ÿ]|-|_|,", caseSensitive: false))],
          // enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
            hintText: label,
          ),
          controller: controller,
        ),
      ],
    );
  }
}
