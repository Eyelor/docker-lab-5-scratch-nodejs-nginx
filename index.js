const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.write(`Server IP address: ${req.socket.localAddress}\n`);
  res.write(`Server name (hostname): ${os.hostname()}\n`);
  res.write(`App version: ${process.env.APP_VERSION}\n`);
  res.end();
});

server.listen(3000, () => {
  console.log('App is running on port 3000');
});
