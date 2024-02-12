import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:leans/components/dialogs.dart';
import 'package:path/path.dart';

import 'package:provider/provider.dart';

class WebServer extends ChangeNotifier {
  static const serverAddress = 'localhost:7979';

  String _token = "";
  get token => _token;
  void changeToken(value) => _token = value;

  ///Comunicates the server via http request and return a Map with the server response
  ///
  ///Example Post:
  ///```dart
  ///sendServerMessage("/login", { username: "test", password: "123" })
  ///```
  ///
  ///Example Get:
  ///```dart
  ///sendServerMessage("/status")
  ///```
  static Future<Response> sendMessage(context, {required String address, Map<String, dynamic>? body, bool isGet = false}) async {
    Response? result;
    //Get Response
    if (isGet) {
      try {
        result = await get(
          Uri.http(serverAddress, address, body),
          headers: {"Authorization": Provider.of<WebServer>(context, listen: false).token},
        );
      } catch (error) {
        if (result == null) {
          return Response(jsonEncode({"error": true, "message": "No Connection: $error"}), 504);
        }
        return result;
      }
      return result;
    }
    //Post Response
    else {
      try {
        result = await post(
          Uri.http(serverAddress, address),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            "Authorization": Provider.of<WebServer>(context, listen: false).token,
          },
          body: jsonEncode(body),
        );
      } catch (error) {
        if (result == null) {
          return Response(jsonEncode({"error": true, "message": "No Connection: $error"}), 504);
        }
        return result;
      }
      return result;
    }
  }

  ///Send a file to the drive
  static Future<Response> sendFile(
    context, {
    required String address,
    required Uint8List fileBytes,
    required String fileName,
    required String saveDirectory,
  }) async {
    Map<String, String> headers = {
      "Content-type": "application/octet-stream",
      "Authorization": Provider.of<WebServer>(context, listen: false).token,
    };
    // Converting Bytes to File
    String fileEncoded = base64Encode(fileBytes);
    Map<String, dynamic> body = {
      "file": fileEncoded,
      "saveDirectory": saveDirectory,
      "fileName": fileName,
    };
    String sendBody = jsonEncode(body);
    try {
      // Upload to the server
      var response = await post(Uri.http(serverAddress, address), headers: headers, body: sendBody);
      return response;
    } catch (error) {
      return Response(jsonEncode({"message": error}), 400);
    }
  }

  ///Returns true if no error occurs, fatal erros return to home screen
  static bool errorTreatment(BuildContext context, Response response, {bool isFatal = false}) {
    checkFatal() {
      if (isFatal) {
        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        Provider.of<WebServer>(context, listen: false).changeToken("");
      }
    }

    switch (response.statusCode) {
      case 413:
        checkFatal();
        Dialogs.alert(context, title: "Temporary Banned", message: jsonDecode(response.body)["message"]);
        return false;
      case 403:
        checkFatal();
        Dialogs.alert(context, title: "Invalid Types", message: jsonDecode(response.body)["message"]);
        return false;
      case 401:
        checkFatal();
        Provider.of<WebServer>(context, listen: false).changeToken("");
        Dialogs.alert(context, title: "Wrong Credentials", message: jsonDecode(response.body)["message"]);
        return false;
      case 500:
        checkFatal();
        Dialogs.alert(context, title: "Internal Error", message: jsonDecode(response.body)["message"]);
        return false;
      case 504:
        checkFatal();
        Dialogs.alert(context, title: "No Connection", message: jsonDecode(response.body)["message"]);
        return false;
    }
    return true;
  }
}
