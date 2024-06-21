import 'package:flutter/material.dart';
import 'package:leans/components/web_server.dart';

class LaritaProvider extends ChangeNotifier {
  int apiPorts = 7878;

  String _username = "anonymous";
  String get username => _username;
  void changeUsername(value) => _username = value;

  String _token = "";
  String get token => _token;
  void changeToken(value) => _token = value;

  String _laritaEmotionalState = "Larita";
  String get laritaEmotionalState => _laritaEmotionalState;
  void changeLaritaEmotionalState(String value) => _laritaEmotionalState = value;

  Map<String, Color> laritaEmotionalColors = {
    "neutral": Colors.grey,
    "happy": const Color.fromARGB(255, 54, 161, 58),
    "veryhappy": const Color.fromARGB(255, 64, 179, 67),
    "ultrahappy": const Color.fromARGB(255, 73, 204, 77),
  };

  Color getMessageBoxColor(int index) {
    Color? color = laritaEmotionalColors[chatMessages[index]["EmotionalType"]];
    if (color == null)
      return laritaEmotionalColors["neutral"]!;
    else
      return color;
  }

  Alignment getMessageAlign(int index) {
    if (chatMessages[index]["Sender"] == "Larita")
      return Alignment.centerLeft;
    else
      return Alignment.centerRight;
  }

  List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  void changeUserMessages(List<Map<String, dynamic>> value) => _chatMessages = value;
  void addMessages(Map<String, dynamic> value) => _chatMessages.add(value);

  Future<bool> sendMessage(BuildContext context, String message) {
    return WebServer.sendMessage(context, address: "/chatbot/generatePrompt", api: "larita", requestType: "post", body: {
      "Message": message,
    }).then((response) {
      //Check errors
      if (WebServer.errorTreatment(context, "larita", response)) {
        // Adding the Larita message
        addMessages({
          "Sender": "Larita",
          "EmotionalType": "neutral",
          "Message": "",
          "Failed": false,
        });
        Future.doWhile(() async {
          return WebServer.sendMessage(context, address: "/chatbot/receivePrompt", api: "larita", requestType: "get").then((messageResponse) async {
            // Stop if returned errors
            if (!WebServer.errorTreatment(context, "larita", messageResponse)) return false;

            // API Errors
            if (messageResponse.data["Error"] == true) {
              _chatMessages[_chatMessages.length - 1]["Failed"] = true;
              _chatMessages[_chatMessages.length - 1]["Message"] = messageResponse.data["Message"] ?? "Invalid Error";
              notifyListeners();
              return false;
            }

            if (messageResponse.data["Message"] != null) {
              _chatMessages[_chatMessages.length - 1]["Message"] += messageResponse.data["Message"];
              notifyListeners();
            }

            // Stop if finished
            if (messageResponse.data["IsOver"]) return false;

            // If the message is null is because the IA is too busy
            if (messageResponse.data["Message"] == null) await Future.delayed(Durations.short4);

            return true;
          });
        });
        return true;
      } else
        return false;
    });
  }
}

class LaritaUtils {
  static log(String message) {
    // ignore: avoid_print
    print("[Larita] $message");
  }
}
