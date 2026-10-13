import 'dart:convert';

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:miriago/data/bangumi_api_client.dart';
import 'package:miriago/l10n/l10n.dart';
import 'package:miriago/plan/pilgrimage_models.dart';

void main() {
  test(
    'a romaji title Bangumi does not know is found by its Japanese title',
    () async {
      final bangumiKeywords = <String>[];
      final client = BangumiApiClient(
        httpClient: MockClient((request) async {
          if (request.url.host == 'graphql.anilist.co') {
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'data': {
                    'Page': {
                      'media': [
                        {
                          'title': {'native': 'たまゆら'},
                        },
                        {
                          'title': {'native': 'たまゆら'},
                        },
                      ],
                    },
                  },
                }),
              ),
              200,
            );
          }
          final keyword =
              (jsonDecode(request.body) as Map)['keyword'] as String;
          bangumiKeywords.add(keyword);
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'data': [
                  if (keyword == 'たまゆら')
                    {'id': 7, 'type': 2, 'name': 'たまゆら', 'nsfw': false},
                ],
              }),
            ),
            200,
          );
        }),
      );

      final works = await client.searchSubjects(
        'Tamayura',
        types: const {BangumiSubjectType.anime},
      );

      expect(bangumiKeywords, ['Tamayura', 'たまゆら']);
      expect(works.single.bangumiId, 7);
    },
  );

  test(
    'uses small Bangumi cover and normalizes protocol-relative URL',
    () async {
      final client = _clientWithImages({
        'small': '//lain.bgm.tv/r/200/pic/cover/demo.jpg',
        'common': 'https://lain.bgm.tv/r/400/pic/cover/demo.jpg',
      });

      final works = await client.searchSubjects(
        '测试作品',
        types: const {BangumiSubjectType.anime},
      );

      expect(
        works.single.coverImageUrl,
        'https://lain.bgm.tv/r/200/pic/cover/demo.jpg',
      );
    },
  );

  test('falls back through supported Bangumi cover sizes', () async {
    final client = _clientWithImages({
      'small': '',
      'common': 'http://lain.bgm.tv/r/400/pic/cover/demo.jpg',
      'large': 'https://lain.bgm.tv/pic/cover/demo.jpg',
    });

    final works = await client.searchAnime('测试作品');

    expect(
      works.single.coverImageUrl,
      'https://lain.bgm.tv/r/400/pic/cover/demo.jpg',
    );
  });

  test('keeps cover null when Bangumi images are unavailable', () async {
    final client = _clientWithImages(null);

    final works = await client.searchAnime('测试作品');

    expect(works.single.coverImageUrl, isNull);
  });

  test(
    'skips malformed cover candidates and preserves fallback order',
    () async {
      final client = _clientWithImages({
        'small': 12,
        'common': '/relative-only.jpg',
        'medium': 'https://lain.bgm.tv/pic/cover/medium.jpg',
        'large': 'https://lain.bgm.tv/pic/cover/large.jpg',
      });
      expect(
        (await client.searchAnime('test')).single.coverImageUrl,
        'https://lain.bgm.tv/pic/cover/medium.jpg',
      );
    },
  );
  test('English shows the Japanese title over the first Latin alias', () async {
    final previous = l10n;
    addTearDown(() => l10n = previous);
    final client = BangumiApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 115908,
                'nsfw': false,
                'type': BangumiSubjectType.anime.code,
                'name': '響け！ユーフォニアム',
                'name_cn': '吹响吧！上低音号',
                'infobox': [
                  {
                    'key': '别名',
                    'value': [
                      {'v': '吹响！悠风号'},
                      {'v': 'Hibike! Euphonium'},
                      {'v': 'Sound! Euphonium'},
                    ],
                  },
                ],
              },
            ],
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      }),
    );

    l10n = lookupAppLocalizations(const Locale('en'));
    final english = (await client.searchAnime('euphonium')).single;
    expect(english.title, '響け！ユーフォニアム');
    expect(english.subtitle, 'Hibike! Euphonium');

    l10n = lookupAppLocalizations(const Locale('zh'));
    final chinese = (await client.searchAnime('euphonium')).single;
    expect(chinese.title, '吹响吧！上低音号');
    expect(chinese.subtitle, '響け！ユーフォニアム');
  });
}

BangumiApiClient _clientWithImages(Object? images) {
  return BangumiApiClient(
    httpClient: MockClient((request) async {
      expect(request.method, 'POST');
      return http.Response(
        jsonEncode({
          'data': [
            {
              'id': 326,
              'nsfw': false,
              'type': BangumiSubjectType.anime.code,
              'name': 'Test Work',
              'name_cn': '测试作品',
              'date': '2026-07-20',
              'images': images,
            },
          ],
        }),
        200,
        headers: const {'content-type': 'application/json'},
      );
    }),
  );
}
