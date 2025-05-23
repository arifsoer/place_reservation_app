import 'package:flutter/material.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/map_builder/area_editor.view.dart';
import 'package:place_reservation/modules/map_builder/level.model.dart';
import 'package:place_reservation/modules/map_builder/map.controller.dart';
import 'package:place_reservation/modules/map_builder/seat_qr.model.dart';
import 'package:provider/provider.dart';

import 'area.model.dart';

class BuilderListener {
  final List<Area> areas;
  final int? selectedIndex;
  final Currentcoordinate? currentCoordinates;
  final List<SeatQR> qrSeats;

  BuilderListener(
    this.areas,
    this.selectedIndex,
    this.currentCoordinates,
    this.qrSeats,
  );
}

class MapBuilderView extends StatefulWidget {
  const MapBuilderView({super.key});

  @override
  State<MapBuilderView> createState() => _MapBuilderViewState();
}

class _MapBuilderViewState extends State<MapBuilderView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapController>(
      builder: (context, controller, child) {
        List<LevelMap> leveList = controller.levels;
        int? selectedLevel = controller.selectedLevel;
        return controller.isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(defaultPadding * 0.5),
              child: Row(
                spacing: 0.5 * defaultPadding,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      spacing: 0.5 * defaultPadding,
                      children: [
                        Row(
                          spacing: defaultPadding * 0.5,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  () => controller.addNewMap(
                                    LevelMap(
                                      'Level ${leveList.length + 1}',
                                      leveList.length,
                                    ),
                                  ),
                              child: const Text('Add Level'),
                            ),
                            ElevatedButton(
                              onPressed:
                                  controller.isCurrentMapGenerating
                                      ? null
                                      : () {
                                        controller.generateCurrentMap();
                                      },
                              child:
                                  controller.isCurrentMapGenerating
                                      ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : const Text('Set as Current Use'),
                            ),
                          ],
                        ),
                        Text(
                          'Latest Generated: ${controller.currentMap?.createdAt}',
                        ),
                        if (!controller.isSeatQRCreatedAfterMap)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade400,
                              borderRadius: BorderRadius.circular(
                                0.5 * defaultPadding,
                              ),
                              border: Border.all(
                                color: Colors.deepOrange.shade900,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding,
                                vertical: defaultPadding * 0.5,
                              ),
                              child: Row(
                                spacing: defaultPadding * 0.5,
                                children: [
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    color: Colors.deepOrange.shade900,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'The QR code generated before the map, click Set as Current Map to generate Latest the QR code',
                                      style: TextStyle(
                                        color: Colors.deepOrange.shade900,
                                        fontSize: 0.8 * defaultPadding,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: leveList.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(
                                  height: defaultPadding * 0.5,
                                ),
                            itemBuilder: (context, index) {
                              final level = leveList[index];
                              return ListTile(
                                selected: index == selectedLevel,
                                tileColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    0.5 * defaultPadding,
                                  ),
                                ),
                                title: Text(level.name),
                                onTap:
                                    () => controller.changeSelectedLevel(index),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child:
                        controller.isFething
                            ? Center(child: CircularProgressIndicator())
                            : child!,
                  ),
                ],
              ),
            );
      },
      child: Selector<MapController, BuilderListener>(
        selector:
            (_, conttroller) => BuilderListener(
              conttroller.areas,
              conttroller.selectedLevel,
              conttroller.currentCoordinates,
              conttroller.qrSeats,
            ),
        builder:
            (context, value, child) => AreaEditor(
              areas: value.areas,
              selectedLevel: value.selectedIndex,
              currentCoordinates: value.currentCoordinates,
              qrSeats: value.qrSeats,
            ),
      ),
    );
  }
}
