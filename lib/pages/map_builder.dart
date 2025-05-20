import 'package:flutter/material.dart';
import 'package:place_reservation/modules/map_builder/builder.view.dart';
import 'package:place_reservation/modules/map_builder/map.controller.dart';
import 'package:provider/provider.dart';

class MapBuilderPage extends StatelessWidget {
  const MapBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Builder')),
      body: ChangeNotifierProvider(
        create: (context) => MapController(),
        child: MapBuilderView(), // Use the BuilderView widget here
      ),
    );
  }
}
