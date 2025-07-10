import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveUtil {
  static const double maxDesktopWidth = 1920.0;
  static const double standardDesktopWidth = 1024.0;
  static const double iPadProBreakpoint = 1024.0;
  static const double iPadBreakpoint = 768.0;
  static const double tabletBreakpoint = 768.0;
  static const double largeMobileBreakpoint = 420.0;
  static const double mobileBreakpoint = 375.0;
  static const double smallMobileBreakpoint = 320.0;

  static const double maxDesktopScale = 1.4;
  static const double desktopScale = 1.3;
  static const double iPadProScale = 1.35;
  static const double iPadScale = 1.25;
  static const double largeMobileScale = 1.0;
  static const double mobileScale = 0.95;
  static const double smallMobileScale = 0.9;

  static double scaleSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    double screenWidth = mediaQuery.size.width;
    double screenHeight = mediaQuery.size.height;
    double pixelDensity = mediaQuery.devicePixelRatio;

    double shortestSide = math.min(screenWidth, screenHeight);
    double longestSide = math.max(screenWidth, screenHeight);

    bool isIPad = shortestSide >= 768 && (longestSide / shortestSide) < 1.5;
    bool isIPadPro = shortestSide >= 1024 && isIPad;

    double scaleFactor;

    if (screenWidth >= maxDesktopWidth) {
      scaleFactor = maxDesktopScale;
    } else if (screenWidth >= standardDesktopWidth || isIPadPro) {
      scaleFactor = iPadProScale;
    } else if (screenWidth >= iPadBreakpoint || isIPad) {
      scaleFactor = iPadScale;
    } else if (screenWidth >= largeMobileBreakpoint) {
      scaleFactor = largeMobileScale;
    } else if (screenWidth >= mobileBreakpoint) {
      scaleFactor = mobileScale;
    } else {
      scaleFactor = smallMobileScale;
    }

    if (isIPad && pixelDensity >= 2.0) {
      scaleFactor *= 1.1;
    }

    scaleFactor = scaleFactor.clamp(0.85, 1.8);

    double calculatedSize = baseSize * scaleFactor;

    double minSize;
    if (baseSize >= 24) {
      minSize = isIPad ? 28.0 : 20.0;
    } else if (baseSize >= 16) {
      minSize = isIPad ? 20.0 : 14.0;
    } else {
      minSize = isIPad ? 16.0 : 12.0;
    }

    return math.max(calculatedSize, minSize);
  }

  static double scaleText(BuildContext context, double baseSize) {
    return scaleSize(context, baseSize);
  }

  static double scaleIcon(BuildContext context, double baseSize) {
    return scaleSize(context, baseSize) * 1.1;
  }

  static double scalePadding(BuildContext context, double baseSize) {
    return scaleSize(context, baseSize) * 0.9;
  }

  static double scaleRadius(BuildContext context, double baseSize) {
    return scaleSize(context, baseSize) * 0.95;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final longestSide = math.max(size.width, size.height);
    final aspectRatio = longestSide / shortestSide;

    if (shortestSide >= 1024 && aspectRatio < 1.5) {
      return DeviceType.iPadPro;
    } else if (shortestSide >= 768 && aspectRatio < 1.5) {
      return DeviceType.iPad;
    } else if (shortestSide >= 600) {
      return DeviceType.largePhone;
    } else {
      return DeviceType.phone;
    }
  }

  static bool isIPad(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.iPad || deviceType == DeviceType.iPadPro;
  }
}

enum DeviceType {
  phone,
  largePhone,
  iPad,
  iPadPro,
}

extension ResponsiveExtension on num {
  double rs(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, toDouble());
  double rt(BuildContext context) =>
      ResponsiveUtil.scaleText(context, toDouble());
  double ri(BuildContext context) =>
      ResponsiveUtil.scaleIcon(context, toDouble());
  double rp(BuildContext context) =>
      ResponsiveUtil.scalePadding(context, toDouble());
  double rr(BuildContext context) =>
      ResponsiveUtil.scaleRadius(context, toDouble());
}
