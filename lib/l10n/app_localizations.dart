import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @appLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 MiriaGo...'**
  String get appLoading;

  /// No description provided for @alignPhotoTitle.
  ///
  /// In zh, this message translates to:
  /// **'对齐裁剪'**
  String get alignPhotoTitle;

  /// No description provided for @alignPhotoAction.
  ///
  /// In zh, this message translates to:
  /// **'对齐裁剪'**
  String get alignPhotoAction;

  /// No description provided for @alignPhotoHint.
  ///
  /// In zh, this message translates to:
  /// **'双指缩放、拖动照片，让它与参考图重合'**
  String get alignPhotoHint;

  /// No description provided for @alignPhotoFrameOpacity.
  ///
  /// In zh, this message translates to:
  /// **'参考图'**
  String get alignPhotoFrameOpacity;

  /// No description provided for @alignPhotoRotation.
  ///
  /// In zh, this message translates to:
  /// **'旋转'**
  String get alignPhotoRotation;

  /// No description provided for @alignPhotoDifference.
  ///
  /// In zh, this message translates to:
  /// **'差值叠加'**
  String get alignPhotoDifference;

  /// No description provided for @alignPhotoDifferenceHint.
  ///
  /// In zh, this message translates to:
  /// **'重合的地方会变暗'**
  String get alignPhotoDifferenceHint;

  /// No description provided for @alignPhotoReset.
  ///
  /// In zh, this message translates to:
  /// **'重新居中'**
  String get alignPhotoReset;

  /// No description provided for @alignPhotoSave.
  ///
  /// In zh, this message translates to:
  /// **'保存裁剪'**
  String get alignPhotoSave;

  /// No description provided for @alignPhotoSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中...'**
  String get alignPhotoSaving;

  /// No description provided for @alignPhotoSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存裁剪'**
  String get alignPhotoSaved;

  /// No description provided for @alignPhotoSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，原图未更改'**
  String get alignPhotoSaveFailed;

  /// No description provided for @alignPhotoRemoveTitle.
  ///
  /// In zh, this message translates to:
  /// **'移除裁剪'**
  String get alignPhotoRemoveTitle;

  /// No description provided for @alignPhotoRemoveMessage.
  ///
  /// In zh, this message translates to:
  /// **'将恢复为未裁剪的原图，调色会重新应用。'**
  String get alignPhotoRemoveMessage;

  /// No description provided for @alignPhotoRemoveConfirm.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get alignPhotoRemoveConfirm;

  /// No description provided for @alignPhotoRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已移除裁剪'**
  String get alignPhotoRemoved;

  /// No description provided for @alignPhotoNoPhoto.
  ///
  /// In zh, this message translates to:
  /// **'巡礼照片不可用'**
  String get alignPhotoNoPhoto;

  /// No description provided for @alignPhotoNoReference.
  ///
  /// In zh, this message translates to:
  /// **'这条记录没有参考图，无法对齐'**
  String get alignPhotoNoReference;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
