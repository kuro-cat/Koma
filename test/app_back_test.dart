import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miriago/data/sample_pilgrimage_repository.dart';
import 'package:miriago/main.dart';

void main() {
  testWidgets('Back returns to Plan, and closes an open menu first', (
    tester,
  ) async {
    await tester.pumpWidget(
      MiriaGoApp(repository: SamplePilgrimageRepository()),
    );
    await tester.pumpAndSettle();
    NavigationBar bar() => tester.widget(find.byType(NavigationBar));

    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();
    expect(bar().selectedIndex, 2);

    // With the status menu open, Back only closes the menu.
    await tester.tap(find.byKey(const ValueKey('records-status-filter')));
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsNothing);
    expect(bar().selectedIndex, 2);

    // The next Back goes to Plan instead of leaving the app.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(bar().selectedIndex, 0);
  });
}
