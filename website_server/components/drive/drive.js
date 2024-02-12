const fs = require("fs");
const path = require('path');
const multer = require('multer');
const { getToken } = require('./authentication');

///Returns date time
function getDateTime() {
    const now = new Date();
    const hora = now.getHours();
    const dia = now.getDate();
    const mes = now.getMonth() + 1;
    const ano = now.getFullYear();
    return `${hora}h/${dia}d/${mes}m/${ano}y`;
}

function drive(http, resetIpTimeout) {
    //Get Folders
    http.get('/drive/getfolders', (req, res) => {
        const directory = req.query.directory;
        if (typeof getToken() !== "string") {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (req.headers.authorization != getToken()) {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (typeof directory !== "string") {
            res.status(401).send({ error: true, message: "Invalid Directory, what are you trying to do my friend?" });
        }
        resetIpTimeout(req.connection.remoteAddress);
        //Creating the folder if not exist
        fs.mkdirSync("./drive", { recursive: true });
        //Reading folders and files
        fs.readdir("./drive" + directory, { withFileTypes: true }, (err, folder) => {
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
    });

    //Get Images
    http.get('/drive/getimages', (req, res) => {
        const directory = req.query.directory;
        if (typeof getToken() !== "string") {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (req.headers.authorization != getToken()) {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (typeof directory !== "string") {
            res.status(401).send({ error: true, message: "Invalid Directory, what are you trying to do my friend?" });
        }
        resetIpTimeout(req.connection.remoteAddress);
        //Getting the image path
        let filePath = path.resolve(__dirname, '../', '../', 'drive') + directory;
        //Returning the image
        res.sendFile(filePath);
    });

    //Get Images
    http.post('/drive/createfolder', (req, res) => {
        let data = req.body;
        if (typeof data["directory"] !== "string") {
            res.status(401).send({ error: true, message: "Invalid Folder Name, why you are sending me a non string folder name?" });
            return;
        }
        if (typeof getToken() !== "string") {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (req.headers.authorization != getToken()) {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        //Create folder
        fs.mkdirSync("./drive/" + data["directory"], { recursive: true });
        console.log("[" + getDateTime() + "] Folder created")
        res.status(200).send({
            error: false, message: "success"
        });
    });

    //Remove
    http.post('/drive/delete', (req, res) => {
        let data = req.body;
        if (typeof data["item"] !== "string") {
            console.log("send1")
            res.status(401).send({ error: true, message: "Invalid Item Name, why you are sending me a non string item name?" });
            return;
        }
        if (typeof getToken() !== "string") {
            console.log("send2")
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (req.headers.authorization != getToken()) {
            console.log("send3")
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        fs.rm("./drive" + data["item"], { recursive: true }, (err) => {
            if (err != null) {
                err = err.toString();
                if (!err.includes("no such file or directory")) {
                    console.log("send4")
                    res.status(500).send({ error: true, message: err });
                    return;
                }
            }
        });
        fs.unlink("./drive" + data["item"], (err) => {
            if (err != null) {
                err = err.toString();
                if (!err.includes("no such file or directory") && !err.includes("illegal operation on a directory, unlink")) {
                    console.log("send5")
                    console.log(err);
                    res.status(500).send({ error: true, message: err });
                    return;
                }
            }
        });
        console.log("[" + getDateTime() + "] " + data["item"] + " deleted")
        res.status(200).send({
            error: false, message: "success"
        });
    });

    //Get Images
    http.post('/drive/uploadfile', (req, res) => {
        let directory = req.headers.directory;
        let fileName = req.headers.filename;
        if (typeof directory !== "string") {
            res.status(401).send({ error: true, message: "Invalid Directory, why you are sending me a non string directory?" });
            return;
        }
        if (typeof getToken() !== "string") {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        if (req.headers.authorization != getToken()) {
            res.status(401).send({ error: true, message: "Invalid Token, your local token will be reset try again." });
            return;
        }
        let fileSavePath = path.resolve(__dirname, '../', '../', 'drive') + directory;
        //Upload storage path
        let storage = multer.diskStorage({ destination: fileSavePath, filename: function (req, file, cb) { cb(null, fileName); } });
        // Create the upload method and the configurations
        const upload = multer({ storage: storage }).single('file');

        // Start receiving the image
        upload(req, res, function (err) {
            //Check for erros
            if (err) {
                return res.status(500).send({ error: true, message: "Error uploading the file " + err });
            }

            console.log("[" + getDateTime() + "] File " + fileName + " Received")
            //Success
            res.status(200).send({
                error: false, message: "success"
            });
        });
    });
    console.log("Drive Loaded");
}

module.exports = drive;