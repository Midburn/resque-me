var express = require('express');
var redis = require('redis');
var bodyParser = require('body-parser');
var uuid = require('node-uuid');
var app = express();
var cluster = require('cluster');
var numCPUs = require('os').cpus().length;
var posix = require('posix');

posix.setrlimit('nofile', { soft: 10000 });


var ticketsQueueName = 'tickets-queue';
var bannedQueueName = 'banned-queue';

app.use(bodyParser.json());

var client = redis.createClient({
	retry_unfulfilled_commands: true,
	retry_strategy: function(options){
		return 1;
	}
});

client.on("error", function(err) {
	console.error("Redis Client Error " + err);
});

var numMessagesSent = 0,
	numRequestBanned = 0;

function printStats() {
	setTimeout(function() {
		console.log('Messages sent: ' + numMessagesSent + ', messages banned: ' + numRequestBanned);
		printStats();
	}, 1000 * 60);
}
printStats();

app.all('/*', function(req, res, next) {
	req.on('error', function(err) {
		console.error(err.stack);
	});
	res.header('Access-Control-Allow-Origin', '*');
	res.header('Access-Control-Allow-Headers', 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept');
	res.header('Access-Control-Allow-Methods', 'HEAD,POST,OPTIONS');
	log(req);
	next();
});



app.post('/register', function(req, res) {

	if (!req.body.username) {
		return res.status(400).end();
	}
	var headers = req.headers;
	var messageJson = JSON.stringify({
		'ip': headers['REMOTE_ADDR'],
		'timestamp': new Date().getTime(),
		'email': req.body.username
	});


	isQueueOpen(function(isOpen) {
		var queueName = isOpen ? ticketsQueueName : bannedQueueName;
		// console.log("queueName: "+ queueName)

		client.hset(queueName, uuid.v4(), messageJson, function(err, result) {

			console.log(result);
			if (err) {
				console.error(err);
			}
			if (result) {
				if (isOpen) {
					numMessagesSent++;
					res.status(200).json({
						success: true
					});
				} else {
					numRequestBanned++;
					res.status(400).end();
				}
			}
		});
	})

});

function log(req) {
	var headers = req.headers;
	var ip = req.headers['x-forwarded-for'] ||
		req.connection.remoteAddress ||
		req.socket.remoteAddress ||
		req.connection.socket.remoteAddress;
	console.log('[access log] ' + req.method + ' ' + ip + ' ' + req.originalUrl + ' [' + JSON.stringify(req.body) + ']');

}

function isQueueOpen(callback) {
	return client.get('is_queue_open', function(err, res) {
		if (err) {
			console.error(err);
		}
		callback(true);
		// callback(res);
	});
}


if (cluster.isMaster) {
	// Fork workers.
	console.log("Starting node cluster for " +numCPUs + " cpus")
	for (var i = 0; i < numCPUs; i++) {
		cluster.fork();
	}

	cluster.on('exit', (worker, code, signal) => {
		console.log(`worker ${worker.process.pid} died`);
	});
} else {

	app.listen(3000, function() {
		console.log('Tickets queue running at on port: 3000');
	});
}