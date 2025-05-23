import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:localstorage/localstorage.dart';
import 'package:place_reservation/firebase_options.dart';
import 'package:place_reservation/modules/auth/auth.controller.dart';
import 'package:place_reservation/pages/area_builder.dart';
import 'package:place_reservation/pages/coordinate_config.dart';
import 'package:place_reservation/pages/login.dart';
import 'package:place_reservation/pages/map_builder.dart';
import 'package:place_reservation/pages/qr_scanner.dart';
import 'package:place_reservation/theme.dart';
import 'package:provider/provider.dart';

import 'pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE,
      ],
      logFileExtension: LogFileExtension.LOG,
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ['network', 'database', 'ui'],
      autoClearLogs: true,
      zipsRetentionPeriodInDays: 7,
      isDebuggable: true, // Set to false in release builds
    );
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initLocalStorage();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: MaterialApp(
        theme: defaultTheme,
        initialRoute: '/login',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/map-builder': (context) => const MapBuilderPage(),
          '/area-builder': (context) => const AreaBuilderPage(),
          '/coordinates-settings': (context) => const CoordinatesConfigPage(),
          '/qr-scanner': (context) => const QRScannerPage(),
        },
      ),
    );
  }
}
