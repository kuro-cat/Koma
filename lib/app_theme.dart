import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'widgets/keyboard_dismiss_on_tap.dart' show dismissKeyboardOnTapOutside;

import 'plan/pilgrimage_models.dart';

/// Tsumiki's Cool Earth rule for custom colours: hues from ochre through
/// greens to sea blue, at moderate saturation; never pink or purple.
const coolEarthMinHue = 35.0;
const coolEarthMaxHue = 205.0;
const coolEarthMaxSaturation = 0.6;

/// [color] moved into the Cool Earth range, so a stored or typed colour
/// outside it (pink, purple, neon) shows as its nearest allowed one.
Color coolEarth(Color color) {
  final hsv = HSVColor.fromColor(color.withValues(alpha: 1));
  final hue = hsv.hue;
  final clampedHue = hue >= coolEarthMinHue && hue <= coolEarthMaxHue
      ? hue
      // Blues and violets settle on sea blue; magentas and reds on ochre.
      : hue > coolEarthMaxHue && hue < 290
      ? coolEarthMaxHue
      : coolEarthMinHue;
  return hsv
      .withHue(clampedHue)
      .withSaturation(math.min(hsv.saturation, coolEarthMaxSaturation))
      .toColor();
}

/// Koma's palette: Tsumiki's Fjord sea (light) and Night sea (dark) grounds,
/// ink and rules, with one accent chosen in Settings from Tsumiki's colours.
class AppColors {
  const AppColors._();

  static AppThemePalette palette = AppThemePalette.fjord;
  static int customAccentValue = 0xFF2F6F80;
  static Brightness brightness = Brightness.light;

  static bool get isDark => brightness == Brightness.dark;

  // Paper is the page ground, raise the ground of keys, fields and panels,
  // paper-2 the pressed and quiet ground.
  static const _lightPaper = Color(0xFFF2F5F5);
  static const _darkPaper = Color(0xFF0F1A1C);
  static const _lightRaise = Color(0xFFFBFCFC);
  static const _darkRaise = Color(0xFF1C2D30);
  static const _lightPaper2 = Color(0xFFE2E9EA);
  static const _darkPaper2 = Color(0xFF172628);
  static const _lightInk = Color(0xFF152022);
  static const _darkInk = Color(0xFFE4ECEC);
  static const _lightInk2 = Color(0xFF475759);
  static const _darkInk2 = Color(0xFFA3B3B4);
  static const _lightInk3 = Color(0xFF5D6D6F);
  static const _darkInk3 = Color(0xFF8C9D9E);
  static const _lightRule = Color(0xFFCBD5D7);
  static const _darkRule = Color(0xFF2C4043);
  static const _lightRule2 = Color(0xFFDDE5E6);
  static const _darkRule2 = Color(0xFF223436);
  static const _lightRed = Color(0xFFC24A3C);
  static const _darkRed = Color(0xFFE07A6E);
  static const _lightOchre = Color(0xFF855F0E);
  static const _darkOchre = Color(0xFFD8AD4C);

  static Color get background => isDark ? _darkPaper : _lightPaper;
  static Color get surface => isDark ? _darkRaise : _lightRaise;
  static Color get surfaceMuted => isDark ? _darkPaper2 : _lightPaper2;
  static Color get textPrimary => isDark ? _darkInk : _lightInk;
  static Color get textSecondary => isDark ? _darkInk2 : _lightInk2;

  /// Placeholders, disabled text and drag grips.
  static Color get textTertiary => isDark ? _darkInk3 : _lightInk3;

  /// Field edges and the sides of lists.
  static Color get border => isDark ? _darkRule : _lightRule;

  /// Row dividers and column seams.
  static Color get divider => isDark ? _darkRule2 : _lightRule2;

  /// Structural lines: frames of keys and panels, rules over lists.
  static Color get ink => textPrimary;
  static Color get warning => isDark ? _darkOchre : _lightOchre;
  static Color get error => isDark ? _darkRed : _lightRed;

  /// The swatch shown for [palette] in Settings, in the current theme.
  static Color swatch(AppThemePalette palette, {int? customValue}) {
    if (palette == AppThemePalette.custom) {
      return coolEarth(Color(customValue ?? customAccentValue));
    }
    final (light, dark) = _accents[palette]!;
    return isDark ? dark : light;
  }

