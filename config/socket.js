var socketIO = require('socket.io');

module.exports = function (server) {
  var io = socketIO.listen(server);

  io.sockets.on('connection', function (socket) {
    socket.emit('news', { hello: 'world' });
    socket.on('my other event', function (data) {
      console.log(data);
    });
  });
};