import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/map_builder/area.model.dart';
import 'package:place_reservation/modules/map_builder/area_editor.controller.dart';
import 'package:provider/provider.dart';

class AreaBuilderView extends StatelessWidget {
  const AreaBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AreaEditorController>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.all(defaultPadding * 0.5),
          child: Row(
            spacing: 0.5 * defaultPadding,
            children: [
              Expanded(
                flex: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding * 0.5),
                    child: Column(
                      spacing: defaultPadding,
                      children: [
                        Text(
                          'Legends',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount:
                                controller.currentAreaData?.seats.length ?? 0,
                            separatorBuilder:
                                (context, index) => const SizedBox(
                                  height: defaultPadding * 0.5,
                                ),
                            itemBuilder: (context, index) {
                              final seat =
                                  controller.currentAreaData?.seats[index];
                              return ListTile(
                                title: Text(seat?.id ?? ''),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    defaultPadding * 0.5,
                                  ),
                                  side: BorderSide(color: Colors.black),
                                ),
                                tileColor: Colors.blue,
                                selected: controller.selectedSeat == index,
                                onTap: () {
                                  controller.setSelectedSeat(index);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: EditorBox(controller: controller, child: child),
              ),
            ],
          ),
        );
      },
      child: Selector<AreaEditorController, AreaEditorListener>(
        builder: (context, selectedValue, child) {
          return SeatEditor(
            area: selectedValue.area,
            selectedSeat: selectedValue.selectedSeat,
          );
        },
        selector:
            (_, controller) => AreaEditorListener(
              area: controller.area,
              selectedSeat: controller.selectedSeat,
            ),
      ),
    );
  }
}

class AreaEditorListener {
  final Area? area;
  final int? selectedSeat;

  AreaEditorListener({required this.area, required this.selectedSeat});
}

/// Inside consumer widget
class EditorBox extends StatelessWidget {
  const EditorBox({super.key, required this.controller, required this.child});

  final AreaEditorController controller;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var area = controller.area;
    return Column(
      spacing: defaultPadding * 0.5,
      children: [
        Row(
          spacing: defaultPadding * 0.5,
          children: [
            ElevatedButton(
              onPressed: () {
                controller.addSeat();
              },
              child: Text('Add Seat'),
            ),
            if (controller.selectedSeat != null)
              ElevatedButton(
                onPressed: () {
                  controller.removeSeat();
                },
                child: Text('Remove Seat'),
              ),
            if (controller.isNeedToSave)
              ElevatedButton(
                onPressed: () {
                  controller.saveArea();
                },
                child: Text('Save Area'),
              ),
          ],
        ),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
              ),
              child:
                  !controller.isLoading
                      ? Center(
                        child:
                            area != null
                                ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: defaultPadding,
                                  children: [
                                    Text(
                                      area.id,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                      ),
                                    ),
                                    SizedBox(
                                      width: area.width.toDouble(),
                                      height: area.height.toDouble(),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: child,
                                      ),
                                    ),
                                  ],
                                )
                                : SizedBox(
                                  child: Text(
                                    'No area selected',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                      )
                      : Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}

class SeatEditor extends StatefulWidget {
  const SeatEditor({super.key, required this.area, required this.selectedSeat});

  final Area? area;
  final int? selectedSeat;

  @override
  State<SeatEditor> createState() => _SeatEditorState();
}

class _SeatEditorState extends State<SeatEditor> {
  List<Seat> seats = [];

  @override
  void initState() {
    seats = widget.area?.seats ?? [];
    super.initState();
  }

  Widget buildBox(Seat seat) {
    var isSelected = widget.selectedSeat == seats.indexOf(seat);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.black,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(seat.id, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget buildUnselectSeat(Seat seat, BuildContext context) {
    return Positioned(
      left: seat.x,
      top: seat.y,
      child: GestureDetector(
        onTap: () {
          context.read<AreaEditorController>().setSelectedSeat(
            seats.indexOf(seat),
          );
        },
        child: SizedBox(width: 75, height: 75, child: buildBox(seat)),
      ),
    );
  }

  Widget buildSelectedSeat(Seat seat, BuildContext context) {
    return TransformableBox(
      rect: Rect.fromLTWH(seat.x, seat.y, 75, 75),
      clampingRect: Offset.zero & MediaQuery.sizeOf(context),
      onChanged: (result, event) {
        setState(() {
          seat.changePosition(result.rect.topLeft);
        });
        context.read<AreaEditorController>().updateSeat(
          seats.indexOf(seat),
          seat,
        );
        context.read<AreaEditorController>().setToSave();
      },
      resizable: false,
      contentBuilder: (context, rect, flip) => buildBox(seat),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          seats.map((seat) {
            return widget.selectedSeat == seats.indexOf(seat)
                ? buildSelectedSeat(seat, context)
                : buildUnselectSeat(seat, context);
          }).toList(),
    );
  }
}
