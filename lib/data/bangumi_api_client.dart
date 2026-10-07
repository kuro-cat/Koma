import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/bangumi_config.dart';
import '../plan/pilgrimage_models.dart';
import '../l10n/l10n.dart';

class BangumiApiClient {
  BangumiApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null;

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  static const searchTimeout = Duration(seconds: 15);

  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  Future<List<PilgrimageWork>> searchSubjects(
    String keyword, {
    required Set<BangumiSubjectType> types,
  }) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      return const [];
    }

    final uri = Uri.parse(
      '${BangumiConfig.apiBaseUrl}/v0/search/subjects',
    ).replace(queryParameters: const {'limit': '12'});
    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer ${BangumiConfig.apiToken}',
            'Content-Type': 'application/json',
            if (!kIsWeb) 'User-Agent': BangumiConfig.userAgent,
          },
          body: jsonEncode({
            'keyword': query,
            'sort': 'match',
            'filter': {
              'nsfw': false,
              if (types.isNotEmpty)
                'type': types.map((type) => type.code).toList(growable: false),
            },
          }),
        )
        // A stalled search would otherwise spin until the OS gives up.
        .timeout(searchTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BangumiApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body) as Map<String, Object?>;
    final data = decoded['data'];
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, Object?>>()
        // Treat missing/malformed safety flags as unknown, not as safe.
        .where(
          (subject) =>
              subject['nsfw'] == false &&
              (!subject.containsKey('adult') || subject['adult'] == false),
        )
        .map(_workFromSubject)
        .toList(growable: false);
  }

  /// Cover thumbnail of one subject, or null when it has none or is marked
  /// as adult content.
  Future<String?> fetchSubjectCover(int bangumiId) async {
    final response = await _httpClient
        .get(
          Uri.parse('${BangumiConfig.apiBaseUrl}/v0/subjects/$bangumiId'),
          headers: {
            'Authorization': 'Bearer ${BangumiConfig.apiToken}',
            if (!kIsWeb) 'User-Agent': BangumiConfig.userAgent,
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BangumiApiException(response.statusCode, response.body);
    }
    final subject = jsonDecode(utf8.decode(response.bodyBytes));
    if (subject is! Map<String, Object?> ||
        subject['nsfw'] != false ||
        (subject.containsKey('adult') && subject['adult'] != false)) {
      return null;
    }
    return _coverImageUrl(subject['images']);
  }

  Future<List<PilgrimageWork>> searchAnime(String keyword) {
    return searchSubjects(keyword, types: const {BangumiSubjectType.anime});
  }

  PilgrimageWork _workFromSubject(Map<String, Object?> subject) {
    final bangumiId = subject['id'] as int;
    final subjectType = BangumiSubjectType.fromCode(subject['type'] as int?);
    final date = subject['date'] as String? ?? '';
    final (:title, :subtitle) = bangumiWorkTitles(
      bangumiId: bangumiId,
      name: subject['name'] as String? ?? 'Bangumi #$bangumiId',
      nameCn: subject['name_cn'] as String? ?? '',
      aliases: _infoboxAliases(subject['infobox']),
    );
    final coverImageUrl = _coverImageUrl(subject['images']);

    final metaParts = [
      if (subjectType != null) subjectType.label,
      if (date.isNotEmpty) date,
    ];

    return PilgrimageWork(
      id: 'bangumi-$bangumiId',
      bangumiId: bangumiId,
      bangumiSubjectType: subjectType,
      coverImageUrl: coverImageUrl,
      title: title,
      subtitle: subtitle,
      city: metaParts.isEmpty
          ? l10n.bangumiApiClientNoRegion
          : metaParts.join(' / '),
      source: WorkSource.bangumi,
    );
  }

  String? _coverImageUrl(Object? value) {
    if (value is! Map) {
      return null;
    }
    for (final key in const ['small', 'common', 'medium', 'grid', 'large']) {
      final candidate = value[key];
      if (candidate is! String || candidate.trim().isEmpty) {
        continue;
      }
      final text = candidate.trim();
      if (text.startsWith('//')) {
        return 'https:$text';
      }
      final uri = Uri.tryParse(text);
      if (uri == null || !uri.hasAuthority) {
        continue;
      }
      return uri.scheme == 'http'
          ? uri.replace(scheme: 'https').toString()
          : text;
    }
    return null;
  }
}

class BangumiApiException implements Exception {
  const BangumiApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() {
    return 'BangumiApiException($statusCode): $body';
  }
}

/// Title and subtitle for a Bangumi work. In Chinese: the Chinese name over
/// the Japanese one. Otherwise: the Japanese name over the first alias
/// written in Latin letters (usually the English or romaji title).
({String title, String subtitle}) bangumiWorkTitles({
  required int bangumiId,
  required String name,
  required String nameCn,
  Iterable<String> aliases = const [],
}) {
  if (l10n.localeName.startsWith('zh')) {
    return nameCn.isEmpty
        ? (title: name, subtitle: '')
        : (title: nameCn, subtitle: name);
  }
  final latinAlias = aliases
      .map((alias) => alias.trim())
      .where(
        (alias) => _latinLetter.hasMatch(alias) && !_cjkOrKana.hasMatch(alias),
      )
      .firstOrNull;
  return (title: name.isEmpty ? nameCn : name, subtitle: latinAlias ?? '');
}

final _latinLetter = RegExp('[A-Za-z]');
final _cjkOrKana = RegExp(r'[\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]');

/// The infobox "别名" (alias) values, which Bangumi gives either as one
/// string or as a list of `{v: ...}` entries.
Iterable<String> _infoboxAliases(Object? infobox) sync* {
  if (infobox is! List) return;
  for (final entry in infobox.whereType<Map>()) {
    if (entry['key'] != '别名') continue;
    final value = entry['value'];
    if (value is String) yield value;
    if (value is List) {
      for (final item in value.whereType<Map>()) {
        if (item['v'] case final String alias) yield alias;
      }
    }
  }
}
