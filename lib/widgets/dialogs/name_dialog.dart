

import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget nameDialog(BuildContext context, StateSetter? setState, SharedPreferences prefs,
    {bool isIntentional = false}) {
  TextEditingController controller = TextEditingController();
  return AlertDialog(
    title: const Text("Entrez votre nom"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Est utilisé pour vérifier les connections"),
        CustomTextInput(controller: controller, label: ""),
      ],
    ),
    actions: [
      /*if (isIntentional)
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            InheritedPreferences.of(context)?.prefs.setString("scannerName", "");
            Navigator.pop(context, controller.text);
          },
        ),*/
      TextButton(
        child: const Text("Confirm"),
        onPressed: () {
          if(controller.text.isEmpty) return;
          prefs.setString("scannerName", controller.text);
          try{
            // context.read<DatabaseHolder>().setScannerName(controller.text);
          // ignore: empty_catches
          } on ProviderNotFoundException{}
          if(setState != null)setState(() {});
          else Navigator.pop(context, controller.text);
        },
      )
    ],
  );
}
Future<String?> showNameDialog(BuildContext context, SharedPreferences prefs) async {
  return await showDialog(context: context, builder: (context)=>nameDialog(context, null, prefs,));
}