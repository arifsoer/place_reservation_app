import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';

const _coodinatesCollection = 'current_coordinates';
const _coordinatesId = 'coordinates_id';
final _coordinatesRef = firestoreIntance.collection(_coodinatesCollection);
final _coordinatesConverter = _coordinatesRef.withConverter<Currentcoordinate>(
  fromFirestore: (snapshot, _) => Currentcoordinate.fromJson(snapshot.data()!),
  toFirestore: (coordinates, _) => coordinates.toJson(),
);

class CoordinatesService {
  static Future<void> setCoordinates(Currentcoordinate coordinates) async {
    try {
      await _coordinatesConverter.doc(_coordinatesId).set(coordinates);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to add new coordinates: $e');
    }
  }

  static Future<DocumentSnapshot<Currentcoordinate>?> getCoordinates() async {
    try {
      final snapshot = await _coordinatesConverter.doc(_coordinatesId).get();
      if (snapshot.exists) {
        return snapshot;
      } else {
        debugPrint('No coordinates found');
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
