'use strict';

window.angular.module('map', [])
  .directive('map', function () {
    var L = window.L;

    return {
      restrict: 'E',
      replace: true,
      templateUrl: '/modules/map/map.html',
      link: function ($scope) {

        var map = L.map('map').setView([29.91685, -1.14258], 3);
        var tile_url = 'http://{s}.tiles.mapbox.com/v3/lemonde.map-fr-labels/{z}/{x}/{y}.png';

        L.tileLayer(tile_url, {
          subdomains: ['a', 'b', 'c', 'd'],
          zoom: 3,
          minZoom: 3,
          maxZoom: 9,
          attribution: 'Ludow, Amadour, Greg, José & Charlotte'
        }).addTo(map);


        var playerMark, solutionMark, path;

        function onMapClick (e) {
          if ($scope.result)
            return ;
          emitAnswer(e.latlng);
          placePlayerMark(e.latlng);
        }

        function emitAnswer (latlng) {
          var answer = {
            questionId: $scope.question.id,
            answer: {
              lat: latlng.lat,
              long: latlng.lng
            }
          };
          console.log('emit "answer"', answer);
          window.socket.emit('answer', answer);
        }

        function placePlayerMark (latlng) {
          playerMark = playerMark || L.circleMarker(latlng, {color: 'blue'}).setRadius(20).addTo(map);
          playerMark.setLatLng(latlng);
        }

        function placeSolutionMark (latlng) {
          solutionMark = solutionMark || L.circleMarker(latlng, {color: 'green'}).setRadius(20).addTo(map);
          solutionMark.setLatLng(latlng);
        }

        function showSolutionPath () {
          if (! playerMark || solutionMark)
            return ;

          path = L.polyline([playerMark.getLatLng(), solutionMark.getLatLng()], {color: 'red'}).addTo(map);
          // zoom the map to the polyline
          map.fitBounds(path.getBounds());
        }

        function resetMarkers () {
          if (playerMark) {
            map.removeLayer(playerMark);
            playerMark = null;
          }

          if(solutionMark) {
            map.removeLayer(solutionMark);
            solutionMark = null;
          }

          if (path) {
            map.removeLayer(path);
            path = null;
          }
        }

        map.on('click', onMapClick);

        resetMarkers();

        $scope.$watch('result', function (result) {
          if (! result || $scope.waiting)
            return ;

          placeSolutionMark({lat: result.solve.lat, lng: result.solve.long});
          showSolutionPath();
        });

        $scope.$watch('question', resetMarkers);
      }
    };
  });