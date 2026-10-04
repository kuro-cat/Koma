import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Strings for the app's current locale, readable with or without a
/// BuildContext. The MaterialApp builder keeps it in sync; it starts as
/// Chinese so widgets pumped outside the app (tests) keep their text.
// ponytail: global, so widgets already built keep the old language after a
// live system-language switch until they rebuild; use AppLocalizations.of
// in those widgets if that matters.
AppLocalizations l10n = lookupAppLocalizations(const Locale('zh'));
