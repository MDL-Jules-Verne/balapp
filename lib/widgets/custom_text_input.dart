import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextInput extends StatelessWidget {
  const CustomTextInput({Key? key, required this.controller, required this.label, this.showTopLabel = true, this.disableFormatter=false, this.callback}) : super(key: key);
  final TextEditingController controller;
  final String label;
  final bool showTopLabel;
  final bool disableFormatter;
  final void Function(String?)? callback;

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(showTopLabel) Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        if(showTopLabel) const SizedBox(
          height: 8,
        ),
        TextField(
          onChanged: callback,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: [if (!disableFormatter) FilteringTextInputFormatter.allow(RegExp("[a-zÀ-ÿ]|-|_|,", caseSensitive: false))],
          // enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            // border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.fromLTRB(8, 24, 12, 13),
            hintText: label,

          ),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          controller: controller,
        ),
      ],
    );
  }
}
