import 'package:cloud_firestore/cloud_firestore.dart';

class SeatPlan {
  String seatId;
  String userId;
  String userName;
  String userEmail;
  DateTime plannedDate;
  DateTime? claimedDate;

  SeatPlan({
    required this.seatId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.plannedDate,
    required this.claimedDate,
  });

  toJson() {
    return {
      'seat_id': seatId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'planned_date': plannedDate,
      'claimed_date': claimedDate,
    };
  }

  static SeatPlan fromJson(Map<String, dynamic> json) {
    return SeatPlan(
      seatId: json['seat_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userEmail: json['user_email'] as String,
      plannedDate: (json['planned_date'] as Timestamp).toDate(),
      claimedDate:
          json['claimed_date'] != null
              ? (json['claimed_date'] as Timestamp).toDate()
              : null,
    );
  }
}
