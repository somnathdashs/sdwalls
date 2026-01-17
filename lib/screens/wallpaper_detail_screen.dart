import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wallpaper.dart';
import '../services/wallpaper_service.dart';
import '../utils/responsive_utils.dart';
import '../services/history_service.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final Wallpaper wallpaper;

  const WallpaperDetailScreen({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    HistoryService.addToViewed(widget.wallpaper);
  }

  Future<void> _setWallpaper(int location) async {
    setState(() => _isLoading = true);

    try {
      final service = WallpaperService();
      var success = false;
      await service
          .setWallpaper(
        widget.wallpaper.getImageUrl(),
        location,
      )
          .then((onValue) async {
        setState(() {
          success = onValue;
        });
        await HistoryService.addToApplied(
          widget.wallpaper,
          location,
          onValue.toString(),
        );
      }).catchError((onError) async {
        setState(() {
          success = false;
        });
        await HistoryService.addToApplied(
          widget.wallpaper,
          location,
          'Error: $onError',
        );
      });

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Wallpaper Set!'),
                content: const Text(
                    'Enjoy your new wallpaper! Would you like to support the developer by buying a coffee?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No, thanks'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _launchURL('https://www.buymeacoffee.com/somnathdash');
                    },
                    child: const Text('Buy me a coffee'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to set wallpaper'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      await HistoryService.addToApplied(
        widget.wallpaper,
        location,
        'Error: $e',
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  void _showSetWallpaperDialog() {
    final isTablet = ResponsiveUtils.isTablet(context);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    final iconSize = ResponsiveUtils.getIconSize(context, 24);

    if (Platform.isWindows) {
      _setWallpaper(1);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTablet ? 50 : 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Text(
              'Set Wallpaper',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            ListTile(
              leading: Icon(Icons.home, size: iconSize),
              title: Text('Home Screen', style: TextStyle(fontSize: fontSize)),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 8 : 4,
              ),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, size: iconSize),
              title: Text('Lock Screen', style: TextStyle(fontSize: fontSize)),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 8 : 4,
              ),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.phonelink, size: iconSize),
              title: Text('Both Screens', style: TextStyle(fontSize: fontSize)),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 8 : 4,
              ),
              onTap: () {
                Navigator.pop(context);
                _setWallpaper(3);
              },
            ),
            SizedBox(height: isTablet ? 16 : 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = ResponsiveUtils.isTablet(context);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    final titleSize = ResponsiveUtils.getFontSize(context, 18);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: ResponsiveUtils.getIconSize(context, 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Hero(
            tag: widget.wallpaper.id,
            child: CachedNetworkImage(
              imageUrl: widget.wallpaper.getImageUrl(),
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: Center(
                  child: SizedBox(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 60 : 50,
                    child: const CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: Icon(
                  Icons.error,
                  size: ResponsiveUtils.getIconSize(context, 48),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isTablet ? 60 : 50,
                      height: isTablet ? 60 : 50,
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    Text(
                      'Setting wallpaper...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              padding: ResponsiveUtils.getScreenPadding(context).copyWith(
                top: isTablet ? 40 : 30,
                bottom: isTablet ? 30 : 20,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'By ${widget.wallpaper.author}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      widget.wallpaper.getDisplayInfo(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: fontSize * 0.9,
                      ),
                    ),
                    if (widget.wallpaper.getTagsList().isNotEmpty) ...[
                      SizedBox(height: isTablet ? 12 : 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            widget.wallpaper.getTagsList().take(5).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 10,
                              vertical: isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize * 0.85,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    SizedBox(height: isTablet ? 24 : 16),
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.getButtonHeight(context),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showSetWallpaperDialog,
                        icon: Icon(
                          Icons.wallpaper,
                          size: ResponsiveUtils.getIconSize(context, 20),
                        ),
                        label: Text(
                          'Set as Wallpaper',
                          style: TextStyle(fontSize: titleSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
