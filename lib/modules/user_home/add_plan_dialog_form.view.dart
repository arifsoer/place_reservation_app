import 'package:flutter/material.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/auth/auth.controller.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.model.dart';
import 'package:provider/provider.dart';

class AddPlanDialogForm extends StatefulWidget {
  const AddPlanDialogForm({
    super.key,
    required this.screenSize,
    required this.seats,
    required this.onPlanAdded,
  });

  final Size screenSize;
  final List<String> seats;
  final void Function(SeatPlan) onPlanAdded;

  @override
  State<AddPlanDialogForm> createState() => _AddPlanDialogFormState();
}

class _AddPlanDialogFormState extends State<AddPlanDialogForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedSeat;
  DateTime? _selectedDate;

  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthController>(context).user;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      elevation: 8,
      child: SizedBox(
        width: widget.screenSize.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding / 2),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: defaultPadding,
              children: [
                Text(
                  'Make a Plan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 7)),
                    );
                    if (date != null) {
                      _dateController.text =
                          '${date.day}/${date.month}/${date.year}';
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Seat',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                  ),
                  isExpanded: true,
                  value: _selectedSeat,
                  items:
                      widget.seats
                          .map(
                            (x) => DropdownMenuItem<String>(
                              value: x,
                              child: Text(x),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSeat = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Seat';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Handle the reservation logic here

                        final newSeatPlan = SeatPlan(
                          seatId: _selectedSeat ?? '',
                          userId: user?.uid ?? '',
                          userName: user?.displayName ?? '',
                          userEmail: user?.email ?? '',
                          plannedDate: _selectedDate!,
                          claimedDate: null,
                        );
                        widget.onPlanAdded(newSeatPlan);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text('Make a Plan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
