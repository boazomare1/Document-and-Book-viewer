import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets getScreenPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }

  static double getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    double screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.5;
    } else {
      return baseSpacing * 2;
    }
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getCardWidth(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth - 32; // Full width minus padding
    } else if (isTablet(context)) {
      return (screenWidth - 48) / 2; // Half width minus padding
    } else {
      return (screenWidth - 64) / 3; // Third width minus padding
    }
  }

  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return getScreenWidth(context) * 0.8;
    } else if (isTablet(context)) {
      return 300;
    } else {
      return 400;
    }
  }

  static double getBottomBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return 80;
    } else {
      return 100;
    }
  }

  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static BorderRadius getAdaptiveBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return BorderRadius.circular(12);
    } else {
      return BorderRadius.circular(16);
    }
  }

  static double getAdaptiveIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 24;
    } else if (isTablet(context)) {
      return 28;
    } else {
      return 32;
    }
  }
}

class AdaptiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveLayout.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

class AdaptiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  )
  builder;

  const AdaptiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveLayout.isMobile(context);
    bool isTablet = ResponsiveLayout.isTablet(context);
    bool isDesktop = ResponsiveLayout.isDesktop(context);

    return builder(context, isMobile, isTablet, isDesktop);
  }
}
