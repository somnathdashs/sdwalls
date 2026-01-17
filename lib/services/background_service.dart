import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdwalls/services/history_service.dart';
import 'package:sdwalls/services/pixabay_service.dart';
import 'package:sdwalls/services/wallpaper_service.dart';

class BackgroundService {
  static const String taskName = 'wallpaper_update_task';

  static Future<void> scheduleWallpaperUpdate(
      String interval, String term, int location, String oriantation) async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stopService");
    }
    service.startService();
    service.invoke("startService", {
      "interval": interval,
      "term": term,
      "location": location,
      "oriantation": oriantation,
    });
  }

  static Future<void> cancelWallpaperUpdate() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stopService");
    }
  }

  static Future<Map<String, dynamic>?> getLastUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = prefs.getBool('last_update_success');
      final info = prefs.getString('last_update_info');
      final location = prefs.getInt('last_update_location');
      final timeMs = prefs.getInt('last_update_time');
      final imageUrl = prefs.getString('last_update_image');

      if (info != null &&
          timeMs != null &&
          location != null &&
          success != null) {
        return {
          'success': success,
          'info': info,
          'location': location,
          'time': DateTime.fromMillisecondsSinceEpoch(timeMs),
          'imageUrl': imageUrl,
        };
      }
      return null;
    } catch (e) {
      print('Error getting last update: $e');
      return null;
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterBackgroundService serviceInstance = FlutterBackgroundService();

  service.on('startService').listen((event) {
    final interval = event!['interval'];
    final term = event['term'];
    final location = event['location'];
    final oriantation = event['oriantation'];

    Duration frequency;
    switch (interval) {
      case '1m':
        frequency = const Duration(minutes: 1);
        break;
      case '1h':
        frequency = const Duration(hours: 1);
        break;
      case '15h':
        frequency = const Duration(hours: 15);
        break;
      case '24h':
        frequency = const Duration(hours: 24);
        break;
      case '3d':
        frequency = const Duration(days: 3);
        break;
      case '1w':
        frequency = const Duration(days: 7);
        break;
      case '1m':
        frequency = const Duration(days: 30);
        break;
      default:
        frequency = const Duration(hours: 24);
    }

    Timer.periodic(frequency, (timer) async {
      await updateWallpaperBackground({
        'term': term,
        'location': location,
        'oriantation': oriantation,
      });
    });
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

Future<void> updateWallpaperBackground(
    Map<String, dynamic>? inputData) async {
  try {
    final term = inputData?['term'] ?? 'random';
    final location = inputData?['location'] ?? '';
    final oriantation = inputData?["oriantation"] ?? "";

    // Get random wallpaper from Pixabay with safe search enabled
    final pixabayService = PixabayService();
    final wallpaper = await pixabayService.getRandomWallpaper(
      term == 'random' ? null : term,
      oriantation,
    );

    if (wallpaper == null) {
      return;
    }

    final service = WallpaperService();
    final result = await service.setWallpaper(
      wallpaper.getImageUrl(),
      location,
    );

    // ✅ Add to history for auto wallpapers!
    await HistoryService.addToApplied(
      wallpaper,
      location,
      result.toString(),
    );

    // Show notification
    // await _showWallpaperNotification(wallpaper.getImageUrl(), wallpaper.author);
  } catch (e) {
    print('Background update error: $e');
  }
}
