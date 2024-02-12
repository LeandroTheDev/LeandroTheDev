import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leans/components/web_server.dart';
import 'package:provider/provider.dart';

class Dialogs {
  ///Ask for drive credentials
  static Future<void> driveCredentials(BuildContext context) {
    TextEditingController username = TextEditingController();
    TextEditingController password = TextEditingController();

    final screenSize = MediaQuery.of(context).size;

    bool sucess = false;
    Completer<void> completer = Completer<void>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Credentials"),
        content: SizedBox(
          height: screenSize.height * 0.5,
          width: screenSize.width * 0.5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                //Username
                TextField(
                  controller: username,
                ),
                //Password
                TextField(
                  controller: password,
                ),
                const SizedBox(height: 10),
                //Confirm Button
                ElevatedButton(
                    onPressed: () async {
                      loading(context);
                      WebServer.sendMessage(
                        context,
                        address: "/drive/login",
                        body: {
                          "username": username.text,
                          "password": password.text,
                        },
                      ).then(
                        (response) {
                          Navigator.pop(context);
                          if (WebServer.errorTreatment(context, response)) {
                            Provider.of<WebServer>(context, listen: false).changeToken(jsonDecode(response.body)["message"]);
                            sucess = true;
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                    child: const Text("Confirm"))
              ],
            ),
          ),
        ),
      ),
    ).then((value) => !sucess ? Navigator.pop(context) : completer.complete());
    return completer.future;
  }

  ///Show a custom alert
  static void alert(BuildContext context, {String title = "Alert", String message = ""}) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: screenSize.height * 0.5,
          width: screenSize.width * 0.5,
          child: Text(message),
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  ///Show the loading dialog
  static void loading(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          content: SizedBox(
            width: screenSize.width * 0.5,
            height: screenSize.height * 0.5,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 70),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  ///Show a prompt to user type something
  static Future<String> typeInput(BuildContext context, {title = ""}) {
    Completer<String> completer = Completer<String>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController input = TextEditingController();
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                title: Column(
                  children: [
                    TextField(
                      controller: input,
                      decoration: InputDecoration(
                        labelText: title,
                        labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary), // Cor da borda inferior quando o campo não está focado
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20),
                    ),
                    // Spacer
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => {
                        completer.complete(input.text),
                        Navigator.pop(context),
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    return completer.future;
  }

  /// Simple show a alert dialog to the user
  static Future<bool> showQuestion(
    BuildContext context, {
    String title = "",
    String content = "",
    String buttonTitle = "Yes",
    String buttonTitle2 = "No",
  }) {
    final screenSize = MediaQuery.of(context).size;
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              title: Text(title, style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
              content: Text(content, style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
              actions: [
                //yes
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    completer.complete(true);
                  },
                  child: Text(buttonTitle, style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                ),
                //no
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    completer.complete(false);
                  },
                  child: Text(buttonTitle2, style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                ),
              ],
            ),
          ),
        );
      },
    );

    return completer.future;
  }
}
