import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class PixabayService {
  static const String _apiKey = '36834532-13ad685a813b839ca7fd87e39';
  static const String _baseUrl = 'https://pixabay.com/api';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Fetch wallpapers with orientation filter
  Future<List<Wallpaper>> fetchWallpapers(
    String category, {
    int perPage = 30,
    int page = 1,
    String orientation = 'vertical', // 'vertical', 'horizontal', or 'all'
    bool childSafety = false,
  }) async {
    try {
      String pixabayCategory = _mapCategory(category);
      String query = category.toLowerCase() == 'latest' ? '' : pixabayCategory;

      final Map<String, String> params = {
        'key': _apiKey,
        'q': query,
        'image_type': 'photo',
        'orientation': orientation, // vertical, horizontal, or all
        'category': pixabayCategory == 'all' ? '' : pixabayCategory,
        'min_width': orientation == 'horizontal' ? '1920' : '1080',
        'min_height': orientation == 'horizontal' ? '1080' : '1920',
        'safesearch': childSafety.toString(),
        'per_page': perPage.toString(),
        'page': page.toString(),
        'order': category.toLowerCase() == 'latest' ? 'latest' : 'popular',
      };

      params.removeWhere((key, value) => value.isEmpty);

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List hits = data['hits'] ?? [];
        return hits.map((json) => Wallpaper.fromPixabayJson(json)).toList();
      } else {
        throw Exception('Failed to load wallpapers');
      }
    } catch (e) {
      throw Exception('Error fetching wallpapers: $e');
    }
  }

  /// Search wallpapers with orientation filter
  Future<List<Wallpaper>> searchWallpapers(
    String query, {
    int perPage = 30,
    int page = 1,
    String orientation = 'vertical',
    bool childSafety = false,
  }) async {
    try {
      final Map<String, String> params = {
        'key': _apiKey,
        'q': query,
        'image_type': 'photo',
        'orientation': orientation,
        'min_width': orientation == 'horizontal' ? '1920' : '1080',
        'min_height': orientation == 'horizontal' ? '1080' : '1920',
        'safesearch': childSafety.toString(),
        'per_page': perPage.toString(),
        'page': page.toString(),
        'order': 'popular',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List hits = data['hits'] ?? [];
        return hits.map((json) => Wallpaper.fromPixabayJson(json)).toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Error searching wallpapers: $e');
    }
  }

  /// Get random wallpaper with orientation
  Future<Wallpaper?> getRandomWallpaper(
      [String? term,
      String orientation = 'vertical',
      bool childSafety = false]) async {
    try {
      final Map<String, String> params = {
        'key': _apiKey,
        'q': term ?? '',
        'image_type': 'photo',
        'orientation': orientation,
        'min_width': orientation == 'horizontal' ? '1920' : '1080',
        'min_height': orientation == 'horizontal' ? '1080' : '1920',
        'safesearch': childSafety.toString(),
        'per_page': '20',
        'order': 'popular',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List hits = data['hits'] ?? [];

        if (hits.isNotEmpty) {
          final randomIndex =
              DateTime.now().millisecondsSinceEpoch % hits.length;
          return Wallpaper.fromPixabayJson(hits[randomIndex]);
        }
      }
      return null;
    } catch (e) {
      print('Error getting random wallpaper: $e');
      return null;
    }
  }

  String _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'latest':
        return 'all';
      case 'space':
        return 'science';
      case 'nature':
        return 'nature';
      case 'architecture':
        return 'buildings';
      case 'animals':
        return 'animals';
      case 'technology':
        return 'computer';
      case 'abstract':
        return 'backgrounds';
      case 'cars':
        return 'transportation';
      default:
        return category.toLowerCase();
    }
  }
}
