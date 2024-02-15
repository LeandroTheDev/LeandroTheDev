const Credentials = require("./credentials");

class Authentication {
    login(req, res) {
        //Getting data
        const data = req.body;
        console.log(req.ip + " trying to logging");

        //Validations
        if (typeof data["username"] !== "string") {
            console.log(req.ip + " refused, invalid data");
            res.status(400).send({ error: true, message: 'Invalid Data' });
            return;
        }
        if (typeof data["password"] !== "string") {
            console.log(req.ip + " refused, invalid data");
            res.status(400).send({ error: true, message: 'Invalid Data' });
            return;
        }

        //Credentials for login
        if (data["username"] == Credentials.username && data["password"] == Credentials.password) {
            const database = require("./database");
            let token = "";
            //Generating the token
            for (let i = 0; i < 100; i++) {
                token += Math.floor(Math.random() * 10);
            }
            //Updating the token in database
            database.updateUserToken(token);
            //Success
            res.status(200).send({ error: false, message: token });
        }

        //Wrong Credentials
        else {
            console.log(req.ip + " refused, wrong credentials");
            res.status(401).send({ error: true, message: 'Invalid Credentials' });
            return;
        }
    }
    
    instanciateAuthentication(http) {
        //Post
        http.post('/drive/login', this.login);
    }
}

module.exports = new Authentication;