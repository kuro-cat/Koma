import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:miriago/align/photo_alignment.dart';

/// True when every frame corner lies on the photo, i.e. the crop has no gaps.
bool coversFrame(PhotoAlignment a, double photoAspect) {
  const epsilon = 1e-9;
  final cos = math.cos(a.rotation);
  final sin = math.sin(a.rotation);
  for (final corner in [
    (0.0, 0.0),
    (1.0, 0.0),
    (0.0, a.frameHeight),
    (1.0, a.frameHeight),
  ]) {
    final dx = corner.$1 - a.centerX;
    final dy = corner.$2 - a.centerY;
    final localX = cos * dx + sin * dy;
    final localY = -sin * dx + cos * dy;
    if (localX.abs() > a.scale / 2 + epsilon ||
        localY.abs() > a.scale / photoAspect / 2 + epsilon) {
      return false;
    }
  }
  return true;
}

void main() {
  const frameAspect = 16 / 9;

  test('cover fills the frame for portrait and landscape photos', () {
    for (final photoAspect in [3 / 4, 4 / 3, 16 / 9, 21 / 9]) {
      final a = PhotoAlignment.cover(
        photoAspect: photoAspect,
        frameAspect: frameAspect,
      );
      expect(coversFrame(a, photoAspect), isTrue, reason: '$photoAspect');
      expect(a.clamped(photoAspect: photoAspect), a);
    }
  });

  test('clamp never leaves gaps after shrinking, panning or rotating', () {
    const photoAspect = 4 / 3;
    final start = PhotoAlignment.cover(
      photoAspect: photoAspect,
      frameAspect: frameAspect,
    );
    final random = math.Random(7);
    for (var i = 0; i < 500; i++) {
      final moved = start.copyWith(
        centerX: random.nextDouble() * 3 - 1,
        centerY: random.nextDouble() * 3 - 1,
        scale: random.nextDouble() * 3,
        rotation: (random.nextDouble() - 0.5) * math.pi,
      );
      final clamped = moved.clamped(photoAspect: photoAspect);
      expect(coversFrame(clamped, photoAspect), isTrue, reason: '$moved');
      expect(clamped.rotation, moved.rotation);
    }
  });

  test('clamp keeps a valid zoomed-in alignment unchanged', () {
    const photoAspect = 4 / 3;
    final a = PhotoAlignment.cover(
      photoAspect: photoAspect,
      frameAspect: frameAspect,
    ).copyWith(scale: 2, centerX: 0.6, rotation: 0.1);
    expect(a.clamped(photoAspect: photoAspect), a);
  });

  test('round-trips through JSON', () {
    final a = PhotoAlignment.cover(
      photoAspect: 4 / 3,
      frameAspect: frameAspect,
    ).copyWith(rotation: 0.2);
    expect(PhotoAlignment.fromJson(a.toJson()), a);
  });
}
