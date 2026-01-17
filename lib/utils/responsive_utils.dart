import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return 6; // Desktop/Large tablets landscape
    } else if (width >= 900) {
      return 4; // Tablets landscape
    } else if (width >= 600) {
      return 3; // Tablets portrait
    } else {
      return 2; // Mobile
    }
  }

  static double getGridAspectRatio(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) {
      return 0.65; // Slightly different ratio for tablets
    }
    return 0.6; // Mobile ratio
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  static double getCardElevation(BuildContext context) {
    return isTablet(context) || isDesktop(context) ? 6.0 : 4.0;
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isTablet(context)) {
      return baseFontSize * 1.2;
    } else if (isDesktop(context)) {
      return baseFontSize * 1.4;
    }
    return baseFontSize;
  }

  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isTablet(context)) {
      return baseIconSize * 1.2;
    } else if (isDesktop(context)) {
      return baseIconSize * 1.4;
    }
    return baseIconSize;
  }

  static BoxConstraints getMaxWidthConstraint(BuildContext context) {
    // For very wide screens, limit content width for better readability
    if (isDesktop(context)) {
      return const BoxConstraints(maxWidth: 1600);
    }
    return const BoxConstraints();
  }

  static double getButtonHeight(BuildContext context) {
    if (isTablet(context)) {
      return 56.0;
    }
    return 50.0;
  }

  static double getCategoryChipHeight(BuildContext context) {
    if (isTablet(context)) {
      return 44.0;
    }
    return 40.0;
  }

  static double getAppBarHeight(BuildContext context) {
    if (isTablet(context)) {
      return 64.0;
    }
    return 56.0;
  }
}
