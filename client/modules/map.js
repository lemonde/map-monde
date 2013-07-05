'use strict';

var template = '<div>Vas-y José, mets nous ta carte !</div>';

function MapCtrl ($scope) {

  $scope.vars = "toto";

}

app.directive('map', function () {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        selected: '=',
        items: '=',
        onselect: '='
    },
    transclude: true,
    template: template,
    controller: 'MapCtrl',
    link: function ($scope, $element, $attrs) {
      $($element).css({
        color: 'purple'
      });
    }
  }
});