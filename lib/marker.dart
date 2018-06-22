import 'dart:ui';

class Marker {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String icon;
  final Color color;
  final bool draggable;

  static const Color _defaultColor = const Color(-769226);

  Marker(
    this.id,
    this.title,
    this.latitude,
    this.longitude, {
    this.icon: "",
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
    return {
      "id": id,
      "title": title,
      "latitude": latitude,
      "longitude": longitude,
      "icon": icon != null ? icon : "",
      "type": "pin",
      "draggable": draggable,
      "color": {
        "r": color.red,
        "g": color.green,
        "b": color.blue,
        "a": color.alpha
      }
    };
  }
}
