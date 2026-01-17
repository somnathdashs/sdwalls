# SDwalls - Responsive Wallpaper App

A beautiful, responsive Flutter wallpaper application with auto-update functionality using **Pixabay API with Safe Search enabled**. Optimized for both **mobile phones** and **tablets**.

## 🎯 Features

### Core Features
✨ **Responsive Design** - Automatically adapts to phones, tablets, and large screens  
🔒 **Safe Search Enabled** - Family-friendly content with Pixabay's safe search  
🏠 **Home Screen** - Categories: Latest, Space, Nature, Architecture, Animals, Technology, Abstract, Cars  
🔍 **Search Functionality** - Find any wallpaper with safe search filtering  
📱 **Set Wallpapers** - Home Screen, Lock Screen, or Both  
⏰ **Auto-Update** - Intervals: 1hr, 15hr, 24hr, 3 days, 1 week, 1 month  
🔔 **Background Notifications** - Get notified before wallpaper changes  
🎨 **Modern Dark Theme** - Beautiful UI with purple accents  

### Responsive Features
📲 **Mobile Optimized** - 2-column grid layout  
📱 **Tablet Optimized** - 3-4 column grid with enhanced UI elements  
🖥️ **Desktop Ready** - Up to 6-column grid with max-width constraints  
🔄 **Adaptive Text** - Font sizes scale based on device  
📐 **Smart Spacing** - Padding and margins adjust per device  
🎯 **Touch Targets** - Larger buttons and controls on tablets  

### Safety Features
✅ **Safe Search Always On** - All API calls include safesearch=true  
✅ **Family-Friendly** - Content filtered at API level  
✅ **Quality Control** - Minimum resolution requirements  
✅ **Vertical Orientation** - Optimized for mobile wallpapers  

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio or VS Code
- Pixabay API Key (Free - 5000 requests/hour)

### Step 1: Get Pixabay API Key

1. Visit: https://pixabay.com/accounts/register/
2. Create a free account
3. Go to: https://pixabay.com/api/docs/
4. Copy your API key

**Important:** Pixabay **ALLOWS** wallpaper applications (unlike Unsplash)

### Step 2: Extract Project

```bash
unzip sdwalls_responsive_app.zip
cd sdwalls
```

### Step 3: Add API Key

Open `lib/services/pixabay_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_PIXABAY_API_KEY_HERE';
```

With your actual key:
```dart
static const String _apiKey = 'your_actual_api_key_12345';
```

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Run the App

```bash
# On mobile device/emulator
flutter run

# For specific device
flutter devices
flutter run -d <device_id>
```

### Step 6: Build APK

```bash
# Release build
flutter build apk --release

# Split APKs by architecture (smaller size)
flutter build apk --split-per-abi
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Responsive Breakpoints

The app uses intelligent breakpoints:

| Device Type | Width | Grid Columns | Features |
|-------------|-------|--------------|----------|
| **Mobile** | < 600px | 2 | Compact layout |
| **Tablet** | 600-1199px | 3-4 | Enhanced UI, larger text |
| **Desktop** | ≥ 1200px | 4-6 | Max-width container, spacious |

### Adaptive Elements

- **Font Sizes**: Scale 1.0x (mobile), 1.2x (tablet), 1.4x (desktop)
- **Icon Sizes**: Scale proportionally
- **Button Heights**: 50px (mobile), 56px (tablet)
- **Grid Spacing**: 8px (mobile), 12px (tablet)
- **Padding**: 12px (mobile), 24px (tablet), 40px (desktop)

## 🔐 Pixabay API & Safe Search

### Why Pixabay?
- ✅ **Wallpaper apps explicitly allowed**
- ✅ **5000 requests/hour** (vs Unsplash's 50)
- ✅ **Built-in safe search**
- ✅ **No attribution required**
- ✅ **High-quality vertical images**

### Safe Search Implementation

Every API call includes `safesearch=true`:

```dart
final Map<String, String> params = {
  'key': _apiKey,
  'safesearch': 'true',  // ✅ Safe search enabled
  'orientation': 'vertical',
  'min_width': '1080',
  'min_height': '1920',
  // ... other params
};
```

This ensures all content is:
- Family-friendly
- Appropriate for all ages
- Filtered at the API level
- Safe for work (SFW)

## 🎨 Project Structure

```
sdwalls/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── models/
│   │   └── wallpaper.dart              # Wallpaper data model
│   ├── providers/
│   │   └── wallpaper_provider.dart     # State management
│   ├── screens/
│   │   ├── splash_screen.dart          # Responsive splash
│   │   ├── home_screen.dart            # Main screen
│   │   ├── search_screen.dart          # Search with safe search
│   │   ├── auto_wallpaper_screen.dart  # Auto-update settings
│   │   └── wallpaper_detail_screen.dart # Details & set wallpaper
│   ├── services/
│   │   ├── pixabay_service.dart        # Pixabay API (safe search)
│   │   ├── wallpaper_service.dart      # Set wallpaper logic
│   │   └── background_service.dart     # Background tasks
│   ├── widgets/
│   │   ├── category_chip.dart          # Responsive category chips
│   │   └── wallpaper_grid.dart         # Responsive grid
│   └── utils/
│       └── responsive_utils.dart       # Responsive helper functions
├── android/                             # Android config
├── pubspec.yaml                         # Dependencies
└── README.md                            # This file
```

## 📊 Responsive Design Implementation

### ResponsiveUtils Class

The app uses a centralized `ResponsiveUtils` class that provides:

```dart
// Check device type
ResponsiveUtils.isMobile(context)    // < 600px
ResponsiveUtils.isTablet(context)    // 600-1199px
ResponsiveUtils.isDesktop(context)   // ≥ 1200px

