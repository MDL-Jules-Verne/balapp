import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/prefs_inherited.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget nameDialog(BuildContext context, TextEditingController controller, StateSetter setState, SharedPreferences prefs,
    {bool isIntentional = false}) {
  return AlertDialog(
    title: const Text("Enter a name"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("We need your name to determine who scanned which ticket and avoid database conflicts"),
        CustomTextInput(controller: controller, label: ""),
      ],
    ),
    actions: [
      if (isIntentional)
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            InheritedPreferences.of(context)?.prefs.setString("scannerName", "");
            Navigator.pop(context, controller.text);
          },
        ),
      TextButton(
        child: const Text("Confirm (can't be changed again)"),
        onPressed: () {
          prefs.setString("scannerName", controller.text);
          try{
            context.read<DatabaseHolder>().setScannerName(controller.text);
          // ignore: empty_catches
          } on ProviderNotFoundException{}
          setState(() {});
        },
      )
    ],
  );
}
