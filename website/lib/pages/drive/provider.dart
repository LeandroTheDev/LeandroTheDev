import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:leans/components/dialogs.dart';
import 'package:leans/components/web_server.dart';

class DriveProvider extends ChangeNotifier {
  String _username = "";
  String get username => _username;
  void changeUsername(value) => _username = value;

  String _token = "";
  String get token => _token;
  void changeToken(value) => _token = value;

  List _folders = [];
  List get folders => _folders;
  void changeFolders(value) => _folders = value.map((e) => e.toString()).toList();

  List _files = [];
  List get files => _files;
  void changeFiles(value) => _files = value;

  String _directory = "";
  String get directory => _directory;
  void changeDirectory(value) => _directory = value;

  Map<String, MemoryImage> _cacheImages = {};
  Map<String, MemoryImage> get cacheImages => _cacheImages;
  void changeCacheImages(value) => _cacheImages = value;
  void addImageToCache(String key, MemoryImage value) => _cacheImages[key] = value;

  Map _cacheVideos = {};
  Map get cacheVideos => _cacheVideos;
  void changeCacheVideos(value) => _cacheVideos = value;

  Map<String, double> _uploadStatus = {};
  Map<String, double> get uploadStatus => _uploadStatus;
  void changeUploadStatus(value) => _uploadStatus = value;
  void updateKeyUploadStatus(String key, double value) => _uploadStatus[key] = value;

  //
  //#region Directory Managment
  //
  /// Ask for the server the new contents from the actual directory
  Future refreshDirectory(BuildContext context) {
    DriveUtils.log("---Refreshing directory---");
    return WebServer.sendMessage(context, api: 'drive', address: "/drive/getfolders", body: {"directory": directory}, requestType: "get").then(
      (response) {
        DriveUtils.log("Finished with code: ${response.statusCode}");
        // Check errors
        if (WebServer.errorTreatment(context, "drive", response, isFatal: false)) {
          DriveUtils.log("No errors occurs, proceeding to the data");

          // Load folders and files
          final data = response.data["message"];

          DriveUtils.log("Folders quantity: ${data["folders"].length}");
          DriveUtils.log("Files quantity: ${data["files"].length}");

          changeFolders(data["folders"]);
          changeFiles(data["files"]);

          DriveUtils.log("Loading images from file if exists");

          // Image Loader
          for (int i = 0; i < files.length; i++) {
            if (DriveUtils.checkIfIsImage(files[i])) {
              DriveUtils.log("Image in file $i detected, downloading thumbnail...");
              // Get image
              WebServer.downloadFile(context, api: "drive", address: "/drive/getfile", body: {"directory": "$directory/${files[i]}"}).then((response) {
                // Check errors
                if (WebServer.errorTreatment(context, "drive", response)) {
                  // Add the image received to image cache
                  addImageToCache(files[i], MemoryImage(response.data));
                  notifyListeners();

                  DriveUtils.log("Image file $i thumbnail finished downloading");
                }
              });
            }
          }
        }
        notifyListeners();
      },
    );
  }

  /// Change the actual directory and refresh the directories
  nextDirectory(BuildContext context, int folderIndex) {
    String? folderName = folders[folderIndex];
    // ignore: unnecessary_null_comparison
    if (folderName == null) {
      // Wtf flutter compiler? how this cannot be null?
      Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
      Dialogs.alert(context, title: "Ops", message: "Something goes wrong when you try to change the directory, if the error persist please contact LeandroTheDev");
    }
    _directory += "/$folderName";
    refreshDirectory(context);
  }

  /// Go to previous directory and refresh the directories
  previousDirectory(BuildContext context) {
    try {
      int barrierIndex = _directory.lastIndexOf('/');
      //Remove the last folder in directory variable
      _directory = _directory.substring(0, barrierIndex);
    } catch (error) {
      return;
    }
    refreshDirectory(context);
  }

  /// Returns the final part of the directory
  getDirectoryName() {
    int slashIndex = _directory.lastIndexOf('/');
    if (slashIndex != -1) {
      return _directory.substring(slashIndex + 1);
    } else {
      return _directory;
    }
  }

  /// Creates a new folder on the actual directory
  createFolder(BuildContext context) {
    Dialogs.typeInput(context).then(
      (folderName) => {
        WebServer.sendMessage(context, api: "drive", address: 'drive/createfolder', body: {"directory": "$_directory/$folderName"}).then(
          (response) => {
            //Check errors
            if (WebServer.errorTreatment(context, "drive", response)) refreshDirectory(context),
          },
        )
      },
    );
  }

  /// Delete a folder or file from the actual directory
  delete(BuildContext context, String itemName) {
    Dialogs.showQuestion(context, title: "Are you sure?", content: "Do you want to delete $itemName?").then(
      (value) => {
        if (value)
          WebServer.sendMessage(context, api: "drive", address: '/drive/delete', body: {"item": "$_directory/$itemName"}, requestType: "delete").then(
            (response) => {
              //Check errors
              if (WebServer.errorTreatment(context, "drive", response)) refreshDirectory(context),
            },
          ),
      },
    );
  }
  //
  //#endregion Directory Managment
  //

  //
  //#region Directory Data
  //

  /// Get the image thumbnail widget by the file name,
  /// if not exist yet will return a progress indicator widget
  Widget getImageThumbnail(String fileName) {
    if (_cacheImages[fileName] == null) {
      return const CircularProgressIndicator();
    } else {
      return Image(image: _cacheImages[fileName]!);
    }
  }

  /// Upload a file to the actual directory
  uploadFile(BuildContext context) {
    try {
      Dialogs.loading(context);
      FilePicker.platform.pickFiles(allowMultiple: true).then(
        (result) {
          if (result != null) {
            DriveUtils.log("Total files to be send: ${result.files.length}");
            Navigator.pop(context);

            int filesCompleted = 0;
            for (int i = 0; i < result.files.length; i++) {
              try {
                // Null bytes treatment
                if (result.files[i].bytes == null) throw "File not found";

                // Update upload status for the file
                _uploadStatus[result.files[i].name] = 0;
                notifyListeners();

                // Send selected image to the server
                WebServer.sendFile(
                  context,
                  api: "drive",
                  address: '/drive/uploadfile',
                  fileBytes: result.files[i].bytes!,
                  configs: {"fileName": result.files[i].name, "saveDirectory": directory},
                ).then(
                  (response) {
                    filesCompleted++;

                    // Update upload status for the file
                    _uploadStatus[result.files[i].name] = 100;

                    DriveUtils.log("File send finished with code: ${response.statusCode}, remaining: $filesCompleted/${result.files.length}");

                    // Check for errors
                    WebServer.errorTreatment(context, "drive", response);

                    // If the total files finished, refresh the directory
                    if (filesCompleted == result.files.length) refreshDirectory(context);
                  },
                );
              } catch (error) {
                _uploadStatus[result.files[i].name] = -1;
                Dialogs.alert(context, title: "Error", message: "Cannot send the file: ${result.files[i].name} reason: $error");
              }
            }
          } else {
            Navigator.pop(context);
          }
        },
      );
    } catch (error) {
      Dialogs.alert(context, message: "Cannot upload files, reason: $error");
    }
  }
  //
  //#endregion
  //
}

class DriveUtils {
  /// Simple check the last string characters for matching files
  static checkIfIsImage(String fileName) {
    if (fileName.endsWith(".png")) return true;
    if (fileName.endsWith(".jpg")) return true;
    if (fileName.endsWith(".jpeg")) return true;
    return false;
  }

  static log(String message) {
    // ignore: avoid_print
    print(message);
  }
}
