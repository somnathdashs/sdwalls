import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper.dart';
import '../providers/wallpaper_provider.dart';
import '../screens/wallpaper_detail_screen.dart';
import '../utils/responsive_utils.dart';

class WallpaperGrid extends StatefulWidget {
  final List<Wallpaper> wallpapers;

  const WallpaperGrid({super.key, required this.wallpapers});

  @override
  State<WallpaperGrid> createState() => _WallpaperGridState();
}

class _WallpaperGridState extends State<WallpaperGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreWallpapers();
    }
  }

  void _loadMoreWallpapers() {
    final provider = context.read<WallpaperProvider>();
    if (provider.hasMoreData && !provider.isLoadingMore) {
      provider.loadMoreWallpapers();
    }
  }

  /// Get aspect ratio based on orientation
  double _getAspectRatio(String orientation, bool isTablet) {
    switch (orientation) {
      case 'horizontal':
        // Landscape wallpapers (wider than tall)
        return isTablet ? 1.6 : 1.5; // 16:10 ratio
      case 'vertical':
        // Portrait wallpapers (taller than wide)
        return isTablet ? 0.65 : 0.6; // 2:3 ratio
      case 'all':
        // Mixed orientations - use middle ground
        return isTablet ? 0.8 : 0.75;
      default:
        return isTablet ? 0.65 : 0.6;
    }
  }

  /// Get grid columns based on orientation and device
  int _getGridColumns(BuildContext context, String orientation) {
    final width = MediaQuery.of(context).size.width;
    
    if (orientation == 'horizontal') {
      // Fewer columns for landscape wallpapers (they're wider)
      if (width >= 1200) return 3; // Desktop
      if (width >= 900) return 2;  // Large tablet landscape
      if (width >= 600) return 2;  // Tablet portrait
      return 1;                    // Mobile (single column for landscape)
    } else {
      // More columns for portrait wallpapers (standard)
      if (width >= 1200) return 6; // Desktop
      if (width >= 900) return 4;  // Large tablet landscape
      if (width >= 600) return 3;  // Tablet portrait
      return 2;                    // Mobile
    }
  }

  /// Check if wallpaper is landscape
  bool _isLandscape(Wallpaper wallpaper) {
    return wallpaper.imageWidth > wallpaper.imageHeight;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final padding = ResponsiveUtils.getScreenPadding(context);

    return Consumer<WallpaperProvider>(
      builder: (context, provider, child) {
        final orientation = provider.orientation;
        final crossAxisCount = _getGridColumns(context, orientation);
        final aspectRatio = _getAspectRatio(orientation, isTablet);

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: isTablet ? 12 : 8,
                  mainAxisSpacing: isTablet ? 12 : 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final wallpaper = widget.wallpapers[index];
                    return _buildWallpaperCard(
                      context, 
                      wallpaper, 
                      orientation,
                      isTablet,
                    );
                  },
                  childCount: widget.wallpapers.length,
                ),
              ),
            ),
            
            // Loading more indicator
            if (provider.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: isTablet ? 40 : 32,
                          height: isTablet ? 40 : 32,
                          child: CircularProgressIndicator(
                            strokeWidth: isTablet ? 3 : 2,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'Loading more ${_getOrientationText(orientation)} wallpapers...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // End of data indicator
            if (!provider.hasMoreData && widget.wallpapers.isNotEmpty && !provider.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: ResponsiveUtils.getIconSize(context, 32),
                          color: Colors.green,
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'You\'ve seen all ${_getOrientationText(orientation)} wallpapers!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total: ${widget.wallpapers.length} wallpapers',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build individual wallpaper card
  Widget _buildWallpaperCard(
    BuildContext context,
    Wallpaper wallpaper,
    String orientation,
    bool isTablet,
  ) {
    final isLandscape = _isLandscape(wallpaper);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper),
          ),
        );
      },
      child: Hero(
        tag: wallpaper.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main wallpaper image
              CachedNetworkImage(
                imageUrl: wallpaper.getThumbnailUrl(),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isTablet ? 40 : 30,
                          height: isTablet ? 40 : 30,
                          child: CircularProgressIndicator(
                            strokeWidth: isTablet ? 3 : 2,
                          ),
                        ),
                        if (isLandscape) ...[
                          SizedBox(height: 12),
                          Icon(
                            Icons.landscape,
                            size: ResponsiveUtils.getIconSize(context, 24),
                            color: Colors.grey[600],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        size: ResponsiveUtils.getIconSize(context, 32),
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: ResponsiveUtils.getFontSize(context, 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Orientation indicator badge (top-right)
              if (orientation == 'all')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLandscape ? Colors.orange : Colors.blue,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLandscape 
                              ? Icons.stay_current_landscape
                              : Icons.stay_current_portrait,
                          size: ResponsiveUtils.getIconSize(context, 14),
                          color: isLandscape ? Colors.orange : Colors.blue,
                        ),
                        if (isTablet) ...[
                          SizedBox(width: 4),
                          Text(
                            isLandscape ? 'H' : 'V',
                            style: TextStyle(
                              color: isLandscape ? Colors.orange : Colors.blue,
                              fontSize: ResponsiveUtils.getFontSize(context, 10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              
              // Gradient overlay at bottom
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
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Author name
                      Text(
                        wallpaper.author,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getFontSize(context, 12),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Stats row
                      if (isTablet || isLandscape) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            // Resolution (important for landscape)
                            if (isLandscape) ...[
                              Icon(
                                Icons.aspect_ratio,
                                size: ResponsiveUtils.getIconSize(context, 12),
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${wallpaper.imageWidth}×${wallpaper.imageHeight}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: ResponsiveUtils.getFontSize(context, 10),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                            
                            // Likes
                            Icon(
                              Icons.favorite,
                              size: ResponsiveUtils.getIconSize(context, 14),
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(width: 2),
                            Text(
                              _formatNumber(wallpaper.likes),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: ResponsiveUtils.getFontSize(context, 10),
                              ),
                            ),
                            
                            // Views (tablet only)
                            if (isTablet) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.visibility,
                                size: ResponsiveUtils.getIconSize(context, 14),
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(width: 2),
                              Text(
                                _formatNumber(wallpaper.views),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: ResponsiveUtils.getFontSize(context, 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Hover/ripple effect for tablets
              if (isTablet)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper),
                          ),
                        );
                      },
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get orientation display text
  String _getOrientationText(String orientation) {
    switch (orientation) {
      case 'horizontal':
        return 'landscape';
      case 'vertical':
        return 'portrait';
      case 'all':
        return '';
      default:
        return '';
    }
  }

  /// Format large numbers
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
