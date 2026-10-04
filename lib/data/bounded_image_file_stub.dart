import 'dart:typed_data';
import 'bounded_image_decoder.dart';
import '../l10n/l10n.dart';

String resolveBoundedImagePath(String path) => path;
Future<Uint8List> readBoundedImageFile(
  String path, {
  int maxBytes = maxImageEncodedBytes,
}) async {
  throw ImageBudgetException(
    ImageBudgetFailure.unsupported,
    l10n.boundedImageFileStubUnsupported,
  );
}
