import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/background_service.dart';
import '../utils/responsive_utils.dart';

class AutoWallpaperScreen extends StatefulWidget {
  const AutoWallpaperScreen({super.key});

  @override
  State<AutoWallpaperScreen> createState() => _AutoWallpaperScreenState();
}

class _AutoWallpaperScreenState extends State<AutoWallpaperScreen> {
  bool _isEnabled = false;
  String _selectedInterval = '24h';
  String _selectedTerm = 'random';
  int _selectedLocation = 3; // Default: Both screens
  String _selectedOrientation = 'vertical'; // Default: Portrait
  final TextEditingController _termController = TextEditingController();
  Map<String, dynamic>? _lastUpdate;

  final Map<String, String> intervals = {
    '1m': '1 Min',
    '1h': '1 Hour',
    '15h': '15 Hours',
    '24h': '24 Hours',
    '3d': '3 Days',
    '1w': '1 Week',
    '1mt': '1 Month',
  };

  final Map<int, String> locations = {
    1: 'Home Screen',
    2: 'Lock Screen',
    3: 'Both Screens',
  };

  final Map<int, IconData> locationIcons = {
    1: Icons.home,
    2: Icons.lock,
    3: Icons.phonelink,
  };

  final Map<String, String> orientations = {
    'vertical': 'Portrait',
    'horizontal': 'Landscape',
    'all': 'Both',
  };

