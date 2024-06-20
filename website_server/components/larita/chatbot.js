class ChatBot {

    async receivePrompt(req, res) {
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
        delete require("./init").ipTimeout[req.ip];

    }

    receivePromptImage() { }

    instanciateChatBot(http, timeoutFunction) {
        this.resetIpTimeout = timeoutFunction;

        //Get
        http.post('/chatbot/receivePrompt', this.receivePrompt);
        http.post('/chatbot/receivePromptImage', this.receivePromptImage);
    }
}

module.exports = new ChatBot;