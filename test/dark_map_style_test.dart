import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miriago/map/map_tile_config.dart';
import 'package:miriago/plan/pilgrimage_models.dart';

void main() {
  test(
    'base appearance overrides theme without replacing custom providers',
    () {
      const settings = AppSettings();
      expect(resolvedMapLibreStyle(settings, dark: false), openFreeMapStyleUrl);
      expect(
        resolvedMapLibreStyle(settings, dark: true),
        darkMapStyleAsset(OpenFreeMapStyle.liberty),
      );
      expect(
        resolvedMapLibreStyle(
          settings.copyWith(mapAppearance: MapAppearance.light),
          dark: true,
        ),
        openFreeMapStyleUrl,
      );
      expect(
        resolvedMapLibreStyle(
          settings.copyWith(mapAppearance: MapAppearance.dark),
          dark: false,
        ),
        darkMapStyleAsset(OpenFreeMapStyle.liberty),
      );
      expect(
        resolvedMapLibreStyle(
          settings.copyWith(
            openFreeMapStyle: OpenFreeMapStyle.dark,
            mapAppearance: MapAppearance.light,
          ),
          dark: true,
        ),
        readableDarkMapStyleAsset,
      );
      for (final appearance in MapAppearance.values) {
        final custom = settings.copyWith(
          mapAppearance: appearance,
          mapTileProvider: MapTileProvider.customMapLibreStyle,
          customMapLibreStyleUrl: 'https://example.com/style.json',
        );
        expect(
          resolvedMapLibreStyle(custom, dark: true),
          'https://example.com/style.json',
        );
        expect(
          xyzTileUrl(
            custom.copyWith(mapTileProvider: MapTileProvider.openStreetMap),
          ),
          openStreetMapTileUrl,
        );
        expect(
          xyzTileUrl(
            custom.copyWith(
              mapTileProvider: MapTileProvider.customXyz,
              customXyzTileUrl: 'https://example.com/{z}/{x}/{y}.png',
            ),
          ),
          'https://example.com/{z}/{x}/{y}.png',
        );
      }
    },
  );

  test('each style retains its identity across appearance and app themes', () {
    final assets = <String>{};
    for (final style in OpenFreeMapStyle.values) {
      assets.add(darkMapStyleAsset(style));
      for (final appearance in MapAppearance.values) {
        for (final dark in [false, true]) {
          final settings = AppSettings(
            openFreeMapStyle: style,
            mapAppearance: appearance,
          );
          final expectedDark =
              style == OpenFreeMapStyle.dark ||
              appearance == MapAppearance.dark ||
              (appearance == MapAppearance.automatic && dark);
          expect(
            resolvedMapLibreStyle(settings, dark: dark),
            expectedDark
                ? darkMapStyleAsset(style)
                : openFreeMapStyleOption(style).styleUrl,
          );
        }
      }
    }
    expect(assets.length, OpenFreeMapStyle.values.length);
  });

  for (final variant in OpenFreeMapStyle.values) {
    test(
      '${variant.name} dark preserves source layers, geometry and expressions',
      () {
        final source =
            jsonDecode(
                  File(
                    'tool/map_styles/${variant.name}.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        final dark =
            jsonDecode(File(darkMapStyleAsset(variant)).readAsStringSync())
                as Map<String, dynamic>;
        for (final key in ['version', 'sources', 'sprite', 'glyphs']) {
          expect(dark[key], source[key], reason: key);
        }
        final before = (source['layers'] as List).cast<Map<String, dynamic>>();
        final after = (dark['layers'] as List).cast<Map<String, dynamic>>();
        expect(after.length, before.length);
        for (var i = 0; i < before.length; i++) {
          final a = Map<String, dynamic>.from(before[i])..remove('paint');
          final b = Map<String, dynamic>.from(after[i])..remove('paint');
          expect(b, a, reason: '${variant.name}/${a['id']}');
          final paint = before[i]['paint'] as Map<String, dynamic>? ?? {};
          for (final entry in paint.entries) {
            if (!entry.key.endsWith('-color') &&
                entry.key != 'text-halo-width' &&
                !(entry.key == 'fill-opacity' &&
                    paint.containsKey('fill-pattern'))) {
              expect(
                after[i]['paint'][entry.key],
                entry.value,
                reason: '${a['id']}/${entry.key}',
              );
            }
            if (entry.key.endsWith('-color') && entry.value is List) {
              expect(
                _expressionShape(after[i]['paint'][entry.key]),
                _expressionShape(entry.value),
              );
            }
          }
        }
      },
    );
  }

  test(
    'bundled style has portable sources and attribution',
    () {
      final style =
          jsonDecode(File(readableDarkMapStyleAsset).readAsStringSync())
              as Map<String, dynamic>;
      expect(style['version'], 8);
      final layers = (style['layers'] as List).cast<Map<String, dynamic>>();
      expect(layers.map((l) => l['id']).toSet().length, layers.length);
      for (final key in ['sprite', 'glyphs']) {
        expect(style[key], startsWith('https://'));
      }
      expect(
        style['sources']['openmaptiles']['url'],
        'https://tiles.openfreemap.org/planet',
      );
      expect(
        File('assets/maps/LICENSE.txt').readAsStringSync(),
        contains('CartoDB'),
      );
    },
  );
}

Object? _expressionShape(Object? value) {
  if (value is List) return value.map(_expressionShape).toList();
  if (value is String && RegExp(r'^(#|rgba?\(|hsla?\()').hasMatch(value)) {
    return '<color>';
  }
  return value;
}
