import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper.dart';

class HistoryService {
  static const String _viewedKey = 'viewed_wallpapers';
  static const String _appliedKey = 'applied_wallpapers';
  static const int _maxHistoryItems = 100;

  /// Add wallpaper to viewed history
  static Future<void> addToViewed(Wallpaper wallpaper) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewedJson = prefs.getStringList(_viewedKey) ?? [];
      
      // Store complete wallpaper data in Pixabay format
      final historyItem = {
        'id': wallpaper.id,
        'user': wallpaper.author,
        'tags': wallpaper.tags,
        'previewURL': wallpaper.previewUrl,
        'webformatURL': wallpaper.webformatUrl,
        'largeImageURL': wallpaper.largeImageUrl,
        'fullHDURL': wallpaper.fullHDUrl,
        'imageWidth': wallpaper.imageWidth,
        'imageHeight': wallpaper.imageHeight,
        'views': wallpaper.views,
        'downloads': wallpaper.downloads,
        'likes': wallpaper.likes,
        'viewedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Remove if already exists (to update timestamp)
      viewedJson.removeWhere((item) {
        final decoded = json.decode(item);
        return decoded['id'] == wallpaper.id;
      });
      
      viewedJson.insert(0, json.encode(historyItem));
      
      if (viewedJson.length > _maxHistoryItems) {
        viewedJson.removeRange(_maxHistoryItems, viewedJson.length);
      }
      
      await prefs.setStringList(_viewedKey, viewedJson);
      print('✅ Added to viewed history: ${wallpaper.author}');
    } catch (e) {
      print('❌ Error adding to viewed history: $e');
    }
  }

  /// Add wallpaper to applied history
  static Future<void> addToApplied(
    Wallpaper wallpaper,
    int location,
    String result,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appliedJson = prefs.getStringList(_appliedKey) ?? [];
      
      // Store complete wallpaper data in Pixabay format
      final historyItem = {
        'id': wallpaper.id,
        'user': wallpaper.author,
        'tags': wallpaper.tags,
        'previewURL': wallpaper.previewUrl,
        'webformatURL': wallpaper.webformatUrl,
        'largeImageURL': wallpaper.largeImageUrl,
        'fullHDURL': wallpaper.fullHDUrl,
        'imageWidth': wallpaper.imageWidth,
        'imageHeight': wallpaper.imageHeight,
        'views': wallpaper.views,
        'downloads': wallpaper.downloads,
        'likes': wallpaper.likes,
        'appliedAt': DateTime.now().millisecondsSinceEpoch,
        'location': location,
        'result': result,
        'success': !result.toLowerCase().contains('failed') && 
                   !result.toLowerCase().contains('error'),
      };
      
      appliedJson.insert(0, json.encode(historyItem));
      
      if (appliedJson.length > _maxHistoryItems) {
        appliedJson.removeRange(_maxHistoryItems, appliedJson.length);
      }
      
      await prefs.setStringList(_appliedKey, appliedJson);
      print('✅ Added to applied history: ${wallpaper.author} - Location: $location - Success: ${!result.toLowerCase().contains('failed')}');
    } catch (e) {
      print('❌ Error adding to applied history: $e');
    }
  }

  /// Get viewed wallpapers history
  static Future<List<HistoryItem>> getViewedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewedJson = prefs.getStringList(_viewedKey) ?? [];
      
      print('📖 Loading viewed history: ${viewedJson.length} items');
      
      return viewedJson.map((item) {
        final decoded = json.decode(item);
        return HistoryItem.fromJson(decoded, HistoryType.viewed);
      }).toList();
    } catch (e) {
      print('❌ Error getting viewed history: $e');
      return [];
    }
  }

  /// Get applied wallpapers history
  static Future<List<HistoryItem>> getAppliedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appliedJson = prefs.getStringList(_appliedKey) ?? [];
      
      print('📖 Loading applied history: ${appliedJson.length} items');
      
      return appliedJson.map((item) {
        final decoded = json.decode(item);
        return HistoryItem.fromJson(decoded, HistoryType.applied);
      }).toList();
    } catch (e) {
      print('❌ Error getting applied history: $e');
      return [];
    }
  }

  /// Get all history sorted by time
  static Future<List<HistoryItem>> getAllHistory() async {
    try {
      final viewed = await getViewedHistory();
      final applied = await getAppliedHistory();
      
      final allHistory = [...viewed, ...applied];
      
      allHistory.sort((a, b) {
        final aTime = a.type == HistoryType.viewed ? a.viewedAt : a.appliedAt;
        final bTime = b.type == HistoryType.viewed ? b.viewedAt : b.appliedAt;
        return bTime!.compareTo(aTime!);
      });
      
      return allHistory;
    } catch (e) {
      print('❌ Error getting all history: $e');
      return [];
    }
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_viewedKey);
      await prefs.remove(_appliedKey);
      print('🗑️ Cleared all history');
    } catch (e) {
      print('❌ Error clearing history: $e');
    }
  }

  /// Clear viewed history only
  static Future<void> clearViewedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_viewedKey);
      print('🗑️ Cleared viewed history');
    } catch (e) {
      print('❌ Error clearing viewed history: $e');
    }
  }

  /// Clear applied history only
  static Future<void> clearAppliedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_appliedKey);
      print('🗑️ Cleared applied history');
    } catch (e) {
      print('❌ Error clearing applied history: $e');
    }
  }

  /// Remove specific item from history
  static Future<void> removeFromHistory(String wallpaperId, HistoryType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = type == HistoryType.viewed ? _viewedKey : _appliedKey;
      final historyJson = prefs.getStringList(key) ?? [];
      
      historyJson.removeWhere((item) {
        final decoded = json.decode(item);
        return decoded['id'] == wallpaperId;
      });
      
      await prefs.setStringList(key, historyJson);
      print('🗑️ Removed item $wallpaperId from ${type == HistoryType.viewed ? 'viewed' : 'applied'} history');
    } catch (e) {
      print('❌ Error removing from history: $e');
    }
  }

  /// Get history statistics
  static Future<Map<String, int>> getHistoryStats() async {
    try {
      final viewed = await getViewedHistory();
      final applied = await getAppliedHistory();
      final successful = applied.where((item) => item.success == true).length;
      final failed = applied.where((item) => item.success == false).length;
      
      return {
        'totalViewed': viewed.length,
        'totalApplied': applied.length,
        'successfulApplications': successful,
        'failedApplications': failed,
      };
    } catch (e) {
      return {
        'totalViewed': 0,
        'totalApplied': 0,
        'successfulApplications': 0,
        'failedApplications': 0,
      };
    }
  }
}

