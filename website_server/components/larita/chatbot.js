const usersChatInstances = {};
class ChatBot {
    async generatePrompt(req, res) {
        const headers = req.headers;
        const body = req.body;

        //Dependencies
        const database = require('./database');
        const {
            stringsTreatment,
            tokenCheckTreatment,
            promptTreatment,
        } = require('./utils');

        //Errors Treatments
        if (stringsTreatment(typeof headers.username, res, "Invalid Username, why you are sending any invalid username?", 401)) return;
        if (tokenCheckTreatment(headers.token, await database.getUserToken(headers.username), res)) return;
        if (promptTreatment(body.Message, res)) return;
        delete require("./init").ipTimeout[req.ip];

        if (usersChatInstances[headers.token] == undefined)
            usersChatInstances[headers.token] = new ChatInstance(headers.token);

        try {
            usersChatInstances[headers.token].sendPrompt(body.Message);
        } catch (error) {
            console.log("[Larita] " + headers.username + " too fast, the IA is still busy: " + error);
            return res.status(500).send({
                error: true,
                message: error
            });
        }

        res.status(200).send({
            "Message": "Generating",
        });
    }

    generatePromptImage() { }

    async receivePrompt(req, res) {
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

        if (usersChatInstances[headers.token] == undefined) {
            return res.status(403).send({
                error: true,
                message: "No instance enabled for this account"
            });
        }
        let data = await usersChatInstances[headers.token].getLastMessage();
        delete require("./init").ipTimeout[req.ip];
        res.status(200).send({
            "Emotional": ":)",
            "EmotionalType": "happy",
            "IsOver": data["isOver"],
            "Message": data["message"],
            "Error": data["error"],
        });

    }

    instanciateChatBot(http, timeoutFunction) {
        this.resetIpTimeout = timeoutFunction;

        //Get
        http.post('/chatbot/generatePrompt', this.generatePrompt);
        http.post('/chatbot/generatePromptImage', this.generatePromptImage);
        http.get('/chatbot/receivePrompt', this.receivePrompt);
    }
}

class ChatInstance {
    constructor(token) {
        this.available = true;
        this.token = token;
        this.chatMessages = [];
        this.receivingChatMessage = null;
        this.tries = 0;
        this.error = null;
    }

    sendPrompt(message) {
        if (!this.available) throw "The prompt is busy";
        this.available = false;

        const http = require('http');
        // Adding the user prompt
        this.chatMessages.push({
            "role": "user",
            "content": message
        });
        const data = {
            "model": "llama3",
            "messages": this.chatMessages
        };
        // Create the IA message
        this.chatMessages.push({
            role: "assistant",
            content: ""
        });

        // Request data
        const req = http.request({
            hostname: 'localhost',
            port: 11434,
            path: '/api/chat',
            method: 'POST',
        }, (res) => {
            res.setEncoding('utf8');

            // On receive data
            const listener = (chunk) => {
                try {
                    // Parsing the data
                    let data = JSON.parse(chunk);
                    // Saving message processed
                    this.chatMessages[this.chatMessages.length - 1]["content"] += data["message"]["content"];

                    // Cache message
                    if (this.receivingChatMessage == null) this.receivingChatMessage = "";
                    this.receivingChatMessage += data["message"]["content"];

                } catch (error) {
                    // Remove the IA final history
                    this.chatMessages.pop();
                    // Remove the user final history
                    this.chatMessages.pop();
                    this.error = "Ops, the request cannot be completed";
                    res.off('data', listener);
                }
            };
            res.on('data', listener);

            // On finish
            res.on('end', () => {
                // Reenabling the instance usage
                this.available = true;
            });
        });

        // On errors
        req.on('error', (e) => {
            console.error(`[Larita IA] Problem with request: ${e.message}`);
        });

        req.write(JSON.stringify(data));
        req.end();
    }

    getLastMessage() {
        if (this.error != null)
            return {
                error: true,
                isOver: true,
                message: this.error
            }

        let data = {
            isOver: this.available,
            message: this.receivingChatMessage
        };
        this.receivingChatMessage = null;
        return data;
    }
}

module.exports = new ChatBot;