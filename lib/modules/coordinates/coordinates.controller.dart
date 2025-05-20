import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/coordinates/coordinates.service.dart';
import 'package:place_reservation/util.dart';

class CoordinatesController extends ChangeNotifier {
  DocumentSnapshot<Currentcoordinate>? _coordinatesSnapshot;

  bool isLoading = false;

  CoordinatesController() {
    dataInitialization();
  }

  Currentcoordinate? get coordinates {
    if (_coordinatesSnapshot != null) {
      return _coordinatesSnapshot!.data();
    }
    return null;
  }

  Future<void> dataInitialization() async {
    isLoading = true;
    notifyListeners();

    try {
      if (_coordinatesSnapshot != null) {
        _coordinatesSnapshot = await CoordinatesService.getCoordinates();
      } else {
        _coordinatesSnapshot = null;
      }
    } catch (e) {
      debugPrint('Error fetching coordinates: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ControllerResponse> setCoordinates(
    Currentcoordinate coordinates,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      await CoordinatesService.setCoordinates(coordinates);
      _coordinatesSnapshot = await CoordinatesService.getCoordinates();
      notifyListeners();
      return ControllerResponse(statusCode: ResponseStatusCode.success);
    } catch (e) {
      debugPrint('Error adding coordinates: $e');
      return ControllerResponse(
        statusCode: ResponseStatusCode.error,
        message: 'Failed to add coordinates',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
