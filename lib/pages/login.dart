import 'package:flutter/material.dart';
import 'package:place_reservation/modules/auth/auth.controller.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/');
            });
          }
          return child!;
        },
        child: Container(
          color: Colors.white,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Provider.of<AuthController>(
                  context,
                  listen: false,
                ).signInWithGoogle();
              },
              child: const Text('Login'),
            ),
          ),
        ),
      ),
    );
  }
}
