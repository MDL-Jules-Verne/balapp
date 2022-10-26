// ignore_for_file: use_build_context_synchronously

import 'package:balapp/utils/db.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:balapp/widgets/prefs_inherited.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> showConnectDialog(
  BuildContext context,
) {
  return showDialog(context: context, builder: (_) => const ConnectDialog());
}

class ConnectDialog extends StatefulWidget {
  const ConnectDialog({Key? key, this.prefs}) : super(key: key);
  final SharedPreferences? prefs;

  @override
  State<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  TextEditingController controller = TextEditingController();
  String? error;
  int skipButtonTap = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Local connect"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter IP address of local server"),
          CustomTextInput(
            controller: controller,
            label: "",
            disableFormatter: true,
          ),
          if (error != null)
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
            )
        ],
      ),
      actions: [
        TextButton(onPressed: () {
          skipButtonTap ++;
          if(skipButtonTap == 7){
            Navigator.pop(context, "");
          }
        }, child: const Text("Skip (tap multiple times)", style:  TextStyle(color: Colors.white70),)),
        TextButton(
          child: const Text("Confirm"),
          onPressed: () async {
            dynamic result;
            try {
              result = await http
                  .get(Uri.parse("http://${controller.text}/testConnection"))
                  .timeout(const Duration(seconds: 3), onTimeout: () => http.Response("Timeout", 400));
            } catch (e) {
              setState(() {
                print(e);
                error = e.toString();
              });
              return;
            }
            if (result.statusCode >= 200 && result.statusCode < 299) {
              if (widget.prefs != null) {
                widget.prefs!.setString("localServer", controller.text);
              } else {
                InheritedPreferences.of(context)?.prefs.setString("localServer", controller.text);
              }
              context.read<DatabaseHolder>().setLocalSever(controller.text);
              Navigator.pop(context, controller.text);
            } else {
              setState(() {
                error = result.body;
              });
            }
          },
        )
      ],
    );
  }
}
