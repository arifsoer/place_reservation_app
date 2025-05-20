class LevelMap {
  final String name;
  final int order;
  bool isSelected = false;

  LevelMap(this.name, this.order);
  LevelMap.newWithDefault(this.name, this.order);

  toJson() {
    return {'name': name, 'order': order};
  }

  static fromJson(Map<String, dynamic> json) {
    return LevelMap(json['name'] as String, json['order'] as int);
  }
}
