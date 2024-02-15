import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:leans/components/web_server.dart';
import 'package:leans/pages/drive/provider.dart';
import 'package:provider/provider.dart';

class Dialogs {
  ///Ask for drive credentials and update the token
  ///if the server returns the token
  static Future<Response> driveCredentials(BuildContext context) {
    TextEditingController username = TextEditingController();
    TextEditingController password = TextEditingController();

    Completer<Response> completer = Completer<Response>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Credentials",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              //Username
              TextField(controller: username, cursorColor: Theme.of(context).colorScheme.tertiary, style: Theme.of(context).textTheme.titleMedium),
              //Password
              TextField(
                controller: password,
                cursorColor: Theme.of(context).colorScheme.tertiary,
                style: Theme.of(context).textTheme.titleMedium,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Confirm Button
                  ElevatedButton(
                    onPressed: () async {
                      loading(context);
                      WebServer.sendMessage(
                        context,
                        address: "/drive/login",
                        api: "drive",
                        body: {
                          "username": username.text,
                          "password": password.text,
                        },
                      ).then(
                        (response) {
                          Provider.of<DriveProvider>(context, listen: false).changeUsername(username.text);
                          //Close Loading
                          Navigator.pop(context);
                          //Close Credentials
                          Navigator.pop(context);
                          completer.complete(response);
                        },
                      );
                    },
                    child: const Text("Confirm"),
                  ),
                  //Back Button
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, "home"),
                    child: const Text("Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      try {
        completer.complete(Response("", 101));
      } catch (_) {}
    });
    return completer.future;
  }

  ///Show a custom alert
  static void alert(BuildContext context, {String title = "Alert", String message = ""}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message, style: Theme.of(context).textTheme.titleMedium, maxLines: 99),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  ///Show the loading dialog
  static void loading(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          content: SizedBox(
            child: Padding(
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
                title: Column(
                  children: [
                    TextField(
                      controller: input,
                      cursorColor: Theme.of(context).colorScheme.tertiary,
                      style: Theme.of(context).textTheme.titleMedium,
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
              title: Text(title, style: Theme.of(context).textTheme.titleLarge),
              content: Text(content, style: Theme.of(context).textTheme.titleMedium),
              actions: [
                //yes
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    completer.complete(true);
                  },
                  child: Text(buttonTitle, style: Theme.of(context).textTheme.titleMedium),
                ),
                //no
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    completer.complete(false);
                  },
                  child: Text(buttonTitle2, style: Theme.of(context).textTheme.titleMedium),
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
