'use strict';

var app = angular.module('mapMonde', []);

var user = {nickname: 'Robert', logged: false};

app.controller('mapMondeCtrl', function ($scope) {

  $scope.user = user;

  $scope.login = function () {

    $scope.user.logged = true;

  }

});