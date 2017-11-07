class Location {
  final double latitude;
  final double longitude;

  const Location(this.latitude, this.longitude);
  factory Location.fromMap(Map map) {
    return new Location(map["latitude"], map["longitude"]);
  }

  Map toMap() {
    return {"latitude": this.latitude, "longitude": this.longitude};
  }

  @override
  String toString() {
    return 'Location{latitude: $latitude, longitude: $longitude}';
  }
}
