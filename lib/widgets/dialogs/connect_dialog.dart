// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../utils/init_future.dart';

Future<List?> showConnectDialog(BuildContext context, bool showSkipButton) {
  return showDialog(context: context, builder: (_) => ConnectDialog(showSkipButton: showSkipButton));
}

class ConnectDialog extends StatefulWidget {
  const ConnectDialog({Key? key, this.prefs, required this.showSkipButton}) : super(key: key);
  final SharedPreferences? prefs;
  final bool showSkipButton;

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
        if (widget.showSkipButton)
          TextButton(
              onPressed: () {
                skipButtonTap++;
                if (skipButtonTap == 7) {
                  Navigator.pop(context, "");
                }
              },
              child: const Text(
                "Skip (tap multiple times)",
                style: TextStyle(color: Colors.black38),
              )),
        TextButton(
          child: const Text("Confirm"),
          onPressed: () {
            connectToServer( context, true,
                setError: (newErr) => setState(() => error = newErr), uri: controller.text);

            /*dynamic result;
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
              // context.read<DatabaseHolder>().setLocalSever(controller.text);
              Navigator.pop(context, controller.text);
            } else {
              setState(() {
                error = resFuture<List?>ody;
              });
            }*/
          },
        )
      ],
    );
  }
}

Future<List?> connectToServer(context, bool fromPopup, {Function(String)? setError, required String uri}) async {
  WebSocketChannel channel;
  try{
    channel = WebSocketChannel.connect(Uri.parse('ws://$uri'));
  } on SocketException {
    return null;
  } catch(e,s){
    print(e);
    print(s);
    return null;
  }
  channel.stream.listen((event) async {
    String? mode;
    List? db;
    try {
      var data = jsonDecode(event);
      mode = data["mode"];
      db = data["db"] as List;
    } catch (e) {
      if (setError != null) setError("Error parsing message");
      if(!fromPopup) Navigator.pop(context);
      return;
    }
    AppMode? appMode = AppMode.getByString(mode ?? '');
    if (appMode == null) {
      if (setError != null) setError("This AppMode doesn't exist");
      if(!fromPopup) Navigator.pop(context);
      return;
    }
      Navigator.pop(context, [uri, appMode, db, channel]);
  });
  channel.sink.add('Hello!');
  if(!fromPopup) return await Navigator.push(context, MaterialPageRoute(builder: (_)=>Container()));
  if(!fromPopup) Navigator.pop(context);
  return null;
}
