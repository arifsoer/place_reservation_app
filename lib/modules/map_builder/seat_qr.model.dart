import 'dart:convert';

class SeatQR {
  final String seatId;
  final double x;
  final double y;

  SeatQR({required this.seatId, required this.x, required this.y});

  @override
  String toString() {
    var seatQR = {'seatId': seatId, 'x': x, 'y': y};
    return jsonEncode(seatQR);
  }

  Map<String, dynamic> toJson() {
    return {'seatId': seatId, 'x': x, 'y': y};
  }

  static SeatQR fromJson(Map<String, dynamic> json) {
    return SeatQR(
      seatId: json['seatId'] as String,
      x: json['x'] as double,
      y: json['y'] as double,
    );
  }
}
