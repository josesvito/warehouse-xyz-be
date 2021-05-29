const jwt = require('jsonwebtoken');
const fs = require('fs');
var connection = require('./conn');
var axios = require('axios')
var qs = require('querystring')
var response = require('./res')

exports.jwtSign = (payload) => {
    const privateKey = fs.readFileSync('./private.pem', 'utf8');
    const token = jwt.sign({payload}, privateKey, {
        algorithm: 'RS256',
        expiresIn: '2d'
    });
    return token;
}

exports.jwtVerify = (token) => {
    const publicKey = fs.readFileSync('./public.pem', 'utf8');
    try {
        return jwt.verify(token, publicKey, {
            algorithm: 'RS256'
        });
    } catch (e) {
        return ({
            name: 'JsonWebTokenError',
            message: 'invalid signature'
        })
    }
}

exports.hasUndefined = () => {
    let hasUndefined = false
    for (var i in arguments) {
        if (typeof arguments[i] == "undefined" && arguments[i] == "") {
            return true
        }
    }
    return hasUndefined
}

exports.dynamicSort = (property) => {
    let sortOrder = 1;

    if (property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
    }

    return function (a, b) {
        if (sortOrder == -1) {
            return b[property].localeCompare(a[property]);
        } else {
            return a[property].localeCompare(b[property]);
        }
    }
}

exports.sanitize = (someInput) => {
    if(someInput){
        if (someInput.trim() == "") {
            return null
        }
        if (someInput.trim() == "true") {
            return 1
        } else if (someInput.trim() == "false") {
            return 0
        }
    }
    return someInput
}

exports.routeAccess = function (token, routeLevel) {
    try {
        const payload = this.jwtVerify(token).payload
        if(routeLevel.find(r => r == payload.role_id)) {
            return payload
        }
    } catch (e) {
        return
    }
}