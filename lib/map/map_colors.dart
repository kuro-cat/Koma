import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Map overlays need readable colors over both tiles and floating surfaces.
class MapColors {
  const MapColors._();

  /// Raise in dark mode (`raise-dark` in DESIGN.md). Accents are checked
  /// against it even when the app itself is light.
  static const _darkRaise = Color(0xFF1C2D30);

  static Color get surface => AppColors.surface;
  static Color get surfaceMuted => AppColors.surfaceMuted;

  /// Marker edges sit on map tiles, so dark mode uses ink-3, which reads on
  /// dark tiles where the rule colour would vanish.
  static Color get border =>
      AppColors.isDark ? AppColors.textTertiary : AppColors.border;
  static Color get accent => readable(AppColors.accent);
  static Color get accentDark =>
      AppColors.isDark ? accent : AppColors.accentDark;
  static Color get onAccent =>
      AppColors.isDark ? AppColors.background : AppColors.onAccent;

  static Color readable(Color color, {bool? dark}) {
    if (!(dark ?? AppColors.isDark)) return color;
    var result = color.withValues(alpha: 1);
    // Preserve hue while making even custom near-black accents distinguishable.
    for (var step = 0; step < 20; step++) {
      if ((result.computeLuminance() + 0.05) /
              (_darkRaise.computeLuminance() + 0.05) >=
          4.5) {
        break;
      }
      result = Color.lerp(result, Colors.white, 0.12)!;
    }
    return result;
  }
}
