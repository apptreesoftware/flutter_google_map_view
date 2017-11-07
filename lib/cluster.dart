import 'dart:ui';

import 'package:map_view/marker.dart';

class Cluster extends Marker {
  final int clusterCount;

  Cluster(String id, String title, double latitude, double longitude,
      this.clusterCount, Color color)
      : super(id, title, latitude, longitude, color: color);

  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map["type"] = "cluster";
    map["clusterCount"] = clusterCount;
    return map;
  }
}
