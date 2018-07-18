import 'dart:ui';

class Marker {
  final String id;
  final String title;
  final double latitude;
  final double longitude;

  ///Marker Icon representation object.
  ///
  ///Setting this value replaces the attribute color.
  ///If the image can't be set, the color will be used with the default marker.
  final MarkerIcon markerIcon;

  ///The rotation of the marker in degrees clockwise from the default position.
  final double rotation;

  ///Color of the default marker.
  final Color color;

  ///Enables/disables the marker drag functionality.
  final bool draggable;

  static const Color _defaultColor = const Color(-769226);

  Marker(
    this.id,
    this.title,
    this.latitude,
    this.longitude, {
    this.rotation: 0.0,
    this.markerIcon,
    this.color: _defaultColor,
    this.draggable: false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Marker && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": id,
      "title": title,
      "latitude": latitude,
      "longitude": longitude,
      "rotation": rotation,
      "type": "pin",
      "draggable": draggable,
      "color": {
        "r": color.red,
        "g": color.green,
        "b": color.blue,
        "a": color.alpha
      }
    };
    if (markerIcon != null)
      map.putIfAbsent("markerIcon", () => markerIcon.toMap());
    return map;
  }
}

class MarkerIcon {
  ///Asset image to be set in the marker.
  String asset;

  ///Width of the image icon.
  ///
  ///Should not be 0.0, otherwise the image original width will be used.
  ///
  ///Sizes behave differently in each platform, so change this value to match
  ///the desired look in each platform.
  double width;

  ///Height of the image icon.
  ///
  ///Should not be 0.0, otherwise the image original height will be used.
  ///
  ///Sizes behave differently in each platform, so change this value to match
  ///the desired look in each platform.
  double height;

  MarkerIcon(
    this.asset, {
    this.width = 0.0,
    this.height = 0.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerIcon &&
          runtimeType == other.runtimeType &&
          asset == other.asset &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => asset.hashCode ^ width.hashCode ^ height.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "asset": asset,
      "width": width,
      "height": height,
    };
  }
}
