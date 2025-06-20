import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.model.dart';

const _seatPlanCollection = 'seat_plan';
final _seatPlanCollectionRef = firestoreIntance.collection(_seatPlanCollection);
final _seatPlanConverter = _seatPlanCollectionRef.withConverter<SeatPlan>(
  fromFirestore: (snapshot, _) => SeatPlan.fromJson(snapshot.data()!),
  toFirestore: (seats, _) => seats.toJson(),
);

class SeatPlanService {
  static Future<void> addSeatPlan(SeatPlan seatPlan) async {
    try {
      await _seatPlanConverter.add(seatPlan);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to add new seat plan: $e');
    }
  }

  static Future<void> updateSeatPlan(String id, SeatPlan seatPlan) async {
    try {
      await _seatPlanConverter.doc(id).update(seatPlan.toJson());
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to update seat plan: $e');
    }
  }

  static Future<List<QueryDocumentSnapshot<SeatPlan>>>
  getSeatPlansByDateAndSeat(String seatId, DateTime date) async {
    try {
      final buildDate = DateTime(date.year, date.month, date.day);
      final snapshot =
          await _seatPlanConverter
              .where('seat_id', isEqualTo: seatId)
              .where(
                'planned_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(buildDate),
              )
              .where(
                'planned_date',
                isLessThan: Timestamp.fromDate(
                  buildDate.add(const Duration(days: 1)),
                ),
              )
              .where('claimed_date', isNull: true)
              .get();
      return snapshot.docs;
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<QueryDocumentSnapshot<SeatPlan>>>
  getUpcomingSeatPlansByUser(String userId, DateTime todayDate) async {
    try {
      var buildDate = DateTime(todayDate.year, todayDate.month, todayDate.day);
      final snapshot =
          await _seatPlanConverter
              .where('user_id', isEqualTo: userId)
              .where(
                'planned_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(buildDate),
              )
              .get();
      return snapshot.docs;
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
}
