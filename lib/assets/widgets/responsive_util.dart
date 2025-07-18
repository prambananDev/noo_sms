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

  static Size? _cachedScreenSize;
  static double? _cachedPixelRatio;
  static BuildContext? _lastContext;

  static Map<String, double> _getScreenData(BuildContext context) {
    try {
      if (_lastContext != context) {
        _cachedScreenSize = null;
        _cachedPixelRatio = null;
        _lastContext = context;
      }

      if (_cachedScreenSize != null && _cachedPixelRatio != null) {
        return {
          'width': _cachedScreenSize!.width,
          'height': _cachedScreenSize!.height,
          'pixelRatio': _cachedPixelRatio!,
        };
      }

      final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);

      if (mediaQuery != null) {
        _cachedScreenSize = mediaQuery.size;
        _cachedPixelRatio = mediaQuery.devicePixelRatio;

        return {
          'width': mediaQuery.size.width,
          'height': mediaQuery.size.height,
          'pixelRatio': mediaQuery.devicePixelRatio,
        };
      }

      return {
        'width': 375.0,
        'height': 812.0,
        'pixelRatio': 2.0,
      };
    } catch (e) {
      return {
        'width': 375.0,
        'height': 812.0,
        'pixelRatio': 2.0,
      };
    }
  }

  static double scaleSize(BuildContext context, double baseSize) {
    try {
      final screenData = _getScreenData(context);
      final double screenWidth = screenData['width']!;
      final double screenHeight = screenData['height']!;
      final double pixelDensity = screenData['pixelRatio']!;

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
    } catch (e) {
      return baseSize;
    }
  }

  static double scaleText(BuildContext context, double baseSize) {
    return scaleSize(context, baseSize);
  }

  static double scaleIcon(BuildContext context, double baseSize) {
    try {
      return scaleSize(context, baseSize) * 1.1;
    } catch (e) {
      return baseSize * 1.1;
    }
  }

  static double scalePadding(BuildContext context, double baseSize) {
    try {
      return scaleSize(context, baseSize) * 0.9;
    } catch (e) {
      return baseSize * 0.9;
    }
  }

  static double scaleRadius(BuildContext context, double baseSize) {
    try {
      return scaleSize(context, baseSize) * 0.95;
    } catch (e) {
      return baseSize * 0.95;
    }
  }

  static DeviceType getDeviceType(BuildContext context) {
    try {
      final screenData = _getScreenData(context);
      final double shortestSide =
          math.min(screenData['width']!, screenData['height']!);
      final double longestSide =
          math.max(screenData['width']!, screenData['height']!);
      final double aspectRatio = longestSide / shortestSide;

      if (shortestSide >= 1024 && aspectRatio < 1.5) {
        return DeviceType.iPadPro;
      } else if (shortestSide >= 768 && aspectRatio < 1.5) {
        return DeviceType.iPad;
      } else if (shortestSide >= 600) {
        return DeviceType.largePhone;
      } else {
        return DeviceType.phone;
      }
    } catch (e) {
      return DeviceType.phone;
    }
  }

  static bool isIPad(BuildContext context) {
    try {
      final deviceType = getDeviceType(context);
      return deviceType == DeviceType.iPad || deviceType == DeviceType.iPadPro;
    } catch (e) {
      return false;
    }
  }

  static void clearCache() {
    _cachedScreenSize = null;
    _cachedPixelRatio = null;
    _lastContext = null;
  }

  static double getScreenHeight(BuildContext context) {
    try {
      final screenData = _getScreenData(context);
      return screenData['height']!;
    } catch (e) {
      return 812.0;
    }
  }
}

enum DeviceType {
  phone,
  largePhone,
  iPad,
  iPadPro,
}

extension ResponsiveExtension on num {
  double rs(BuildContext context) {
    try {
      return ResponsiveUtil.scaleSize(context, toDouble());
    } catch (e) {
      return toDouble();
    }
  }

  double rt(BuildContext context) {
    try {
      return ResponsiveUtil.scaleText(context, toDouble());
    } catch (e) {
      return toDouble();
    }
  }

  double ri(BuildContext context) {
    try {
      return ResponsiveUtil.scaleIcon(context, toDouble());
    } catch (e) {
      return toDouble() * 1.1;
    }
  }

  double rp(BuildContext context) {
    try {
      return ResponsiveUtil.scalePadding(context, toDouble());
    } catch (e) {
      return toDouble() * 0.9;
    }
  }

  double rr(BuildContext context) {
    try {
      return ResponsiveUtil.scaleRadius(context, toDouble());
    } catch (e) {
      return toDouble() * 0.95;
    }
  }
}
