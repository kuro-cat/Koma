import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../data/bounded_image_decoder.dart';

/// Where a pilgrimage photo sits under its reference frame.
///
/// Coordinates are in frame space: the frame is 1 unit wide and
/// `1 / frameAspect` units tall, origin at its top-left. The photo's center is
/// at ([centerX], [centerY]), it is [scale] units wide, and it is rotated by
/// [rotation] radians (clockwise on screen) about its center. The saved crop is
/// exactly the frame rectangle.
@immutable
class PhotoAlignment {
  const PhotoAlignment({
    required this.frameAspect,
    required this.centerX,
    required this.centerY,
    required this.scale,
    this.rotation = 0,
  });

  /// Centered, unrotated, and just large enough to cover the frame.
  factory PhotoAlignment.cover({
    required double photoAspect,
    required double frameAspect,
  }) {
    return PhotoAlignment(
      frameAspect: frameAspect,
      centerX: 0.5,
      centerY: 0.5 / frameAspect,
      scale: math.max(1, photoAspect / frameAspect),
    );
  }

  factory PhotoAlignment.fromJson(Map<String, Object?> json) {
    double read(String key, [double? fallback]) {
      final value = json[key];
      if (value is num && value.isFinite) return value.toDouble();
      if (fallback != null) return fallback;
      throw FormatException('Invalid photo alignment: $key');
    }

    final frameAspect = read('frameAspect');
    final scale = read('scale');
    if (frameAspect <= 0 || scale <= 0) {
      throw const FormatException('Invalid photo alignment size');
    }
    return PhotoAlignment(
      frameAspect: frameAspect,
      centerX: read('centerX'),
      centerY: read('centerY'),
      scale: scale,
      rotation: read('rotation', 0),
    );
  }

  final double frameAspect;
  final double centerX;
  final double centerY;
  final double scale;
  final double rotation;

  double get frameHeight => 1 / frameAspect;

  Map<String, Object?> toJson() => {
    'frameAspect': frameAspect,
    'centerX': centerX,
    'centerY': centerY,
    'scale': scale,
    'rotation': rotation,
  };

  PhotoAlignment copyWith({
    double? centerX,
    double? centerY,
    double? scale,
    double? rotation,
  }) {
    return PhotoAlignment(
      frameAspect: frameAspect,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  /// The nearest alignment, keeping [rotation], where the photo still covers
  /// every corner of the frame: scale grows if needed, then the center is
  /// pulled back inside the allowed box.
  PhotoAlignment clamped({required double photoAspect}) {
    final cos = math.cos(rotation);
    final sin = math.sin(rotation);
    // Half extents of the frame measured along the photo's own axes.
    final extentX = (cos.abs() + sin.abs() * frameHeight) / 2;
    final extentY = (sin.abs() + cos.abs() * frameHeight) / 2;
    final photoHeightRatio = 1 / photoAspect;
    final minScale = math.max(2 * extentX, 2 * extentY / photoHeightRatio);
    final nextScale = math.max(scale, minScale);

    // Frame center relative to the photo center, in photo axes.
    final dx = 0.5 - centerX;
    final dy = frameHeight / 2 - centerY;
    final localX = cos * dx + sin * dy;
    final localY = -sin * dx + cos * dy;
    final limitX = math.max(0.0, nextScale / 2 - extentX);
    final limitY = math.max(0.0, nextScale * photoHeightRatio / 2 - extentY);
    final clampedX = localX.clamp(-limitX, limitX);
    final clampedY = localY.clamp(-limitY, limitY);

    return copyWith(
      scale: nextScale,
      centerX: 0.5 - (cos * clampedX - sin * clampedY),
      centerY: frameHeight / 2 - (sin * clampedX + cos * clampedY),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PhotoAlignment &&
      other.frameAspect == frameAspect &&
      other.centerX == centerX &&
      other.centerY == centerY &&
      other.scale == scale &&
      other.rotation == rotation;

  @override
  int get hashCode =>
      Object.hash(frameAspect, centerX, centerY, scale, rotation);
}

/// Draws [photo] placed by [alignment] into a frame of [frameSize] pixels.
void paintAlignedPhoto(
  ui.Canvas canvas,
  ui.Size frameSize,
  ui.Image photo,
  PhotoAlignment alignment,
) {
  final unit = frameSize.width;
  final width = alignment.scale * unit;
  final height = width * photo.height / photo.width;
  canvas
    ..save()
    ..translate(alignment.centerX * unit, alignment.centerY * unit)
    ..rotate(alignment.rotation)
    ..drawImageRect(
      photo,
      ui.Rect.fromLTWH(0, 0, photo.width.toDouble(), photo.height.toDouble()),
      ui.Rect.fromCenter(center: ui.Offset.zero, width: width, height: height),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    )
    ..restore();
}

/// Renders the frame-shaped crop of [photoBytes] as a JPEG, keeping the
/// photo's own pixel density (bounded by [ImageDecodeTarget.grading]).
Future<Uint8List> renderAlignedJpeg({
  required Uint8List photoBytes,
  required PhotoAlignment alignment,
}) async {
  final photo = await decodeBoundedImage(
    photoBytes,
    target: ImageDecodeTarget.grading,
  );
  ui.Image? output;
  try {
    final width = math.max(1, (photo.width / alignment.scale).round());
    final height = math.max(1, (width / alignment.frameAspect).round());
    final recorder = ui.PictureRecorder();
    paintAlignedPhoto(
      ui.Canvas(recorder),
      ui.Size(width.toDouble(), height.toDouble()),
      photo,
      alignment,
    );
    final picture = recorder.endRecording();
    try {
      output = await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
    final data = await output.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    if (data == null) throw StateError('Aligned photo has no pixels');
    return compute(_encodeJpegWorker, {
      'width': width,
      'height': height,
      'rgba': data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    });
  } finally {
    output?.dispose();
    photo.dispose();
  }
}

Uint8List _encodeJpegWorker(Map<String, Object> input) {
  final rgba = input['rgba']! as Uint8List;
  final image = img.Image.fromBytes(
    width: input['width']! as int,
    height: input['height']! as int,
    bytes: rgba.buffer,
    bytesOffset: rgba.offsetInBytes,
    numChannels: 4,
  );
  return Uint8List.fromList(img.encodeJpg(image, quality: 94));
}
