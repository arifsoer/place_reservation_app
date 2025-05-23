import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/coordinates/coordinates.service.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';
import 'package:place_reservation/modules/map_builder/current_map.model.dart';
import 'package:place_reservation/modules/map_builder/level.model.dart';
import 'package:place_reservation/modules/map_builder/map.service.dart';
import 'package:place_reservation/modules/map_builder/seat-qr.service.dart';
import 'package:place_reservation/modules/map_builder/seat_qr.model.dart';

class MapController extends ChangeNotifier {
  List<QueryDocumentSnapshot<LevelMap>> docLevels = [];
  List<LevelMap> levels = [];
  int? selectedLevel;

  List<QueryDocumentSnapshot<SeatQR>> _docSeatsQR = [];
  DateTime? _seatQRCreatedAt;

  List<QueryDocumentSnapshot<Area>> docAreas = [];
  List<Area> areas = [];

  CurrentMap? _currentMapLib;

  DocumentSnapshot<Currentcoordinate>? _currentCoordinatesSnapshot;

  bool isLoading = false;
  bool isFething = false;
  bool isCurrentMapGenerating = false;

  QueryDocumentSnapshot<LevelMap>? get levelDoc =>
      selectedLevel != null ? docLevels[selectedLevel!] : null;
  LevelMap? get level => selectedLevel != null ? levels[selectedLevel!] : null;

  Currentcoordinate? get currentCoordinates {
    if (_currentCoordinatesSnapshot != null) {
      return _currentCoordinatesSnapshot!.data();
    }
    return null;
  }

  CurrentMap? get currentMap {
    if (_currentMapLib != null) {
      return _currentMapLib;
    }
    return null;
  }

  DateTime? get seatQRCreatedAt => _seatQRCreatedAt;
  bool get isSeatQRCreatedAfterMap =>
      _docSeatsQR.isNotEmpty &&
      _docSeatsQR[0].data().createdAt != null &&
      currentMap != null &&
      (_docSeatsQR[0].data().createdAt!.isAfter(currentMap!.createdAt) ||
          _docSeatsQR[0].data().createdAt!.isAtSameMomentAs(
            currentMap!.createdAt,
          ));
  List<SeatQR> get qrSeats => _docSeatsQR.map((doc) => doc.data()).toList();

  MapController() {
    // Initialize the controller with some default values or fetch from a service
    dataInitialization();
  }

  String? getSeatQrId(int seatIndex) {
    if (_docSeatsQR.isNotEmpty) {
      var seatQr = _docSeatsQR[seatIndex];
      return seatQr.id;
    }
    return null;
  }

  Map<String, String> getAreaArgument(int areaIndex) {
    if (levelDoc == null) return {};
    var docArea = docAreas[areaIndex];
    return {'levelId': levelDoc!.id, 'areaId': docArea.id};
  }

  Future<void> intialSelectedLevel() async {
    if (docLevels.isNotEmpty) {
      selectedLevel = 0;
      final List<QueryDocumentSnapshot<Area>> areaSnapshots =
          await MapService.getAreas(levelDoc!.id);
      docAreas = areaSnapshots;
      areas = areaSnapshots.map((doc) => doc.data()).toList();
    } else {
      selectedLevel = null;
      docAreas = [];
      areas = [];
    }
    notifyListeners();
  }

  Future<void> dataInitialization() async {
    isLoading = true;
    notifyListeners();

    // Fetch levels and areas from the service
    final fethedLevels = await MapService.getLevels();
    docLevels = fethedLevels;
    levels = fethedLevels.map((doc) => doc.data()).toList();
    selectedLevel = null;

    // fetch Currect Coordinates
    _currentCoordinatesSnapshot = await CoordinatesService.getCoordinates();

    // to get Seats QR
    _docSeatsQR = await SeatQRService.getSeatQr();
    if (_docSeatsQR.isNotEmpty) {
      _seatQRCreatedAt = _docSeatsQR[0].data().createdAt;
    }

    isLoading = false;
    isCurrentMapGenerating = true;
    notifyListeners();

    getLatestCurrentMap();
  }

  Future<void> getQrSeats() async {
    _docSeatsQR = await SeatQRService.getSeatQr();
    if (_docSeatsQR.isNotEmpty) {
      _seatQRCreatedAt = _docSeatsQR[0].data().createdAt;
    }
    notifyListeners();
  }

  Future<void> getLatestCurrentMap() async {
    MapService.getLatestCurrentMap()
        .then((currentMapSnap) {
          if (currentMapSnap != null) {
            _currentMapLib = currentMapSnap.data();
          } else {
            _currentMapLib = null;
          }
          isCurrentMapGenerating = false;
          notifyListeners();
        })
        .catchError((error) {
          debugPrint('Error fetching current map: $error');
        })
        .whenComplete(() {
          isCurrentMapGenerating = false;
          notifyListeners();
        });
  }

  void addNewMap(LevelMap newLevel) async {
    await MapService.addNewLevel(newLevel);
    dataInitialization();

    notifyListeners();
  }

  Future<void> updateAllAreas() async {
    if (levelDoc == null) return;
    for (int i = 0; i < docAreas.length; i++) {
      var doc = docAreas[i];
      await MapService.updateArea(levelDoc!.id, doc.id, areas[i]);
    }
  }

  void changeSelectedLevel(int index) async {
    selectedLevel = index;
    isFething = true;
    notifyListeners();

    final List<QueryDocumentSnapshot<Area>> areaSnapshots =
        await MapService.getAreas(levelDoc!.id);
    docAreas = areaSnapshots;
    areas = areaSnapshots.map((doc) => doc.data()).toList();

    isFething = false;
    notifyListeners();
  }

  void addNewArea(Area newArea) {
    areas.add(newArea);
    MapService.addNewArea(levelDoc!.id, newArea);
    updateAllAreas();
    notifyListeners();
  }

  Future<void> generateCurrentMap() async {
    isCurrentMapGenerating = true;
    notifyListeners();

    List<CurrentLevel> currentLevels = [];
    List<String> seats = [];
    for (int i = 0; i < docLevels.length; i++) {
      var levelDoc = docLevels[i];
      var areaSnapshots = await MapService.getAreas(levelDoc.id);
      for (var snapshotArea in areaSnapshots) {
        var area = snapshotArea.data();
        seats.addAll(area.seats.map((seat) => seat.id).toList());
      }
      currentLevels.add(
        CurrentLevel(
          name: levelDoc.data().name,
          areas:
              areaSnapshots
                  .map((doc) => CurrentArea.fromArea(doc.data()))
                  .toList(),
        ),
      );
    }

    final newCurrentMap = CurrentMap(
      levels: currentLevels,
      createdAt: DateTime.now(),
    );
    final seat = Seats(seats: seats, createdAt: DateTime.now());

    // generate List of QR Codes
    for (var seatId in seats) {
      var seatQr = SeatQR(
        seatId: seatId,
        x: currentCoordinates?.x ?? 0,
        y: currentCoordinates?.y ?? 0,
        createdAt: DateTime.now(),
      );
      await SeatQRService.addSeatQr(seatQr);
    }

    await MapService.setCurrentMap(newCurrentMap);
    await MapService.setCurrentSeats(seat);

    await getLatestCurrentMap();
    await getQrSeats();
    isCurrentMapGenerating = false;
    notifyListeners();
  }
}
