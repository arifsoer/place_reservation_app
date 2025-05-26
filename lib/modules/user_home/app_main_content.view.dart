import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:intl/intl.dart';
import 'package:place_reservation/constant.dart';
import 'package:place_reservation/modules/auth/auth.controller.dart';
import 'package:place_reservation/modules/seat_plan/seat_plan.model.dart';
import 'package:place_reservation/modules/user_home/add_plan_dialog_form.view.dart';
import 'package:place_reservation/modules/user_home/user_home.controller.dart';
import 'package:provider/provider.dart';

class AppMainUserHomeListener {
  final bool isLoading;
  final List<String> seats;

  AppMainUserHomeListener({required this.isLoading, required this.seats});
}

class AppMainContent extends StatelessWidget {
  const AppMainContent({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Selector<UserHomeController, AppMainUserHomeListener>(
      selector:
          (context, controller) => AppMainUserHomeListener(
            isLoading: controller.isLoading,
            seats: controller.curretSeatList,
          ),
      builder: (context, appMainUserHomeListener, child) {
        return Stack(
          children: [
            SafeArea(
              child: Center(
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding / 2),
                        child: Row(
                          children: [
                            Text(
                              'Welcome! ${user?.displayName}',
                              style: Theme.of(context).textTheme.titleMedium!,
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () async {
                                await Provider.of<AuthController>(
                                  context,
                                  listen: false,
                                ).signOut();
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                });
                              },
                              icon: Icon(Icons.logout, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: defaultPadding * 0.5),
                    Expanded(
                      child: MainContent(seats: appMainUserHomeListener.seats),
                    ),
                  ],
                ),
              ),
            ),
            if (appMainUserHomeListener.isLoading)
              AbsorbPointer(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            defaultPadding * 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding * 0.5),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.seats});

  final List<String> seats;

  @override
  Widget build(BuildContext context) {
    void onPlanAdded(SeatPlan plan) async {
      final result = await Provider.of<UserHomeController>(
        context,
        listen: false,
      ).addSeatPlan(plan);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Got feedback from process'),
          ),
        );
      });
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<UserHomeController>(
                    builder: (context, controller, child) {
                      if (controller.todaySeatPlan != null) {
                        final plan = controller.todaySeatPlan!;
                        return GestureDetector(
                          onTap: () async {
                            var qrResult = await Navigator.pushNamed(
                              context,
                              '/qr-scanner',
                            );
                            if (qrResult != null) {
                              FlutterLogs.logInfo(
                                'MainPage',
                                'Claim Prosec',
                                'Claim seat plan with QR code: $qrResult',
                              );
                              print(controller);
                            }
                          },
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Your Plan for Today',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Seat ID: ${plan.seatId}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  DateFormat(
                                    'd MMM yyyy',
                                  ).format(plan.plannedDate),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text('Tap here to claim seat'),
                              ],
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () async {
                          String? qrResult = await Navigator.pushNamed<String?>(
                            context,
                            '/qr-scanner',
                          );
                          if (qrResult != null) {
                            // Handle the QR result if needed
                          }
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'You dont have any plan yet today',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Tap Here to direct claim seat,\nor select below button to other action',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                OverflowBar(
                  spacing: defaultPadding,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            Size screenSize = MediaQuery.of(context).size;
                            return AddPlanDialogForm(
                              screenSize: screenSize,
                              seats: seats,
                              onPlanAdded: onPlanAdded,
                            );
                          },
                        );
                      },
                      child: Text('Make a Plan'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Friends Summon'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey.shade400, thickness: 1),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: defaultPadding,
              horizontal: defaultPadding * 0.5,
            ),
            child: Column(
              children: [
                Text(
                  'Upcoming Plans',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: Consumer<UserHomeController>(
                    builder: (context, controller, child) {
                      if (controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.upcomingSeatPlans.isEmpty) {
                        return Text('No plans available');
                      }
                      return ListView.builder(
                        itemCount: controller.upcomingSeatPlans.length,
                        itemBuilder: (context, index) {
                          final plan = controller.upcomingSeatPlans[index];
                          return ListTile(
                            title: Text(plan.seatId),
                            subtitle: Text(
                              DateFormat('d MMM yyyy').format(plan.plannedDate),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // controller.removeSeatPlan(plan);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
