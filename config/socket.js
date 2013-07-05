var socketIO = require('socket.io'),
    _ = require('lodash'),
    capitales = require('../data/liste_capitale.json');

module.exports = function (server) {

  // Game
  require('../server/game')({
    io: socketIO.listen(server),
    questionProvider: function (cb) {

      var questions = _.map(capitales, function (capitale, key) {
        return {
          id: key + 1,
          question: 'Où se trouve ' + capitale.libelle + ' ?',
          solve: {
            lat: capitale.latitude,
            long: capitale.longitude
          },
          time: 10
        };
      });

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