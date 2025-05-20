import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/map_builder/current_map.model.dart';
import 'package:place_reservation/modules/map_builder/map.service.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.model.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.service.dart';
import 'package:place_reservation/util.dart';

class UserHomeController extends ChangeNotifier {
  final User user = FirebaseAuth.instance.currentUser!;

  Seats? _currentSeats;
  List<SeatPlan>? _upcomingSeatPlan;

  bool isLoading = false;
  bool isFething = false;

  List<String> get curretSeatList => _currentSeats?.seats ?? [];
  List<SeatPlan> get upcomingSeatPlans => _upcomingSeatPlan ?? [];

  UserHomeController() {
    dataInitialization();
  }

  Future<void> dataInitialization() async {
    try {
      isLoading = true;
      notifyListeners();

      // Fetch the current seats
      final seatsSnap = await MapService.getCurrentSeats();
      _currentSeats = seatsSnap?.data();

      fetchUpcomingSeatPlans();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUpcomingSeatPlans() async {
    try {
      isFething = true;
      notifyListeners();

      // Fetch the upcoming seat plans
      final seatPlansSnap = await SeatPlanService.getUpcomingSeatPlansByUser(
        user.uid,
        DateTime.now(),
      );
      if (seatPlansSnap.isNotEmpty) {
        _upcomingSeatPlan = seatPlansSnap.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print('Error fetching upcoming seat plans: $e');
    } finally {
      isFething = false;
      notifyListeners();
    }
  }

  Future<ControllerResponse> addSeatPlan(SeatPlan seatPlan) async {
    try {
      isLoading = true;
      notifyListeners();

      // plan validation
      final seatPlanSnap = await SeatPlanService.getSeatPlansByDateAndSeat(
        seatPlan.seatId,
        seatPlan.plannedDate,
      );

      if (seatPlanSnap.isNotEmpty) {
        return ControllerResponse(
          statusCode: ResponseStatusCode.validationError,
          message: 'Seat plan already exists for this date',
        );
      }

      await SeatPlanService.addSeatPlan(seatPlan);

      fetchUpcomingSeatPlans();

      return ControllerResponse(
        statusCode: ResponseStatusCode.success,
        message: 'Seat plan added successfully',
      );
    } catch (e) {
      print('Error adding seat plan: $e');
      return ControllerResponse(
        statusCode: ResponseStatusCode.error,
        message: 'Error adding seat plan: $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
