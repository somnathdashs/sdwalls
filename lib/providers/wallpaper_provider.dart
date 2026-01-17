import 'package:flutter/material.dart';
import '../models/wallpaper.dart';
import '../services/pixabay_service.dart';

class WallpaperProvider extends ChangeNotifier {
  final PixabayService _pixabayService = PixabayService();

  List<Wallpaper> _wallpapers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _error = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  String _currentCategory = '';
  String _currentSearchQuery = '';
  String _orientation = 'vertical'; // 'vertical', 'horizontal', 'all'
  bool _childSafety = false; // Default to OFF as per user request

  // Getters
  List<Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  bool get hasMoreData => _hasMoreData;
  String get orientation => _orientation;
  bool get childSafety => _childSafety;

  /// Set orientation filter
  void setOrientation(String newOrientation) {
    if (_orientation != newOrientation) {
      _orientation = newOrientation;
      notifyListeners();
    }
  }

  /// Toggle Child Safety
  void toggleChildSafety(bool value) {
    if (_childSafety != value) {
      _childSafety = value;
      notifyListeners();
      // Reload current category with new setting
      if (_currentSearchQuery.isNotEmpty) {
        searchWallpapers(_currentSearchQuery, refresh: true);
      } else {
        fetchWallpapers(_currentCategory.isEmpty ? 'latest' : _currentCategory,
            refresh: true);
      }
    }
  }

  /// Fetch wallpapers with orientation
  Future<void> fetchWallpapers(String category, {bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _wallpapers.clear();
      _currentCategory = category;
      _currentSearchQuery = '';
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newWallpapers = await _pixabayService.fetchWallpapers(
        category,
        page: _currentPage,
        perPage: 20,
        orientation: _orientation,
        childSafety: _childSafety,
      );

      if (refresh) {
        _wallpapers = newWallpapers;
      } else {
        _wallpapers.addAll(newWallpapers);
      }

      _hasMoreData = newWallpapers.length >= 20;
      _currentPage++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error =
          'Failed to load wallpapers. Please check your API key and internet connection.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search wallpapers with orientation
  Future<void> searchWallpapers(String query, {bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _wallpapers.clear();
      _currentSearchQuery = query;
      _currentCategory = '';
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newWallpapers = await _pixabayService.searchWallpapers(
        query,
        page: _currentPage,
        perPage: 20,
        orientation: _orientation,
        childSafety: _childSafety,
      );

      if (refresh) {
        _wallpapers = newWallpapers;
      } else {
        _wallpapers.addAll(newWallpapers);
      }

      _hasMoreData = newWallpapers.length >= 20;
      _currentPage++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Search failed. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more wallpapers
  Future<void> loadMoreWallpapers() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      List<Wallpaper> newWallpapers;

      if (_currentSearchQuery.isNotEmpty) {
        newWallpapers = await _pixabayService.searchWallpapers(
          _currentSearchQuery,
          page: _currentPage,
          perPage: 20,
          orientation: _orientation,
          childSafety: _childSafety,
        );
      } else {
        newWallpapers = await _pixabayService.fetchWallpapers(
          _currentCategory,
          page: _currentPage,
          perPage: 20,
          orientation: _orientation,
          childSafety: _childSafety,
        );
      }

      _wallpapers.addAll(newWallpapers);
      _hasMoreData = newWallpapers.length >= 20;
      _currentPage++;

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
      print('Error loading more wallpapers: $e');
    }
  }

  /// Get random wallpaper
  Future<Wallpaper?> getRandomWallpaper([String? term]) async {
    try {
      return await _pixabayService.getRandomWallpaper(
          term, _orientation, _childSafety);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMoreData = true;
    _wallpapers.clear();
    _currentCategory = '';
    _currentSearchQuery = '';
    notifyListeners();
  }
}
