// adaptive_design_template.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:io' show Platform;

// Main Theme Configuration
class AdaptiveTheme {
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  // Material 3 Color Scheme
  static ColorScheme getAndroidColorScheme(BuildContext context,
      {Color? seedColor}) {
    return ColorScheme.fromSeed(
      seedColor: seedColor ?? const Color(0xFF6750A4),
      brightness: Theme.of(context).brightness,
    );
  }

  // Apply theme to the app
  static ThemeData getTheme(BuildContext context, {Color? seedColor}) {
    if (isAndroid) {
      final colorScheme = getAndroidColorScheme(context, seedColor: seedColor);
      return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    } else {
      return Theme.of(context).copyWith(
        platform: TargetPlatform.iOS,
      );
    }
  }
}

// Base Adaptive Screen Widget
class AdaptiveScreen extends StatelessWidget {
  final Widget? androidAppBar;
  final Widget? iosNavigationBar;
  final Widget body;
  final Widget? bottomBar;
  final Color? androidBackgroundColor;
  final bool extendBodyBehindAppBar;
  final Widget? background;

  const AdaptiveScreen({
    Key? key,
    this.androidAppBar,
    this.iosNavigationBar,
    required this.body,
    this.bottomBar,
    this.androidBackgroundColor,
    this.extendBodyBehindAppBar = false,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      return Scaffold(
        backgroundColor:
            androidBackgroundColor ?? Theme.of(context).colorScheme.surface,
        appBar: androidAppBar as PreferredSizeWidget?,
        body: body,
        bottomNavigationBar: bottomBar,
      );
    } else {
      return Scaffold(
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        body: Stack(
          children: [
            if (background != null) background!,
            // Default iOS gradient background
            if (background == null)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5FF),
                      Color(0xFFF3E5F5),
                      Color(0xFFE1F5FE),
                    ],
                  ),
                ),
              ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (iosNavigationBar != null) iosNavigationBar!,
                  Expanded(child: body),
                  if (bottomBar != null) bottomBar!,
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Adaptive App Bar
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  const AdaptiveAppBar({
    Key? key,
    this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.bottom,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        56.0 + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      final colorScheme = Theme.of(context).colorScheme;
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        centerTitle: centerTitle,
        leading: onBack != null
            ? IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: colorScheme.onSurface,
                ),
              )
            : null,
        // title: subtitle != null
        //     ? Column(
        //         crossAxisAlignment: centerTitle
        //             ? CrossAxisAlignment.center
        //             : CrossAxisAlignment.start,
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           if (title != null)
        //             Text(
        //               title!,
        //               style: TextStyle(
        //                 fontSize: 20,
        //                 fontWeight: FontWeight.w600,
        //                 color: colorScheme.onSurface,
        //               ),
        //             ),
        //           if (subtitle != null)
        //             Text(
        //               subtitle!,
        //               style: TextStyle(
        //                 fontSize: 12,
        //                 color: colorScheme.onSurfaceVariant,
        //               ),
        //             ),
        //         ],
        //       )
        //     : title != null
        //         ? Text(
        //             title!,
        //             style: TextStyle(
        //               fontSize: 20,
        //               fontWeight: FontWeight.w600,
        //               color: colorScheme.onSurface,
        //             ),
        //           )
        //         : null,
        actions: actions,
        bottom: bottom,
      );
    } else {
      // iOS Glass Navigation Bar
      return GlassNavigationBar(
        title: title,
        subtitle: subtitle,
        onBack: onBack,
        actions: actions,
        bottom: bottom,
      );
    }
  }
}

// iOS Glass Navigation Bar Component
class GlassNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const GlassNavigationBar({
    Key? key,
    this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        100.0 + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.7),
                  Colors.white.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      if (onBack != null)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: onBack,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.back,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Adaptive Card Widget
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AdaptiveCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      return Card(
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        color: color,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    } else {
      return GlassCard(
        margin: margin,
        padding: padding,
        gradient: gradient,
        onTap: onTap,
        child: child,
      );
    }
  }
}

// iOS Glass Card Component
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient ??
                      LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.5),
                        ],
                      ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Adaptive Text Field
class AdaptiveTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? androidIcon;
  final IconData? iosIcon;
  final TextInputType inputType;
  final int maxLines;
  final String? prefix;
  final bool required;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  const AdaptiveTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.androidIcon,
    this.iosIcon,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.prefix,
    this.required = false,
    this.validator,
    this.obscureText = false,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      final colorScheme = Theme.of(context).colorScheme;
      return TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        obscureText: obscureText,
        validator: validator,
        textCapitalization: inputType == TextInputType.text
            ? TextCapitalization.words
            : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          prefixIcon: androidIcon != null ? Icon(androidIcon) : null,
          prefixText: prefix,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iosIcon != null) ...[
                Icon(
                  iosIcon,
                  size: 20,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label + (required ? ' *' : ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: controller,
            keyboardType: inputType,
            maxLines: maxLines,
            obscureText: obscureText,
            prefix: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      prefix!,
                      style: const TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  )
                : null,
            suffix: suffix,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      );
    }
  }
}

// Adaptive Button
class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final Color? color;

  const AdaptiveButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      final colorScheme = Theme.of(context).colorScheme;

      if (isPrimary) {
        return FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: color != null
              ? FilledButton.styleFrom(backgroundColor: color)
              : null,
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                )
              : icon != null
                  ? Icon(icon)
                  : const SizedBox.shrink(),
          label: Text(isLoading ? 'Loading...' : label),
        );
      } else {
        return OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? colorScheme.outline),
            foregroundColor: color,
          ),
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(label),
        );
      }
    } else {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: isLoading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      color ?? CupertinoColors.activeBlue,
                      color?.withOpacity(0.8) ?? CupertinoColors.systemBlue,
                    ],
                  )
                : null,
            border: !isPrimary
                ? Border.all(
                    color: color ?? CupertinoColors.activeBlue,
                    width: 1.5,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isLoading
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isPrimary
                              ? Colors.white
                              : color ?? CupertinoColors.activeBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: isPrimary
                              ? Colors.white
                              : color ?? CupertinoColors.activeBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }
  }
}

// Adaptive Loading Indicator
class AdaptiveLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const AdaptiveLoadingIndicator({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      return CircularProgressIndicator(
        valueColor:
            color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
      );
    } else {
      return CupertinoActivityIndicator(
        radius: size ?? 20,
        color: color,
      );
    }
  }
}

// Adaptive Section Title
class AdaptiveSectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const AdaptiveSectionTitle({
    Key? key,
    required this.title,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      final colorScheme = Theme.of(context).colorScheme;
      return Padding(
        padding: padding ?? const EdgeInsets.only(left: 4, bottom: 12, top: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
            letterSpacing: 0.1,
          ),
        ),
      );
    } else {
      return Padding(
        padding: padding ?? const EdgeInsets.only(left: 4, bottom: 12, top: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
            letterSpacing: -0.5,
          ),
        ),
      );
    }
  }
}

// Adaptive Bottom Bar
class AdaptiveBottomBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const AdaptiveBottomBar({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: children,
        ),
      );
    } else {
      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              left: padding?.horizontal ?? 16,
              right: padding?.horizontal ?? 16,
              top: padding?.vertical ?? 16,
              bottom: MediaQuery.of(context).padding.bottom +
                  (padding?.vertical ?? 16),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.6),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: children,
            ),
          ),
        ),
      );
    }
  }
}

// Adaptive Icon
class AdaptiveIcon extends StatelessWidget {
  final IconData androidIcon;
  final IconData iosIcon;
  final double? size;
  final Color? color;

  const AdaptiveIcon({
    Key? key,
    required this.androidIcon,
    required this.iosIcon,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      AdaptiveTheme.isAndroid ? androidIcon : iosIcon,
      size: size,
      color: color,
    );
  }
}

// Adaptive Dialog
class AdaptiveDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;

  const AdaptiveDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AdaptiveTheme.isAndroid) {
      return AlertDialog(
        title: title != null ? Text(title!) : null,
        content: content,
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      );
    } else {
      return CupertinoAlertDialog(
        title: title != null ? Text(title!) : null,
        content: content,
        actions: actions ?? [],
      );
    }
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
  }) {
    if (AdaptiveTheme.isAndroid) {
      return showDialog<T>(
        context: context,
        builder: (context) => AdaptiveDialog(
          title: title,
          content: content,
          actions: actions,
        ),
      );
    } else {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => AdaptiveDialog(
          title: title,
          content: content,
          actions: actions,
        ),
      );
    }
  }
}

void adaptiveHaptic() {
  if (AdaptiveTheme.isIOS) {
    HapticFeedback.lightImpact();
  } else {
    HapticFeedback.selectionClick();
  }
}
