'use strict';

module.exports = function (app) {
  // Only one route
  app.use(function (req, res) {
    return res.render('templates/main');
  });
};