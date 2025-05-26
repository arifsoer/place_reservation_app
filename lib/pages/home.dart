import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:place_reservation/modules/auth/auth.controller.dart';
import 'package:place_reservation/modules/user_home/app_main_content.view.dart';
import 'package:place_reservation/modules/user_home/user_home.controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? WebMainPage() : AppMainPage();
  }
}

class AppMainPage extends StatefulWidget {
  const AppMainPage({super.key});

  @override
  State<AppMainPage> createState() => _AppMainPageState();
}

class _AppMainPageState extends State<AppMainPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserHomeController>(
        context,
        listen: false,
      ).dataInitialization();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthController>(context).user;
    return Scaffold(body: AppMainContent(user: user));
  }
}

class WebMainPage extends StatelessWidget {
  const WebMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(child: Placeholder(child: Text('this is home page'))),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('Map Builder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/map-builder');
              },
            ),
            ListTile(
              title: const Text('Coordinates Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/coordinates-settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
