import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miriago/app_theme.dart';
import 'package:miriago/plan/pilgrimage_models.dart';

class _ConstLabel extends StatelessWidget {
  const _ConstLabel();

  @override
  Widget build(BuildContext context) =>
      Text('label', style: TextStyle(color: AppColors.textPrimary));
}

void main() {
  testWidgets('const widgets pick up a system dark-mode switch', (
    tester,
  ) async {
    addTearDown(() {
      applyAppColorsFromSettings(
        const AppSettings(),
        platformBrightness: Brightness.light,
      );
    });
    const settings = AppSettings(themeMode: AppThemeMode.system);
    applyAppColorsFromSettings(settings, platformBrightness: Brightness.light);
    await tester.pumpWidget(const MaterialApp(home: _ConstLabel()));
    final lightColor = tester.widget<Text>(find.text('label')).style!.color;

    applyAppColorsFromSettings(settings, platformBrightness: Brightness.dark);
    await tester.pump();
    await tester.pump();

    final darkColor = tester.widget<Text>(find.text('label')).style!.color;
    expect(darkColor, isNot(lightColor));
  });
}
