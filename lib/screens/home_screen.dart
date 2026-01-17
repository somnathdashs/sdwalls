import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdwalls/screens/about_screen.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/wallpaper_grid.dart';
import '../utils/responsive_utils.dart';
import 'search_screen.dart';
import 'auto_wallpaper_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> categories = [
    'Latest',
    'Space',
    'Nature',
    'Architecture',
    'Animals',
    'Technology',
    'Abstract',
    'Cars',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WallpaperProvider>();
      if (Platform.isWindows || ResponsiveUtils.isTablet(context)) {
        provider.setOrientation('horizontal');
      } else if (Platform.isAndroid) {
        // Assuming Android phones are not tablets
        provider.setOrientation('vertical');
      }
      provider.fetchWallpapers('latest');
    });
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedIndex = index);
    context.read<WallpaperProvider>().fetchWallpapers(
          categories[index].toLowerCase(),
          refresh: true,
        );
  }

  void _onOrientationChanged(String orientation) {
    final provider = context.read<WallpaperProvider>();
    provider.setOrientation(orientation);
    // Reload current category with new orientation
    provider.fetchWallpapers(
      categories[_selectedIndex].toLowerCase(),
      refresh: true,
    );
  }

  Future<void> _onRefresh() async {
    await context.read<WallpaperProvider>().fetchWallpapers(
          categories[_selectedIndex].toLowerCase(),
          refresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final iconSize = ResponsiveUtils.getIconSize(context, 24);
    final titleSize = ResponsiveUtils.getFontSize(context, 24);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(ResponsiveUtils.getAppBarHeight(context)),
        child: AppBar(
          title: Text(
            'SDwalls',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
            ),
          ),
          actions: [
            // Orientation Filter Button
            Consumer<WallpaperProvider>(
              builder: (context, provider, child) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    provider.orientation == 'vertical'
                        ? Icons.stay_current_portrait
                        : provider.orientation == 'horizontal'
                            ? Icons.stay_current_landscape
                            : Icons.crop_free,
                    size: iconSize,
                  ),
                  tooltip: 'Orientation',
                  onSelected: _onOrientationChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'vertical',
                      child: Row(
                        children: [
                          Icon(
                            Icons.stay_current_portrait,
                            color: provider.orientation == 'vertical'
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Vertical (Portrait)',
                            style: TextStyle(
                              fontWeight: provider.orientation == 'vertical'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: provider.orientation == 'vertical'
                                  ? Colors.purple
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'horizontal',
                      child: Row(
                        children: [
                          Icon(
                            Icons.stay_current_landscape,
                            color: provider.orientation == 'horizontal'
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Horizontal (Landscape)',
                            style: TextStyle(
                              fontWeight: provider.orientation == 'horizontal'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: provider.orientation == 'horizontal'
                                  ? Colors.purple
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'all',
                      child: Row(
                        children: [
                          Icon(
                            Icons.crop_free,
                            color: provider.orientation == 'all'
                                ? Colors.purple
                                : Colors.grey,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'All Orientations',
                            style: TextStyle(
                              fontWeight: provider.orientation == 'all'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: provider.orientation == 'all'
                                  ? Colors.purple
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      enabled: false, // It's a switch, not a selectable item
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    provider.childSafety
                                        ? Icons.child_care
                                        : Icons.no_adult_content,
                                    color: provider.childSafety
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Child Safety',
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: provider.childSafety,
                                onChanged: (value) {
                                  provider.toggleChildSafety(value);
                                  Navigator.pop(
                                      context); // Close menu to apply changes
                                },
                                activeColor: Colors.purple,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search, size: iconSize),
              tooltip: 'Search',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.history, size: iconSize),
              tooltip: 'History',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline, size: iconSize),
              tooltip: 'About',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            if (!Platform.isWindows)
              IconButton(
                icon: Icon(Icons.auto_awesome, size: iconSize),
                tooltip: 'Auto Wallpaper',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AutoWallpaperScreen()),
                  );
                },
              ),
            if (isTablet) SizedBox(width: 8),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            Container(
              height: ResponsiveUtils.getCategoryChipHeight(context) + 16,
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: isTablet ? 16 : 8,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: isTablet ? 12 : 8),
                    child: CategoryChip(
                      label: categories[index],
                      isSelected: _selectedIndex == index,
                      onTap: () => _onCategorySelected(index),
                    ),
                  );
                },
              ),
            ),
            if (isTablet)
              Consumer<WallpaperProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          provider.childSafety
                              ? Icons.verified_user
                              : Icons.gpp_bad,
                          size: 16,
                          color: provider.childSafety
                              ? Colors.green[400]
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Child Safety: ${provider.childSafety ? 'ON' : 'OFF'} • Infinite Scroll • ${provider.orientation == 'vertical' ? 'Portrait' : provider.orientation == 'horizontal' ? 'Landscape' : 'All'} Mode',
                          style: TextStyle(
                            color: provider.childSafety
                                ? Colors.green[400]
                                : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            Expanded(
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
                            child:
                                const CircularProgressIndicator(strokeWidth: 3),
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          Text(
                            'Loading beautiful wallpapers...',
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtils.getFontSize(context, 16),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.error.isNotEmpty &&
                      provider.wallpapers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: ResponsiveUtils.getScreenPadding(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: isTablet ? 80 : 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: isTablet ? 24 : 16),
                            Text(
                              provider.error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize:
                                    ResponsiveUtils.getFontSize(context, 16),
                              ),
                            ),
                            SizedBox(height: isTablet ? 24 : 16),
                            ElevatedButton.icon(
                              onPressed: () => _onRefresh(),
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getFontSize(context, 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (provider.wallpapers.isNotEmpty) {
                    return WallpaperGrid(wallpapers: provider.wallpapers);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
