import 'package:balapp/utils/prefs_inherited.dart';
import 'package:balapp/widgets/custom_text_input.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

showConnectDialog(BuildContext context,) {
  TextEditingController controller = TextEditingController();
  return showDialog(context: context, builder: (_){

    String? error;
    return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Local connect"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter IP address of local server"),
                CustomTextInput(controller: controller, label: "", disableFormatter: true,),
                if(error != null) Text(error!, style: const TextStyle(color: Colors.red),)
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Confirm"),
                onPressed: () async {
                  dynamic result;
                  try{
                    result = await http.get(Uri.parse("http://${controller.text}/testConnection")).timeout(const Duration(seconds: 3), onTimeout: ()=>http.Response("Timeout", 400));
                  }catch(e){
                    setState((){
                      print(e);
                      error = e.toString();
                    });
                    return;
                  }
                  if(result.statusCode >= 200 && result.statusCode < 299) {
                    // ignore: use_build_context_synchronously
                    InheritedPreferences.of(context)?.prefs.setString("localServer", controller.text);
                    Navigator.pop(context);

                  } else {
                    setState((){
                      error = result.body;
                    });
                  }
                },
              )
            ],
          );
        }
    );
  });

}
