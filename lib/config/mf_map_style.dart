/// Branded light Google Map style for MchongoFasta (blue fintech, calm streets).
/// Applied via [GoogleMap.style].
const mfGoogleMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{ "color": "#f2f4f7" }]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#1a2b56" }]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{ "color": "#ffffff" }]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#d6dce8" }]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{ "color": "#e8eef9" }]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{ "color": "#dce9df" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#ffffff" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#e5e7eb" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{ "color": "#eef2ff" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{ "color": "#d6e0ff" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#b8c9ff" }]
  },
  {
    "featureType": "transit",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#c5d8f6" }]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#5b8cff" }]
  }
]
''';
