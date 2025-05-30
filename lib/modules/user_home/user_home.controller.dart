import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/map_builder/current_map.model.dart';
import 'package:place_reservation/modules/map_builder/map.service.dart';
import 'package:place_reservation/modules/map_builder/seat-qr.service.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.model.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.service.dart';
import 'package:place_reservation/util.dart';

class UserHomeController extends ChangeNotifier {
  final User user = FirebaseAuth.instance.currentUser!;

  Seats? _currentSeats;
  List<QueryDocumentSnapshot<SeatPlan>>? _upcomingSeatPlan;
  QueryDocumentSnapshot<SeatPlan>? _todaySeatPlan;

  bool isLoading = false;
  bool isFething = false;

  List<String> get curretSeatList => _currentSeats?.seats ?? [];
  List<SeatPlan> get upcomingSeatPlans =>
      _upcomingSeatPlan?.map((doc) => doc.data()).toList() ?? [];
  SeatPlan? get todaySeatPlan => _todaySeatPlan?.data();

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

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      // Fetch the upcoming seat plans
      final seatPlansSnap = await SeatPlanService.getUpcomingSeatPlansByUser(
        user.uid,
        DateTime.now(),
      );
      if (seatPlansSnap.isNotEmpty) {
        final findToday = seatPlansSnap.where((snap) {
          final seatPlan = snap.data();
          final plannedDate = seatPlan.plannedDate;
          return plannedDate.day == today.day &&
              plannedDate.month == today.month &&
              plannedDate.year == today.year;
        });
        _todaySeatPlan = findToday.isNotEmpty ? findToday.first : null;
        _upcomingSeatPlan =
            seatPlansSnap.where((snap) {
              if (_todaySeatPlan != null && snap.id == _todaySeatPlan!.id) {
                return false; // Skip today's plan
              }
              return true; // Include other plans
            }).toList();
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
          message:
              'Seat plan already exists for this date or someone else has plan for this seat.',
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

  Future<ControllerResponse> toProsessClaimSeatPlan(String seatPlanId) async {
    try {
      isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 5));
      print('Claiming seat plan with ID: $seatPlanId');
      // to validate is the seat plan is correct seat plan today
      final scannedSeatQr = await SeatQRService.getSeatQrById(seatPlanId);

      return ControllerResponse(
        statusCode: ResponseStatusCode.success,
        message: 'Seat plan claimed successfully',
      );
    } catch (e) {
      print('Error claiming seat plan: $e');
      return ControllerResponse(
        statusCode: ResponseStatusCode.error,
        message: 'Error claiming seat plan: $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
