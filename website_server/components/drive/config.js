const cors = require('cors');
const { authentication } = require('./authentication');
const drive = require('./drive');

//Declare HTTP
const http = require('express')();
var ipTimeout = {};
function resetIpTimeout(ip) {
    delete ipTimeout[ip];
}
//Enable json suport
http.use(require('express').json());
//Enable cors for web
http.use(cors());
//Ports for the server
http.listen(7979, () => { console.log("Drive Responses Loaded"), authentication(http), drive(http, resetIpTimeout) });
//DDOS Protection
http.use((req, res, next) => {
    //Ip blocked
    if (ipTimeout[req.ip] == 99) {
        res.status(413).send({ error: true, message: 'Too Many Attempts' });
        return;
    }

    //Add a limiter for ips
    if (ipTimeout[req.ip] == undefined) {
        ipTimeout[req.ip] = 0
        //Reset Timer
        setTimeout(function () {
            delete ipTimeout[req.ip];
        }, 100000);
    }
    else ipTimeout[req.ip] += 1;

    //If the ip try to communicate 5 times to fast then block it
    if (ipTimeout[req.ip] > 2) ipTimeout[req.ip] = 99;

    next();
});

module.exports = http;