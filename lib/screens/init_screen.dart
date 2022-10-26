import 'package:balapp/widgets/connect_dialog.dart';
import 'package:balapp/widgets/name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key, required this.setState, required this.prefs}) : super(key: key);
  final StateSetter setState;
  final SharedPreferences prefs;
  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int state = 0;
  @override
  void initState(){
    Future.delayed(const Duration(), () async {
      String? name;
      while (name == null || name.isEmpty){
        name = await showDialog(context: context, builder: (_)=> nameDialog(context, null , widget.prefs));
      }
      String? ip;
      while (ip == null){
        ip = await showConnectDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
