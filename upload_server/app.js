// simple node.js server for receiving test uploads

var http = require('http');
var fs = require('fs');
var url = require('url');

var PORT;

if(process.argv.length > 2){
	PORT = parseInt(process.argv[2]);
} else {
	PORT = 3201;
}

if(process.argv.length > 3){
	upload_folder = process.argv[3]
} else {
    upload_folder = '~/wptagent-control/other_data/';
}

/*
 * Create uploads folder if it doesn't exist
 */

const options = {
	key: fs.readFileSync('key.pem'),
	cert: fs.readFileSync('cert.pem')
};

var server = http.createServer(function(req, res) {
	console.log("req from " + req.socket.remoteAddress + ":" + req.socket.remotePort);
	console.log(req.method + " " + req.url + " HTTP/" + req.httpVersion);
	console.log(req.headers);

	/*
	 * add public IP to saved string
	 */
	var ip_address = req.connection.remoteAddress;

	var outst = fs.createWriteStream(upload_folder + decodeURIComponent(url.parse(req.url).pathname).split('/').slice(-1)[0]);

	outst.on("error", function(err) {
		console.error('stream errors: ' + err);
		res.writeHead(500, {'Content-Type' : 'text/plain', 'Access-Control-Allow-Origin' : '*', 'Access-Control-Allow-Headers' : '*'});
		res.end('failed');
	});

	outst.on("finish", function() {
		console.log('stream end');
		res.writeHead(200, {'Content-Type' : 'text/plain', 'Access-Control-Allow-Origin' : '*', 'Access-Control-Allow-Headers' : '*'});
		res.end('ok');
	});

	req.pipe(outst);
});

server.listen(PORT, function() {
	console.log("http server listening on *:"+PORT);
});
