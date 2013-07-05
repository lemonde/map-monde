'use strict';

var app = angular.module('mapMonde', []);
var socket = io.connect('http://localhost');

app.controller('mapMondeCtrl', function ($scope) {

  // Check join response
  socket.on("join-status", function (error) {
    console.log('receive join-status', error);
    if (error === false) {
      $scope.error = true;
    }
    else {
      $scope.user.logged = true;
      $scope.$apply();
    }
  });

  socket.on("question", function (data) {
    console.log('receive question', data);
  });

  socket.on("result", function (data) {
    console.log('receive result', data);
  });

  $scope.user = {nickname: '', logged: false};

  $scope.login = function () {

    if($scope.user.nickname !== '') {

      socket.emit("join", {
        nickname: $scope.user.nickname
      });

    }

  }

});