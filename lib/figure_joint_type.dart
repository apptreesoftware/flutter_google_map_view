class FigureJointType {
  const FigureJointType._(this.value);

  final int value;

  ///Default: Mitered joint, with fixed pointed extrusion equal to half the stroke width on the outside of the joint.
  ///
  /// See: https://developers.google.com/android/reference/com/google/android/gms/maps/model/JointType
  static const FigureJointType def = const FigureJointType._(0);

  ///Flat bevel on the outside of the joint.
  ///
  /// See: https://developers.google.com/android/reference/com/google/android/gms/maps/model/JointType
  static const FigureJointType bevel = const FigureJointType._(1);

  ///Rounded on the outside of the joint by an arc of radius equal to half the stroke width, centered at the vertex.
  ///
  /// See: https://developers.google.com/android/reference/com/google/android/gms/maps/model/JointType
  static const FigureJointType round = const FigureJointType._(2);
}
