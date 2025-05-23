import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:localstorage/localstorage.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/helpers.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';
import 'package:place_reservation/modules/map_builder/map.controller.dart';
import 'package:place_reservation/modules/map_builder/seat_qr.model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AreaEditor extends StatefulWidget {
  const AreaEditor({
    super.key,
    required this.areas,
    required this.selectedLevel,
    required this.currentCoordinates,
    required this.qrSeats,
  });

  final List<Area> areas;
  final int? selectedLevel;
  final Currentcoordinate? currentCoordinates;
  final List<SeatQR> qrSeats;

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
    var isQrGenerated = widget.qrSeats.any(
      (element) => element.seatId == seat.id,
    );
    SeatQR? seatQr =
        isQrGenerated
            ? widget.qrSeats.firstWhere((element) => element.seatId == seat.id)
            : null;
    return Positioned(
      left: seat.x,
      top: seat.y,
      child: GestureDetector(
        onTap:
            !isQrGenerated
                ? null
                : () {
                  var seatQrId = Provider.of<MapController>(
                    context,
                    listen: false,
                  ).getSeatQrId(widget.qrSeats.indexOf(seatQr!));
                  if (seatQrId != null) {
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
                                      data: seatQrId,
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
                  }
                },
        child: SizedBox(
          width: 75,
          height: 75,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isQrGenerated ? Colors.green : Colors.grey,
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
