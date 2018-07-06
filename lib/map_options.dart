import 'package:map_view/camera_position.dart';
import 'package:map_view/location.dart';
import 'package:map_view/map_view_type.dart';

class MapOptions {
  /// Allows the app to receive location updates.
  final bool showUserLocation;
  /// show/hide the button to center the map on the user location.
  ///
  /// Requires showUserLocation to be true.
  final bool showMyLocationButton;
  /// show/hide the compass button on the map.
  ///
  /// Normally is not visible all the time. Becomes visible when the orientation
  /// of the map is changes through gesture.
  final bool showCompassButton;
  /// show/hide the toolbar while on the map activity/view.
  ///
  /// Actions passed to the MapView.show(MapOptions,<ToolbarAction>[]) function will not work
  /// because they will not be visible.
  final bool hideToolbar;
  final CameraPosition initialCameraPosition;
  final String title;
  static const CameraPosition _defaultCamera =
      const CameraPosition(const Location(45.5329661, -122.7059508), 12.0);
  MapViewType mapViewType;

  MapOptions(
      {this.showUserLocation: false,
      this.showMyLocationButton: false,
      this.showCompassButton: false,
      this.hideToolbar = false,
      this.initialCameraPosition: _defaultCamera,
      this.title: "",
      this.mapViewType: MapViewType.normal});

  Map<String, dynamic> toMap() {
    return {
      "showUserLocation": showUserLocation,
      "showMyLocationButton": showMyLocationButton,
      "showCompassButton": showCompassButton,
      "hideToolbar": hideToolbar,
      "cameraPosition": initialCameraPosition.toMap(),
      "title": title,
      "mapViewType": getMapTypeName(mapViewType)
    };
  }

  String getMapTypeName(MapViewType mapType) {
    String mapTypeName = "normal";
    switch (mapType) {
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
