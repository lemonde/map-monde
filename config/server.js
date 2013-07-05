'use strict';

var express = require('express'),
    app = express(),
    server = require('http').createServer(app),
    path = require('path'),
    base = path.resolve(__dirname + '/..');

app.configure(function() {

  // express config
  app.use(express.compress());
  app.use(express.bodyParser());
  app.use(app.router);

  // aliases
  app.use('/bower_components', express.static(base + '/bower_components'));
});

app.configure('development', function () {
  app.use(express.static(base + '/client'));
  app.use('/assets/font', express.static(base + '/bower_components/font-awesome/font'));
});

app.configure(function () {
  // routes
  require('./routes')(app);
  // socket
  require('./socket')(server);
});

exports = module.exports = server;

exports.use = function() {
  app.use.apply(app, arguments);
};
