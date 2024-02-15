import 'package:flutter/material.dart';
import 'package:leans/pages/drive/provider.dart';
import 'package:provider/provider.dart';

class Utils {
  static getApiProvider(BuildContext context, String api) {
    switch (api) {
      case "drive":
        return Provider.of<DriveProvider>(context, listen: false);
      default:
        throw "API $api not found";
    }
  }
}