  static const _accents = {
    AppThemePalette.fjord: (Color(0xFF2F6F80), Color(0xFF6FB3C4)),
    AppThemePalette.spruce: (Color(0xFF2F6B5C), Color(0xFF7DBFAE)),
    AppThemePalette.moss: (Color(0xFF4D6A2C), Color(0xFF9FC27F)),
    AppThemePalette.lake: (Color(0xFF3A5F8F), Color(0xFF8FB3DE)),
    AppThemePalette.ink: (_lightInk, _darkInk),
  };

  /// The one colour that acts: primary keys, text actions, selection,
  /// progress. Every palette passes 4.5:1 as text on paper and raise.
  static Color get accent {
    if (palette == AppThemePalette.custom) {
      final custom = coolEarth(Color(customAccentValue));
      return isDark ? _readableAccent(custom) : _deepenForText(custom);
    }
    return swatch(palette);
  }

  /// The pressed state of [accent].
  static Color get accentDark {
    final hsl = HSLColor.fromColor(accent);
    final lightness = isDark
        ? (hsl.lightness + 0.08).clamp(0.0, 1.0)
        : (hsl.lightness * 0.8).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Text and icons on an [accent] fill.
  static Color get onAccent => foregroundOn(accent);

  /// The accent's quiet ground: checked chips, the current row, washes.
  static Color get accentWash =>
      Color.alphaBlend(accent.withValues(alpha: isDark ? 0.18 : 0.11), surface);

  /// Foregrounds on neutral or lightly tinted surfaces, not brand fills.
  static Color get accentForeground => _readableAccent(accent);
  static Color get accentStrongForeground => _readableAccent(accentDark);

  static Color _readableAccent(Color color) {
    final surfaces = [background, surface, surfaceMuted, accentWashFor(color)];
    final opaque = color.withValues(alpha: 1);
    final target = isDark ? Colors.white : Colors.black;
    for (var step = 0; step <= 20; step++) {
      final candidate = Color.lerp(opaque, target, step / 20)!;
      if (surfaces.every((surface) => _contrast(candidate, surface) >= 4.5)) {
        return candidate;
      }
    }
    return target;
  }

  static Color accentWashFor(Color color) =>
      Color.alphaBlend(color.withValues(alpha: isDark ? 0.18 : 0.11), surface);

  /// A custom colour darkened until it reads as text on the light ground.
  static Color _deepenForText(Color color) {
    final opaque = color.withValues(alpha: 1);
    for (var step = 0; step <= 20; step++) {
      final candidate = Color.lerp(opaque, _lightInk, step / 20)!;
      if (_contrast(candidate, _lightPaper) >= 4.5) return candidate;
    }
    return _lightInk;
  }

  static double _contrast(Color a, Color b) {
    final values = [a.computeLuminance(), b.computeLuminance()]..sort();
    return (values.last + 0.05) / (values.first + 0.05);
  }

  static Color foregroundOn(Color fill) {
    final opaque = Color.alphaBlend(fill, surface);
    return _contrast(Colors.white, opaque) >= _contrast(_darkPaper, opaque)
        ? Colors.white
        : _darkPaper;
  }

  static const cameraDarkSurface = Color(0xFF0F1A1C);
  static const cameraDarkOverlay = Color(0xFF1C2D30);
}

/// Settings chrome uses a 1px *gap* over a filled [AppColors.border] parent
/// instead of a 1px stroke. Flutter web rasterizes horizontal (and rotated)
/// hairlines as near-white lines.
class AppHairline extends StatelessWidget {
  const AppHairline({super.key, this.color, this.axis = Axis.horizontal});

