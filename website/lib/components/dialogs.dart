import 'dart:async';

import 'package:flutter/material.dart';

class Dialogs {
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
  static Future<String> typeInput(BuildContext context, {String title = ""}) {
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
                    // Title
                    Text(title),
                    // Input
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