// Get adaptive values
ResponsiveUtils.getGridColumns(context)      // 2-6 columns
ResponsiveUtils.getFontSize(context, 16)     // Scaled font
ResponsiveUtils.getIconSize(context, 24)     // Scaled icon
ResponsiveUtils.getScreenPadding(context)    // Adaptive padding
```

### Example Usage

```dart
final isTablet = ResponsiveUtils.isTablet(context);
final fontSize = ResponsiveUtils.getFontSize(context, 16);

Text(
  'Hello',
  style: TextStyle(fontSize: fontSize),
)
```

## 🔧 Testing on Different Devices

### Mobile Testing
```bash
# Phone emulator
flutter run
```

### Tablet Testing
```bash
# Create tablet emulator in Android Studio
# Pixel Tablet or Samsung Galaxy Tab

flutter run -d <tablet_device_id>
```

### Multiple Screen Sizes
The app automatically adapts to:
- Small phones (< 360px width)
- Regular phones (360-599px)
- Small tablets (600-767px)
- Large tablets (768-1199px)
- Desktop/Large displays (≥ 1200px)

## ⚙️ Configuration

### Categories

Edit categories in `lib/screens/home_screen.dart`:
```dart
final List<String> categories = [
  'Latest',
  'Space',
  'Nature',
  // Add more...
];
```

### Theme Colors

Change colors in `lib/main.dart`:
```dart
colorScheme: ColorScheme.dark(
  primary: Colors.purple[400]!,  // Change this
  secondary: Colors.purpleAccent,
),
```

### Grid Layout

Adjust responsive grid in `lib/utils/responsive_utils.dart`:
```dart
static int getGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width >= 1200) return 6;  // Adjust for desktop
  if (width >= 900) return 4;   // Adjust for tablet landscape
  if (width >= 600) return 3;   // Adjust for tablet portrait
  return 2;                      // Mobile
}
```

## 🆘 Troubleshooting

### API Issues

**Problem:** Rate limit exceeded  
**Solution:** Pixabay free tier = 5000/hour (very generous)

**Problem:** No results  
**Solution:** Check API key in `pixabay_service.dart`

### UI Issues

**Problem:** Layout looks wrong on tablet  
**Solution:** Test in landscape mode, adjust breakpoints if needed

**Problem:** Text too small/large  
**Solution:** Adjust multipliers in `ResponsiveUtils.getFontSize()`

### Build Issues

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Supported Devices

### Tested On
- ✅ Phones: 4" to 7" screens
- ✅ Tablets: 7" to 13" screens
- ✅ Foldables: Galaxy Fold, Surface Duo
- ✅ Android 5.0 to Android 14

### Orientation Support
- ✅ Portrait mode (primary)
- ✅ Landscape mode (tablets)
- ✅ Auto-rotation supported

## 🔐 Permissions

Auto-handled for all Android versions:
- **INTERNET** - Download wallpapers
- **SET_WALLPAPER** - Apply wallpapers
- **POST_NOTIFICATIONS** - Background updates (Android 13+)
- **READ_MEDIA_IMAGES** - Image access (Android 13+)

## 💡 Tips for Best Experience

### For Mobile Users
- Use 2-column grid for faster scrolling
- Search uses safe search automatically
- Auto-wallpaper works in background

### For Tablet Users
- Rotate to landscape for more columns
- Larger touch targets for easier navigation
- Enhanced details view with more info

### For Developers
- Customize breakpoints in `responsive_utils.dart`
- Add more categories in `home_screen.dart`
- Adjust grid ratios for your needs
- Test on multiple screen sizes

## 📝 Before Publishing

- [ ] Add app logo to `assets/logo.png`
- [ ] Configure app signing
- [ ] Test on phones and tablets
- [ ] Test in portrait and landscape
- [ ] Verify safe search is working
- [ ] Update version in `pubspec.yaml`
- [ ] Create Play Store screenshots (phone + tablet)
- [ ] Write privacy policy
- [ ] Build release APK
- [ ] Test release APK on multiple devices

## 🎓 Learn More

- **Flutter Responsive Design**: https://docs.flutter.dev/development/ui/layout/responsive
- **Pixabay API**: https://pixabay.com/api/docs/
- **MediaQuery**: https://api.flutter.dev/flutter/widgets/MediaQuery-class.html

## ⚖️ Legal & Compliance

✅ **Pixabay allows wallpaper apps**  
✅ **Safe search ensures family-friendly content**  
✅ **No attribution required (but appreciated)**  
✅ **Commercial use allowed**  
✅ **5000 requests/hour free tier**  

## 🎉 Credits

- Wallpapers powered by [Pixabay](https://pixabay.com)
- Built with [Flutter](https://flutter.dev)
- Icons from Material Design

---

**Made with ❤️ for Mobile & Tablet Users**

For issues or questions, check the troubleshooting section first.
