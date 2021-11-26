const express = require('express'),
    app = express(),
    cors = require('cors'),
    helmet = require('helmet'),
    port = process.env.PORT || 3000,
    bodyParser = require('body-parser')

app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

app.use(cors())

app.use(helmet())

const routes = require('./routes');
routes(app);

const cluster = require('cluster');
if (cluster.isMaster) {
    cluster.fork();

    cluster.on('exit', function (worker, code, signal) {
        cluster.fork();
    });
}
if (cluster.isWorker) {
    app.listen(port);
    console.log('RESTful API server started on: ' + port);
}