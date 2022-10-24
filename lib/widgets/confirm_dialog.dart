import 'package:balapp/widgets/prefs_inherited.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> showConfirmDialog(BuildContext context, String action, String description, Function callback) async {
  bool? isConfirmed = await showDialog(context: context, builder: (_) => AlertDialog(
    title: Text(action),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(description),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: const Text("Annuler", style: TextStyle(color: Colors.red),),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: const Text('Continuer', style: TextStyle(color: Colors.green),),

      )
    ],
  ));

  if(isConfirmed == true){
    callback();
  }
}
