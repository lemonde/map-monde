'use strict';

var app = window.angular.module('mapMonde', []),
  socket = window.io.connect('http://localhost');

app.controller('mapMondeCtrl', function ($scope) {

  socket.on('join-status', function (error) {
    console.log('receive "joint-status"', error);
    $scope.user.logged = true;
    $scope.$apply();
  });

  socket.on('question', function (question) {
    console.log('receive "question"', question);
    $scope.question = question;
    $scope.$apply();
  });

  socket.on('result', function (result) {
    console.log('receive "result"', result);
    $scope.result = result;
    $scope.$apply();
  });

  $scope.user = {nickname: '', logged: false};

  $scope.login = function () {
    if (! $scope.user.nickname)
      return ;

    socket.emit('join', {
      nickname: $scope.user.nickname
    });
  };
});