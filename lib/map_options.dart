import 'package:map_view/camera_position.dart';
import 'package:map_view/location.dart';

class MapOptions {
  final bool showUserLocation;
  final CameraPosition initialCameraPosition;
  final String title;
  static const CameraPosition _defaultCamera =
      const CameraPosition(const Location(45.5329661, -122.7059508), 12.0);

  MapOptions(
      {this.showUserLocation: false,
      this.initialCameraPosition: _defaultCamera,
      this.title: ""});

  Map<String, dynamic> toMap() {
    return {
      "showUserLocation": showUserLocation,
      "cameraPosition": initialCameraPosition.toMap(),
      "title": title
    };
  }
}
