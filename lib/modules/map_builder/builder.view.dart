import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:localstorage/localstorage.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/helpers.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/map_builder/level.model.dart';
import 'package:place_reservation/modules/map_builder/map.controller.dart';
import 'package:place_reservation/modules/map_builder/seat_qr.model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'area.model.dart';

class BuilderListener {
  final List<Area> areas;
  final int? selectedIndex;
  final Currentcoordinate? currentCoordinates;
  BuilderListener(this.areas, this.selectedIndex, this.currentCoordinates);
}

class MapBuilderView extends StatelessWidget {
  const MapBuilderView({super.key});

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
            ),
        builder:
            (context, value, child) => AreaEditor(
              areas: value.areas,
              selectedLevel: value.selectedIndex,
              currentCoordinates: value.currentCoordinates,
            ),
      ),
    );
  }
}

class AreaEditor extends StatefulWidget {
  const AreaEditor({
    super.key,
    required this.areas,
    required this.selectedLevel,
    required this.currentCoordinates,
  });

  final List<Area> areas;
  final int? selectedLevel;
  final Currentcoordinate? currentCoordinates;

  @override
  State<AreaEditor> createState() => _AreaEditorState();
}

class _AreaEditorState extends State<AreaEditor> {
  List<Area> maps = [];
  bool isEdited = false;

  @override
  void initState() {
    super.initState();
    maps = widget.areas;
  }

  Widget buildSeat(Seat seat) {
    return Positioned(
      left: seat.x,
      top: seat.y,
      child: GestureDetector(
        onTap: () {
          var seatQr = SeatQR(
            seatId: seat.id,
            x: widget.currentCoordinates?.x ?? 0,
            y: widget.currentCoordinates?.y ?? 0,
          );
          showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: defaultPadding * 0.5,
                      children: [
                        Text('Seat QR Code for ${seat.id}'),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: QrImageView(
                            data: '$seatQr',
                            version: QrVersions.auto,
                            size: 320,
                            gapless: false,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        },
        child: SizedBox(
          width: 75,
          height: 75,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(seat.id, style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  DecoratedBox buildBox(Area map) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            ...(map.seats.map((seat) => buildSeat(seat))),
            Center(child: Text(map.id, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Positioned buildUnSelectedArea(Area map) {
    return Positioned(
      left: map.x,
      top: map.y,
      width: map.width,
      height: map.height,
      child: GestureDetector(
        onTap: () {
          setState(() {
            for (var element in maps) {
              element.isSelected = false;
            }
            map.isSelected = true;
          });
        },
        child: buildBox(map),
      ),
    );
  }

  TransformableBox buildSelectedArea(Area map, BuildContext context) {
    return TransformableBox(
      rect: Rect.fromLTWH(map.x, map.y, map.width, map.height),
      clampingRect: Offset.zero & MediaQuery.sizeOf(context),
      onChanged: (result, event) {
        setState(() {
          map.changeRect(result.rect);
          isEdited = true;
        });
      },
      contentBuilder: (context, rect, flip) => buildBox(map),
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedAreaIndex = maps.indexWhere((element) => element.isSelected);
    var hasSelectedArea = selectedAreaIndex != -1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 0.5 * defaultPadding,
      children: [
        Row(
          spacing: defaultPadding * 0.5,
          children:
              widget.selectedLevel != null
                  ? [
                    ElevatedButton(
                      onPressed: () {
                        var level = context.read<MapController>().level;
                        var areaName =
                            'Area ${(level?.name ?? '').replaceAll('Level ', '')}${indexToLetter(maps.length)}';
                        Area newArea = Area.newWithDefault(areaName);
                        Provider.of<MapController>(
                          context,
                          listen: false,
                        ).addNewArea(newArea);
                      },
                      child: const Text('Add Area'),
                    ),
                    if (hasSelectedArea)
                      ElevatedButton(
                        onPressed: () {
                          var selectedAreaIndex = maps.indexWhere(
                            (element) => element.isSelected,
                          );
                          var argument = context
                              .read<MapController>()
                              .getAreaArgument(selectedAreaIndex);
                          localStorage.setItem(
                            'areadEditorVal',
                            jsonEncode(argument),
                          );
                          Navigator.pushNamed(context, '/area-builder');
                        },
                        child: const Text('Edit Selected Area'),
                      ),
                    if (isEdited)
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<MapController>(
                            context,
                            listen: false,
                          ).updateAllAreas().then((value) {
                            setState(() {
                              isEdited = false;
                              for (var element in maps) {
                                element.isSelected = false;
                              }
                            });
                          });
                        },
                        child: const Text('Save Area Position'),
                      ),
                  ]
                  : [],
        ),
        Expanded(
          child: GestureDetector(
            onTap:
                () => {
                  setState(() {
                    for (var element in maps) {
                      element.isSelected = false;
                    }
                  }),
                },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child:
                  maps.isNotEmpty
                      ? Stack(
                        fit: StackFit.expand,
                        children:
                            maps
                                .map(
                                  (map) =>
                                      map.isSelected
                                          ? buildSelectedArea(map, context)
                                          : buildUnSelectedArea(map),
                                )
                                .toList(),
                      )
                      : Center(
                        child: Text(
                          widget.selectedLevel != null
                              ? 'No area added yet'
                              : 'no level selected',
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
