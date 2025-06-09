import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/map_builder/current_map.model.dart';
import 'package:place_reservation/modules/map_builder/map.service.dart';
import 'package:place_reservation/modules/map_builder/seat-qr.service.dart';
import 'package:place_reservation/modules/seat_claim/seat_claim.dart';
import 'package:place_reservation/modules/seat_claim/seat_claim.service.dart';
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

      // check the seletected date on the list
      if (seatPlan.plannedDate.isBefore(DateTime.now())) {
        return ControllerResponse(
          statusCode: ResponseStatusCode.validationError,
          message: 'Selected date cannot be in the past.',
        );
      }
      if (_upcomingSeatPlan != null) {
        final plannedDateList =
            _upcomingSeatPlan!.map((plan) => plan.data().plannedDate).toList();
        final withTodayDate = [
          if (_todaySeatPlan != null) _todaySeatPlan!.data().plannedDate,
          ...plannedDateList,
        ];
        if (withTodayDate.contains(seatPlan.plannedDate)) {
          return ControllerResponse(
            statusCode: ResponseStatusCode.validationError,
            message:
                'Seat plan already exists for this date, try another date.',
          );
        }
      }

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

      // to validate is the seat plan is correct seat plan today
      final scannedSeatQr = await SeatQRService.getSeatQrById(seatPlanId);
      if (scannedSeatQr == null) {
        return ControllerResponse(
          statusCode: ResponseStatusCode.validationError,
          message:
              'No Seat QR found, ensure you have scanned the correct QR code.',
        );
      }
      // to check with today seat plan
      final scannedData = scannedSeatQr.data();
      if (_todaySeatPlan == null ||
          _todaySeatPlan!.data().seatId != scannedData!.seatId) {
        return ControllerResponse(
          statusCode: ResponseStatusCode.validationError,
          message:
              'This seat plan does not match with today\'s seat plan, please check again.',
        );
      }

      // to update the currect today seat plan and add the claimed data
      final updatedSeatPlan = _todaySeatPlan!.data().copyWith(
        claimedDate: DateTime.now(),
      );
      await SeatPlanService.updateSeatPlan(_todaySeatPlan!.id, updatedSeatPlan);

      final newSeatClaim = SeatClaim(
        seatId: updatedSeatPlan.seatId,
        userId: user.uid,
        userName: user.displayName ?? 'Guest User',
        userEmail: user.email ?? '',
        isPlanned: true,
        claimedDate: DateTime.now(),
      );
      await SeatClaimService.addSeatClaim(newSeatClaim);

      fetchUpcomingSeatPlans();

      return ControllerResponse(
        statusCode: ResponseStatusCode.success,
        message: 'Seat plan claimed successfully',
      );
    } catch (e) {
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
