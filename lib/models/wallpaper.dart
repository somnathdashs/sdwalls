class Wallpaper {
  final String id;
  final String author;
  final String tags;
  final String previewUrl;
  final String webformatUrl;
  final String largeImageUrl;
  final String fullHDUrl;
  final int imageWidth;
  final int imageHeight;
  final int views;
  final int downloads;
  final int likes;

  Wallpaper({
    required this.id,
    required this.author,
    required this.tags,
    required this.previewUrl,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.fullHDUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.views,
    required this.downloads,
    required this.likes,
  });

  // Constructor for Pixabay JSON response
  factory Wallpaper.fromPixabayJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id']?.toString() ?? '',
      author: json['user'] ?? 'Unknown',
      tags: json['tags'] ?? '',
      previewUrl: json['previewURL'] ?? '',
      webformatUrl: json['webformatURL'] ?? '',
      largeImageUrl: json['largeImageURL'] ?? json['webformatURL'] ?? '',
      fullHDUrl: json['fullHDURL'] ?? json['largeImageURL'] ?? json['webformatURL'] ?? '',
      imageWidth: json['imageWidth'] ?? 1080,
      imageHeight: json['imageHeight'] ?? 1920,
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  // Backward compatibility constructor
  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper.fromPixabayJson(json);
  }

  String getImageUrl() {
    // Return best available quality
    if (fullHDUrl.isNotEmpty) return fullHDUrl;
    if (largeImageUrl.isNotEmpty) return largeImageUrl;
    return webformatUrl;
  }

  String getPreviewUrl() {
    return previewUrl;
  }

  String getThumbnailUrl() {
    return webformatUrl;
  }

  String getOptimizedUrl(int targetWidth, int targetHeight) {
    // Return the best quality available
    return getImageUrl();
  }

  // Get display info for UI
  String getDisplayInfo() {
    return 'By $author • ${_formatNumber(views)} views • ${_formatNumber(likes)} likes';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  List<String> getTagsList() {
    return tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }
}
