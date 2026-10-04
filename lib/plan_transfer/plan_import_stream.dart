import 'dart:typed_data';

import '../l10n/l10n.dart';
import 'plan_import_package.dart';

Future<Uint8List> readBoundedPlanImportStream(
  Stream<List<int>> stream, {
  PlanImportLimits limits = const PlanImportLimits(),
}) async {
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    final size = bytes.length + chunk.length;
    if (size > limits.maxCompressedBytes) {
      throw PlanImportLimitException(
        l10n.planImportPackageResourceArchiveBytes,
        size,
        limits.maxCompressedBytes,
      );
    }
    bytes.add(chunk);
  }
  return bytes.takeBytes();
}
