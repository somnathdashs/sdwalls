# SDwalls Integration Guide - Responsive Version

## Complete Setup for Mobile & Tablet Devices

### Prerequisites Check

Before starting, ensure you have:
- [ ] Flutter SDK 3.0.0 or higher
- [ ] Android Studio or VS Code
- [ ] Android device or emulator
- [ ] Tablet emulator (optional, for testing)

Check Flutter installation:
```bash
flutter doctor
```

---

## Step-by-Step Integration

### STEP 1: Extract Project

```bash
unzip sdwalls_responsive_app.zip
cd sdwalls
```

---

### STEP 2: Get Pixabay API Key

#### Why Pixabay?
- ✅ **Explicitly allows wallpaper applications**
- ✅ **5000 requests/hour (vs Unsplash's 50)**
- ✅ **Built-in safe search**
- ✅ **No attribution required**
- ✅ **High-quality images**

#### Get Your Key:
1. Visit: https://pixabay.com/accounts/register/
2. Create free account (no credit card needed)
3. Verify email
4. Go to: https://pixabay.com/api/docs/
5. Scroll down and copy your API key

**Example Key Format:** `12345678-abc123def456ghi789jkl012`

---

### STEP 3: Add API Key to Project

Open `lib/services/pixabay_service.dart`

**Find line 8:**
```dart
static const String _apiKey = 'YOUR_PIXABAY_API_KEY_HERE';
```

**Replace with your key:**
```dart
static const String _apiKey = '12345678-abc123def456ghi789jkl012';
```

**⚠️ CRITICAL:** Make sure safe search is enabled (it's already in the code):
```dart
'safesearch': 'true',  // ✅ This ensures family-friendly content
```

---

### STEP 4: Add Logo (Optional)

1. Create `assets` folder in project root:
```bash
mkdir assets
```

2. Add your logo as `logo.png` (512x512px recommended)

3. Generate splash screen:
```bash
dart run flutter_native_splash:create
```

---

### STEP 5: Install Dependencies

```bash
flutter pub get
```

**If you encounter errors:**
```bash
flutter clean
flutter pub get
```

---

### STEP 6: Test on Mobile Device

#### Connect Physical Device:
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect via USB
4. Run:
```bash
flutter devices
flutter run
```

#### Or Use Emulator:
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

---

### STEP 7: Test on Tablet (Optional but Recommended)

#### Create Tablet Emulator in Android Studio:
1. Open Android Studio
2. Tools → Device Manager
3. Create Device → Tablet
4. Select: Pixel Tablet or Samsung Galaxy Tab
5. Download system image (API 30+)
6. Finish

#### Run on Tablet:
```bash
flutter devices
flutter run -d <tablet_device_id>
```

#### Test in Both Orientations:
- Portrait mode
- Landscape mode
- Verify grid adapts (3-4 columns on tablet)

---

### STEP 8: Verify Responsive Design

#### Mobile (< 600px):
- [ ] 2-column grid
- [ ] Compact spacing
- [ ] Standard text sizes
- [ ] Categories scroll horizontally

#### Tablet (600-1199px):
- [ ] 3-4 column grid
- [ ] Larger spacing
- [ ] Bigger text/icons
- [ ] Enhanced UI elements
- [ ] Hover effects work

#### Desktop (≥ 1200px):
- [ ] 4-6 column grid
- [ ] Max-width container
- [ ] Very spacious layout

---

### STEP 9: Verify Safe Search

1. Open the app
2. Search for various terms
3. Verify all results are family-friendly
4. Check: No inappropriate content

**Behind the scenes:**
Every API call includes:
```dart
'safesearch': 'true',
'orientation': 'vertical',
'min_width': '1080',
'min_height': '1920',
```

---

### STEP 10: Test Auto Wallpaper Feature

1. Open app
2. Tap Auto Wallpaper icon (⭐)
3. Enable auto wallpaper
4. Grant notification permission
5. Select 1 hour interval (for testing)
6. Choose "Random" or enter term
7. Close app
8. Wait 1 hour
9. Verify notification appears
10. Tap notification to apply wallpaper

---

## Responsive Design Testing Checklist

### Test on Multiple Screen Sizes

#### Small Phone (< 360px):
```bash
# Test on small device
flutter run
```
- [ ] UI is not cramped
- [ ] Text is readable
- [ ] Buttons are tappable

#### Regular Phone (360-599px):
- [ ] 2-column grid
- [ ] Comfortable spacing
- [ ] Standard text sizes

#### Small Tablet (600-767px):
- [ ] 3-column grid
- [ ] Increased text sizes
- [ ] Larger touch targets

#### Large Tablet (768-1199px):
- [ ] 4-column grid in portrait
- [ ] Enhanced UI details
- [ ] Comfortable for touch

#### Landscape Mode (Tablets):
- [ ] More columns displayed
- [ ] Layout doesn't break
- [ ] Content is centered

---

## Customization Guide

### Change Theme Colors

Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.dark(
  primary: Colors.purple[400]!,    // Main color
  secondary: Colors.purpleAccent,  // Accent color
),
```

**Popular color schemes:**
- Blue: `Colors.blue[400]`, `Colors.blueAccent`
- Green: `Colors.green[400]`, `Colors.greenAccent`
- Orange: `Colors.orange[400]`, `Colors.deepOrange`

### Adjust Responsive Breakpoints

Edit `lib/utils/responsive_utils.dart`:
```dart
static bool isTablet(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= 600 && width < 1200;  // Adjust these values
}
```

### Change Grid Columns

```dart
static int getGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width >= 1200) return 6;  // Desktop
  if (width >= 900) return 5;   // Large tablet landscape
  if (width >= 600) return 3;   // Tablet portrait
  return 2;                      // Mobile
}
```

### Add More Categories

Edit `lib/screens/home_screen.dart`:
```dart
final List<String> categories = [
  'Latest',
  'Space',
  'Nature',
  'Architecture',
  'Your Category Here',  // Add here
];
```

---

## Build Release APK

### Standard Build:
```bash
flutter build apk --release
```

### Split by Architecture (Recommended):
```bash
flutter build apk --split-per-abi
```

**This creates smaller APKs:**
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

**Location:** `build/app/outputs/flutter-apk/`

---

## Troubleshooting

### Issue: API returns 401 Unauthorized
**Solution:** Double-check your API key in `pixabay_service.dart`

### Issue: No wallpapers load
**Solutions:**
1. Verify internet connection
2. Check API key is correct
3. Ensure safe search parameter is present
4. Check Pixabay API status

### Issue: Layout looks wrong on tablet
**Solutions:**
1. Check device width in Flutter DevTools
2. Verify breakpoints in `responsive_utils.dart`
3. Test in both portrait and landscape
4. Clear app cache and rebuild

### Issue: Text too small on tablet
**Solution:** Adjust font size multiplier:
```dart
static double getFontSize(BuildContext context, double baseFontSize) {
  if (isTablet(context)) {
    return baseFontSize * 1.3;  // Increase from 1.2 to 1.3
  }
  return baseFontSize;
}
```

### Issue: Grid columns not changing
**Solution:**
1. Hot restart app (not hot reload)
2. Verify `ResponsiveUtils.getGridColumns()` is called
3. Check MediaQuery is accessible

### Issue: Build fails
**Solution:**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk
```

