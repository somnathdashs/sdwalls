import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid.dart';
import '../utils/responsive_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && query != _lastSearchQuery) {
      _lastSearchQuery = query;
      context.read<WallpaperProvider>().searchWallpapers(query, refresh: true);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _lastSearchQuery = '';
    context.read<WallpaperProvider>().resetPagination();
  }

  Future<void> _onRefresh() async {
    if (_lastSearchQuery.isNotEmpty) {
      await context.read<WallpaperProvider>().searchWallpapers(_lastSearchQuery, refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ResponsiveUtils.getAppBarHeight(context)),
        child: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: !isTablet,
            style: TextStyle(color: Colors.white, fontSize: fontSize),
            decoration: InputDecoration(
              hintText: 'Search wallpapers...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: fontSize,
              ),
              border: InputBorder.none,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size: iconSize * 0.8),
                      onPressed: _clearSearch,
                    ),
                  IconButton(
                    icon: Icon(Icons.search, size: iconSize),
                    onPressed: _performSearch,
                  ),
                ],
              ),
            ),
            onSubmitted: (_) => _performSearch(),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Consumer<WallpaperProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.wallpapers.isEmpty) {
              return Center(
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
                      'Searching...',
                      style: TextStyle(fontSize: fontSize, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            
            if (provider.wallpapers.isEmpty && !provider.isLoading && _lastSearchQuery.isEmpty) {
              return Center(
                child: Padding(
                  padding: ResponsiveUtils.getScreenPadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: isTablet ? 100 : 80,
                        color: Colors.grey[700],
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      Text(
                        'Search for amazing wallpapers',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 18),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 8),
                      Text(
                        'Try: nature, space, cars, abstract, animals...',
                        style: TextStyle(
                          fontSize: fontSize * 0.9,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (provider.wallpapers.isEmpty && !provider.isLoading && _lastSearchQuery.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: ResponsiveUtils.getScreenPadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: isTablet ? 80 : 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      Text(
                        'No results for "$_lastSearchQuery"',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 18),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 8),
                      Text(
                        'Try different keywords',
                        style: TextStyle(
                          fontSize: fontSize * 0.9,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      ElevatedButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                        label: Text('Clear Search'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (provider.wallpapers.isNotEmpty) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                    color: Colors.grey[900]?.withOpacity(0.5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: ResponsiveUtils.getIconSize(context, 16),
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Results for "$_lastSearchQuery"',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: fontSize * 0.9,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${provider.wallpapers.length}${provider.hasMoreData ? '+' : ''} wallpapers',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: fontSize * 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: WallpaperGrid(wallpapers: provider.wallpapers),
                  ),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