  final Color? color;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? AppColors.border;
    if (axis == Axis.vertical) {
      return ColoredBox(color: lineColor, child: const SizedBox(width: 1));
    }
    return ColoredBox(
      color: lineColor,
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

class AppTheme {
  const AppTheme._();

  static const double appBarHeight = kToolbarHeight;

  static ThemeData light({
    AppThemePalette palette = AppThemePalette.fjord,
    int customAccentValue = 0xFF2F6F80,
  }) {
    return of(
      brightness: Brightness.light,
      palette: palette,
      customAccentValue: customAccentValue,
    );
  }

  static ThemeData dark({
    AppThemePalette palette = AppThemePalette.fjord,
    int customAccentValue = 0xFF2F6F80,
  }) {
    return of(
      brightness: Brightness.dark,
      palette: palette,
      customAccentValue: customAccentValue,
    );
  }

  static ThemeData of({
    required Brightness brightness,
    AppThemePalette palette = AppThemePalette.fjord,
    int customAccentValue = 0xFF2F6F80,
  }) {
    AppColors.brightness = brightness;
    AppColors.palette = palette;
    AppColors.customAccentValue = customAccentValue;
    final ink = AppColors.ink;
    final paper = AppColors.background;
    final raise = AppColors.surface;
    final accent = AppColors.accent;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.accentWash,
      onPrimaryContainer: ink,
      secondary: accent,
      onSecondary: AppColors.onAccent,
      secondaryContainer: AppColors.accentWash,
      onSecondaryContainer: ink,
      error: AppColors.error,
      onError: AppColors.foregroundOn(AppColors.error),
      surface: raise,
      onSurface: ink,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      surfaceTint: Colors.transparent,
      shadow: Colors.transparent,
      surfaceContainerLowest: paper,
      surfaceContainerLow: raise,
      surfaceContainer: raise,
      surfaceContainerHigh: raise,
      surfaceContainerHighest: AppColors.surfaceMuted,
      inverseSurface: ink,
      onInverseSurface: paper,
      inversePrimary: AppColors.accentDark,
    );

    final textTheme = _textTheme(ink);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      fontFamily: AppType.family,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      shadowColor: Colors.transparent,
    );

    // Keys: square, framed in ink on raise, inverting to ink when pressed.
    final keyBackground = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) return AppColors.surfaceMuted;
      if (states.contains(WidgetState.pressed)) return ink;
      return raise;
    });
    final keyForeground = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) return AppColors.textTertiary;
      if (states.contains(WidgetState.pressed)) return paper;
      return ink;
    });
    final keySide = WidgetStateProperty.resolveWith<BorderSide?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return BorderSide(color: AppColors.border);
      }
      return BorderSide(color: ink);
    });
    final primaryBackground = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) return AppColors.surfaceMuted;
      if (states.contains(WidgetState.pressed)) return ink;
      return accent;
    });
    final primaryForeground = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) return AppColors.textTertiary;
      if (states.contains(WidgetState.pressed)) return paper;
      return AppColors.onAccent;
    });
    const square = WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(),
    );
    const noOverlay = WidgetStatePropertyAll<Color?>(Colors.transparent);
    final controlText = WidgetStatePropertyAll<TextStyle?>(
      textTheme.labelLarge,
    );
    const keySize = WidgetStatePropertyAll<Size?>(Size(48, 48));
    const keyPadding = WidgetStatePropertyAll<EdgeInsetsGeometry?>(
      EdgeInsets.symmetric(horizontal: 16),
    );
    const flat = WidgetStatePropertyAll<double?>(0);

    final framed = BorderSide(color: ink);
    final quietEdge = BorderSide(color: AppColors.border);

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: AppTheme.appBarHeight,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: ink)),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: IconThemeData(color: ink),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: ink,
        shape: const RoundedRectangleBorder(),
      ),
      dividerColor: AppColors.divider,
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: primaryBackground,
          foregroundColor: primaryForeground,
          overlayColor: noOverlay,
          shape: square,
          minimumSize: keySize,
          padding: keyPadding,
          textStyle: controlText,
          elevation: flat,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: keyBackground,
          foregroundColor: keyForeground,
          side: keySide,
          overlayColor: noOverlay,
          shape: square,
          minimumSize: keySize,
          padding: keyPadding,
          textStyle: controlText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: keyBackground,
          foregroundColor: keyForeground,
          side: keySide,
          overlayColor: noOverlay,
          shape: square,
          minimumSize: keySize,
          padding: keyPadding,
          textStyle: controlText,
          elevation: flat,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textTertiary;
            }
            return AppColors.accentForeground;
          }),
          overlayColor: WidgetStatePropertyAll(AppColors.accentWash),
          shape: square,
          minimumSize: keySize,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 10),
          ),
          textStyle: controlText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textTertiary;
            }
            return ink;
          }),
          overlayColor: WidgetStatePropertyAll(AppColors.surfaceMuted),
          shape: square,
          minimumSize: keySize,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? ink : raise,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? paper
                : AppColors.textSecondary,
          ),
          side: WidgetStatePropertyAll(framed),
          overlayColor: noOverlay,
          shape: square,
          textStyle: controlText,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: raise,
        selectedColor: AppColors.accentWash,
        disabledColor: AppColors.surfaceMuted,
        side: WidgetStateBorderSide.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? framed : quietEdge,
        ),
        shape: const RoundedRectangleBorder(),
        labelStyle: textTheme.labelLarge,
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raise,
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: quietEdge,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: quietEdge,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withValues(alpha: 0.28),
        selectionHandleColor: accent,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(),
        side: BorderSide(color: ink, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(AppColors.onAccent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : ink,
        ),
      ),
      // A white knob on the accent track in both modes; the default uses the
      // on-accent colour, which is near-black on the dark-mode accent.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : ink,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent
              : AppColors.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? accent : AppColors.border,
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        trackHeight: 4,
        activeTrackColor: accent,
        inactiveTrackColor: AppColors.surfaceMuted,
        thumbColor: ink,
        overlayColor: accent.withValues(alpha: 0.12),
        thumbShape: const _SquareThumbShape(),
        trackShape: const RectangularSliderTrackShape(),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
        valueIndicatorColor: ink,
        valueIndicatorTextStyle: textTheme.labelLarge?.copyWith(color: paper),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: AppColors.surfaceMuted,
        circularTrackColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: ink),
        textStyle: textTheme.labelMedium?.copyWith(color: paper),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: raise,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(side: framed),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: raise,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: Border(top: framed),
        dragHandleColor: AppColors.border,
        dragHandleSize: const Size(36, 4),
      ),
      cardTheme: CardThemeData(
        color: raise,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(side: quietEdge),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: raise,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        menuPadding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(side: framed),
        textStyle: textTheme.labelLarge,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(raise),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: flat,
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          side: WidgetStatePropertyAll(framed),
          shape: square,
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(ink),
          overlayColor: WidgetStatePropertyAll(AppColors.accentWash),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14),
          ),
          textStyle: controlText,
          shape: square,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: raise,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // The current tab carries the chosen theme colour.
        indicatorColor: AppColors.accent,
        indicatorShape: const RoundedRectangleBorder(),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.onAccent
                : AppColors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? textTheme.labelMedium?.copyWith(
                  color: AppColors.accentForeground,
                  fontWeight: FontWeight.w600,
                )
              : textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: ink, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        dividerColor: ink,
        dividerHeight: 1,
        overlayColor: noOverlay,
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: Radius.zero,
        thumbColor: WidgetStatePropertyAll(AppColors.textTertiary),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        space: 1,
        thickness: 1,
        indent: 0,
        endIndent: 0,
      ),
    );
  }

  /// Tsumiki's type scale on Material's roles, with tabular numbers.
  static TextTheme _textTheme(Color ink) {
    const tabular = [FontFeature.tabularFigures()];
    TextStyle style(double size, FontWeight weight, {double tracking = 0}) =>
        TextStyle(
          fontFamily: AppType.family,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: tracking,
          color: ink,
          fontFeatures: tabular,
        );
    return TextTheme(
      displayLarge: style(44, FontWeight.w600, tracking: -1.3),
      displayMedium: style(38, FontWeight.w600, tracking: -1.1),
      displaySmall: style(32, FontWeight.w600, tracking: -0.8),
      headlineLarge: style(30, FontWeight.w600, tracking: -0.6),
      headlineMedium: style(26, FontWeight.w600, tracking: -0.5),
      headlineSmall: style(22, FontWeight.w600, tracking: -0.3),
      titleLarge: style(20, FontWeight.w600, tracking: -0.2),
      titleMedium: style(18, FontWeight.w600, tracking: -0.2),
      titleSmall: style(15, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400),
      bodyMedium: style(15, FontWeight.w400),
      bodySmall: style(13, FontWeight.w500),
      labelLarge: style(14, FontWeight.w500),
      labelMedium: style(13, FontWeight.w500),
      labelSmall: style(12, FontWeight.w500),
    );
  }
}

