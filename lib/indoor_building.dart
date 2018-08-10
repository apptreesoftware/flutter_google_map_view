class IndoorBuilding {
  final bool underground;
  final int defaultIndex;
  final List<IndoorLevel> levels;

  IndoorBuilding(this.underground, this.defaultIndex, this.levels);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndoorBuilding &&
          runtimeType == other.runtimeType &&
          underground == other.underground &&
          defaultIndex == other.defaultIndex &&
          levels == other.levels;

  @override
  int get hashCode =>
      underground.hashCode ^ defaultIndex.hashCode ^ levels.hashCode;

  @override
  String toString() {
    return 'IndoorBuilding{underground: $underground, defaultIndex: $defaultIndex, levels: $levels}';
  }
}

class IndoorLevel {
  final String name;
  final String shortName;

  IndoorLevel(this.name, this.shortName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndoorLevel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          shortName == other.shortName;

  @override
  int get hashCode => name.hashCode ^ shortName.hashCode;

  @override
  String toString() {
    return 'IndoorLevel{name: $name, shortName: $shortName}';
  }
}
