import 'dart:ui';

import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/location.dart';

class Polyline {
  final String id;
  List<Location> points;
  ///Only supported in Android. iOS don't have this for some reason.
  ///https://developers.google.com/android/reference/com/google/android/gms/maps/model/JointType
  final FigureJointType jointType;
  final double width;
  final Color color;

  static const Color _defaultColor = const Color(-769226);
  static const double _defaultWidth = 10.0;
  static const FigureJointType _defaultJointType = FigureJointType.def;

  Polyline(
    this.id,
    this.points, {
    this.color: _defaultColor,
    this.width: _defaultWidth,
    this.jointType: _defaultJointType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Polyline && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "points": Location.listToMap(points),
      "width": width,
      "jointType": jointType.value,
      "color": {
        "r": color.red,
        "g": color.green,
        "b": color.blue,
        "a": color.alpha
      }
    };
  }
}