/// Faces and the one special style the theme's roles do not cover.
class AppType {
  const AppType._();

  static const family = 'Archivo';
  static const condensed = 'ArchivoCondensed';

  /// Condensed tracked caps: names of sections, readouts and columns only,
  /// always in full ink. Uppercase the text with [caps].
  static TextStyle get capsStyle => TextStyle(
    fontFamily: condensed,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.04,
    color: AppColors.ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static String caps(String text) => text.toUpperCase();
}

/// The name of a section in condensed caps, as in Tsumiki's schedule.
class CapsLabel extends StatelessWidget {
  const CapsLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppType.caps(text),
      style: AppType.capsStyle.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Tsumiki's slider thumb: a square of ink.
class _SquareThumbShape extends SliderComponentShape {
  const _SquareThumbShape();

  static const _size = 16.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(_size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    context.canvas.drawRect(
      Rect.fromCenter(center: center, width: _size, height: _size),
      Paint()..color = sliderTheme.thumbColor ?? AppColors.ink,
    );
  }
}

/// The app's font-size preference applied on top of [base], the system text
/// size (Dynamic Type, Android font scale), so accessibility sizes keep
/// working. Growth from the app preference stops at twice the font size;
/// a larger system size is always honoured.
TextScaler appTextScaler(
  double fontScale, {
  TextScaler base = TextScaler.noScaling,
}) {
  final clampedScale = fontScale.clamp(0.7, 1.4);
  final easedScale = (1 + (clampedScale - 1) * 0.58).clamp(0.7, 1.6);
  return AppTextScaler(base: base, factor: easedScale.toDouble());
}

/// [appTextScaler] on top of the system text size. Always starts from the
/// platform value rather than the inherited one, so nested scaled subtrees
/// (routes, overlays) never scale twice.
TextScaler appTextScalerFor(BuildContext context, double fontScale) {
  return appTextScaler(
    fontScale,
    base: MediaQueryData.fromView(View.of(context)).textScaler,
  );
}

class AppTextScaler extends TextScaler {
  const AppTextScaler({required this.base, required this.factor});