  final Map<String, IconData> orientationIcons = {
    'vertical': Icons.stay_current_portrait,
    'horizontal': Icons.stay_current_landscape,
    'all': Icons.crop_free,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadLastUpdate();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = prefs.getBool('auto_wallpaper_enabled') ?? false;
      _selectedInterval = prefs.getString('auto_wallpaper_interval') ?? '24h';
      _selectedTerm = prefs.getString('auto_wallpaper_term') ?? 'random';
      _selectedLocation = prefs.getInt('auto_wallpaper_location') ?? 3;
      _selectedOrientation =
          prefs.getString('auto_wallpaper_orientation') ?? 'vertical';
      if (_selectedTerm != 'random') {
        _termController.text = _selectedTerm;
      }
    });
  }

  Future<void> _loadLastUpdate() async {
    final lastUpdate = await BackgroundService.getLastUpdate();
    setState(() {
      _lastUpdate = lastUpdate;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_wallpaper_enabled', _isEnabled);
    await prefs.setString('auto_wallpaper_interval', _selectedInterval);
    await prefs.setString('auto_wallpaper_term', _selectedTerm);
    await prefs.setInt('auto_wallpaper_location', _selectedLocation);
    await prefs.setString('auto_wallpaper_orientation', _selectedOrientation);
  }

  Future<void> _toggleAutoWallpaper(bool value) async {
    if (value) {
      setState(() => _isEnabled = true);
      await _saveSettings();
      await BackgroundService.scheduleWallpaperUpdate(
        _selectedInterval,
        _selectedTerm,
        _selectedLocation,
        _selectedOrientation,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Auto wallpaper enabled for ${locations[_selectedLocation]} (${orientations[_selectedOrientation]})!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() => _isEnabled = false);
      await _saveSettings();
      await BackgroundService.cancelWallpaperUpdate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.pause_circle_outline, color: Colors.orange),
                SizedBox(width: 12),
                Text('Auto wallpaper disabled'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatLastUpdateTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    final titleSize = ResponsiveUtils.getFontSize(context, 18);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(ResponsiveUtils.getAppBarHeight(context)),
        child: AppBar(
          title: Text(
            'Auto Wallpaper',
            style:
                TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 20)),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: ResponsiveUtils.getMaxWidthConstraint(context),
          child: ListView(
            padding: ResponsiveUtils.getScreenPadding(context),
            children: [
              // Enable Auto Wallpaper Card
              Card(
                elevation: ResponsiveUtils.getCardElevation(context),
                child: SwitchListTile(
                  title: Text(
                    'Enable Auto Wallpaper',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Automatically change wallpaper at set intervals - no notifications needed!',
                    style: TextStyle(fontSize: fontSize * 0.9),
                  ),
                  value: _isEnabled,
                  onChanged: _toggleAutoWallpaper,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 8 : 4,
                  ),
                ),
              ),

              // Show last update info if available
              if (_lastUpdate != null) ...[
                SizedBox(height: isTablet ? 16 : 12),
                Card(
                  elevation: ResponsiveUtils.getCardElevation(context),
                  color: _lastUpdate!['success']
                      ? Colors.green[900]!.withOpacity(0.3)
                      : Colors.red[900]!.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _lastUpdate!['success']
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: _lastUpdate!['success']
                                  ? Colors.green
                                  : Colors.red,
                              size: ResponsiveUtils.getIconSize(context, 24),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              _lastUpdate!['success']
                                  ? 'Last Auto Update'
                                  : 'Last Update Failed',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: _lastUpdate!['success']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        if (_lastUpdate!['success']) ...[
                          Text(
                            'Wallpaper by ${_lastUpdate!['info']}',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Applied to ${locations[_lastUpdate!['location']]} • ${_formatLastUpdateTime(_lastUpdate!['time'])}',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              color: Colors.grey,
                            ),
                          ),
                        ] else ...[
                          Text(
                            _lastUpdate!['info'],
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: isTablet ? 24 : 16),

              if (_isEnabled) ...[
                // Wallpaper Location Selection Card
                Card(
                  elevation: ResponsiveUtils.getCardElevation(context),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply Wallpaper To',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        ...locations.entries.map((entry) {
                          return RadioListTile<int>(
                            title: Row(
                              children: [
                                Icon(
                                  locationIcons[entry.key],
                                  size:
                                      ResponsiveUtils.getIconSize(context, 20),
                                  color: _selectedLocation == entry.key
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  entry.value,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              entry.key == 1
                                  ? 'Set wallpaper for home screen only'
                                  : entry.key == 2
                                      ? 'Set wallpaper for lock screen only'
                                      : 'Set wallpaper for both home and lock screens',
                              style: TextStyle(fontSize: fontSize * 0.85),
                            ),
                            value: entry.key,
                            groupValue: _selectedLocation,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 0,
                            ),
                            onChanged: (value) async {
                              setState(() => _selectedLocation = value!);
                              await _saveSettings();
                              if (_isEnabled) {
                                await BackgroundService.scheduleWallpaperUpdate(
                                  _selectedInterval,
                                  _selectedTerm,
                                  _selectedLocation,
                                  _selectedOrientation,
                                );
                              }
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 24 : 16),

                // NEW: Wallpaper Orientation Selection Card
                Card(
                  elevation: ResponsiveUtils.getCardElevation(context),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallpaper Orientation',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        ...orientations.entries.map((entry) {
                          return RadioListTile<String>(
                            title: Row(
                              children: [
                                Icon(
                                  orientationIcons[entry.key],
                                  size:
                                      ResponsiveUtils.getIconSize(context, 20),
                                  color: _selectedOrientation == entry.key
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  entry.value,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              entry.key == 'vertical'
                                  ? 'Vertical wallpapers for phones'
                                  : entry.key == 'horizontal'
                                      ? 'Horizontal wallpapers for tablets/desktops'
                                      : 'Mix of portrait and landscape wallpapers',
                              style: TextStyle(fontSize: fontSize * 0.85),
                            ),
                            value: entry.key,
                            groupValue: _selectedOrientation,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 0,
                            ),
                            onChanged: (value) async {
                              setState(() => _selectedOrientation = value!);
                              await _saveSettings();
                              if (_isEnabled) {
                                await BackgroundService.scheduleWallpaperUpdate(
                                  _selectedInterval,
                                  _selectedTerm,
                                  _selectedLocation,
                                  _selectedOrientation,
                                );
                              }
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 24 : 16),

                // Update Interval Card
                Card(
                  elevation: ResponsiveUtils.getCardElevation(context),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Interval',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        ...intervals.entries.map((entry) {
                          return RadioListTile<String>(
                            title: Text(
                              entry.value,
                              style: TextStyle(fontSize: fontSize),
                            ),
                            value: entry.key,
                            groupValue: _selectedInterval,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 0,
                            ),
                            onChanged: (value) async {
                              setState(() => _selectedInterval = value!);
                              await _saveSettings();
                              if (_isEnabled) {
                                await BackgroundService.scheduleWallpaperUpdate(
                                  _selectedInterval,
                                  _selectedTerm,
                                  _selectedLocation,
                                  _selectedOrientation,
                                );
                              }
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 24 : 16),

                // Wallpaper Source Card
                Card(
                  elevation: ResponsiveUtils.getCardElevation(context),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallpaper Source',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        RadioListTile<String>(
                          title: Text(
                            'Random',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          subtitle: Text(
                            'Get random safe wallpapers from all categories',
                            style: TextStyle(fontSize: fontSize * 0.85),
                          ),
                          value: 'random',
                          groupValue: _selectedTerm,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 0,
                          ),
                          onChanged: (value) async {
                            setState(() {
                              _selectedTerm = value!;
                              _termController.clear();
                            });
                            await _saveSettings();
                            if (_isEnabled) {
                              await BackgroundService.scheduleWallpaperUpdate(
                                _selectedInterval,
                                _selectedTerm,
                                _selectedLocation,
                                _selectedOrientation,
                              );
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(
                            'Specific Term',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          subtitle: Text(
                            'Enter a search term for themed wallpapers',
                            style: TextStyle(fontSize: fontSize * 0.85),
                          ),
                          value: 'custom',
                          groupValue:
                              _selectedTerm == 'random' ? 'random' : 'custom',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 8 : 0,
                          ),
                          onChanged: (value) {
                            setState(() => _selectedTerm = 'custom');
                          },
                        ),
                        if (_selectedTerm != 'random')
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 16 : 8,
                              vertical: isTablet ? 12 : 8,
                            ),
                            child: TextField(
                              controller: _termController,
                              style: TextStyle(fontSize: fontSize),
                              decoration: InputDecoration(
                                hintText: 'e.g., nature, space, cars, abstract',
                                hintStyle: TextStyle(fontSize: fontSize * 0.9),
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 20 : 16,
                                ),
                                prefixIcon: const Icon(Icons.search),
                              ),
                              onSubmitted: (value) async {
                                if (value.isNotEmpty) {
                                  setState(() => _selectedTerm = value);
                                  await _saveSettings();
                                  if (_isEnabled) {
                                    await BackgroundService
                                        .scheduleWallpaperUpdate(
                                      _selectedInterval,
                                      _selectedTerm,
                                      _selectedLocation,
                                      _selectedOrientation,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // How it works Card
                Card(
                  elevation: ResponsiveUtils.getCardElevation(context),
                  color: Colors.blue[900]!.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: ResponsiveUtils.getIconSize(context, 24),
                            ),
                            SizedBox(width: isTablet ? 12 : 8),
                            Text(
                              'How it works',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 16 : 8),
                        Text(
                          '• Wallpaper updates automatically at your chosen interval\n'
                          '• Applied directly to your selected location (Home/Lock/Both)\n'
                          '• Fetches wallpapers in your preferred orientation\n'
                          '• No notifications - wallpaper changes silently\n'
                          '• Works even when the app is closed\n'
                          '• All wallpapers are safe and family-friendly',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: fontSize * 0.95,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _termController.dispose();
    super.dispose();
  }
}
