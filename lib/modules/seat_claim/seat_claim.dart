import 'package:cloud_firestore/cloud_firestore.dart';

class SeatClaim {
  final String seatId;
  final String userId;
  final String userName;
  final String userEmail;
  final bool isPlanned;
  final DateTime claimedDate;

  SeatClaim({
    required this.seatId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.isPlanned,
    required this.claimedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'seat_id': seatId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'is_planned': isPlanned,
      'claimed_date': claimedDate.toIso8601String(),
    };
  }

  static SeatClaim fromJson(Map<String, dynamic> json) {
    return SeatClaim(
      seatId: json['seat_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userEmail: json['user_email'] as String,
      isPlanned: json['is_planned'] as bool,
      claimedDate: (json['claimed_date'] as Timestamp).toDate(),
    );
  }
}