---

## Testing Matrix

Test on these configurations:

| Device Type | Screen Size | Orientation | Columns | Status |
|-------------|-------------|-------------|---------|--------|
| Small Phone | < 360px | Portrait | 2 | [ ] |
| Phone | 360-599px | Portrait | 2 | [ ] |
| Small Tablet | 600-767px | Portrait | 3 | [ ] |
| Small Tablet | 600-767px | Landscape | 4 | [ ] |
| Large Tablet | 768-1199px | Portrait | 3 | [ ] |
| Large Tablet | 768-1199px | Landscape | 4 | [ ] |

---

## Performance Optimization

### For Mobile:
- 2-column grid is optimal
- Smaller image thumbnails
- Conservative padding

### For Tablets:
- 3-4 column grid
- Higher quality thumbnails
- Enhanced visual details
- Larger touch targets

### Image Loading:
- Uses `cached_network_image`
- Automatic memory management
- Progressive loading
- Error placeholders

---

## Publishing Checklist

### Before Submission:

#### App Store Assets:
- [ ] Phone screenshots (5.5", 6.5")
- [ ] Tablet screenshots (10", 12.9")
- [ ] Both portrait and landscape
- [ ] Feature graphic
- [ ] App icon (512x512)

#### Testing:
- [ ] Tested on 3+ phone sizes
- [ ] Tested on 2+ tablet sizes
- [ ] Tested portrait mode
- [ ] Tested landscape mode
- [ ] Verified safe search works
- [ ] Auto wallpaper tested
- [ ] Permissions granted properly

#### Documentation:
- [ ] Privacy policy created
- [ ] App description written
- [ ] Feature list complete
- [ ] Screenshots taken

#### Technical:
- [ ] Signed APK created
- [ ] ProGuard enabled (optional)
- [ ] Version number updated
- [ ] Tested release build

---

## Support Different Android Versions

### Handled Automatically:
- **Android 5-12**: Legacy storage permissions
- **Android 13+**: New media permissions
- **Android 14**: Latest compatibility

### Permission Flow:
1. App requests permissions at runtime
2. User grants/denies
3. App handles gracefully
4. Clear error messages

---

## API Usage Monitoring

Monitor your Pixabay API usage:
1. Visit: https://pixabay.com/api/docs/
2. View your stats
3. Track requests/hour
4. Free tier: 5000/hour

**Best Practices:**
- Cache images locally
- Don't make unnecessary requests
- Use pagination
- Handle rate limits gracefully

---

## Responsive Design Best Practices

### DO:
✅ Test on multiple screen sizes
✅ Use MediaQuery for responsive values
✅ Provide larger touch targets on tablets
✅ Scale fonts appropriately
✅ Use adaptive layouts

### DON'T:
❌ Hardcode pixel values
❌ Assume device orientation
❌ Ignore landscape mode
❌ Use fixed widths
❌ Forget tablet users

---

## Getting Help

If you encounter issues:

1. **Check this guide** - Most issues are covered here
2. **Review README.md** - Additional documentation
3. **Test on different devices** - Isolate the problem
4. **Check Flutter logs** - Look for error messages
5. **Verify API key** - Most common issue

---

## Final Notes

### This App Is:
✅ Production-ready
✅ Fully responsive
✅ Safe for all audiences
✅ Optimized for phones & tablets
✅ Legal and compliant
✅ Well-documented

### You Get:
📱 Mobile-optimized experience
📲 Tablet-enhanced features
🔒 Safe search built-in
📊 5000 API requests/hour
🎨 Modern, beautiful UI
🔄 Auto-wallpaper feature

---

**Happy Building! Your app is ready for phones and tablets! 🎉**
