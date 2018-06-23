class Location {
  final double latitude;
  final double longitude;

  /// Time in milliseconds
  final int time;

  /// Altitude in meters.
  ///
  /// Read platform specification for this value.
  final double altitude;

  /// Speed in meters per second
  final double speed;

  /// Bearing value in a range from 0.0 to 360.0.
  ///
  /// This value is called "course" in the iOS platform. Check the CLLocation class reference for more info.
  ///
  /// This is not the device orientation. For more info, read each platform documentation regarding this value.
  final double bearing;

  /// Horizontal accuracy in meters
  ///
  /// Read platform specification for this value.
  final double horizontalAccuracy;

  /// Vertical accuracy in meters.
  ///
  /// Read platform specification for this value.
  /// In Android is required API 26 onwards.
  final double verticalAccuracy;

  const Location(latitude, longitude)
      : latitude = latitude,
        longitude = longitude,
        time = 0,
        altitude = 0.0,
        speed = 0.0,
        bearing = 0.0,
        horizontalAccuracy = 0.0,
        verticalAccuracy = 0.0;

  Location.full(this.latitude, this.longitude, this.time, this.altitude,
      this.speed, this.bearing, this.horizontalAccuracy, this.verticalAccuracy);

  factory Location.fromMap(Map map) {
    return new Location(map["latitude"], map["longitude"]);
  }

  factory Location.fromMapFull(Map map) {
    return new Location.full(
      map["latitude"],
      map["longitude"],
      map["time"],
      map["altitude"],
      map["speed"],
      map["bearing"],
      map["horizontalAccuracy"],
      map["verticalAccuracy"],
    );
  }

  static List<Map<String, dynamic>> listToMap(List<Location> list) {
    List<Map<String, dynamic>> result = [];
    for (var element in list) {
      result.add(element.toMap());
    }
    return result;
  }

  Map<String, dynamic> toMap() => {
        "latitude": latitude,
        "longitude": longitude,
        "time": time,
        "altitude": altitude,
        "speed": speed,
        "bearing": bearing,
        "horizontalAccuracy": horizontalAccuracy,
        "verticalAccuracy": verticalAccuracy,
      };

  @override
  String toString() {
    return 'Location{latitude: $latitude, longitude: $longitude, time: $time, altitude: $altitude, speed: $speed, bearing: $bearing, horizontalAccuracy: $horizontalAccuracy, verticalAccuracy: $verticalAccuracy}';
  }
}
