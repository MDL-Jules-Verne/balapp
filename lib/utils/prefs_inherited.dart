import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InheritedPreferences extends InheritedWidget{
  const InheritedPreferences(this.prefs, {Key? key, required super.child}) : super(key:key );

  final SharedPreferences prefs;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
  static InheritedPreferences? of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<InheritedPreferences>();

}