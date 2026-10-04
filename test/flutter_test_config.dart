import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:miriago/data/work_cover_backfill.dart';

/// Widget tests have no network; tests that cover the backfill run it
/// explicitly. Tests assert on the Chinese strings, so they run in zh.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WorkCoverBackfill.automaticEnabled = false;
  TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
      .localesTestValue = const [Locale('zh')];
  await testMain();
}