/// History item model
class HistoryItem {
  final Wallpaper wallpaper;
  final HistoryType type;
  final DateTime? viewedAt;
  final DateTime? appliedAt;
  final int? location;
  final String? result;
  final bool? success;

  HistoryItem({
    required this.wallpaper,
    required this.type,
    this.viewedAt,
    this.appliedAt,
    this.location,
    this.result,
    this.success,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json, HistoryType type) {
    try {
      // Create a proper Pixabay JSON structure for the Wallpaper model
      final pixabayJson = {
        'id': json['id'],
        'user': json['user'] ?? 'Unknown',
        'tags': json['tags'] ?? '',
        'previewURL': json['previewURL'] ?? '',
        'webformatURL': json['webformatURL'] ?? '',
        'largeImageURL': json['largeImageURL'] ?? '',
        'fullHDURL': json['fullHDURL'] ?? '',
        'imageWidth': json['imageWidth'] ?? 1920,
        'imageHeight': json['imageHeight'] ?? 1080,
        'views': json['views'] ?? 0,
        'downloads': json['downloads'] ?? 0,
        'likes': json['likes'] ?? 0,
      };
      
      final wallpaper = Wallpaper.fromPixabayJson(pixabayJson);
      
      return HistoryItem(
        wallpaper: wallpaper,
        type: type,
        viewedAt: json['viewedAt'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(json['viewedAt']) 
            : null,
        appliedAt: json['appliedAt'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(json['appliedAt']) 
            : null,
        location: json['location'],
        result: json['result'],
        success: json['success'],
      );
    } catch (e) {
      print('❌ Error parsing history item: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  String getLocationName() {
    switch (location) {
      case 1:
        return 'Home Screen';
      case 2:
        return 'Lock Screen';
      case 3:
        return 'Both Screens';
      default:
        return 'Unknown';
    }
  }

  String getTimeAgo() {
    final time = type == HistoryType.viewed ? viewedAt : appliedAt;
    if (time == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

enum HistoryType {
  viewed,
  applied,
}
