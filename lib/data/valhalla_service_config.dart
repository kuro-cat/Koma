import '../l10n/l10n.dart';

const defaultValhallaBaseUrl = 'https://valhalla1.openstreetmap.de';

String normalizeValhallaBaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return defaultValhallaBaseUrl;
  }
  return trimmed.replaceFirst(RegExp(r'/+$'), '');
}

String? validateValhallaBaseUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return l10n.valhallaServiceConfigUrlIncomplete;
  }
  if (uri.scheme != 'https' && uri.scheme != 'http') {
    return l10n.valhallaServiceConfigUrlScheme;
  }
  return null;
}
