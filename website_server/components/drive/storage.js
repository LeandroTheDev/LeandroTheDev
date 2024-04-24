const fs = require("fs");
const path = require('path');
const multer = require('multer');

class DriveStorage {
    static directoryTreatment(directory) {
        const slashTest = directory.indexOf("../") !== -1 || directory.indexOf("//") !== -1 || directory.indexOf("./") !== -1;
        return slashTest;
    }

    async getFolders(req, res) {
        const directory = req.query.directory;
        const headers = req.headers;

        //Dependencies
        const database = require('./database');
        const {
            stringsTreatment,
            tokenCheckTreatment,
        } = require('./utils');

        //Errors Treatments
        if (stringsTreatment(typeof headers.username, res, "Invalid Username, why you are sending any invalid username?", 401)) return;
        if (tokenCheckTreatment(headers.token, await database.getUserToken(headers.username), res)) return;
        if (stringsTreatment(typeof directory, res, "Invalid Directory, what are you trying to do my friend?", 401)) return;
        if (DriveStorage.directoryTreatment(directory)) {
            res.status(401).send({ error: true, message: "Invalid Directory, you cannot do this alright?" });
            return;
        }
        delete require("./init").ipTimeout[req.ip];

        //Getting the program path
        const drivePath = path.resolve(__dirname, '../', '../', 'drive', headers.username);
        //Creating the folder if not exist
        fs.mkdirSync(drivePath, { recursive: true });
        //Reading folders and files
        fs.readdir(drivePath + directory, { withFileTypes: true }, (err, folder) => {
            if (err != null) {
                err = err.toString();
                if (err.includes("no such file or directory")) {
                    res.status(500).send({ error: true, message: "No such file or directory in: " + directory });
                } else {
                    res.status(500).send({ error: true, message: err });
                }
                return;
            }
            // Filter out directories
            const folders = folder.filter(item => item.isDirectory()).map(folder => folder.name);
            const files = folder.filter(item => item.isFile()).map(file => file.name);
            res.status(200).send({
                error: false, message: {
                    "folders": folders,
                    "files": files
                }
            });
        });
    }

    async getFile(req, res) {
        const directory = req.query.directory;
        const headers = req.headers;

        //Dependencies
        const database = require('./database');
        const {
            stringsTreatment,
            tokenCheckTreatment,
        } = require('./utils');

        //Errors Treatments
        if (stringsTreatment(typeof headers.username, res, "Invalid Username, why you are sending any invalid username?", 401)) return;
        if (tokenCheckTreatment(headers.token, await database.getUserToken(headers.username), res)) return;
        if (stringsTreatment(typeof directory, res, "Invalid Directory, what are you trying to do my friend?", 401)) return;
        if (DriveStorage.directoryTreatment(directory)) {
            res.status(401).send({ error: true, message: "Invalid Directory, you cannot do this alright?" });
            return;
        }
        delete require("./init").ipTimeout[req.ip];

        //Getting the image path
        let filePath = path.resolve(__dirname, '../', '../', 'drive', headers.username) + directory;
        //Returning the image
        res.status(200).send(fs.readFileSync(filePath).toString('base64'));
    }

    async createFolder(req, res) {
        function getDateTime() {
            const now = new Date();
            const hora = now.getHours();
            const dia = now.getDate();
            const mes = now.getMonth() + 1;
            const ano = now.getFullYear();
            return `${hora}h/${dia}d/${mes}m/${ano}y`;
        }
        const directory = req.body.directory;
        const headers = req.headers;

        //Dependencies
        const database = require('./database');
        const {
            stringsTreatment,
            tokenCheckTreatment,
        } = require('./utils');

        //Errors Treatments
        if (stringsTreatment(typeof headers.username, res, "Invalid Username, why you are sending any invalid username?", 401)) return;
        if (tokenCheckTreatment(headers.token, await database.getUserToken(headers.username), res)) return;
        if (stringsTreatment(typeof directory, res, "Invalid Directory, what are you trying to do my friend?", 401)) return;
        if (DriveStorage.directoryTreatment(directory)) {
            res.status(403).send({ error: true, message: "Invalid Directory, the directory must contain only letter and numbers" });
            return;
        }
        delete require("./init").ipTimeout[req.ip];

        //Getting the program path
        const drivePath = path.resolve(__dirname, '../', '../', 'drive', headers.username);
        //Create folder
        fs.mkdirSync(drivePath + directory, { recursive: true });
        console.log("[Drive Storage] " + getDateTime() + " " + headers.username + " Folder created in " + directory)
        res.status(200).send({
            error: false, message: "success"
        });
    }

