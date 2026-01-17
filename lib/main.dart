import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/wallpaper_provider.dart';
import 'services/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid || Platform.isIOS) {
  //   await initializeService();
  // }
  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
//   service.startService();
// }

// import 'dart:ui';

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();

//   service.on('setAsForeground').listen((event) {
//     service.setAsForegroundService();
//   });

//   service.on('setAsBackground').listen((event) {
//     service.setAsBackgroundService();
//   });

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   return true;
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
      ],
      child: MaterialApp(
        title: 'SDwalls',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1a1a1a),
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1a1a1a),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            centerTitle: false,
          ),
          colorScheme: ColorScheme.dark(
            primary: Colors.purple[400]!,
            secondary: Colors.purpleAccent,
            surface: const Color(0xFF1e1e1e),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1e1e1e),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
