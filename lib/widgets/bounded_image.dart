import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../data/anitabi_image_fetcher.dart';
import '../data/bounded_image_decoder.dart';
import '../data/bounded_image_file_stub.dart'
    if (dart.library.io) '../data/bounded_image_file_io.dart';
import '../desktop/desktop_asset_image.dart';
import '../desktop/tauri_bridge.dart';
import '../plan/pilgrimage_models.dart';
import 'image_load_limiter.dart';

final _previewReads = ImageLoadLimiter(2);

Future<Uint8List> readBoundedImageSource(
  String path, {
  AnitabiImageSource source = AnitabiImageSource.auto,
  int maxBytes = maxImageEncodedBytes,
}) async {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    final bytes = await fetchAnitabiImageBytes(
      path,
      source: source,
      maxBytes: maxBytes,
    );
    if (bytes == null) throw StateError(l10n.boundedImageUnavailable);
    return bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  }
  if (path.startsWith('data:')) {
    final comma = path.indexOf(',');
    if (comma < 0 || !path.substring(0, comma).endsWith(';base64')) {
      throw ImageBudgetException(
        ImageBudgetFailure.unsupported,
        l10n.boundedImageBadSource,
      );
    }
    checkImageEncodedLength(
      ((path.length - comma - 1) ~/ 4) * 3 - 2,
      maxBytes: maxBytes,
    );
    final bytes = base64Decode(path.substring(comma + 1));
    checkImageEncodedLength(bytes.length, maxBytes: maxBytes);
    return bytes;
  }
  if (kIsWeb && isDesktopAssetPath(path)) {
    final asset = await readDesktopAsset(path: path, maxBytes: maxBytes);
    checkImageEncodedLength(
      (asset.dataBase64.length ~/ 4) * 3 - 2,
      maxBytes: maxBytes,
    );
    final bytes = base64Decode(asset.dataBase64);
    checkImageEncodedLength(bytes.length, maxBytes: maxBytes);
    return bytes;
  }
  if (path.startsWith('docs/sample_images/')) {
    final data = await rootBundle.load(path);
    checkImageEncodedLength(data.lengthInBytes, maxBytes: maxBytes);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
  return readBoundedImageFile(path, maxBytes: maxBytes);
}

/// Stable cache key lets preview and its disposal lease share one read/decode.
/// Each stream emits exactly one image, including for animated sources.
class BoundedImageProvider extends ImageProvider<BoundedImageProvider> {
  BoundedImageProvider({
    String? path,
    this.bytes,
    this.target = ImageDecodeTarget.panel,
    this.source = AnitabiImageSource.auto,
  }) : assert(path != null || bytes != null),
       path = path == null ? null : resolveBoundedImagePath(path);
  final String? path;
  final Uint8List? bytes;
  final ImageDecodeTarget target;
  final AnitabiImageSource source;

  @override
  Future<BoundedImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    BoundedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_load());
  }

  Future<ImageInfo> _load() async {
    final permit = await _previewReads.acquire();
    try {
      final encoded =
          bytes ?? await readBoundedImageSource(path!, source: source);
      return ImageInfo(
        image: await decodeBoundedImage(encoded, target: target),
      );
    } catch (_) {
      PaintingBinding.instance.imageCache.evict(this);
      rethrow;
    } finally {
      permit.release();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is BoundedImageProvider &&
      path == other.path &&
      identical(bytes, other.bytes) &&
      source == other.source &&
      target.maxEdge == other.target.maxEdge &&
      target.maxPixels == other.target.maxPixels;
  @override
  int get hashCode => Object.hash(
    path,
    identityHashCode(bytes),
    source,
    target.maxEdge,
    target.maxPixels,
  );
}

class BoundedImage extends StatelessWidget {
  const BoundedImage({
    super.key,
    this.path,
    this.bytes,
    this.fit = BoxFit.contain,
    this.target = ImageDecodeTarget.panel,
    this.source = AnitabiImageSource.auto,
  });
  final String? path;
  final Uint8List? bytes;
  final BoxFit fit;
  final ImageDecodeTarget target;
  final AnitabiImageSource source;
  @override
  Widget build(BuildContext context) => Image(
    image: BoundedImageProvider(
      path: path,
      bytes: bytes,
      target: target,
      source: source,
    ),
    fit: fit,
    frameBuilder: (context, child, frame, synchronous) => frame != null
        ? child
        : target.maxEdge <= 512
        ? ColoredBox(color: AppColors.surfaceMuted)
        : LayoutBuilder(
            builder: (context, constraints) => Center(
              child: constraints.maxHeight < 64 || constraints.maxWidth < 100
                  ? Tooltip(
                      message: l10n.boundedImageLoading,
                      child: const Icon(Icons.hourglass_empty),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_empty),
                        const SizedBox(height: 12),
                        Text(l10n.boundedImageLoading),
                      ],
                    ),
            ),
          ),
    errorBuilder: (context, error, stack) => target.maxEdge <= 512
        ? Tooltip(
            message: error.toString(),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined),
            ),
          )
        : BoundedImageError(error: error),
  );
}

class BoundedImageError extends StatelessWidget {
  const BoundedImageError({super.key, required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final message = error is ImageBudgetException
          ? (error as ImageBudgetException).message
          : l10n.boundedImageUnavailable;
      if (constraints.maxWidth < 160 || constraints.maxHeight < 90) {
        return Tooltip(
          message: message,
          child: const Center(child: Icon(Icons.image_not_supported_outlined)),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    },
  );
}
