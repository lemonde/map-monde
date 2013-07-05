'use strict';

module.exports = function (app) {
  // Only one route
  app.get('/', function (req, res) {
    return res.render('templates/main');
  });
};