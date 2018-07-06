import 'package:map_view/location.dart';

class CameraPosition {
  final Location center;
  final double zoom;
  final double bearing;
  final double tilt;

  const CameraPosition(this.center, this.zoom,
      {this.bearing = 0.0, this.tilt = 0.0});

  factory CameraPosition.fromMap(Map map) {
    return new CameraPosition(new Location.fromMap(map), map["zoom"],
        bearing: map["bearing"], tilt: map["tilt"]);
  }

  Map toMap() {
    Map map = center.toMap();
    map["zoom"] = zoom;
    map["bearing"] = bearing;
    map["tilt"] = tilt;
    return map;
  }
}
