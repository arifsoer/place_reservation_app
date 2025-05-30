import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/map_builder/seat_qr.model.dart';

const _seatQrCollection = 'seat_qr';
final _seatQrRef = firestoreIntance.collection(_seatQrCollection);
final _seatQrConverter = _seatQrRef.withConverter<SeatQR>(
  fromFirestore: (snapshot, _) => SeatQR.fromJson(snapshot.data()!),
  toFirestore: (seatQr, _) => seatQr.toJson(),
);

class SeatQRService {
  static Future<void> addSeatQr(SeatQR seatQR) async {
    try {
      await _seatQrConverter.add(seatQR);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to add new seat QR: $e');
    }
  }

  static Future<List<QueryDocumentSnapshot<SeatQR>>> getSeatQr() async {
    try {
      final snapshot = await _seatQrConverter.get();
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

  static Future<DocumentSnapshot<SeatQR>?> getSeatQrById(String id) async {
    try {
      final doc = await _seatQrConverter.doc(id).get();
      if (doc.exists) {
        return doc;
      } else {
        debugPrint('No SeatQR found with id: $id');
        return null;
      }
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
