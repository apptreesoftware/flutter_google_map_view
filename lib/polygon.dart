import 'dart:ui';

import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/location.dart';

class Polygon {
  final String id;
  List<Location> points;
  List<Hole> holes;
  final double strokeWidth;
  final Color fillColor;
  final Color strokeColor;
  ///Only supported in Android. iOS don't have this for some reason.
  ///https://developers.google.com/android/reference/com/google/android/gms/maps/model/JointType
  final FigureJointType jointType;

  static const Color _defaultColor = const Color(-769226);
  static const double _defaultWidth = 10.0;
  static const FigureJointType _defaultJointType = FigureJointType.def;
  static const List<Hole> _defaultHoles = <Hole>[];

  Polygon(
    this.id,
    this.points, {
    this.fillColor: _defaultColor,
    this.strokeColor: _defaultColor,
    this.strokeWidth: _defaultWidth,
    this.jointType: _defaultJointType,
    this.holes: _defaultHoles,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Polygon && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "points": Location.listToMap(points),
      "holes": Hole.listToMap(holes),
      "strokeWidth": strokeWidth,
      "jointType": jointType.value,
      "fillColor": {
        "r": fillColor.red,
        "g": fillColor.green,
        "b": fillColor.blue,
        "a": fillColor.alpha
      },
      "strokeColor": {
        "r": strokeColor.red,
        "g": strokeColor.green,
        "b": strokeColor.blue,
        "a": strokeColor.alpha
      },
    };
  }
}

class Hole {
  List<Location> points = [];

  Hole(this.points);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hole &&
          runtimeType == other.runtimeType &&
          points == other.points;

  @override
  int get hashCode => points.hashCode;

  static listToMap(List<Hole> holes) {
    List<Map<String, dynamic>> result = [];
    for (var element in holes) {
      result.add(element.toMap());
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      "points": Location.listToMap(points),
    };
  }
}
