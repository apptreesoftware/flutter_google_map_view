import 'package:map_view/location.dart';

class CameraPosition {
  final Location center;
  final double zoom;

  const CameraPosition(this.center, this.zoom);

  factory CameraPosition.fromMap(Map map) {
    return new CameraPosition(new Location.fromMap(map), map["zoom"]);
  }

  Map toMap() {
    Map map = center.toMap();
    map["zoom"] = zoom;
    return map;
  }
}
