import 'package:flutter/material.dart';
import 'package:leans/components/dialogs.dart';
import 'package:leans/components/web_server.dart';
import 'package:leans/pages/larita/provider.dart';
import 'package:provider/provider.dart';

class LaritaHome extends StatefulWidget {
  const LaritaHome({super.key});

  @override
  State<LaritaHome> createState() => _LaritaHomeState();
}

class _LaritaHomeState extends State<LaritaHome> {
  TextEditingController userInput = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool loaded = false;
  bool processingMessage = false;

  @override
  void initState() {
    super.initState();
    userInput.addListener(() => setState(() => userInput));
  }

  @override
  void dispose() {
    super.dispose();
    userInput.dispose();
    scrollController.dispose();
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    LaritaProvider larita = Provider.of<LaritaProvider>(context, listen: true);
    Size screenSize = MediaQuery.of(context).size;

    //Check if credentials is needed
    if (!loaded && larita.token == "") {
      loaded = true;
      larita.changeUserMessages([
        {
          "Sender": "Larita",
          "EmotionalType": "neutral",
          "Message": "Hello :D, how i can help you today?",
          "Failed": false,
        }
      ]);
      //Ask for credentials
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Dialogs.laritaCredentials(context).then(
          (response) {
            if (WebServer.errorTreatment(context, "larita", response, isFatal: true)) {
              LaritaUtils.log("No errors in credentials, updating token");
              larita.changeToken(response.data["message"]);
            }
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(larita.laritaEmotionalState, style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
          },
        ),
      ),
      body: Column(
        children: [
          // Messages Box
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemCount: processingMessage ? larita.chatMessages.length + 1 : larita.chatMessages.length,
                itemBuilder: (context, index) {
                  // Loading widget
                  if (index + 1 > larita.chatMessages.length)
                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            padding: const EdgeInsets.all(15),
                            // Decoration
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: larita.laritaEmotionalColors["neutral"],
                            ),
                            // Message
                            child: const CircularProgressIndicator()),
                      ),
                    );
                  // Message box
                  else
                    return Align(
                      alignment: larita.getMessageAlign(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          // Decoration
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: larita.getMessageBoxColor(index),
                          ),
                          // Message
                          child: larita.chatMessages[index]["Message"]!.isEmpty
                              ? const CircularProgressIndicator()
                              : Text(
                                  larita.chatMessages[index]["Message"]!,
                                  style: larita.chatMessages[index]["Failed"] ? const TextStyle(color: Color.fromARGB(255, 150, 63, 56), fontSize: 16, overflow: TextOverflow.ellipsis) : Theme.of(context).textTheme.titleMedium,
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                ),
                        ),
                      ),
                    );
                },
              ),
            ),
          ),
          // Input Box
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: larita.laritaEmotionalColors["neutral"]),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Type input
                    SizedBox(
                      width: screenSize.width - 128,
                      child: TextField(
                        enabled: !processingMessage,
                        controller: userInput,
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: InputDecoration(
                          hintText: "Talk Here",
                          hintStyle: Theme.of(context).textTheme.titleMedium,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                    // Send File Button
                    IconButton(
                      icon: const Icon(Icons.file_open),
                      onPressed: processingMessage
                          ? null
                          : () {
                              Dialogs.alert(context, title: "Not yet...", message: "This features is not available yet");
                            },
                    ),
                    // Send Message Button
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: processingMessage || userInput.text.isEmpty
                          ? null
                          : () async {
                              LaritaUtils.log("Sending message");
                              String message = userInput.text;
                              userInput.clear();
                              larita.addMessages({
                                "Sender": "User",
                                "Emotional": "neutral",
                                "EmotionalType": null,
                                "Message": message,
                                "Failed": false,
                              });
                              setState(() => processingMessage = true);
                              scrollToBottom();
                              bool success = await larita.sendMessage(context, message);
                              success ? LaritaUtils.log("Message success") : LaritaUtils.log("Message failed");
                              setState(() => processingMessage = false);
                              LaritaUtils.log("Screen refreshed");
                              scrollToBottom();
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
