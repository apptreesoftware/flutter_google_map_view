class Location {
  final double latitude;
  final double longitude;

  const Location(this.latitude, this.longitude);
  factory Location.fromMap(Map map) {
    return new Location(map["latitude"], map["longitude"]);
  }

  static List<Map<String, dynamic>> listToMap(List<Location> list) {
    List<Map<String, dynamic>> result = [];
    for (var element in list) {
      result.add(element.toMap());
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    return {"latitude": this.latitude, "longitude": this.longitude};
  }

  @override
  String toString() {
    return 'Location{latitude: $latitude, longitude: $longitude}';
  }
}
