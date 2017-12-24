import 'package:map_view/camera_position.dart';
import 'package:map_view/location.dart';
import 'package:map_view/map_view_type.dart';

class MapOptions {
  final bool showUserLocation;
  final CameraPosition initialCameraPosition;
  final String title;
  static const CameraPosition _defaultCamera =
      const CameraPosition(const Location(45.5329661, -122.7059508), 12.0);
  MapViewType mapViewType;

  MapOptions(
      {this.showUserLocation: false,
      this.initialCameraPosition: _defaultCamera,
      this.title: "",
      this.mapViewType: MapViewType.normal});

  Map<String, dynamic> toMap() {
    return {
      "showUserLocation": showUserLocation,
      "cameraPosition": initialCameraPosition.toMap(),
      "title": title,
      "mapViewType" : getMapTypeName(mapViewType)
    };
  }

  String getMapTypeName(MapViewType mapType) {
    String mapTypeName = "normal";
    switch(mapType) {
      case MapViewType.none:
        mapTypeName = "none";
        break;
      case MapViewType.satellite:
        mapTypeName = "satellite";
        break;
      case MapViewType.terrain:
        mapTypeName = "terrain";
        break;
      case MapViewType.hybrid:
        mapTypeName = "hybrid";
        break;
      case MapViewType.normal:
        mapTypeName = "normal";
        break;
    }
    return mapTypeName;
  }
}
