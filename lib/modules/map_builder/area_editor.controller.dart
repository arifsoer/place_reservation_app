import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';
import 'package:place_reservation/modules/map_builder/map.service.dart';

class AreaEditorController extends ChangeNotifier {
  final String levelid;
  final String areaid;

  bool isLoading = false;

  bool isNeedToSave = false;
  DocumentSnapshot<Area>? areaDoc;
  Area? _currentAreaData;
  int? _selectedSeat;

  Area? get area => areaDoc?.data();
  Area? get currentAreaData => _currentAreaData;
  int? get selectedSeat => _selectedSeat;

  AreaEditorController({required this.levelid, required this.areaid}) {
    loadArea();
  }

  Future<void> loadArea() async {
    isLoading = true;
    notifyListeners();

    areaDoc = await MapService.getAreaById(levelid, areaid);
    _currentAreaData = areaDoc?.data();

    isLoading = false;
    notifyListeners();
  }

  void setSelectedSeat(int? seat) {
    _selectedSeat = seat;
    notifyListeners();
  }

  void setToSave() {
    isNeedToSave = true;
    notifyListeners();
  }

  void updateSeat(int index, Seat seat) {
    if (area == null) return;
    _currentAreaData?.seats[index] = seat;
    setToSave();
    notifyListeners();
  }

  void addSeat() {
    if (area == null) return;
    _currentAreaData?.seats.add(
      Seat.newWithDefault(
        'Seat ${currentAreaData?.id.replaceAll('Area ', '')}-${_currentAreaData!.seats.length + 1}',
      ),
    );
    saveArea();
    notifyListeners();
  }

  void removeSeat() {
    if (area == null || selectedSeat == null) return;
    _currentAreaData?.seats.removeAt(selectedSeat!);
    saveArea();
    notifyListeners();
  }

  Future<void> saveArea() async {
    if (area == null) return;
    isLoading = true;
    notifyListeners();

    try {
      await MapService.updateArea(levelid, areaid, _currentAreaData!);
      isNeedToSave = false;
      _selectedSeat = null;
      await loadArea();
    } catch (e) {
      debugPrint('Error saving area: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
