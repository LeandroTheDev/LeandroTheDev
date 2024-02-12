const Credentials = require("./credentials");
var token = undefined;

function authentication(http) {
    http.post('/drive/login', async (req, res) => {
        let data = req.body;
        if (typeof data["username"] !== "string") {
            res.status(400).send({ error: true, message: 'Invalid Data' });
            return;
        }
        if (typeof data["password"] !== "string") {
            res.status(400).send({ error: true, message: 'Invalid Data' });
            return;
        }
        //Credentials for login
        if (data["username"] == Credentials.username && data["password"] == Credentials.password) {
            let newToken = '';
            for (let i = 0; i < 100; i++) {
                newToken += Math.floor(Math.random() * 10);
            }
            updateToken(newToken);
            //30 minutes to invalidate the newToken
            setTimeout(function () { updateToken(undefined) }, 1800000);
            res.status(200).send({ error: false, message: getToken() });
        } else {
            res.status(401).send({ error: true, message: 'Invalid Credentials' });
            return;
        }
    });
    console.log("Drive Authentication Loaded");
}

function updateToken(value) {
    token = value;
}

function getToken() {
    return token
}

module.exports = {
    authentication,
    getToken,
    updateToken
};