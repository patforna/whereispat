function initialize_map() {

    //A couple of custom images for the map markers	
    var twitterMarkerImage = new google.maps.MarkerImage('/images/twitter_newbird_blue.png', null, null, null, new google.maps.Size(35, 35));
    var bicycleMarkerImage = new google.maps.MarkerImage('/images/bicycle_50.png', null, null, null, null);

    var patsCurrentLocation = new google.maps.LatLng($('.latitude').text(), $('.longitude').text());

    var mapOptions = {
        center: patsCurrentLocation,
        zoom: 7,
        mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

    var currentLocation = new google.maps.Marker({
        position: patsCurrentLocation,
        map: map,
        title: "Pat woz ere!",
        animation: google.maps.Animation.BOUNCE,
        icon: bicycleMarkerImage
    });

    var howFarCircle = new google.maps.Circle({
        center: patsCurrentLocation,
        map: map,
        radius: $('.how-far').text() * 1609,
        fillColor: "#c30083",
        fillOpacity: 0.1,
        strokeWeight: 2,
        strokeColor: "#c30083",
        strokeOpacity: 0.5
    });

    var probable_route = [];
    var bounds = new google.maps.LatLngBounds();

    $.each(route.places, function() {
        //expand the bounds to fit each previous location...
        bounds.extend(new google.maps.LatLng(this.latitude, this.longitude));        
     
        //build the probable route
        if (Date.parse(this.visited_at) > Date.parse("2012-04-23 18:46:41 +0200")) {
	      console.log("This tweet happened after the manual route mapping: " + this.visited_at);
          probable_route.push(new google.maps.LatLng(this.latitude, this.longitude));
        }

        //Create markers for each previous location...
        var pathMarker = new google.maps.Marker({
            position: new google.maps.LatLng(this.latitude, this.longitude),
            map: map,
            icon: twitterMarkerImage
        });
    });

    var patsPath = new google.maps.Polyline({
        map: map,
        path: probable_route,
        strokeColor: "#257890",
        strokeOpacity: 0.8,
        strokeWeight: 3,
        geodesic: true
    });
	
	var directionsService = new google.maps.DirectionsService();

	var confirmed_route = [
		{ origin: 'Chiasso, Switzerland', waypoints: ['Lainate Milan, Italy','Rho Milan, Italy','Cusago Milan, Italy'], destination: 'Rosate Milan, Italy' },
		 { origin: 'Rosate Milan, Italy', waypoints: ['Motta Visconti Milan','Pavia','Casteggio','Montalto Pavese Pavia','Lirio Pavia','Rocca de\' Giorgi Pavia'], destination: 'Nibbiano Piacenza, Italy' },
		{ origin: 'Nibbiano Piacenza, Italy', waypoints: ['Pecorara','Marzonago, Pecorara', 'Pecorara','Bobbio'], destination: '29024 Ferriere Piacenza, Italy' },
		{ origin: '29024 Ferriere Piacenza, Italy', waypoints: ['Selva, Ferriere Piacenza, Italy','43041 Bedonia Parma','44.387037,9.884037'], destination: 'La Spezia' },
		{ origin: 'La Spezia', waypoints: ['Pugliola','44.106016,9.95151','Viareggio'], destination: 'Lucca' },
		{ origin: 'Lucca', waypoints: ['Pieve San Paolo, Capannori', 'Corte Stanghellini, Capannori','Altopascio','Castelfiorentino','Poggibonsi','Monteriggioni'], destination: 'Siena' },
		{ origin: 'Siena', waypoints: ['Buonoconvento','Pienza'], destination: 'Montepulciano' },
		{ origin: 'Montepulciano', waypoints: ['Castelione del Lago', 'Magione'], destination: 'Perugia' },
		{ origin: 'Perugia', waypoints: ['Assisi','Spoleto'], destination: 'Terni' },
		{ origin: 'Terni', waypoints: ['42.487463,12.766349','42.265019,13.162308','42.247962,13.185697','Borgorese'], destination: 'Avezzano' },
		{ origin: 'Avezzano', waypoints: ['Borgo Ottomila','Pescasseroli'], destination: 'Opi' },
		{ origin: 'Opi', waypoints: ['Alfedena','Isernia','Bojano'], destination: 'Vinchiaturo' },
		{ origin: 'Vinchiaturo', waypoints: ['Jelsi', 'Volturara Appula', 'Motta Montecorvino Foggia', 'Foggia', '41.429407,15.66302', 'Corso Giuseppe Garibaldi, Trinitapoli'], destination: 'Via Nazareth 18, Barletta', avoidHighways: false }		
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

    //Zoom the map to fit all the previous locations...
    map.fitBounds(bounds);
}

function directionsRequestFor(data) {
	return {
	    origin: data.origin,
	    destination: data.destination,
	    waypoints: $.map(data.waypoints, function(w, i) { return { location: w, stopover: false} }),
	    avoidHighways: (typeof data.avoidHighways === 'undefined') ? true : data.avoidHighways,
	    provideRouteAlternatives: false,
	    travelMode: google.maps.DirectionsTravelMode.DRIVING,
	    unitSystem: google.maps.UnitSystem.METRIC
	};
}


/* pat: could use this to geocode the route once and then cache/serve the coordinates from backend
$.each(response.routes[0].legs, function(i, leg) {
  $.each(leg.steps, function(j, step) {
	geo_data = geo_data.concat(step.path);
  });
}); */				

