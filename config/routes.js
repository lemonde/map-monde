'use strict';

var path = require('path');

module.exports = function (app) {
  // Only one route
  app.use(function (req, res) {
    return res.sendfile(path.resolve(__dirname + '/../server/templates/main.html'));
  });
};