import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/coordinates/CurrentCoordinate.model.dart';
import 'package:place_reservation/modules/coordinates/coordinates.controller.dart';
import 'package:place_reservation/util.dart';
import 'package:provider/provider.dart';

class CoordinatesConfigPage extends StatelessWidget {
  const CoordinatesConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coordinates Settings')),
      body: ChangeNotifierProvider(
        create: (context) => CoordinatesController(),
        child: Center(
          child: SizedBox(
            width: 500,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: CoordinatesForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CoordinatesForm extends StatefulWidget {
  const CoordinatesForm({super.key});

  @override
  State<CoordinatesForm> createState() => _CoordinatesFormState();
}

class _CoordinatesFormState extends State<CoordinatesForm> {
  final _globalKey = GlobalKey<FormState>();

  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void onSaveCoordinates() async {
      try {
        if (_globalKey.currentState!.validate()) {
          final x = double.parse(_xController.text);
          final y = double.parse(_yController.text);
          final coordinates = Currentcoordinate(
            x: x,
            y: y,
            lastUpdated: DateTime.now(),
          );

          final controller = Provider.of<CoordinatesController>(
            context,
            listen: false,
          );
          final response = await controller.setCoordinates(coordinates);

          if (!mounted) return;

          if (response.statusCode == ResponseStatusCode.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coordinates saved successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'Error saving coordinates'),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
      }
    }

    return Form(
      key: _globalKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: defaultPadding,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Coordinates Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          TextFormField(
            controller: _xController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(labelText: 'X Coordinate'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid X coordinate';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _yController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(labelText: 'Y Coordinate'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid Y coordinate';
              }
              return null;
            },
          ),
          Selector<CoordinatesController, bool>(
            selector: (_, controller) => controller.isLoading,
            builder: (context, isLoading, child) {
              return ElevatedButton(
                onPressed: isLoading ? null : onSaveCoordinates,
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Coordinates'),
              );
            },
          ),
        ],
      ),
    );
  }
}
