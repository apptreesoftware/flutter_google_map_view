class ToolbarAction {
  final String title;
  final int identifier;

  /// Show the button in the toolbar only if there is room.
  /// DEFAULTS to false
  /// Only works on Android
  bool showIfRoom = false;

  ToolbarAction(this.title, this.identifier);

  Map get toMap => {"title": title, "identifier": identifier};
}
