const fs = require("fs");
const path = require('path');
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

    //Create Folder
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

    //Upload
    http.post('/drive/uploadfile', (req, res) => {
        let body = [];
        //We need to wait to access the body, because the body is too big
        req.on('data', (chunk) => {
            //After getting the body will push to the variable
            body.push(chunk);
        }).on('end', () => {
            //Converting the body into readable
            body = Buffer.concat(body);
            const data = JSON.parse(body.toString());
            //Getting important variables
            const fileName = data.fileName;
            const directory = data.saveDirectory;
            //Errors check
            if (typeof directory !== "string") {
                res.status(401).send({ error: true, message: "Invalid Directory, why you are sending me a non string directory?" });
                return;
            }
            if (typeof fileName !== "string") {
                res.status(401).send({ error: true, message: "Invalid File Name, why you are sending me a non string file name?" });
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
            //Converting the file to bytes again
            const bytes = Buffer.from(data.file, 'base64');
            //Getting the save path
            const fileSavePath = path.resolve(__dirname, '../', '../', 'drive') + directory;
            try {
                //Saving in the disk
                fs.writeFileSync(path.join(fileSavePath, fileName), bytes);
                console.log("[" + getDateTime() + "] File " + fileName + " Received")
                res.status(200).send({
                    error: false, message: "success"
                });
            } catch (error) {
                res.status(400).send({
                    error: true, message: error
                });
            }
        });
    });
    console.log("Drive Loaded");
}

module.exports = drive;