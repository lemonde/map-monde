'use strict';

var template = '<div id="map_container"><div id="map"></div>   <span id="reset">reset</span> &nbsp;<span id="valider">valider</span> </div>';

function MapCtrl ($scope) {

  $scope.vars = "toto";

}

app.directive('map', function () {
  return {
    restrict: 'E',
    replace: true,
    transclude: true,
    template: template,
    controller: 'MapCtrl',
    link: function ($scope, $element, $attrs) {

      $($element).find('#map').css({
        width: '600px',
        height: '400px'
      });

      var map = L.map('map').setView([29.91685, -1.14258], 3);

      L.tileLayer('http://{s}.tiles.mapbox.com/v3/lemonde.map-fr-labels/{z}/{x}/{y}.png', {
        subdomains: ["a", "b", "c", "d"],
        zoom: 3,
        minZoom: 3,
        maxZoom: 9,
        attribution: 'Ludow, Amadour, Grég & José'
      }).addTo(map);


      var reponse_joueur = null;
      //answer.addTo(map);

      function onMapClick(e) {
          if(reponse_joueur !== null)
          {
            reponse_joueur.setLatLng(e.latlng);
          }
          else
          {
            reponse_joueur = L.marker(e.latlng).addTo(map);
          }
      }

      function resetReponseJoueur(){
        if(reponse_joueur !== null){
          map.removeLayer(reponse_joueur);
          reponse_joueur = null;
        }
      }

      function validerReponseJoueur(){
        if(reponse_joueur !== null){
          var reponse = reponse_joueur.getLatLng(); 
          alert(reponse);
        }
      }

      map.on('click', onMapClick);
      $('#reset').on('click', resetReponseJoueur);
      $('#valider').on('click', validerReponseJoueur);
    }
  }
});