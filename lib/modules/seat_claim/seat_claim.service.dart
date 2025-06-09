import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/seat_claim/seat_claim.dart';

const _seatClaimCollection = 'seat_claims';
final _seatClaimConverter = firestoreIntance
    .collection(_seatClaimCollection)
    .withConverter<SeatClaim>(
      fromFirestore: (snapshot, _) => SeatClaim.fromJson(snapshot.data()!),
      toFirestore: (seatClaim, _) => seatClaim.toJson(),
    );

class SeatClaimService {
  static Future<void> addSeatClaim(SeatClaim seatClaim) async {
    try {
      await _seatClaimConverter.add(seatClaim);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to add new seat claim: $e');
    }
  }
}
