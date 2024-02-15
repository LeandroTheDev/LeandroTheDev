import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

//Dependencies
import 'package:leans/components/dialogs.dart';
import 'package:leans/components/utils.dart';

//Packages
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class WebServer {
  static const serverAddress = 'localhost:7979';

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
  static Future<Response> sendMessage(
    BuildContext context, {
    required String address,
    required String api,
    Map<String, dynamic>? body,
    String requestType = "post",
  }) async {
    Future<Response> getRequest() async {
      Response? result;
      try {
        final apiProvider = Utils.getApiProvider(context, api);
        result = await get(
          Uri.http(serverAddress, address, body),
          headers: {"username": apiProvider.username, "token": apiProvider.token},
        );
      } catch (error) {
        if (result == null) {
          return Response(jsonEncode({"error": true, "message": "No Connection: $error"}), 504);
        }
        return result;
      }
      return result;
    }

    Future<Response> postRequest() async {
      Response? result;
      try {
        final apiProvider = Utils.getApiProvider(context, api);
        result = await post(
          Uri.http(serverAddress, address),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            "username": apiProvider.username,
            "token": apiProvider.token,
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

    Future<Response> deleteRequest() async {
      Response? result;
      try {
        final apiProvider = Utils.getApiProvider(context, api);
        result = await delete(
          Uri.http(serverAddress, address),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            "username": apiProvider.username,
            "token": Utils.getApiProvider(context, api).token,
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

    switch (requestType) {
      case "get":
        return await getRequest();
      case "post":
        return await postRequest();
      case "delete":
        return await deleteRequest();
      default:
        return Response(jsonEncode({"error": true, "message": "Request Type not found"}), 401);
    }
  }

  ///Send a file to the drive
  static Future<Response> sendFile(
    context, {
    required String address,
    required String api,
    required Uint8List fileBytes,
    required String fileName,
    required String saveDirectory,
  }) async {
    Map<String, String> headers = {
      "Content-type": "application/octet-stream",
      "username": Utils.getApiProvider(context, api).username,
      "token": Utils.getApiProvider(context, api).token,
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
  static bool errorTreatment(BuildContext context, String api, Response response, {bool isFatal = false}) {
    checkFatal() {
      if (isFatal) {
        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        Utils.getApiProvider(context, api).changeToken("");
      }
    }

    switch (response.statusCode) {
      //Temporary Banned
      case 413:
        checkFatal();
        Dialogs.alert(context, title: "Temporary Banned", message: jsonDecode(response.body)["message"]);
        return false;
      //Invalid Datas
      case 403:
        checkFatal();
        Dialogs.alert(context, title: "Invalid Types", message: jsonDecode(response.body)["message"]);
        return false;
      //Wrong Credentials
      case 401:
        checkFatal();
        Utils.getApiProvider(context, api).changeToken("");
        Dialogs.alert(context, title: "Wrong Credentials", message: jsonDecode(response.body)["message"]);
        return false;
      //Server Crashed
      case 500:
        checkFatal();
        Dialogs.alert(context, title: "Internal Error", message: jsonDecode(response.body)["message"]);
        return false;
      //No connection with the server
      case 504:
        checkFatal();
        Dialogs.alert(context, title: "No Connection", message: jsonDecode(response.body)["message"]);
        return false;
      //User Cancelled
      case 101:
        checkFatal();
        return false;
    }
    return true;
  }
}
