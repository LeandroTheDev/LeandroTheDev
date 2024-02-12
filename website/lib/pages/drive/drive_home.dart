import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:leans/components/dialogs.dart';
import 'package:leans/components/themes.dart';
import 'package:leans/components/web_server.dart';
import 'package:provider/provider.dart';

class DriveHome extends StatefulWidget {
  const DriveHome({super.key});

  @override
  State<DriveHome> createState() => _DriveHomeState();
}

class _DriveHomeState extends State<DriveHome> {
  bool loaded = false;
  List folders = [];
  List files = [];
  String directory = "";

  Map images = {};

  askCredentials() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Dialogs.driveCredentials(context).then(
        //Send a message to get the folders
        (value) => loadDirectory(),
      ),
    );
  }

  loadDirectory() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => WebServer.sendMessage(context, address: "drive/getfolders", body: {"directory": directory}, isGet: true).then(
        (response) {
          //Check errors
          if (WebServer.errorTreatment(context, response, isFatal: true)) {
            //Load folders and files
            final data = jsonDecode(response.body)["message"];
            setState(() {
              folders = data["folders"];
              files = data["files"];
            });
            //Image Loader
            for (int i = 0; i < files.length; i++) {
              if (checkIfIsImage(files[i])) {
                //Get image
                WebServer.sendMessage(context, address: "drive/getimages", body: {"directory": "$directory/${files[i]}"}, isGet: true).then((response) {
                  //Check errors
                  if (WebServer.errorTreatment(context, response)) {
                    //Update image
                    setState(() {
                      images[files[i]] = MemoryImage(response.bodyBytes);
                    });
                  }
                });
              }
            }
          }
        },
      ),
    );
  }

  nextDirectory(String folderName) {
    directory += "/$folderName";
    loadDirectory();
  }

  previousDirectory() {
    try {
      int barrierIndex = directory.lastIndexOf('/');
      //Remove the last folder in directory variable
      directory = directory.substring(0, barrierIndex);
    } catch (error) {
      return;
    }
    loadDirectory();
  }

  checkIfIsImage(String fileName) {
    if (fileName.endsWith(".png")) return true;
    if (fileName.endsWith(".jpeg")) return true;
    return false;
  }

  imageThumbnail(String imageName) {
    if (images[imageName] == null) {
      return const CircularProgressIndicator();
    } else {
      return Image(image: images[imageName]);
    }
  }

  uploadImage() {
    try {
      FilePicker.platform.pickFiles(allowMultiple: true).then(
        (result) {
          if (result != null) {
            for (int i = 0; i < result.files.length; i++) {
              try {
                //Send selected image to the server
                WebServer.sendFile(
                  context,
                  address: 'drive/uploadfile',
                  fileBytes: result.files[i].bytes!,
                  fileName: result.files[i].name,
                  saveDirectory: directory,
                ).then(
                  (response) => {
                    //No errors? update screen
                    if (WebServer.errorTreatment(context, response)) setState(() => loaded = false),
                  },
                );
              } catch (error) {
                Dialogs.alert(context, title: "Error", message: "Cannot send the file: ${result.files[i].name} reason: $error");
              }
            }
          }
        },
      );
    } catch (error) {
      Dialogs.alert(context, message: error.toString());
    }
  }

  createFolder() async {
    await Dialogs.typeInput(context).then(
      (folderName) => {
        WebServer.sendMessage(context, address: 'drive/createfolder', body: {"directory": "$directory/$folderName"}).then(
          (response) => {
            //Check errors
            WebServer.errorTreatment(context, response),
            //Update screen
            setState(() => loaded = false),
          },
        )
      },
    );
  }

  delete(String itemName) {
    Dialogs.showQuestion(context, title: "Are you sure?", content: "Do you want to delete $itemName?").then(
      (value) => {
        if (value)
          WebServer.sendMessage(context, address: 'drive/delete', body: {"item": "$directory/$itemName"}).then(
            (response) => {
              //Check errors
              WebServer.errorTreatment(context, response),
              //Update screen
              setState(() => loaded = false),
            },
          ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themes = Themes.loadThemes(context);
    final webserver = Provider.of<WebServer>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    //Check if credentials is needed
    if (!loaded && webserver.token == "") {
      loaded = true;
      askCredentials();
    }
    //Dont ask for credentials just send a message to get folders
    else if (!loaded) {
      loaded = true;
      loadDirectory();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drive"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          //Title Bar
          Row(
            children: [
              // Back button
              IconButton(onPressed: () => previousDirectory(), icon: const Icon(Icons.arrow_back_ios)),
              // Actual Directory
              Text(
                "Home",
                style: themes["largTextTheme"],
              ),
            ],
          ),
          //Spacer
          const SizedBox(height: 15),
          //Folders
          ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(8),
              width: screenSize.width - 16,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => nextDirectory(folders[index]),
                    child: Row(children: [
                      //Icon
                      SizedBox(
                        width: screenSize.width * 0.15,
                        height: screenSize.height * 0.1,
                        child: const FittedBox(child: Icon(Icons.folder)),
                      ),
                      //Spacer
                      const SizedBox(width: 5),
                      //Name
                      SizedBox(
                        width: screenSize.width * 0.65 - 61,
                        height: screenSize.height * 0.1,
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            folders[index],
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.2,
                    height: screenSize.height * 0.1,
                    child: IconButton(
                      onPressed: () => delete(folders[index]),
                      icon: const FittedBox(child: Icon(Icons.delete)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //Files
          ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(8),
              width: screenSize.width - 16,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black, // Cor da borda
                    width: 2.0, // Espessura da borda
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Row(children: [
                      //Icon
                      SizedBox(
                        width: screenSize.width * 0.15,
                        height: screenSize.height * 0.1,
                        child: FittedBox(child: checkIfIsImage(files[index]) ? imageThumbnail(files[index]) : const Icon(Icons.file_copy)),
                      ),
                      //Spacer
                      const SizedBox(width: 5),
                      //Name
                      SizedBox(
                        width: screenSize.width * 0.65 - 61,
                        height: screenSize.height * 0.1,
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            files[index],
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.2,
                    height: screenSize.height * 0.1,
                    child: IconButton(
                      onPressed: () => delete(files[index]),
                      icon: const FittedBox(child: Icon(Icons.delete)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //Spacer
          const SizedBox(height: 15),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => uploadImage(),
                  child: const Text("Upload File"),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => createFolder(),
                  child: const Text("Create Folder"),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
