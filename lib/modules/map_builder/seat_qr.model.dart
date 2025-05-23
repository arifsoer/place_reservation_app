import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SeatQR {
  final String seatId;
  final double x;
  final double y;
  final DateTime? createdAt;

  SeatQR({
    required this.seatId,
    required this.x,
    required this.y,
    required this.createdAt,
  });

  @override
  String toString() {
    var seatQR = {'seatId': seatId, 'x': x, 'y': y};
    return jsonEncode(seatQR);
  }

  Map<String, dynamic> toJson() {
    return {'seatId': seatId, 'x': x, 'y': y, 'createdAt': createdAt};
  }

  static SeatQR fromJson(Map<String, dynamic> json) {
    return SeatQR(
      seatId: json['seatId'] as String,
      x: json['x'] as double,
      y: json['y'] as double,
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : null,
    );
  }
}
