import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_theme.dart';

class AppFontStyle {
  static TextStyle smallText(
      {double? size,
        Color? color,
        FontWeight? weight,
        String? fontFamily,
        FontStyle? fontStyle}) {
    return TextStyle(
      fontSize: size ?? AppFontSize.quarter.value,
      fontWeight: weight ?? AppFontWeight.normal.value,
      color: color ?? AppTheme.black,
      fontStyle: fontStyle ?? FontStyle.normal,
      fontFamily: fontFamily ?? "Roboto",
    );
  }

  static TextStyle normalText(
      {double? size, Color? color, FontWeight? weight, String? fontFamily}) {
    return TextStyle(
      fontSize: size ?? AppFontSize.normal.value,
      fontWeight: weight ?? AppFontWeight.normal.value,
      color: color ?? AppTheme.black,
      fontFamily: fontFamily ?? "Roboto",
    );
  }
  static TextStyle mediumText(
      {double? size, Color? color, FontWeight? weight, String? fontFamily}) {
    return TextStyle(
      fontSize: size ?? AppFontSize.medium.value,
      fontWeight: weight ?? AppFontWeight.normal.value,
      color: color ?? AppTheme.black,
      fontFamily: fontFamily ?? "Roboto",
    );
  }

  static TextStyle largeText(
      {double? size, Color? color, FontWeight? weight, String? fontFamily}) {
    return TextStyle(
      fontSize: size ?? AppFontSize.large.value,
      fontWeight: weight ?? AppFontWeight.semibold.value,
      color: color ?? AppTheme.black,
      decoration: TextDecoration.none,
      fontFamily: fontFamily ?? "Roboto",
    );
  }

  static TextStyle veryLargeText(
      {double? size, Color? color, FontWeight? weight, String? fontFamily}) {
    return TextStyle(
      fontSize: size ?? AppFontSize.veryLarge.value,
      fontWeight: weight ?? AppFontWeight.medium.value,
      color: color ?? AppTheme.black,
      decoration: TextDecoration.none,
      fontFamily: fontFamily ?? "Roboto",
    );
  }

  static TextStyle body({double? size, Color? color, FontWeight? weight}) {
    return TextStyle(
      fontSize: size ?? AppFontSize.small.value,
      fontWeight: weight ?? AppFontWeight.normal.value,
      color: color ?? AppTheme.black,
    );
  }

  // Method to get adaptive font size based on screen size
  static double getAdaptiveFontSize(double baseSize) {
    double screenWidth = ScreenUtil().screenWidth;
    if (screenWidth <= 320) {  // Small screens (e.g. iPhone SE)
      return baseSize * 0.85;
    } else if (screenWidth <= 375) {  // Medium screens (e.g. iPhone 11)
      return baseSize;
    } else {  // Larger screens (e.g. iPhone 12 and up)
      return baseSize * 1.15;
    }
  }
}

enum AppFontSize {
  mini,
  quarter,
  verySmall,
  small,
  small100,
  small200,
  normal,
  medium,
  medium100,
  large,
  large100,
  large200,
  veryLarge,
  heading,
  appTitle,
  appLargeTitle,
  appLargeTitle100,
  appMediumTitle,
}

extension FontSizeHelper on AppFontSize {
  double get value {
    switch (this) {
      case AppFontSize.mini:
        return AppFontStyle.getAdaptiveFontSize(10.sp);
      case AppFontSize.quarter:
        return AppFontStyle.getAdaptiveFontSize(11.sp);
      case AppFontSize.verySmall:
        return AppFontStyle.getAdaptiveFontSize(12.sp);
      case AppFontSize.small100:
        return AppFontStyle.getAdaptiveFontSize(13.sp);
      case AppFontSize.small200:
        return AppFontStyle.getAdaptiveFontSize(13.1.sp);
      case AppFontSize.small:
        return AppFontStyle.getAdaptiveFontSize(14.sp);
      case AppFontSize.normal:
        return AppFontStyle.getAdaptiveFontSize(15.sp);
      case AppFontSize.medium:
        return AppFontStyle.getAdaptiveFontSize(16.sp);
      case AppFontSize.medium100:
        return AppFontStyle.getAdaptiveFontSize(17.sp);
      case AppFontSize.large:
        return AppFontStyle.getAdaptiveFontSize(18.sp);
      case AppFontSize.large100:
        return AppFontStyle.getAdaptiveFontSize(19.sp);
      case AppFontSize.large200:
        return AppFontStyle.getAdaptiveFontSize(21.sp);
      case AppFontSize.veryLarge:
        return AppFontStyle.getAdaptiveFontSize(24.sp);
      case AppFontSize.appTitle:
        return AppFontStyle.getAdaptiveFontSize(36.sp);
      case AppFontSize.appLargeTitle:
        return AppFontStyle.getAdaptiveFontSize(40.sp);
      case AppFontSize.appMediumTitle:
        return AppFontStyle.getAdaptiveFontSize(50.sp);
      case AppFontSize.appLargeTitle100:
        return AppFontStyle.getAdaptiveFontSize(100.sp);
      default:
        return AppFontStyle.getAdaptiveFontSize(15.sp);
    }
  }
}

enum AppFontWeight {
  bold,
  semibold,
  normal,
  light,
  medium,
  large, regular,
}

extension FontWeightHelper on AppFontWeight {
  FontWeight get value {
    switch (this) {
      case AppFontWeight.bold:
        return FontWeight.w800;
      case AppFontWeight.semibold:
        return FontWeight.w600;
      case AppFontWeight.normal:
        return FontWeight.w400;
      case AppFontWeight.light:
        return FontWeight.w300;
      case AppFontWeight.large:
        return FontWeight.w800;
      case AppFontWeight.medium:
        return FontWeight.w500;
      default:
        return FontWeight.w400;
    }
  }
}
