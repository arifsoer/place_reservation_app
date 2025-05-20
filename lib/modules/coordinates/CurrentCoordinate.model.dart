import 'package:cloud_firestore/cloud_firestore.dart';

class Currentcoordinate {
  final double x;
  final double y;
  final DateTime lastUpdated;

  Currentcoordinate({
    required this.x,
    required this.y,
    required this.lastUpdated,
  });

  toJson() {
    return {'x': x, 'y': y, 'lastUpdated': lastUpdated};
  }

  static Currentcoordinate fromJson(Map<String, dynamic> json) {
    return Currentcoordinate(
      x: json['x'] as double,
      y: json['y'] as double,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
