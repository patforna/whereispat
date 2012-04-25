var whereispat = {
    map: function() {

        var BICYCLE_IMAGE = new google.maps.MarkerImage('/images/bicycle_50.png', null, null, null, null);
        var TWITTER_IMAGE = new google.maps.MarkerImage('/images/twitter_newbird_blue.png', null, null, null, new google.maps.Size(35, 35));

        var instance = {};
        var map = createMap();

        instance.render = function() {
            showCurrentLocation();
            showTweets();
            showRoute();
            showHowFarCircle();
            showProbableRoute();
            fitBounds();
        };

        function createMap() {
            return new google.maps.Map($('#map_canvas')[0], { center: currentLocation(), zoom: 7, mapTypeId: google.maps.MapTypeId.TERRAIN });
        };

        function currentLocation() {
            return new google.maps.LatLng($('.latitude').text(), $('.longitude').text());
        };

        function showCurrentLocation() {
            new google.maps.Marker({
                position: currentLocation(),
                map: map,
                animation: google.maps.Animation.BOUNCE,
                icon: BICYCLE_IMAGE
            });
        };

        function showHowFarCircle() {
            new google.maps.Circle({
                center: currentLocation(),
                map: map,
                radius: $('.how-far').text() * 1609,
                fillColor: "#c30083",
                fillOpacity: 0.1,
                strokeWeight: 2,
                strokeColor: "#c30083",
                strokeOpacity: 0.3
            });
        };

        function showTweets() {
            $.each(route.places, function() {
                new google.maps.Marker({
                    position: new google.maps.LatLng(this.latitude, this.longitude),
                    map: map,
                    icon: TWITTER_IMAGE
                });
            });
        };

        function showRoute() {

            var directionsService = new google.maps.DirectionsService();

            var confirmed_route = [
            {
                origin: 'Chiasso, Switzerland',
                waypoints: ['Lainate Milan, Italy', 'Rho Milan, Italy', 'Cusago Milan, Italy'],
                destination: 'Rosate Milan, Italy'
            },
            {
                origin: 'Rosate Milan, Italy',
                waypoints: ['Motta Visconti Milan', 'Pavia', 'Casteggio', 'Montalto Pavese Pavia', 'Lirio Pavia', 'Rocca de\' Giorgi Pavia'],
                destination: 'Nibbiano Piacenza, Italy'
            },
            {
                origin: 'Nibbiano Piacenza, Italy',
                waypoints: ['Pecorara', 'Marzonago, Pecorara', 'Pecorara', 'Bobbio'],
                destination: '29024 Ferriere Piacenza, Italy'
            },
            {
                origin: '29024 Ferriere Piacenza, Italy',
                waypoints: ['Selva, Ferriere Piacenza, Italy', '43041 Bedonia Parma', '44.387037,9.884037'],
                destination: 'La Spezia'
            },
            {
                origin: 'La Spezia',
                waypoints: ['Pugliola', '44.106016,9.95151', 'Viareggio'],
                destination: 'Lucca'
            },
            {
                origin: 'Lucca',
                waypoints: ['Pieve San Paolo, Capannori', 'Corte Stanghellini, Capannori', 'Altopascio', 'Castelfiorentino', 'Poggibonsi', 'Monteriggioni'],
                destination: 'Siena'
            },
            {
                origin: 'Siena',
                waypoints: ['Buonoconvento', 'Pienza'],
                destination: 'Montepulciano'
            },
            {
                origin: 'Montepulciano',
                waypoints: ['Castelione del Lago', 'Magione'],
                destination: 'Perugia'
            },
            {
                origin: 'Perugia',
                waypoints: ['Assisi', 'Spoleto'],
                destination: 'Terni'
            },
            {
                origin: 'Terni',
                waypoints: ['42.487463,12.766349', '42.265019,13.162308', '42.247962,13.185697', 'Borgorese'],
                destination: 'Avezzano'
            },
            {
                origin: 'Avezzano',
                waypoints: ['Borgo Ottomila', 'Pescasseroli'],
                destination: 'Opi'
            },
            {
                origin: 'Opi',
                waypoints: ['Alfedena', 'Isernia', 'Bojano'],
                destination: 'Vinchiaturo'
            },
            {
                origin: 'Vinchiaturo',
                waypoints: ['Jelsi', 'Volturara Appula', 'Motta Montecorvino Foggia', 'Foggia', '41.429407,15.66302', 'Corso Giuseppe Garibaldi, Trinitapoli'],
                destination: 'Via Nazareth 18, Barletta',
                avoidHighways: false
            }
            ];

            $.each(confirmed_route, function() {
                var directionsRenderer = new google.maps.DirectionsRenderer({ map: map, preserveViewport: true, suppressMarkers: true });
                directionsService.route(directionsRequestFor(this),
                function(response, status) {
                    if (status == google.maps.DirectionsStatus.OK) {
                        directionsRenderer.setDirections(response);
                    } else {
                        console.log("Request to direction service failed. Status: " + status);
                    }
                });

            });

        };

        function showProbableRoute() {
            var probableRoute = [];
            $.each(route.places, function() {
                if (Date.parse(this.visited_at) > Date.parse("2012-04-23 18:46:41 +0200")) {
                    console.log("This tweet happened after the manual route mapping: " + this.visited_at);
                    probableRoute.push(new google.maps.LatLng(this.latitude, this.longitude));
                }
            });

            new google.maps.Polyline({
                map: map,
                path: probableRoute,
                strokeColor: "#257890",
                strokeOpacity: 0.8,
                strokeWeight: 3,
                geodesic: true
            });
        };

        function directionsRequestFor(data) {
            return {
                origin: data.origin,
                destination: data.destination,
                waypoints: $.map(data.waypoints, function(w, i) { return { location: w, stopover: false } }),
                avoidHighways: (typeof data.avoidHighways === 'undefined') ? true: data.avoidHighways,
                provideRouteAlternatives: false,
                travelMode: google.maps.DirectionsTravelMode.DRIVING,
                unitSystem: google.maps.UnitSystem.METRIC
            };
        };

        function fitBounds() {
            var bounds = new google.maps.LatLngBounds();
            $.each(route.places, function() { bounds.extend(new google.maps.LatLng(this.latitude, this.longitude)); });
            map.fitBounds(bounds);
        };

        return instance;
    }
};



/* pat: could use this to geocode the route once and then cache/serve the coordinates from backend
$.each(response.routes[0].legs, function(i, leg) {
  $.each(leg.steps, function(j, step) {
	geo_data = geo_data.concat(step.path);
  });
}); */

