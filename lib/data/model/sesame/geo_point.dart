class GeoPoint{
  final String longitude, latitud;

  GeoPoint({required this.longitude, required this.latitud});

  @override
  String toString() {
    // TODO: implement toString
    return 'Long: $longitude, Lat: $latitud';
  }
}