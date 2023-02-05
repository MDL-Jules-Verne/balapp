

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../utils/init_future.dart';

Future<List?> showConnectDialog(BuildContext context, [String? presetIp]) {
  return showDialog(context: context, builder: (_) => ConnectDialog(presetIp: presetIp));
}

class ConnectDialog extends StatefulWidget {
  const ConnectDialog({Key? key, this.prefs, required this.presetIp}) : super(key: key);
  final SharedPreferences? prefs;
  final String? presetIp;


  @override
  State<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  TextEditingController controller = TextEditingController();
  String? error;
  int skipButtonTap = 0;

  @override
  void initState(){
    super.initState();
    controller.text = widget.presetIp ?? "";
  }

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
            formatter: [FilteringTextInputFormatter.deny(" ") ],
            padding: const EdgeInsets.fromLTRB(8, 13, 12, 13),
          ),
          if (error != null)
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
            )
        ],
      ),
      actions: [
          TextButton(
              onPressed: () {
                skipButtonTap++;
                if (skipButtonTap == 7) {
                  Navigator.pop(context, []);
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
                setError: (newErr) => setState(() => error = newErr), uri: Uri.parse("ws://${controller.text}"));

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

Future<List?> connectToServer(context, bool fromPopup, {Function(String)? setError, required Uri uri}) async {


  WebSocketChannel channel;
  try{
      channel = WebSocketChannel.connect(uri);
  } on SocketException {
    return null;
  } catch(e,s){
    print(e);
    print(s);
    return null;
  }
  StreamSubscription? sub;
  Stream broadcast = channel.stream.asBroadcastStream();
  sub = broadcast.listen((event) async {
    if(event == "testConnection") return;
    String? mode;
    List? db;
    try {
      var data = jsonDecode(event);
      mode = data["mode"];
      db = data["db"] as List;
    } catch (e) {
      print(e);
      if (setError != null) setError("Error parsing message");
      channel.sink.close();
      if(!fromPopup) Navigator.pop(context);
      return;
    }
    AppMode? appMode = AppMode.getByString(mode ?? '');
    if (appMode == null) {
      channel.sink.close();
      if (setError != null) setError("This AppMode doesn't exist");
      if(!fromPopup) Navigator.pop(context);
      return;
    }
      sub?.cancel();
      channel.sink.close();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("serverUrl", uri.toString());
      Navigator.pop(context, [uri, appMode, db, channel, broadcast]);
  });
  channel.sink.add('hello');
  if(!fromPopup) {
    return await Navigator.push(context,  PageRouteBuilder(opaque: false,pageBuilder: (_, __, ___) => Container(),
  ),);
  }
  return null;
}
