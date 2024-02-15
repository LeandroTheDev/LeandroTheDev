import 'package:flutter/material.dart';

class DriveProvider extends ChangeNotifier {
  String _username = "";
  get username => _username;
  void changeUsername(value) => _username = value;

  String _token = "";
  get token => _token;
  void changeToken(value) => _token = value;
}
