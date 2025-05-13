import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveUtil {
  // Screen width breakpoints
  static const double maxDesktopWidth = 1920.0;
  static const double standardDesktopWidth = 1024.0;
  static const double tabletBreakpoint = 768.0;
  static const double largeMobileBreakpoint = 420.0;
  static const double mobileBreakpoint = 375.0;
  static const double smallMobileBreakpoint = 320.0;

  static const double maxDesktopScale = 1.2;
  static const double desktopScale = 1.1;
  static const double tabletScale = 1.05;
  static const double largeMobileScale = 0.95;
  static const double mobileScale = 0.9;
  static const double smallMobileScale = 0.85;

  static double scaleSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double pixelDensity = MediaQuery.devicePixelRatioOf(context);
    double scaleFactor;

    if (screenWidth >= maxDesktopWidth) {
      scaleFactor = (screenWidth / maxDesktopWidth) * maxDesktopScale;
    } else if (screenWidth >= standardDesktopWidth) {
      scaleFactor = (screenWidth / maxDesktopWidth) * desktopScale;
    } else if (screenWidth >= tabletBreakpoint) {
      scaleFactor = (screenWidth / standardDesktopWidth) * tabletScale;
    } else if (screenWidth >= largeMobileBreakpoint) {
      scaleFactor = (screenWidth / largeMobileBreakpoint) * largeMobileScale;
    } else if (screenWidth >= mobileBreakpoint) {
      scaleFactor = (screenWidth / mobileBreakpoint) * mobileScale;
    } else {
      scaleFactor = (screenWidth / smallMobileBreakpoint) * smallMobileScale;
    }

    scaleFactor = scaleFactor.clamp(0.7, 1.4);

    return math.max((baseSize * scaleFactor),
        (pixelDensity > 2 ? pixelDensity * 0.75 : 8.0));
  }
}