  static const maxAppGrowth = 2.0;

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) {
    final system = base.scale(fontSize);
    final scaled = system * factor;
    if (factor <= 1) {
      return scaled;
    }
    final limit = math.max(system, fontSize * maxAppGrowth);
    return math.min(scaled, limit);
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}

double appUiScaler(double uiScale) {
  final clampedScale = uiScale.clamp(0.8, 1.0);
  return 1 + (clampedScale - 1) * 0.72;
}

Brightness resolvedAppBrightness(
  AppSettings settings, {
  required Brightness platformBrightness,
}) {
  return switch (settings.themeMode) {
    AppThemeMode.light => Brightness.light,
    AppThemeMode.dark => Brightness.dark,
    AppThemeMode.system => platformBrightness,
  };
}

ThemeData appThemeFor(
  AppSettings settings, {
  required Brightness platformBrightness,
}) {
  return AppTheme.of(
    brightness: resolvedAppBrightness(
      settings,
      platformBrightness: platformBrightness,
    ),
    palette: settings.themePalette,
    customAccentValue: settings.customThemeColorValue,
  );
}

void applyAppColorsFromSettings(
  AppSettings settings, {
  required Brightness platformBrightness,
}) {
  final brightness = resolvedAppBrightness(
    settings,
    platformBrightness: platformBrightness,
  );
  final changed =
      AppColors.brightness != brightness ||
      AppColors.palette != settings.themePalette ||
      AppColors.customAccentValue != settings.customThemeColorValue;
  AppColors.brightness = brightness;
  AppColors.palette = settings.themePalette;
  AppColors.customAccentValue = settings.customThemeColorValue;
  if (changed) {
    _scheduleColorRefresh();
  }
}

var _colorRefreshScheduled = false;

/// [AppColors] are globals, so widgets that don't depend on the Theme (const
/// ones in particular) keep the old colors when they change, e.g. when the
/// system switches to dark mode with the app open. Rebuild every element
/// once after a change; their state is kept.
void _scheduleColorRefresh() {
  if (_colorRefreshScheduled) return;
  _colorRefreshScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _colorRefreshScheduled = false;
    void markForRebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markForRebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(markForRebuild);
  });
}

Brightness currentPlatformBrightness() {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
}

class AppUiScaleView extends StatelessWidget {
  const AppUiScaleView({required this.scale, required this.child, super.key});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effectiveScale = appUiScaler(scale);
    if ((effectiveScale - 1).abs() < 0.001) {
      return child;
    }

    final size = MediaQuery.sizeOf(context);
    final scaledWidth = size.width / effectiveScale;
    final scaledHeight = size.height / effectiveScale;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxWidth: scaledWidth,
        maxHeight: scaledHeight,
        child: Transform.scale(
          scale: effectiveScale,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: scaledWidth,
            height: scaledHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppButtonStyles {
  const AppButtonStyles._();

  static const compactHeight = 36.0;
  static const compactSize = Size.square(compactHeight);

  static ButtonStyle compactOutlinedButton() {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(44, compactHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  static ButtonStyle compactFilledButton() {
    return FilledButton.styleFrom(
      minimumSize: const Size(44, compactHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  static ButtonStyle compactOutlinedIconButton() {
    return IconButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      disabledForegroundColor: AppColors.textSecondary,
      fixedSize: compactSize,
      minimumSize: compactSize,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.standard,
      side: BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }
}
