/**
* Check if the variable in parameter is a type of string, if not uses the
* res to send a error with the message parameter and status code
* @param {object} variable
* @param {Response} resCallBack
* @param {String} message - "Invalid..."
* @param {int} statusCode - 401
* @returns {boolean} Returns a boolean, true for errors, false for success.
*/
function stringsTreatment(variable, resCallBack, message = "Invalid Argument", statusCode = 401) {
    if (variable !== "string") {
        resCallBack.status(statusCode).send({ error: true, message: message });
        return true;
    }
    return false
}

/**
* Check if the parameters userToken and serverToken is the same, if not uses the
* res to send a error with the message parameter and status code
* @param {String} userToken - "123..."
* @param {String} serverToken - "123..."
* @param {Response} resCallBack
* @param {int} statusCode - 401
* @returns {boolean} Returns a boolean, true for errors, false for success.
*/
function tokenCheckTreatment(userToken, serverToken, resCallBack) {
    if (userToken != serverToken) {
        resCallBack.status(401).send({ error: true, message: "Invalid Token, you will need to login again." });
        return true
    }
    return false
};

/**
* Check if the variable is a valid prompt
* res to send a error with the message parameter and status code
* @param {object} variable
* @param {Response} resCallBack
* @param {String} message - "Invalid..."
* @param {int} statusCode - 401
* @returns {boolean} Returns a boolean, true for errors, false for success.
*/
function promptTreatment(variable, resCallBack, message = "Invalid Prompt", statusCode = 403) {
    if (typeof (variable) !== "string") {
        resCallBack.status(statusCode).send({ error: true, message: message });
        return true;
    } else if (variable.length == 0 || variable.length > 2000) {
        resCallBack.status(statusCode).send({ error: true, message: message });
        return true;
    }

    const regex = /^[a-zA-Z0-9À-ÿ\s.!?:+=\-,]+$/;
    if (!regex.test(variable)) {
        resCallBack.status(statusCode).send({ error: true, message: "You have limited access to specific characters" });
        return true;
    }

    return false;
}

module.exports = {
    stringsTreatment,
    tokenCheckTreatment,
    promptTreatment
}