    async delete(req, res) {
        console.log("okcalled");
        function getDateTime() {
            const now = new Date();
            const hora = now.getHours();
            const dia = now.getDate();
            const mes = now.getMonth() + 1;
            const ano = now.getFullYear();
            return `${hora}h/${dia}d/${mes}m/${ano}y`;
        }
        const item = req.body.item;
        const headers = req.headers;
        //Dependencies
        const database = require('./database');
        const {
            stringsTreatment,
            tokenCheckTreatment,
        } = require('./utils');

        //Errors Treatments
        if (stringsTreatment(typeof headers.username, res, "Invalid Username, why you are sending any invalid username?", 403)) return;
        if (tokenCheckTreatment(headers.token, await database.getUserToken(headers.username), res)) return;
        if (stringsTreatment(typeof item, res, "Invalid Directory, what are you trying to do my friend?", 403)) return;
        if (DriveStorage.directoryTreatment(item)) {
            res.status(401).send({ error: true, message: "Invalid Directory, you cannot do this alright?" });
            return;
        }
        delete require("./init").ipTimeout[req.ip];
        const drivePath = path.resolve(__dirname, '../', '../', 'drive', headers.username);

        let error = false;
        //If is Folder, remove it
        fs.rm(drivePath + item, { recursive: true }, (err) => {
            if (err != null) {
                err = err.toString();
                if (!err.includes("no such file or directory")) {
                    if (!error) {
                        error = true;
                        console.log("[Drive Storage] " + getDateTime() + " " + headers.username + " " + err);
                        res.status(500).send({ error: true, message: err });
                        return;
                    } else error = true;
                }
            }
            //If is File, remove it
            fs.unlink(drivePath + item, (err) => {
                if (err != null) {
                    err = err.toString();
                    if (!err.includes("no such file or directory") && !err.includes("illegal operation on a directory, unlink")) {
                        if (!error) {
                            error = true;
                            console.log("[Drive Storage] " + getDateTime() + " " + headers.username + " " + err);
                            res.status(500).send({ error: true, message: err });
                            return;
                        }
                    }
                }
                //Finish
                if (!error) {
                    console.log("[Drive Storage] " + getDateTime() + " " + headers.username + " deleted: " + item);
                    res.status(200).send({
                        error: false, message: "success"
                    });
                }
            });
        });
    }

    async upload(req, res) {
        function getDateTime() {
            const now = new Date();
            const hour = now.getHours();
            const day = now.getDate();
            const month = now.getMonth() + 1;
            const year = now.getFullYear();
            return `${hour}h/${day}d/${month}m/${year}y`;
        }
        const headers = req.headers;

        //Dependencies
        const database = require('./database');
        const {
            stringsTreatment,
            tokenCheckTreatment,
        } = require('./utils');

        //Errors Treatments
        if (stringsTreatment(typeof headers.username, res, "Invalid Username, why you are sending any invalid username?", 401)) return;
        if (tokenCheckTreatment(headers.token, await database.getUserToken(headers.username), res)) return;

        // Get save directory
        const directory = req.body.saveDirectory;

        // Swipe all files
        for (let fileIndex = 0; fileIndex < req.files.length; fileIndex++) {
            const fileName = req.files[fileIndex]["originalname"];

            //Errors check
            if (stringsTreatment(typeof directory, res, "Invalid Directory, why you are sending me a non string directory?", 401)) return;
            if (stringsTreatment(typeof fileName, res, "Invalid File Name, why you are sending me a non string file name?", 401)) return;
            if (DriveStorage.directoryTreatment(directory)) {
                res.status(401).send({ error: true, message: "Invalid Directory, you cannot do this alright?" });
                return;
            }

            //Converting the file to bytes again
            const bytes = req.files[fileIndex]["buffer"];
            //Getting the save path
            const fileSavePath = path.resolve(__dirname, '../', '../', 'drive', headers.username) + directory;
            try {
                //Saving in the disk
                fs.writeFileSync(path.join(fileSavePath, fileName), bytes);
                delete require("./init").ipTimeout[req.ip];
                console.log("[Drive Storage] " + getDateTime() + " " + directory + "/" + fileName + " received from: " + headers.username)
                res.status(200).send({
                    error: false, message: "success"
                });
            } catch (error) {
                res.status(400).send({
                    error: true, message: error
                });
            }
        }
    }

    instanciateDrive(http, timeoutFunction) {
        this.resetIpTimeout = timeoutFunction;

        //Get
        http.get('/drive/getfolders', this.getFolders);
        http.get('/drive/getfile', this.getFile);

        //Post
        http.post('/drive/createfolder', this.createFolder);
        http.post('/drive/uploadfile', multer().any(), this.upload);

        //Delete
        http.delete('/drive/delete', this.delete);
    }
}

module.exports = new DriveStorage;