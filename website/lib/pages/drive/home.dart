import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:leans/components/dialogs.dart';
import 'package:leans/components/web_server.dart';
import 'package:leans/pages/drive/provider.dart';
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

  //---------
  //Directory
  //---------
  loadDirectory() {
    WebServer.sendMessage(context, api: 'drive', address: "drive/getfolders", body: {"directory": directory}, requestType: "get").then(
      (response) {
        //Check errors
        if (WebServer.errorTreatment(context, "drive", response, isFatal: true)) {
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
              WebServer.sendMessage(context, api: "drive", address: "drive/getimages", body: {"directory": "$directory/${files[i]}"}, requestType: "get").then((response) {
                //Check errors
                if (WebServer.errorTreatment(context, "drive", response)) {
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

  //---------
  //Utils
  //---------
  checkIfIsImage(String fileName) {
    if (fileName.endsWith(".png")) return true;
    if (fileName.endsWith(".jpg")) return true;
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

  getDirectoryName() {
    int slashIndex = directory.lastIndexOf('/');
    if (slashIndex != -1) {
      return directory.substring(slashIndex + 1);
    } else {
      return directory;
    }
  }

  //---------
  //Management
  //---------
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
                  api: "drive",
                  address: 'drive/uploadfile',
                  fileBytes: result.files[i].bytes!,
                  fileName: result.files[i].name,
                  saveDirectory: directory,
                ).then(
                  (response) => {
                    //No errors? update screen
                    if (WebServer.errorTreatment(context, "drive", response)) loadDirectory(),
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

  createFolder() {
    Dialogs.typeInput(context).then(
      (folderName) => {
        WebServer.sendMessage(context, api: "drive", address: 'drive/createfolder', body: {"directory": "$directory/$folderName"}).then(
          (response) => {
            //Check errors
            if (WebServer.errorTreatment(context, "drive", response)) loadDirectory(),
          },
        )
      },
    );
  }

  delete(String itemName) {
    Dialogs.showQuestion(context, title: "Are you sure?", content: "Do you want to delete $itemName?").then(
      (value) => {
        if (value)
          WebServer.sendMessage(context, api: "drive", address: 'drive/delete', body: {"item": "$directory/$itemName"}, requestType: "delete").then(
            (response) => {
              //Check errors
              if (WebServer.errorTreatment(context, "drive", response)) loadDirectory(),
            },
          ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final driveProvider = Provider.of<DriveProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    //Check if credentials is needed
    if (!loaded && driveProvider.token == "") {
      loaded = true;
      //Ask for credentials
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Dialogs.driveCredentials(context).then(
          (response) {
            if (WebServer.errorTreatment(context, "drive", response, isFatal: true)) {
              Provider.of<DriveProvider>(context, listen: false).changeToken(jsonDecode(response.body)["message"]);
              loadDirectory();
            }
          },
        ),
      );
    }
    //If not dont ask for credentials just send a message to get folders
    else if (!loaded) {
      loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => loadDirectory());
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (directory == "") {
          Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
        } else {
          previousDirectory();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Drive"),
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            //Title Bar
            Row(
              children: [
                // Back button
                SizedBox(
                  height: 46,
                  width: 46,
                  child: directory == ""
                      ? const SizedBox(height: 10, width: 25)
                      : IconButton(
                          onPressed: () => previousDirectory(),
                          icon: const Icon(Icons.arrow_back_ios),
                        ),
                ),
                const SizedBox(width: 5),
                // Actual Directory
                SizedBox(
                  height: 24,
                  child: Text(
                    directory == "" ? "Home" : directory,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).secondaryHeaderColor,
                      width: 2.0,
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
                          child: FittedBox(
                              child: Icon(
                            Icons.folder,
                            color: Theme.of(context).secondaryHeaderColor,
                          )),
                        ),
                        //Spacer
                        const SizedBox(width: 5),
                        //Name
                        SizedBox(
                          width: screenSize.width * 0.80 - 142,
                          height: screenSize.height * 0.1,
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              folders[index],
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      height: screenSize.height * 0.1,
                      child: IconButton(
                        onPressed: () => delete(folders[index]),
                        icon: const FittedBox(child: Icon(Icons.delete, color: Colors.redAccent)),
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
                        icon: const FittedBox(child: Icon(Icons.delete, color: Colors.redAccent)),
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
      ),
    );
  }
}
