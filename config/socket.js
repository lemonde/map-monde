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
      var questions = [
        {
          id: 1,
          question: 'Où se trouve Belgrade ?',
          solve: {
            lat: 44.80401,
            long: 20.46513
          },
          time: 10
        },
        {
          id: 2,
          question: 'Où se trouve Paris ?',
          solve: {
            lat: 48.85341,
            long: 2.3488
          },
          time: 5
        },
        {
          id: 3,
          question: 'Où se trouve Longyearbyen ?',
          solve: {
            lat: 78.2186,
            long: 15.64007
          },
          time: 15
        }
      ];

      cb(questions[Math.floor(Math.random()*questions.length)]);
    },
    scoreComputer: function (solve, answer) {
      return answer.lat;
    },
    pauseTime: 10
  });
};