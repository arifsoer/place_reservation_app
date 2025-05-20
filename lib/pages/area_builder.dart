import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:place_reservation/modules/map_builder/area_builder.view.dart';
import 'package:place_reservation/modules/map_builder/area_editor.controller.dart';
import 'package:provider/provider.dart';

class AreaBuilderPage extends StatelessWidget {
  const AreaBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? fromLocalStorage = localStorage.getItem('areadEditorVal');
    Map<String, dynamic>? arg =
        fromLocalStorage != null ? jsonDecode(fromLocalStorage) : null;

    AppBar appBar = AppBar(title: const Text('Area Builder'));

    if (arg == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: Text('No Arguments Provided')),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: ChangeNotifierProvider(
        create:
            (context) => AreaEditorController(
              levelid: arg['levelId'] ?? '',
              areaid: arg['areaId'] ?? '',
            ),
        child: AreaBuilderView(),
      ),
    );
  }
}
