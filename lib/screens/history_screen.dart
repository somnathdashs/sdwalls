import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/history_service.dart';
import '../screens/wallpaper_detail_screen.dart';
import '../utils/responsive_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<HistoryItem> _viewedHistory = [];
  List<HistoryItem> _appliedHistory = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final viewed = await HistoryService.getViewedHistory();
      final applied = await HistoryService.getAppliedHistory();
      final stats = await HistoryService.getHistoryStats();
      print(viewed.first.viewedAt);

      
      setState(() {
        _viewedHistory = viewed;
        _appliedHistory = applied;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory(HistoryType? type) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: Text(
          type == null 
              ? 'Are you sure you want to clear all history?'
              : type == HistoryType.viewed
                  ? 'Clear all viewed wallpapers history?'
                  : 'Clear all applied wallpapers history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        if (type == null) {
          await HistoryService.clearAllHistory();
        } else if (type == HistoryType.viewed) {
          await HistoryService.clearViewedHistory();
        } else {
          await HistoryService.clearAppliedHistory();
        }
        
        _loadHistory();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('History cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing history: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeItem(String wallpaperId, HistoryType type) async {
    try {
      await HistoryService.removeFromHistory(wallpaperId, type);
      _loadHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from history'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 20)),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.visibility, size: ResponsiveUtils.getIconSize(context, 20)),
              text: 'Viewed (${_stats['totalViewed'] ?? 0})',
            ),
            Tab(
              icon: Icon(Icons.wallpaper, size: ResponsiveUtils.getIconSize(context, 20)),
              text: 'Applied (${_stats['totalApplied'] ?? 0})',
            ),
            Tab(
              icon: Icon(Icons.analytics, size: ResponsiveUtils.getIconSize(context, 20)),
              text: 'Stats',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: ResponsiveUtils.getIconSize(context, 24)),
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _clearHistory(null);
                  break;
                case 'clear_viewed':
                  _clearHistory(HistoryType.viewed);
                  break;
                case 'clear_applied':
                  _clearHistory(HistoryType.applied);
                  break;
                case 'refresh':
                  _loadHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_viewed',
                child: Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(width: 8),
                    Text('Clear Viewed'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_applied',
                child: Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(width: 8),
                    Text('Clear Applied'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
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
                    'Loading history...',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryList(_viewedHistory, HistoryType.viewed),
                _buildHistoryList(_appliedHistory, HistoryType.applied),
                _buildStatsView(),
              ],
            ),
    );
  }

  Widget _buildHistoryList(List<HistoryItem> history, HistoryType type) {
    final isTablet = ResponsiveUtils.isTablet(context);
    
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == HistoryType.viewed ? Icons.visibility_off : Icons.wallpaper_outlined,
                size: isTablet ? 80 : 60,
                color: Colors.grey,
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                type == HistoryType.viewed 
                    ? 'No viewed wallpapers yet'
                    : 'No applied wallpapers yet',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                type == HistoryType.viewed
                    ? 'Wallpapers you view will appear here'
                    : 'Wallpapers you set will appear here',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: ResponsiveUtils.getScreenPadding(context),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        
        return Card(
          margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
          elevation: ResponsiveUtils.getCardElevation(context),
          child: ListTile(
            contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.wallpaper.previewUrl,
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: SizedBox(
                      width: isTablet ? 24 : 20,
                      height: isTablet ? 24 : 20,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.error,
                    size: ResponsiveUtils.getIconSize(context, 24),
                  ),
                ),
              ),
            ),
            title: Text(
              'By ${item.wallpaper.author}',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  item.getTimeAgo(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 12),
                    color: Colors.grey,
                  ),
                ),
                if (type == HistoryType.applied) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        item.success == true ? Icons.check_circle : Icons.error,
                        size: ResponsiveUtils.getIconSize(context, 16),
                        color: item.success == true ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 4),
                      Text(
                        item.success == true 
                            ? 'Applied to ${item.getLocationName()}'
                            : 'Failed to apply',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 12),
                          color: item.success == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: ResponsiveUtils.getIconSize(context, 20)),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WallpaperDetailScreen(wallpaper: item.wallpaper),
                      ),
                    );
                    break;
                  case 'remove':
                    _removeItem(item.wallpaper.id, type);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WallpaperDetailScreen(wallpaper: item.wallpaper),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsView() {
    final isTablet = ResponsiveUtils.isTablet(context);
    final titleSize = ResponsiveUtils.getFontSize(context, 18);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    
    return ListView(
      padding: ResponsiveUtils.getScreenPadding(context),
      children: [
        Card(
          elevation: ResponsiveUtils.getCardElevation(context),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usage Statistics',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),
                _buildStatRow(
                  Icons.visibility,
                  'Wallpapers Viewed',
                  '${_stats['totalViewed'] ?? 0}',
                  Colors.blue,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                _buildStatRow(
                  Icons.wallpaper,
                  'Wallpapers Applied',
                  '${_stats['totalApplied'] ?? 0}',
                  Colors.purple,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                _buildStatRow(
                  Icons.check_circle,
                  'Successful Applications',
                  '${_stats['successfulApplications'] ?? 0}',
                  Colors.green,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                _buildStatRow(
                  Icons.error,
                  'Failed Applications',
                  '${_stats['failedApplications'] ?? 0}',
                  Colors.red,
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: isTablet ? 24 : 16),
        
        Card(
          elevation: ResponsiveUtils.getCardElevation(context),
          color: Colors.blue[900]?.withOpacity(0.3),
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
                      'About History',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  '• Viewed history tracks wallpapers you\'ve opened\n'
                  '• Applied history shows wallpapers you\'ve set\n'
                  '• History is stored locally on your device\n'
                  '• Maximum 100 items per category\n'
                  '• You can clear history anytime',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: fontSize * 0.9,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final fontSize = ResponsiveUtils.getFontSize(context, 16);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getIconSize(context, 24),
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
