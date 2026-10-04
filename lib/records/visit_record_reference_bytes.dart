import 'dart:typed_data';

import '../data/bounded_image_decoder.dart';
import '../plan/pilgrimage_models.dart';
import '../widgets/bounded_image.dart';

/// Reads the record's reference image: its local copy, then the point's local
/// copy, then the remote URL. Returns null when the record has no reference.
Future<Uint8List?> loadVisitRecordReferenceBytes(
  PilgrimageVisitRecord record, {
  String? fallbackReferenceImagePath,
  String? fallbackReferenceImageUrl,
}) async {
  for (final path in [
    record.referenceImagePath,
    fallbackReferenceImagePath,
  ].whereType<String>()) {
    try {
      return await readBoundedImageSource(path);
    } on ImageBudgetException {
      rethrow;
    } catch (_) {
      // Missing local references may still have their original remote source.
    }
  }

  final url = record.referenceImageUrl ?? fallbackReferenceImageUrl;
  if (url == null || url.isEmpty) {
    return null;
  }

  return readBoundedImageSource(url);
}
