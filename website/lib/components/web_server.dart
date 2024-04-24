import 'dart:convert';
import 'dart:typed_data';

//Dependencies
import 'package:dio/dio.dart';
import 'package:leans/components/dialogs.dart';
import 'package:leans/components/utils.dart';
import 'package:http/http.dart' as http;

//Packages
import 'package:flutter/material.dart';

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
    body ??= {};

    Future<Response> getRequest() async {
      Dio sender = Dio();
      final apiProvider = Utils.getApiProvider(context, api);

      sender.options.headers = {"username": apiProvider.username, "token": apiProvider.token};
      sender.options.validateStatus = (status) {
        status ??= 504;
        return status < 500;
      };
      return await sender.get("http://$serverAddress$address", queryParameters: body).catchError(
            (error) => Response(
              statusCode: 504,
              data: {"message": error == DioException ? error.message : error.toString()},
              requestOptions: RequestOptions(),
            ),
          );
    }

    Future<Response> postRequest() async {
      Dio sender = Dio();
      final apiProvider = Utils.getApiProvider(context, api);

      sender.options.headers = {
        "content-type": 'application/json',
        "username": apiProvider.username,
        "token": apiProvider.token,
      };
      sender.options.validateStatus = (status) {
        status ??= 504;
        return status < 500;
      };
      return await sender.post("http://$serverAddress$address", data: body).catchError(
            (error) => Response(
              statusCode: 504,
              data: {"message": error == DioException ? error.message : error.toString()},
              requestOptions: RequestOptions(),
            ),
          );
    }

    Future<Response> deleteRequest() async {
      Dio sender = Dio();
      final apiProvider = Utils.getApiProvider(context, api);

      sender.options.headers = {
        "content-type": 'application/json',
        "username": apiProvider.username,
        "token": Utils.getApiProvider(context, api).token,
      };
      sender.options.validateStatus = (status) {
        status ??= 504;
        return status < 500;
      };

      return await sender.delete("http://$serverAddress$address", data: body).catchError(
            (error) => Response(
              statusCode: 504,
              data: {"message": error == DioException ? error.message : error.toString()},
              requestOptions: RequestOptions(),
            ),
          );
    }

    switch (requestType) {
      case "get":
        return await getRequest();
      case "post":
        return await postRequest();
      case "delete":
        return await deleteRequest();
      default:
        return Response(
            statusCode: 504,
            requestOptions: RequestOptions(
              data: {"message": "Invalid request type"},
            ));
    }
  }

  static Future<Response> downloadFile(
    BuildContext context, {
    required String address,
    required String api,
    Map<String, dynamic>? body,
  }) async {
    final apiProvider = Utils.getApiProvider(context, api);

    // Receive download
    http.Response result = await http.get(
      Uri.http(serverAddress, address, body),
      headers: {"username": apiProvider.username, "token": apiProvider.token},
    ).catchError((error) => http.Response(jsonEncode({"error": true, "message": "No Connection: $error"}), 504));
    return Response(
      statusCode: result.statusCode,
      data: base64Decode(result.body),
      requestOptions: RequestOptions(),
    );
  }

  /// Send a file to the drive
  ///
  /// Configs accepts:
  /// saveDirectory, fileName
  static Future<Response> sendFile(
    context, {
    required String address,
    required String api,
    required Uint8List fileBytes,
    String fileName = "temp",
    Map? configs,
  }) async {
    configs ??= {};

    Dio sender = Dio();
    final apiProvider = Utils.getApiProvider(context, api);

    sender.options.headers = {
      "content-type": 'multipart/form-data',
      "username": apiProvider.username,
      "token": apiProvider.token,
    };
    sender.options.validateStatus = (status) {
      status ??= 504;
      return status < 500;
    };

    // Creating data
    FormData formData = FormData();
    formData.fields.add(MapEntry("saveDirectory", configs["saveDirectory"]));
    formData.files.add(MapEntry(
        configs["fileName"],
        MultipartFile.fromBytes(
          fileBytes,
          filename: configs["fileName"],
        )));

    return await sender.post(
      "http://$serverAddress$address",
      data: formData,
      onSendProgress: (count, total) {
        apiProvider.uploadStatus[configs!["fileName"]] = (count / total) * 100;
      },
    ).catchError(
      (error) => Response(
        statusCode: 504,
        data: {"message": error == DioException ? error.message : error.toString()},
        requestOptions: RequestOptions(),
      ),
    );
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
        Dialogs.alert(context, title: "Temporary Banned", message: response.data["message"]);
        return false;
      //Invalid Datas
      case 403:
        checkFatal();
        Dialogs.alert(context, title: "Invalid Types", message: response.data["message"]);
        return false;
      //Wrong Credentials
      case 401:
        checkFatal();
        Utils.getApiProvider(context, api).changeToken("");
        Dialogs.alert(context, title: "Not Authorized", message: response.data["message"]);
        return false;
      case 404:
        checkFatal();
        Utils.getApiProvider(context, api).changeToken("");
        Dialogs.alert(context, title: "Not Found", message: response.data["message"]);
        return false;
      //Server Crashed
      case 500:
        checkFatal();
        Dialogs.alert(context, title: "Internal Error", message: response.data["message"]);
        return false;
      //No connection with the server
      case 504:
        checkFatal();
        Dialogs.alert(context, title: "No Connection", message: response.data["message"]);
        return false;
      //User Cancelled
      case 101:
        checkFatal();
        return false;
    }
    return true;
  }
}
