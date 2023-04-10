import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget lockerPopup(BuildContext context, List<Map> lockers, String? overrideTitle) {
  TextEditingController controller = TextEditingController();
  List<bool> lockersCheck = lockers.map((e) => e["checked"] as bool).toList();
  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title: Text(overrideTitle ?? "Sélectionnez les vestiaires desservis"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < lockers.length; i++)
                Row(
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      value: lockersCheck[i],
                      onChanged: (bool? value) {
                        setState(() {
                          lockersCheck[i] = value!;
                        });
                      },
                    ),
                    Text(lockers[i]["displayName"])
                  ],)
            ]
        ),
        actions: [
          TextButton(
            child: const Text("Finish"),
            onPressed: lockersCheck.every((element) => !element) && overrideTitle == null ? null : (){
              Navigator.pop(context, lockersCheck);
            },
          )
        ]
        ,
      );
    }
  );
}

Future<List<bool>?> showLockerPopup(BuildContext context, List<Map> lockers,[ String? overrideTitle]) async {
  return await showDialog(context: context, builder: (context) => lockerPopup(context, lockers, overrideTitle));
}