import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:place_reservation/constant.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';
import 'package:place_reservation/modules/map_builder/current_map.model.dart';
import 'package:place_reservation/modules/map_builder/level.model.dart';

const levelCollection = 'levels';
final levelColRefference = firestoreIntance
    .collection(levelCollection)
    .withConverter<LevelMap>(
      fromFirestore: (snapshot, _) => LevelMap.fromJson(snapshot.data()!),
      toFirestore: (levelMap, _) => levelMap.toJson(),
    );

const _currentMapId = 'current_map';
const _currentSeats = 'current_seats';
const _currentMapCollection = 'current_map';
final _currentMapColRefference = firestoreIntance.collection(
  _currentMapCollection,
);
final _currentMapConverter = _currentMapColRefference.withConverter<CurrentMap>(
  fromFirestore: (snapshot, _) => CurrentMap.fromJson(snapshot.data()!),
  toFirestore: (currentMap, _) => currentMap.toJson(),
);
final _currentSeatsConverter = _currentMapColRefference.withConverter<Seats>(
  fromFirestore: (snapshot, _) => Seats.fromJson(snapshot.data()!),
  toFirestore: (seats, _) => seats.toJson(),
);

class MapService {
  static Future<DocumentReference<LevelMap>> addNewLevel(LevelMap level) async {
    try {
      return await levelColRefference.add(level);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to add new level: $e');
    }
  }

  static Future<List<QueryDocumentSnapshot<LevelMap>>> getLevels() async {
    try {
      final snapshot = await levelColRefference.orderBy('order').get();
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

  static CollectionReference<Area> getAreasCollection(String levelId) {
    final levelDocRef = levelColRefference.doc(levelId);
    return levelDocRef
        .collection('areas')
        .withConverter<Area>(
          fromFirestore: (snapshot, _) => Area.fromJson(snapshot.data()!),
          toFirestore: (area, _) => area.toJson(),
        );
  }

  static Future<void> addNewArea(String levelId, Area area) async {
    try {
      final areaCollectionRef = getAreasCollection(levelId);
      await areaCollectionRef.add(area);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<void> updateArea(
    String levelId,
    String areaId,
    Area area,
  ) async {
    try {
      final areaCollectionRef = getAreasCollection(levelId);
      await areaCollectionRef.doc(areaId).set(area);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<List<QueryDocumentSnapshot<Area>>> getAreas(
    String levelId,
  ) async {
    try {
      final areaCollectionRef = getAreasCollection(levelId);
      final snapshot = await areaCollectionRef.get();
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

  static Future<DocumentSnapshot<Area>?> getAreaById(
    String levelId,
    String areaId,
  ) async {
    try {
      final areaCollectionRef = getAreasCollection(levelId);
      final doc = await areaCollectionRef.doc(areaId).get();
      return doc;
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

  static Future<void> setCurrentMap(CurrentMap currentMap) async {
    try {
      await _currentMapConverter.doc(_currentMapId).set(currentMap);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<void> setCurrentSeats(Seats seats) async {
    try {
      await _currentSeatsConverter.doc(_currentSeats).set(seats);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.message}');
      rethrow; // Optionally rethrow the error for higher-level handling
    } catch (e, stackTrace) {
      // Handle general errors
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static Future<DocumentSnapshot<CurrentMap>?> getLatestCurrentMap() async {
    try {
      final snapshot = await _currentMapConverter.doc(_currentMapId).get();
      if (snapshot.exists) {
        return snapshot;
      } else {
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

  static Future<DocumentSnapshot<Seats>?> getCurrentSeats() async {
    try {
      final snapshot = await _currentSeatsConverter.doc(_currentSeats).get();
      if (snapshot.exists) {
        return snapshot;
      } else {
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
