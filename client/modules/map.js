'use strict';

var template = '<div id="map_container"><div id="map"></div>   <span id="reset">reset</span> &nbsp;<span id="valider">valider</span> </div>';

function MapCtrl ($scope) {

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
      //var tile_url = 'http://{s}.tiles.mapbox.com/v3/lemonde.map-fr-labels/{z}/{x}/{y}.png';
      var tile_url = 'http://{s}.tiles.mapbox.com/v3/lemonde.map-1q9aj45w/{z}/{x}/{y}.png';

      L.tileLayer(tile_url, {
        subdomains: ["a", "b", "c", "d"],
        zoom: 3,
        minZoom: 3,
        maxZoom: 9,
        attribution: 'Ludow, Amadour, Grég & José'
      }).addTo(map);


      var reponse_joueur = null;
      var reponse_correcte = null;
      var chemin = null;
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

      function resetReponses(){
        if(reponse_joueur !== null){ 
          map.removeLayer(reponse_joueur);
          reponse_joueur = null;
        }
        if(reponse_correcte !== null){ 
          map.removeLayer(reponse_correcte);
          reponse_correcte = null;
        }
        if(chemin !== null){ 
          map.removeLayer(chemin);
          chemin = null;
        }
      }

      function initMapPosition(data){
        var point, zoomLevel;
        var continent_id = data.continent_geonameid;
        resetReponses();
        //alert(continent_id);
        switch(continent_id){
          case 6255151 : //océanie
            point = {lat:-18.31281, lng: 138.51562};
            zoomLevel = 2;
            break;
          case 6255148 : //europe
            point = {lat:48.69096, lng: 9.14062};
            zoomLevel = 2;
            break;
          case 6255147 : //asie
            point = {lat:29.84064, lng: 89.29688};
            zoomLevel = 2;
            break;
          case 6255152 : //antartique
            point = {lat:-78.15856, lng: 16.40626};
            zoomLevel = 2;
            break;
          case 6255150 : //amérique du sud
            point = {lat:-14.60485, lng: -57.65625};
            zoomLevel = 2;
            break;
          case 6255149 : //amérique du nord
            point = {lat:46.07323, lng: -100.54688};
            zoomLevel = 2;
            break;
          case 6255146 : //afrique
            point = {lat:7.1881, lng: 21.09375};
            zoomLevel = 2;
            break;
          default:
            point = [29.91685, -1.14258];
            zoomLevel = 2;
        }

        map.panTo(point);
        //map.setView(point, zoomLevel);

      }

      function validerReponseJoueur(){
        if(reponse_joueur !== null){
          var reponse = reponse_joueur.getLatLng(); 
          //alert(reponse);
          afficherReponseCorrecte();
        }
      }

      function afficherReponseCorrecte(data){
        var lat, lng;
        lat = 25;
        lng = 45;
        reponse_correcte = L.marker({lat: lat, lng: lng}).addTo(map);
        var latlngs = [];
        latlngs.push(reponse_joueur.getLatLng());
        latlngs.push(reponse_correcte.getLatLng());

        chemin = L.polyline(latlngs, {color: 'red'}).addTo(map);

        // zoom the map to the polyline
        map.fitBounds(chemin.getBounds());
      }

      map.on('click', onMapClick);
      $('#reset').on('click', resetReponses);
      $('#valider').on('click', validerReponseJoueur);

      initMapPosition({continent_geonameid:6255146});
    }
  }
});