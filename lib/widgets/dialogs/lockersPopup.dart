import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget lockerPopup(BuildContext context, List<String> lockers) {
  TextEditingController controller = TextEditingController();
  List<bool> lockersCheck = [for (var i in lockers) false];
  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title: const Text("Sélectionnez les vestiaires desservis"),
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
                    Text(lockers[i])
                  ],)
            ]
        ),
        actions: [
          TextButton(
            child: const Text("Finish"),
            onPressed: lockersCheck.every((element) => !element) ? null : (){
              Navigator.pop(context, lockersCheck);
            },
          )
        ]
        ,
      );
    }
  );
}

Future<List<bool>?> showLockerPopup(BuildContext context, List<String> lockers) async {
  return await showDialog(context: context, builder: (context) => lockerPopup(context, lockers));
}