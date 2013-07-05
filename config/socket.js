var socketIO = require('socket.io');

module.exports = function (server) {

  // io : Socket io instance
// questionProvider (callback) : A function that return the question in a callback
// scoreComputer (solve, answer) : Return a score
// pauseTime : Time between two questions

  // Game
  require('../server/game')({
    io: socketIO.listen(server),
    questionProvider: function (cb) {
      cb({
        id: 1,
        question: 'Où se trouve Paris ?',
        solve: {
          lat: 2.460181181021018,
          long: 68.90625
        },
        time: 3
      });
    },
    scoreComputer: function (solve, answer) {
      return answer.lat;
    },
    pauseTime: 3
  });
};