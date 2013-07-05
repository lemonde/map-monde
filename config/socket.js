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
          time: 8
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
          time: 10
        }
      ];

      cb(questions[Math.floor(Math.random()*questions.length)]);
    },
    scoreComputer: function (solve, answer) {

      var lat1 = solve.lat,
        lat2 = answer.lat,
        lon1 = solve.long,
        lon2 = answer.long;

      /** Converts numeric degrees to radians */
      if (typeof(Number.prototype.toRad) === 'undefined') {
        Number.prototype.toRad = function() {
          return this * Math.PI / 180;
        };
      }


      var R = 6371; // km
      var dLat = (lat2-lat1).toRad();
      var dLon = (lon2-lon1).toRad();
      lat1 = lat1.toRad();
      lat2 = lat2.toRad();

      var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      var d = R * c;

      return 1 / d;
    },
    pauseTime: 8
  });
};