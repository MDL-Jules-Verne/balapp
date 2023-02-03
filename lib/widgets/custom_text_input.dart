import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextInput extends StatelessWidget {
  const CustomTextInput(
      {Key? key,
      required this.controller,
      this.label,
      this.formatter,
      this.callback,
      this.padding = const EdgeInsets.fromLTRB(8, 24, 12, 13),
      this.showLabelText = true, this.fontSize = 20})
      : super(key: key);
  final TextEditingController controller;
  final String? label;
  final double fontSize;
  final List<TextInputFormatter>? formatter;
  final bool showLabelText;
  final void Function(String?)? callback;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? formatterNew = formatter;
    formatterNew ??= [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]|-|_|,", caseSensitive: false))];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && showLabelText)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              label!,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        if (label != null && showLabelText)
          const SizedBox(
            height: 8,
          ),
        TextField(
          onChanged: callback,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: formatterNew,
          // enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            // border: const OutlineInputBorder(),
            contentPadding: padding,
            hintText: label,
          ),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
          controller: controller,
        ),
      ],
    );
  }
}
