import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

import 'package:path/path.dart' as p;

class WallpaperService {
  final Dio _dio = Dio();
  static const MethodChannel _channel = MethodChannel('com.sdwalls/wallpaper');

  Future<bool> setWallpaper(String imageUrl, int location) async {
    try {
      final file = await _downloadImage(imageUrl);
      if (file == null) {
        return false;
      }

      if (Platform.isWindows) {
        try {
          String locationType;
          switch (location) {
            case 1:
              locationType = 'homeScreen';
              break;
            case 2:
              locationType = 'lockScreen';
              break;
            case 3:
              locationType = 'bothScreens';
              break;
            default:
              locationType = 'homeScreen';
          }
          await _channel.invokeMethod('setWallpaper',
              {'path': file.path, 'locationType': locationType});
          return true;
        } on PlatformException catch (e) {
          print("Failed to set wallpaper: '${e.message}'.");
          return false;
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        final wallpaperManager = WallpaperManagerFlutter();
        int wallpaperLocation;
        switch (location) {
          case 1:
            wallpaperLocation = WallpaperManagerFlutter.homeScreen;
            break;
          case 2:
            wallpaperLocation = WallpaperManagerFlutter.lockScreen;
            break;
          case 3:
            wallpaperLocation = WallpaperManagerFlutter.bothScreens;
            break;
          default:
            wallpaperLocation = WallpaperManagerFlutter.homeScreen;
        }
        final result = await wallpaperManager.setWallpaper(
          file,
          wallpaperLocation,
        );
        await file.delete();
        return result;
      } else {
        print('Wallpaper setting is not supported on this platform.');
        return false;
      }
    } catch (e) {
      print('Error setting wallpaper: $e');
      return false;
    }
  }

  Future<File?> _downloadImage(String url) async {
    try {
      String filePath;
      if (Platform.isWindows) {
        String executablePath = Platform.resolvedExecutable;
        // Use the path package to extract the directory name
        String executableDir = p.dirname(executablePath);

        print("Executable Directory: $executableDir");
        // Use p.join for safe path construction
        final downloadPath = p.join(executableDir, 'Downloads');
        print(downloadPath);
        final downloadDir = Directory(downloadPath);

        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        // Extract filename from URL or use timestamp to keep it cleaner
        final fileName =
            'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
        filePath = p.join(downloadDir.path, fileName);
      } else {
        final dir = await getTemporaryDirectory();
        filePath = p.join(
            dir.path, 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      await _dio.download(
        url,
        filePath,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      return File(filePath);
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
}
