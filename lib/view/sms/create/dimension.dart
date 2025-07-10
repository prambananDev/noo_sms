import 'package:flutter/material.dart';
import 'package:noo_sms/assets/widgets/responsive_util.dart';

class PPDimensions {
  static const double baseLabelSize = 16.0;
  static const double baseTextSize = 16.0;
  static const double baseHeadingSize = 18.0;
  static const double baseIconSize = 24.0;
  static const double basePadding = 16.0;
  static const double baseSpacing = 20.0;
  static const double baseBorderRadius = 16.0;

  double getLabelSize(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, baseLabelSize);

  double getTextSize(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, baseTextSize);

  double getHeadingSize(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, baseHeadingSize);

  double getIconSize(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, baseIconSize);

  double getPadding(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, basePadding);

  double getSpacing(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, baseSpacing);

  double getBorderRadius(BuildContext context) =>
      ResponsiveUtil.scaleSize(context, baseBorderRadius);

  bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveUtil.tabletBreakpoint;

  bool isMobileScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveUtil.mobileBreakpoint;
}
