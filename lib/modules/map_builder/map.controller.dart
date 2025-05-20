import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/coordinates/coordinates.service.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';
import 'package:place_reservation/modules/map_builder/current_map.model.dart';
import 'package:place_reservation/modules/map_builder/level.model.dart';
import 'package:place_reservation/modules/map_builder/map.service.dart';

class MapController extends ChangeNotifier {
  List<QueryDocumentSnapshot<LevelMap>> docLevels = [];
  List<LevelMap> levels = [];
  int? selectedLevel;

  List<QueryDocumentSnapshot<Area>> docAreas = [];
  List<Area> areas = [];

  CurrentMap? currentMap;

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

  MapController() {
    // Initialize the controller with some default values or fetch from a service
    dataInitialization();
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

    isLoading = false;
    isCurrentMapGenerating = true;
    notifyListeners();

    getLatestCurrentMap();
  }

  Future<void> getLatestCurrentMap() async {
    MapService.getLatestCurrentMap()
        .then((currentMapSnap) {
          if (currentMapSnap != null) {
            currentMap = currentMapSnap.data();
          } else {
            currentMap = null;
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

    await MapService.setCurrentMap(newCurrentMap);
    await MapService.setCurrentSeats(seat);

    await getLatestCurrentMap();
    isCurrentMapGenerating = false;
    notifyListeners();
  }
}
