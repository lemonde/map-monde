'use strict';

var app = window.angular.module('mapMonde', ['map', 'timer']),
  socket = window.io.connect('http://172.30.1.199');

app.controller('mapMondeCtrl', function ($scope) {

  function startTimer(time) {
    console.log(time);
    $scope.timerTime = time;
    $scope.$broadcast('timer:start');
  }

  $scope.user = {nickname: '', logged: false};
  $scope.waiting = true;

  socket.on('join-status', function (error) {
    console.log('receive "joint-status"', error);
    $scope.user.logged = true;
    $scope.$apply();
  });

  socket.on('question', function (question) {
    console.log('receive "question"', question);
    $scope.question = question;
    $scope.result = null;
    startTimer(question.time);
    $scope.$apply();
  });

  socket.on('result', function (result) {
    console.log('receive "result"', result);
    $scope.result = result;
    startTimer(result.time);
    $scope.$apply();
  });

  $scope.$watch('question', function (question) {
    $scope.waiting = ! question || ! $scope.user.logged;
  });

  $scope.login = function () {
    if (! $scope.user.nickname)
      return ;

    socket.emit('join', {
      nickname: $scope.user.nickname
    });
  };
});