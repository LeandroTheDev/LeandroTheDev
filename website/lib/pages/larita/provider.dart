import 'package:flutter/material.dart';

class LaritaProvider extends ChangeNotifier {
  String _username = "";
  String get username => _username;
  void changeUsername(value) => _username = value;

  String _token = "";
  String get token => _token;
  void changeToken(value) => _token = value;
}

class LaritaUtils {
  static log(String message) {
    // ignore: avoid_print
    print(message);
  }
}
