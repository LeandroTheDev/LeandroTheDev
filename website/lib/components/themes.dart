import 'package:flutter/material.dart';

///Themes functions to help during the interface build
class Themes {
  ///Load all themes from the device and return a simple map containg all themes
  ///
  ///largTextTheme
  static Map<String, dynamic> loadThemes(BuildContext context) {
    Map<String, dynamic> themes = {};
    themes["largTextTheme"] = Theme.of(context).textTheme.titleLarge;
    return themes;
  }
}
