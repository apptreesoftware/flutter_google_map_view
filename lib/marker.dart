import 'dart:ui';

class Marker {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final Color color;

  static const Color _defaultColor = const Color.fromARGB(1, 255, 0, 0);

  Marker(this.id, this.title, this.latitude, this.longitude,
      {this.color: _defaultColor});


  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "latitude": latitude,
      "longitude": longitude,
      "type": "pin",
      "color": {
        "r": color.red,
        "g": color.green,
        "b": color.blue,
        "a": color.alpha
      }
    };
  }
}
