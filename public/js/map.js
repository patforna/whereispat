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
        fillOpacity: 0.2,
        strokeWeight: 2,
        strokeColor: "#c30083",
        strokeOpacity: 0.9
    });

    var previousLocations = new Array();
    var bounds = new google.maps.LatLngBounds();

    $.each(route.places,
    function() {
        //expand the bounds to fit each previous location...
        bounds.extend(new google.maps.LatLng(this.latitude, this.longitude));

        //Build the array of past locations...
        previousLocations.push(new google.maps.LatLng(this.latitude, this.longitude));

        //Create markers for each previous location...
        var pathMarker = new google.maps.Marker({
            position: new google.maps.LatLng(this.latitude, this.longitude),
            map: map,
            icon: twitterMarkerImage
        });
    });

    var patsPath = new google.maps.Polyline({
        map: map,
        path: previousLocations,
        strokeColor: "#257890",
        strokeOpacity: 0.8,
        strokeWeight: 3,
        geodesic: true
    });

    //Zoom the map to fit all the previous locations...
    map.fitBounds(bounds);
}