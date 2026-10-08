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
  /// **'正在加载 Koma...'**
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

  /// No description provided for @alignPhotoActionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'与参考图对齐'**
  String get alignPhotoActionSubtitle;

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

  /// No description provided for @settingsResetMessage.
  ///
  /// In zh, this message translates to:
  /// **'{target}将恢复为默认值。'**
  String settingsResetMessage(String target);

  /// No description provided for @settingsAnitabiRestoreMessage.
  ///
  /// In zh, this message translates to:
  /// **'将把{target}恢复为官方默认值。'**
  String settingsAnitabiRestoreMessage(String target);

  /// No description provided for @settingsDesktopLauncherAvailable.
  ///
  /// In zh, this message translates to:
  /// **'桌面启动器 可用 / {platform} / {mode}'**
  String settingsDesktopLauncherAvailable(String platform, String mode);

  /// No description provided for @settingsReferenceImageScale.
  ///
  /// In zh, this message translates to:
  /// **'参考图显示 {percent}%'**
  String settingsReferenceImageScale(int percent);

  /// No description provided for @settingsCameraZoomRange.
  ///
  /// In zh, this message translates to:
  /// **'相机缩放 {min}x - {max}x'**
  String settingsCameraZoomRange(String min, String max);

  /// No description provided for @settingsRemoteConfigApplied.
  ///
  /// In zh, this message translates to:
  /// **'已应用远程配置 v{version}'**
  String settingsRemoteConfigApplied(int version);

  /// No description provided for @settingsRemoteLastCheck.
  ///
  /// In zh, this message translates to:
  /// **'{applied} · 上次检查 {time}'**
  String settingsRemoteLastCheck(String applied, String time);

  /// No description provided for @settingsRemoteLastCheckResult.
  ///
  /// In zh, this message translates to:
  /// **'{applied} · 上次检查 {time}，{result}'**
  String settingsRemoteLastCheckResult(
    String applied,
    String time,
    String result,
  );

  /// No description provided for @settingsMapSource.
  ///
  /// In zh, this message translates to:
  /// **'地图源 {name}'**
  String settingsMapSource(String name);

  /// No description provided for @settingsOpenFreeMapStyle.
  ///
  /// In zh, this message translates to:
  /// **'OpenFreeMap 样式 {name}'**
  String settingsOpenFreeMapStyle(String name);

  /// No description provided for @settingsXyzUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'URL 需要包含 {z}、{x}、{y}。'**
  String settingsXyzUrlHelper(String z, String x, String y);

  /// No description provided for @settingsAnitabiImageSource.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 图片源 {name}'**
  String settingsAnitabiImageSource(String name);

  /// No description provided for @settingsCountValue.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个'**
  String settingsCountValue(int count);

  /// No description provided for @settingsNavigationApp.
  ///
  /// In zh, this message translates to:
  /// **'导航地图 {name}'**
  String settingsNavigationApp(String name);

  /// No description provided for @settingsZoomLevel.
  ///
  /// In zh, this message translates to:
  /// **'{level} 级'**
  String settingsZoomLevel(int level);

  /// No description provided for @settingsThumbnailThresholdSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'视图内点位不超过 {count} 个时显示缩略图；超过时仅显示圆点。'**
  String settingsThumbnailThresholdSubtitle(int count);

  /// No description provided for @settingsSelectedPlans.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {selected} / {total} 个计划'**
  String settingsSelectedPlans(int selected, int total);

  /// No description provided for @settingsPlanSummary.
  ///
  /// In zh, this message translates to:
  /// **'{area} / {count} 个点位'**
  String settingsPlanSummary(String area, int count);

  /// No description provided for @settingsCleaningProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在清理 {completed} / {total}'**
  String settingsCleaningProgress(int completed, int total);

  /// No description provided for @settingsClearReferenceCacheMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除 {count} 个下载缓存，约 {size}。本地上传图片和计划包导入图片不会被删除。'**
  String settingsClearReferenceCacheMessage(int count, String size);

  /// No description provided for @settingsCacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {count} 个缓存文件'**
  String settingsCacheCleared(int count);

  /// No description provided for @settingsFreedSpace.
  ///
  /// In zh, this message translates to:
  /// **'释放 {size}'**
  String settingsFreedSpace(String size);

  /// No description provided for @settingsCacheClearFailedFiles.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个文件清理失败'**
  String settingsCacheClearFailedFiles(int count);

  /// No description provided for @settingsHueSaturationValue.
  ///
  /// In zh, this message translates to:
  /// **'色相 {hue} 度，饱和度 {saturation}%'**
  String settingsHueSaturationValue(int hue, int saturation);

  /// No description provided for @settingsProbeSucceeded.
  ///
  /// In zh, this message translates to:
  /// **'成功 · {ms}ms'**
  String settingsProbeSucceeded(int ms);

  /// No description provided for @settingsImageSourceAutoDescription.
  ///
  /// In zh, this message translates to:
  /// **'优先使用 {official}；失败后尝试 {mirror}。'**
  String settingsImageSourceAutoDescription(String official, String mirror);

  /// No description provided for @settingsImageSourceFixedDescription.
  ///
  /// In zh, this message translates to:
  /// **'固定使用 {url}。'**
  String settingsImageSourceFixedDescription(String url);

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsResetTitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复初始设置'**
  String get settingsResetTitle;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In zh, this message translates to:
  /// **'外观设置'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'主题色、深浅色、缩放、显示等'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get settingsThemeColor;

  /// No description provided for @settingsThemeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get settingsThemeMode;

  /// No description provided for @settingsCameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'拍摄设置'**
  String get settingsCameraTitle;

  /// No description provided for @settingsCameraSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'照片比例、参考图比例、备份等'**
  String get settingsCameraSubtitle;

  /// No description provided for @settingsCaptureAspectRatio.
  ///
  /// In zh, this message translates to:
  /// **'拍摄图片比例'**
  String get settingsCaptureAspectRatio;

  /// No description provided for @settingsCameraZoom.
  ///
  /// In zh, this message translates to:
  /// **'相机缩放'**
  String get settingsCameraZoom;

  /// No description provided for @settingsPhotoBackup.
  ///
  /// In zh, this message translates to:
  /// **'照片备份'**
  String get settingsPhotoBackup;

  /// No description provided for @settingsSavePhotoToGallery.
  ///
  /// In zh, this message translates to:
  /// **'保存巡礼照片到相册'**
  String get settingsSavePhotoToGallery;

  /// No description provided for @settingsComparisonTitle.
  ///
  /// In zh, this message translates to:
  /// **'对比图设置'**
  String get settingsComparisonTitle;

  /// No description provided for @settingsComparisonSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出样式、自动保存到相册'**
  String get settingsComparisonSubtitle;

  /// No description provided for @settingsAutoSaveComparison.
  ///
  /// In zh, this message translates to:
  /// **'自动保存对比图'**
  String get settingsAutoSaveComparison;

  /// No description provided for @settingsAutoSaveComparisonSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保存记录时保存到相册'**
  String get settingsAutoSaveComparisonSubtitle;

  /// No description provided for @settingsDataSourceTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据源设置'**
  String get settingsDataSourceTitle;

  /// No description provided for @settingsDataSourceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'地图源、图片源等'**
  String get settingsDataSourceSubtitle;

  /// No description provided for @settingsMapDisplayTitle.
  ///
  /// In zh, this message translates to:
  /// **'地图显示'**
  String get settingsMapDisplayTitle;

  /// No description provided for @settingsMapDisplaySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点位、片区、聚合与缩略图'**
  String get settingsMapDisplaySubtitle;

  /// No description provided for @settingsClearCacheTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get settingsClearCacheTitle;

  /// No description provided for @settingsFullReferenceCache.
  ///
  /// In zh, this message translates to:
  /// **'完整参考图缓存'**
  String get settingsFullReferenceCache;

  /// No description provided for @settingsDesktopTitle.
  ///
  /// In zh, this message translates to:
  /// **'桌面端'**
  String get settingsDesktopTitle;

  /// No description provided for @settingsDesktopSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'启动器、数据目录等'**
  String get settingsDesktopSubtitle;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于 Koma'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'版本信息、开源许可等'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsResetTarget.
  ///
  /// In zh, this message translates to:
  /// **'所有外观、拍摄和地图设置'**
  String get settingsResetTarget;

  /// No description provided for @settingsReset.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get settingsReset;

  /// No description provided for @settingsResetNotice.
  ///
  /// In zh, this message translates to:
  /// **'恢复后仍可重新调整各项设置'**
  String get settingsResetNotice;

  /// No description provided for @settingsResetDone.
  ///
  /// In zh, this message translates to:
  /// **'已恢复初始设置'**
  String get settingsResetDone;

  /// No description provided for @settingsDesktopLauncherChecking.
  ///
  /// In zh, this message translates to:
  /// **'桌面启动器 检查中'**
  String get settingsDesktopLauncherChecking;

  /// No description provided for @settingsDesktopLauncherUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'桌面启动器 不可用'**
  String get settingsDesktopLauncherUnavailable;

  /// No description provided for @settingsDesktopSystemDataDir.
  ///
  /// In zh, this message translates to:
  /// **'系统数据目录'**
  String get settingsDesktopSystemDataDir;

  /// No description provided for @settingsDesktopPortableDir.
  ///
  /// In zh, this message translates to:
  /// **'便携目录'**
  String get settingsDesktopPortableDir;

  /// No description provided for @settingsDesktopAppDataDir.
  ///
  /// In zh, this message translates to:
  /// **'应用数据目录'**
  String get settingsDesktopAppDataDir;

  /// No description provided for @settingsUrlLabel.
  ///
  /// In zh, this message translates to:
  /// **'URL 地址'**
  String get settingsUrlLabel;

  /// No description provided for @settingsThemeModeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'影响应用整体浅色或深色显示'**
  String get settingsThemeModeSubtitle;

  /// No description provided for @settingsLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settingsDark;

  /// No description provided for @settingsFollowSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsFollowSystem;

  /// No description provided for @settingsThemeColorSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'影响应用整体配色'**
  String get settingsThemeColorSubtitle;

  /// No description provided for @settingsPageScale.
  ///
  /// In zh, this message translates to:
  /// **'页面缩放'**
  String get settingsPageScale;

  /// No description provided for @settingsPageScaleSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'调整界面整体大小（不影响参考图）'**
  String get settingsPageScaleSubtitle;

  /// No description provided for @settingsFontSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get settingsFontSmall;

  /// No description provided for @settingsFontStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get settingsFontStandard;

  /// No description provided for @settingsFontLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get settingsFontLarge;

  /// No description provided for @settingsFontExtraLarge.
  ///
  /// In zh, this message translates to:
  /// **'特大'**
  String get settingsFontExtraLarge;

  /// No description provided for @settingsPersonalization.
  ///
  /// In zh, this message translates to:
  /// **'个性化功能配置'**
  String get settingsPersonalization;

  /// No description provided for @settingsShowAreaProgress.
  ///
  /// In zh, this message translates to:
  /// **'显示片区进度条'**
  String get settingsShowAreaProgress;

  /// No description provided for @settingsShowAreaProgressSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在片区选择弹窗中显示未完成片区的进度背景；完成后仅显示对勾。'**
  String get settingsShowAreaProgressSubtitle;

  /// No description provided for @settingsDismissPlanActions.
  ///
  /// In zh, this message translates to:
  /// **'点击空白收回计划操作'**
  String get settingsDismissPlanActions;

  /// No description provided for @settingsDismissPlanActionsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'展开计划操作后，点击面板外的空白区域自动收回'**
  String get settingsDismissPlanActionsSubtitle;

  /// No description provided for @settingsCaptureAspectRatioHint.
  ///
  /// In zh, this message translates to:
  /// **'自动会优先跟随参考图比例；选择固定比例后会按该比例拍摄。'**
  String get settingsCaptureAspectRatioHint;

  /// No description provided for @settingsFallbackAspectRatio.
  ///
  /// In zh, this message translates to:
  /// **'无参考图时比例'**
  String get settingsFallbackAspectRatio;

  /// No description provided for @settingsFallbackAspectRatioHint.
  ///
  /// In zh, this message translates to:
  /// **'拍摄图片比例为自动、且没有参考图可对齐时使用。'**
  String get settingsFallbackAspectRatioHint;

  /// No description provided for @settingsPhotoLocation.
  ///
  /// In zh, this message translates to:
  /// **'照片定位信息'**
  String get settingsPhotoLocation;

  /// No description provided for @settingsPhotoBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保存记录时同时备份一张巡礼照片。'**
  String get settingsPhotoBackupSubtitle;

  /// No description provided for @settingsPhotoLocationAskDescription.
  ///
  /// In zh, this message translates to:
  /// **'第一次按下快门时选择。定位仅写入照片，不使用点位坐标。'**
  String get settingsPhotoLocationAskDescription;

  /// No description provided for @settingsPhotoLocationDisabledDescription.
  ///
  /// In zh, this message translates to:
  /// **'不申请照片定位权限，也不向照片写入 GPS 信息。'**
  String get settingsPhotoLocationDisabledDescription;

  /// No description provided for @settingsPhotoLocationRecentDescription.
  ///
  /// In zh, this message translates to:
  /// **'拍摄时优先使用设备最近的有效定位；没有可用定位时尝试获取一次。'**
  String get settingsPhotoLocationRecentDescription;

  /// No description provided for @settingsPhotoLocationConfirmDescription.
  ///
  /// In zh, this message translates to:
  /// **'拍摄后在确认记录页面获取新定位，完成或失败后再允许保存。'**
  String get settingsPhotoLocationConfirmDescription;

  /// No description provided for @settingsPhotoLocationBadgeAsk.
  ///
  /// In zh, this message translates to:
  /// **'询问'**
  String get settingsPhotoLocationBadgeAsk;

  /// No description provided for @settingsPhotoLocationBadgeOff.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get settingsPhotoLocationBadgeOff;

  /// No description provided for @settingsPhotoLocationBadgeRecent.
  ///
  /// In zh, this message translates to:
  /// **'最近'**
  String get settingsPhotoLocationBadgeRecent;

  /// No description provided for @settingsRecommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get settingsRecommended;

  /// No description provided for @settingsPhotoLocationConfirmLabel.
  ///
  /// In zh, this message translates to:
  /// **'确认记录时获取定位'**
  String get settingsPhotoLocationConfirmLabel;

  /// No description provided for @settingsAnitabiUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'仅支持公开可访问的 HTTPS 基础地址，不要填写接口路径参数。'**
  String get settingsAnitabiUrlHelper;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'设置保存失败'**
  String get settingsSaveFailed;

  /// No description provided for @settingsTryAgainLater.
  ///
  /// In zh, this message translates to:
  /// **'请稍后重试'**
  String get settingsTryAgainLater;

  /// No description provided for @settingsRestoreDefaultAddresses.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认地址'**
  String get settingsRestoreDefaultAddresses;

  /// No description provided for @settingsAnitabiRestoreTarget.
  ///
  /// In zh, this message translates to:
  /// **'全部 Anitabi 服务地址'**
  String get settingsAnitabiRestoreTarget;

  /// No description provided for @settingsRestoreDefault.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get settingsRestoreDefault;

  /// No description provided for @settingsAnitabiRestoreNotice.
  ///
  /// In zh, this message translates to:
  /// **'当前自定义地址不会被保留'**
  String get settingsAnitabiRestoreNotice;

  /// No description provided for @settingsAnitabiSite.
  ///
  /// In zh, this message translates to:
  /// **'主站地址'**
  String get settingsAnitabiSite;

  /// No description provided for @settingsAnitabiStaticData.
  ///
  /// In zh, this message translates to:
  /// **'静态地图数据'**
  String get settingsAnitabiStaticData;

  /// No description provided for @settingsAnitabiApi.
  ///
  /// In zh, this message translates to:
  /// **'数据 API'**
  String get settingsAnitabiApi;

  /// No description provided for @settingsAnitabiOfficialImage.
  ///
  /// In zh, this message translates to:
  /// **'官方图片服务'**
  String get settingsAnitabiOfficialImage;

  /// No description provided for @settingsAnitabiMirrorImage.
  ///
  /// In zh, this message translates to:
  /// **'备用图片服务'**
  String get settingsAnitabiMirrorImage;

  /// No description provided for @settingsAnitabiServices.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 服务地址'**
  String get settingsAnitabiServices;

  /// No description provided for @settingsServiceAddresses.
  ///
  /// In zh, this message translates to:
  /// **'服务地址'**
  String get settingsServiceAddresses;

  /// No description provided for @settingsTestingConnections.
  ///
  /// In zh, this message translates to:
  /// **'正在测试连接'**
  String get settingsTestingConnections;

  /// No description provided for @settingsTestAllConnections.
  ///
  /// In zh, this message translates to:
  /// **'测试全部连接'**
  String get settingsTestAllConnections;

  /// No description provided for @settingsAddressAutoUpdate.
  ///
  /// In zh, this message translates to:
  /// **'地址自动更新'**
  String get settingsAddressAutoUpdate;

  /// No description provided for @settingsAddressAutoUpdateDescription.
  ///
  /// In zh, this message translates to:
  /// **'连接 Anitabi 失败时，从 MiriaGo 仓库读取最新服务地址，验证可用后再替换。自定义的地址不会被改动。'**
  String get settingsAddressAutoUpdateDescription;

  /// No description provided for @settingsChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检查'**
  String get settingsChecking;

  /// No description provided for @settingsCheckNow.
  ///
  /// In zh, this message translates to:
  /// **'立即检查更新'**
  String get settingsCheckNow;

  /// No description provided for @settingsRemoteConfigNotApplied.
  ///
  /// In zh, this message translates to:
  /// **'尚未应用远程配置'**
  String get settingsRemoteConfigNotApplied;

  /// No description provided for @settingsRoutingConnectionOk.
  ///
  /// In zh, this message translates to:
  /// **'路径规划服务连接正常'**
  String get settingsRoutingConnectionOk;

  /// No description provided for @settingsRoutingConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'路径规划服务连接失败'**
  String get settingsRoutingConnectionFailed;

  /// No description provided for @settingsCustomXyzUrlNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置自定义 XYZ URL'**
  String get settingsCustomXyzUrlNotSet;

  /// No description provided for @settingsCustomXyzUrl.
  ///
  /// In zh, this message translates to:
  /// **'自定义 XYZ URL'**
  String get settingsCustomXyzUrl;

  /// No description provided for @settingsInvalidUrl.
  ///
  /// In zh, this message translates to:
  /// **'URL 格式无效'**
  String get settingsInvalidUrl;

  /// No description provided for @settingsMapLibreStyleUrlNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置 MapLibre style URL'**
  String get settingsMapLibreStyleUrlNotSet;

  /// No description provided for @settingsMapLibreStyleUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'URL 需要指向可公开读取的 style JSON。'**
  String get settingsMapLibreStyleUrlHelper;

  /// No description provided for @settingsAnitabiServicesHint.
  ///
  /// In zh, this message translates to:
  /// **'服务域名变化时可单独调整，不会改写计划中的标准图片链接。'**
  String get settingsAnitabiServicesHint;

  /// No description provided for @settingsConcurrentImageLoads.
  ///
  /// In zh, this message translates to:
  /// **'图片同时请求数'**
  String get settingsConcurrentImageLoads;

  /// No description provided for @settingsConcurrentImageLoadsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'缩略图和完整参考图均按此数量并发请求。数值越大速度可能越快，但网络和内存占用也更高。'**
  String get settingsConcurrentImageLoadsSubtitle;

  /// No description provided for @settingsWalkingRoutes.
  ///
  /// In zh, this message translates to:
  /// **'步行路径规划'**
  String get settingsWalkingRoutes;

  /// No description provided for @settingsValhallaAddress.
  ///
  /// In zh, this message translates to:
  /// **'Valhalla 服务地址'**
  String get settingsValhallaAddress;

  /// No description provided for @settingsValhallaHelper.
  ///
  /// In zh, this message translates to:
  /// **'用于应用内步行路线规划。公开服务没有可用性保证。'**
  String get settingsValhallaHelper;

  /// No description provided for @settingsTestConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get settingsTestConnection;

  /// No description provided for @settingsTest.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get settingsTest;

  /// No description provided for @settingsTestValhallaConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试 Valhalla 连接'**
  String get settingsTestValhallaConnection;

  /// No description provided for @settingsRestoreDefaultValhalla.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认 Valhalla 地址'**
  String get settingsRestoreDefaultValhalla;

  /// No description provided for @settingsValhallaPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'仅发送路线坐标，不会上传计划、作品或照片信息。'**
  String get settingsValhallaPrivacy;

  /// No description provided for @settingsBaseMapBrightness.
  ///
  /// In zh, this message translates to:
  /// **'底图明暗'**
  String get settingsBaseMapBrightness;

  /// No description provided for @settingsFollowTheme.
  ///
  /// In zh, this message translates to:
  /// **'跟随主题'**
  String get settingsFollowTheme;

  /// No description provided for @settingsBaseMapBrightnessHint.
  ///
  /// In zh, this message translates to:
  /// **'适用于 OpenFreeMap；Dark 始终使用深色，其他地图源保留原始样式。'**
  String get settingsBaseMapBrightnessHint;

  /// No description provided for @settingsCurrentLocation.
  ///
  /// In zh, this message translates to:
  /// **'当前位置'**
  String get settingsCurrentLocation;

  /// No description provided for @settingsContinuousLocation.
  ///
  /// In zh, this message translates to:
  /// **'持续更新当前位置'**
  String get settingsContinuousLocation;

  /// No description provided for @settingsContinuousLocationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启定位后持续更新；关闭时仅在点击定位时获取一次。'**
  String get settingsContinuousLocationSubtitle;

  /// No description provided for @settingsMapZoom.
  ///
  /// In zh, this message translates to:
  /// **'地图缩放'**
  String get settingsMapZoom;

  /// No description provided for @settingsMaxZoom.
  ///
  /// In zh, this message translates to:
  /// **'最大缩放倍率'**
  String get settingsMaxZoom;

  /// No description provided for @settingsMaxZoomHint.
  ///
  /// In zh, this message translates to:
  /// **'控制所有地图能够放大的最大级别。'**
  String get settingsMaxZoomHint;

  /// No description provided for @settingsMapMarkers.
  ///
  /// In zh, this message translates to:
  /// **'地图标记'**
  String get settingsMapMarkers;

  /// No description provided for @settingsHideCompletedSpots.
  ///
  /// In zh, this message translates to:
  /// **'隐藏已完成点位'**
  String get settingsHideCompletedSpots;

  /// No description provided for @settingsHideCompletedSpotsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在地图页不显示已标记完成的点位。关闭后仍可在地图上看到全部点位。'**
  String get settingsHideCompletedSpotsSubtitle;

  /// No description provided for @settingsMarkerSize.
  ///
  /// In zh, this message translates to:
  /// **'地图标记大小'**
  String get settingsMarkerSize;

  /// No description provided for @settingsMarkerSizeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'统一调整点位、缩略图、聚合标记、当前位置和片区关键点的大小。'**
  String get settingsMarkerSizeSubtitle;

  /// No description provided for @settingsAreaRange.
  ///
  /// In zh, this message translates to:
  /// **'片区范围'**
  String get settingsAreaRange;

  /// No description provided for @settingsAreaRadius.
  ///
  /// In zh, this message translates to:
  /// **'片区范围半径'**
  String get settingsAreaRadius;

  /// No description provided for @settingsAreaRadiusSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'每个点位向外扩张的距离，用于生成地图上的片区轮廓。'**
  String get settingsAreaRadiusSubtitle;

  /// No description provided for @settingsSpotClustering.
  ///
  /// In zh, this message translates to:
  /// **'地图点位聚合'**
  String get settingsSpotClustering;

  /// No description provided for @settingsAutoCluster.
  ///
  /// In zh, this message translates to:
  /// **'自动聚合密集点位'**
  String get settingsAutoCluster;

  /// No description provided for @settingsAutoClusterSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'仅合并地图标记的显示；点位数据、选择和导入功能不受影响。'**
  String get settingsAutoClusterSubtitle;

  /// No description provided for @settingsClusterRadius.
  ///
  /// In zh, this message translates to:
  /// **'聚合范围'**
  String get settingsClusterRadius;

  /// No description provided for @settingsClusterRadiusSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'屏幕上相距较近的点位会合并为一个带数量的聚合标记。'**
  String get settingsClusterRadiusSubtitle;

  /// No description provided for @settingsClusterMaxZoom.
  ///
  /// In zh, this message translates to:
  /// **'停止聚合级别'**
  String get settingsClusterMaxZoom;

  /// No description provided for @settingsClusterMaxZoomSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'地图放大超过该级别后显示每个原始点位。'**
  String get settingsClusterMaxZoomSubtitle;

  /// No description provided for @settingsMapThumbnails.
  ///
  /// In zh, this message translates to:
  /// **'地图缩略图'**
  String get settingsMapThumbnails;

  /// No description provided for @settingsThumbnailThreshold.
  ///
  /// In zh, this message translates to:
  /// **'缩略图显示阈值'**
  String get settingsThumbnailThreshold;

  /// No description provided for @settingsThumbnailThresholdHint.
  ///
  /// In zh, this message translates to:
  /// **'阈值为 0 时不会在地图上显示缩略图。'**
  String get settingsThumbnailThresholdHint;

  /// No description provided for @settingsPlans.
  ///
  /// In zh, this message translates to:
  /// **'计划'**
  String get settingsPlans;

  /// No description provided for @settingsPlansLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划列表读取失败'**
  String get settingsPlansLoadFailed;

  /// No description provided for @settingsSelectPlans.
  ///
  /// In zh, this message translates to:
  /// **'选择计划'**
  String get settingsSelectPlans;

  /// No description provided for @settingsSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get settingsSelectAll;

  /// No description provided for @settingsClearSelection.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get settingsClearSelection;

  /// No description provided for @settingsClearDownloadedReferenceCache.
  ///
  /// In zh, this message translates to:
  /// **'清除下载的参考图缓存'**
  String get settingsClearDownloadedReferenceCache;

  /// No description provided for @settingsCacheScanFailed.
  ///
  /// In zh, this message translates to:
  /// **'缓存扫描失败'**
  String get settingsCacheScanFailed;

  /// No description provided for @settingsNoCacheToClear.
  ///
  /// In zh, this message translates to:
  /// **'所选计划没有可清理的下载缓存'**
  String get settingsNoCacheToClear;

  /// No description provided for @settingsClearReferenceCacheTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除参考图缓存？'**
  String get settingsClearReferenceCacheTitle;

  /// No description provided for @settingsClear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get settingsClear;

  /// No description provided for @settingsLauncher.
  ///
  /// In zh, this message translates to:
  /// **'启动器'**
  String get settingsLauncher;

  /// No description provided for @settingsAppInfo.
  ///
  /// In zh, this message translates to:
  /// **'应用信息'**
  String get settingsAppInfo;

  /// No description provided for @settingsAppTagline.
  ///
  /// In zh, this message translates to:
  /// **'动漫圣地巡礼计划与拍摄参考工具'**
  String get settingsAppTagline;

  /// No description provided for @settingsCurrentVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前版本'**
  String get settingsCurrentVersion;

  /// No description provided for @settingsLoading.
  ///
  /// In zh, this message translates to:
  /// **'读取中'**
  String get settingsLoading;

  /// No description provided for @settingsAuthor.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get settingsAuthor;

  /// No description provided for @settingsContactEmail.
  ///
  /// In zh, this message translates to:
  /// **'联系邮箱'**
  String get settingsContactEmail;

  /// No description provided for @settingsSourceRepository.
  ///
  /// In zh, this message translates to:
  /// **'开源仓库'**
  String get settingsSourceRepository;

  /// No description provided for @settingsLicense.
  ///
  /// In zh, this message translates to:
  /// **'开源许可'**
  String get settingsLicense;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsViewPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'查看隐私政策'**
  String get settingsViewPrivacyPolicy;

  /// No description provided for @settingsDataAndCopyright.
  ///
  /// In zh, this message translates to:
  /// **'数据与版权'**
  String get settingsDataAndCopyright;

  /// No description provided for @settingsMap.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get settingsMap;

  /// No description provided for @settingsMapDataDescription.
  ///
  /// In zh, this message translates to:
  /// **'可使用 OpenFreeMap、OpenStreetMap 或自定义地图服务。'**
  String get settingsMapDataDescription;

  /// No description provided for @settingsWorks.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get settingsWorks;

  /// No description provided for @settingsWorksDataDescription.
  ///
  /// In zh, this message translates to:
  /// **'作品搜索数据来自 Bangumi。'**
  String get settingsWorksDataDescription;

  /// No description provided for @settingsPilgrimageContent.
  ///
  /// In zh, this message translates to:
  /// **'巡礼内容'**
  String get settingsPilgrimageContent;

  /// No description provided for @settingsPilgrimageContentDescription.
  ///
  /// In zh, this message translates to:
  /// **'巡礼点位与参考图来自 Anitabi。'**
  String get settingsPilgrimageContentDescription;

  /// No description provided for @settingsImageSource.
  ///
  /// In zh, this message translates to:
  /// **'图片源'**
  String get settingsImageSource;

  /// No description provided for @settingsImageSourceDescription.
  ///
  /// In zh, this message translates to:
  /// **'图片源设置只影响访问域名，远端链接统一保留 Anitabi 默认格式。'**
  String get settingsImageSourceDescription;

  /// No description provided for @settingsCopyright.
  ///
  /// In zh, this message translates to:
  /// **'版权归属'**
  String get settingsCopyright;

  /// No description provided for @settingsCopyrightDescription.
  ///
  /// In zh, this message translates to:
  /// **'第三方数据、截图和图片版权归原平台、贡献者或权利方所有。'**
  String get settingsCopyrightDescription;

  /// No description provided for @settingsAspectAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get settingsAspectAuto;

  /// No description provided for @settingsAspectNative.
  ///
  /// In zh, this message translates to:
  /// **'原生'**
  String get settingsAspectNative;

  /// No description provided for @settingsCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get settingsCustom;

  /// No description provided for @settingsAspectWidescreen.
  ///
  /// In zh, this message translates to:
  /// **'宽屏'**
  String get settingsAspectWidescreen;

  /// No description provided for @settingsAspectCinema.
  ///
  /// In zh, this message translates to:
  /// **'电影'**
  String get settingsAspectCinema;

  /// No description provided for @settingsAspectClassic.
  ///
  /// In zh, this message translates to:
  /// **'经典'**
  String get settingsAspectClassic;

  /// No description provided for @settingsAspectCamera.
  ///
  /// In zh, this message translates to:
  /// **'相机'**
  String get settingsAspectCamera;

  /// No description provided for @settingsAspectPortrait.
  ///
  /// In zh, this message translates to:
  /// **'竖屏'**
  String get settingsAspectPortrait;

  /// No description provided for @settingsAspectFullScreen.
  ///
  /// In zh, this message translates to:
  /// **'全面屏'**
  String get settingsAspectFullScreen;

  /// No description provided for @settingsAspectVertical.
  ///
  /// In zh, this message translates to:
  /// **'竖幅'**
  String get settingsAspectVertical;

  /// No description provided for @settingsAspectSquare.
  ///
  /// In zh, this message translates to:
  /// **'方形'**
  String get settingsAspectSquare;

  /// No description provided for @settingsAspectCustomShort.
  ///
  /// In zh, this message translates to:
  /// **'自定'**
  String get settingsAspectCustomShort;

  /// No description provided for @settingsDecrease.
  ///
  /// In zh, this message translates to:
  /// **'减少'**
  String get settingsDecrease;

  /// No description provided for @settingsIncrease.
  ///
  /// In zh, this message translates to:
  /// **'增加'**
  String get settingsIncrease;

  /// No description provided for @settingsCacheContents.
  ///
  /// In zh, this message translates to:
  /// **'缓存内容'**
  String get settingsCacheContents;

  /// No description provided for @settingsFullReferenceCacheSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'清除相机参考和大图查看使用的完整参考图。缩略图缓存会保留，以保持列表和地图加载速度。'**
  String get settingsFullReferenceCacheSubtitle;

  /// No description provided for @settingsCustomAspectRatio.
  ///
  /// In zh, this message translates to:
  /// **'自定义比例'**
  String get settingsCustomAspectRatio;

  /// No description provided for @settingsWidth.
  ///
  /// In zh, this message translates to:
  /// **'宽'**
  String get settingsWidth;

  /// No description provided for @settingsHeight.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get settingsHeight;

  /// No description provided for @settingsEnterValidRatio.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效比例'**
  String get settingsEnterValidRatio;

  /// No description provided for @settingsEnterColorName.
  ///
  /// In zh, this message translates to:
  /// **'请输入颜色名称'**
  String get settingsEnterColorName;

  /// No description provided for @settingsCustomThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'自定义主题色'**
  String get settingsCustomThemeColor;

  /// No description provided for @settingsName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get settingsName;

  /// No description provided for @settingsColorCode.
  ///
  /// In zh, this message translates to:
  /// **'色号'**
  String get settingsColorCode;

  /// No description provided for @settingsAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get settingsAdd;

  /// No description provided for @settingsHueSaturation.
  ///
  /// In zh, this message translates to:
  /// **'色相和饱和度'**
  String get settingsHueSaturation;

  /// No description provided for @settingsBrightness.
  ///
  /// In zh, this message translates to:
  /// **'明度'**
  String get settingsBrightness;

  /// No description provided for @settingsSourceDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get settingsSourceDefault;

  /// No description provided for @settingsSourceRemote.
  ///
  /// In zh, this message translates to:
  /// **'远程配置'**
  String get settingsSourceRemote;

  /// No description provided for @settingsProbeFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get settingsProbeFailed;

  /// No description provided for @settingsNavDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认选项'**
  String get settingsNavDefault;

  /// No description provided for @settingsNavPopularInChina.
  ///
  /// In zh, this message translates to:
  /// **'国内常用'**
  String get settingsNavPopularInChina;

  /// No description provided for @settingsNavIosNative.
  ///
  /// In zh, this message translates to:
  /// **'iOS 原生'**
  String get settingsNavIosNative;

  /// No description provided for @settingsNavCity.
  ///
  /// In zh, this message translates to:
  /// **'城市导航'**
  String get settingsNavCity;

  /// No description provided for @settingsNavGoogleDescription.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过 Google Maps 官方 Maps URL 打开步行路线。'**
  String get settingsNavGoogleDescription;

  /// No description provided for @settingsNavAppleDescription.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过 Apple Map Links 打开步行路线。'**
  String get settingsNavAppleDescription;

  /// No description provided for @settingsNavAmapDescription.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过高德 URI API 打开步行路线，并使用 WGS84 坐标。'**
  String get settingsNavAmapDescription;

  /// No description provided for @settingsNavBaiduDescription.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过百度地图 URI API 打开步行路线，并使用 WGS84 坐标。'**
  String get settingsNavBaiduDescription;

  /// No description provided for @settingsMapRecommendedDefault.
  ///
  /// In zh, this message translates to:
  /// **'推荐默认'**
  String get settingsMapRecommendedDefault;

  /// No description provided for @settingsMapStandardTiles.
  ///
  /// In zh, this message translates to:
  /// **'标准瓦片'**
  String get settingsMapStandardTiles;

  /// No description provided for @settingsMapTileTemplate.
  ///
  /// In zh, this message translates to:
  /// **'瓦片模板'**
  String get settingsMapTileTemplate;

  /// No description provided for @settingsMapStyleUrl.
  ///
  /// In zh, this message translates to:
  /// **'样式 URL'**
  String get settingsMapStyleUrl;

  /// No description provided for @settingsAnitabiSummaryCustom.
  ///
  /// In zh, this message translates to:
  /// **'已自定义，点击管理全部服务'**
  String get settingsAnitabiSummaryCustom;

  /// No description provided for @settingsAnitabiSummaryRemote.
  ///
  /// In zh, this message translates to:
  /// **'使用远程更新的地址，点击管理全部服务'**
  String get settingsAnitabiSummaryRemote;

  /// No description provided for @settingsAnitabiSummaryDefault.
  ///
  /// In zh, this message translates to:
  /// **'使用默认地址，点击管理全部服务'**
  String get settingsAnitabiSummaryDefault;

  /// No description provided for @settingsImageSourceAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动选择'**
  String get settingsImageSourceAuto;

  /// No description provided for @settingsImageSourceOfficial.
  ///
  /// In zh, this message translates to:
  /// **'官方默认'**
  String get settingsImageSourceOfficial;

  /// No description provided for @settingsImageSourceMirror.
  ///
  /// In zh, this message translates to:
  /// **'备用源'**
  String get settingsImageSourceMirror;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在读取隐私政策...'**
  String get privacyPolicyLoading;

  /// No description provided for @privacyPolicyLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策读取失败'**
  String get privacyPolicyLoadFailed;

  /// No description provided for @addPointsClipboardReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法读取剪贴板。'**
  String get addPointsClipboardReadFailed;

  /// No description provided for @addPointsClipboardNoCoordinate.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中没有有效坐标。'**
  String get addPointsClipboardNoCoordinate;

  /// No description provided for @addPointsCoordinateFilled.
  ///
  /// In zh, this message translates to:
  /// **'已填入坐标。'**
  String get addPointsCoordinateFilled;

  /// No description provided for @addPointsTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加内容'**
  String get addPointsTitle;

  /// No description provided for @addPointsRoutePlannerLead.
  ///
  /// In zh, this message translates to:
  /// **'点位很多、懒得逐个整理？'**
  String get addPointsRoutePlannerLead;

  /// No description provided for @addPointsManualEntryReference.
  ///
  /// In zh, this message translates to:
  /// **'手动录入'**
  String get addPointsManualEntryReference;

  /// No description provided for @addPointsPointSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位保存失败，请稍后重试。'**
  String get addPointsPointSaveFailed;

  /// No description provided for @addPointsWorkAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加「{title}」。'**
  String addPointsWorkAdded(String title);

  /// No description provided for @addPointsWorkAddFailed.
  ///
  /// In zh, this message translates to:
  /// **'作品添加失败，请稍后重试。'**
  String get addPointsWorkAddFailed;

  /// No description provided for @addPointsSearchBangumiTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索 Bangumi'**
  String get addPointsSearchBangumiTitle;

  /// No description provided for @addPointsWorkNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'作品名称'**
  String get addPointsWorkNameLabel;

  /// No description provided for @addPointsWorkNameSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：轻音少女'**
  String get addPointsWorkNameSearchHint;

  /// No description provided for @addPointsClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get addPointsClearSearch;

  /// No description provided for @addPointsSearching.
  ///
  /// In zh, this message translates to:
  /// **'搜索中'**
  String get addPointsSearching;

  /// No description provided for @addPointsSearchWorks.
  ///
  /// In zh, this message translates to:
  /// **'搜索作品'**
  String get addPointsSearchWorks;

  /// No description provided for @addPointsBangumiSearchFailed.
  ///
  /// In zh, this message translates to:
  /// **'Bangumi 搜索失败，请检查网络后重试。'**
  String get addPointsBangumiSearchFailed;

  /// No description provided for @addPointsFilterWorkTypes.
  ///
  /// In zh, this message translates to:
  /// **'筛选作品类型'**
  String get addPointsFilterWorkTypes;

  /// No description provided for @addPointsSelectedTypeCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 项'**
  String addPointsSelectedTypeCount(int count);

  /// No description provided for @addPointsLinkClipboardReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法读取剪贴板，请手动粘贴 Anitabi 链接。'**
  String get addPointsLinkClipboardReadFailed;

  /// No description provided for @addPointsLinkClipboardEmpty.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中没有可用的 Anitabi 链接。'**
  String get addPointsLinkClipboardEmpty;

  /// No description provided for @addPointsLinkImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 链接导入'**
  String get addPointsLinkImportTitle;

  /// No description provided for @addPointsAddingTo.
  ///
  /// In zh, this message translates to:
  /// **'加入到：{planName}'**
  String addPointsAddingTo(String planName);

  /// No description provided for @addPointsAnitabiLinkLabel.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 链接'**
  String get addPointsAnitabiLinkLabel;

  /// No description provided for @addPointsAnitabiLinkHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 Anitabi 作品或点位链接'**
  String get addPointsAnitabiLinkHint;

  /// No description provided for @addPointsClearInput.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索框'**
  String get addPointsClearInput;

  /// No description provided for @addPointsPaste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get addPointsPaste;

  /// No description provided for @addPointsOpenAnitabiSpots.
  ///
  /// In zh, this message translates to:
  /// **'打开 Anitabi 点位'**
  String get addPointsOpenAnitabiSpots;

  /// No description provided for @addPointsLinkRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入 Anitabi 链接'**
  String get addPointsLinkRequired;

  /// No description provided for @addPointsLinkInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 Anitabi 地图链接'**
  String get addPointsLinkInvalid;

  /// No description provided for @addPointsLinkMissingWorkId.
  ///
  /// In zh, this message translates to:
  /// **'链接缺少作品 ID，请先在 Anitabi 进入对应作品后复制链接'**
  String get addPointsLinkMissingWorkId;

  /// No description provided for @addPointsLinkExampleTitle.
  ///
  /// In zh, this message translates to:
  /// **'有效链接示例'**
  String get addPointsLinkExampleTitle;

  /// No description provided for @addPointsLinkExampleBody.
  ///
  /// In zh, this message translates to:
  /// **'如果链接里包含作品 ID，会只加载对应作品；\n如果还包含点位 ID，会自动选中该点位。\n没有作品 ID 的链接需要先在 Anitabi 中进入对应作品后重新复制。'**
  String get addPointsLinkExampleBody;

  /// No description provided for @addPointsLinkExampleBangumiIdNote.
  ///
  /// In zh, this message translates to:
  /// **'Bangumi 作品 ID（必须）'**
  String get addPointsLinkExampleBangumiIdNote;

  /// No description provided for @addPointsLinkExampleSpotIdNote.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位 ID（可选）'**
  String get addPointsLinkExampleSpotIdNote;

  /// No description provided for @addPointsWorkSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'作品保存失败，请稍后重试。'**
  String get addPointsWorkSaveFailed;

  /// No description provided for @addPointsManualAddWork.
  ///
  /// In zh, this message translates to:
  /// **'手动添加作品'**
  String get addPointsManualAddWork;

  /// No description provided for @addPointsFillingGuide.
  ///
  /// In zh, this message translates to:
  /// **'填写指南'**
  String get addPointsFillingGuide;

  /// No description provided for @addPointsWorkNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入作品的中文名称'**
  String get addPointsWorkNameHint;

  /// No description provided for @addPointsOriginalTitleLabel.
  ///
  /// In zh, this message translates to:
  /// **'作品原名'**
  String get addPointsOriginalTitleLabel;

  /// No description provided for @addPointsOriginalTitleHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入作品的原名（如日文/英文）'**
  String get addPointsOriginalTitleHint;

  /// No description provided for @addPointsWorkTypeLabel.
  ///
  /// In zh, this message translates to:
  /// **'作品类型'**
  String get addPointsWorkTypeLabel;

  /// No description provided for @addPointsMainRegionLabel.
  ///
  /// In zh, this message translates to:
  /// **'主要地区'**
  String get addPointsMainRegionLabel;

  /// No description provided for @addPointsMainRegionHint.
  ///
  /// In zh, this message translates to:
  /// **'输入作品主要发生或取景的地区'**
  String get addPointsMainRegionHint;

  /// No description provided for @addPointsSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中'**
  String get addPointsSaving;

  /// No description provided for @addPointsSaveWork.
  ///
  /// In zh, this message translates to:
  /// **'保存作品'**
  String get addPointsSaveWork;

  /// No description provided for @addPointsFieldRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写此项'**
  String get addPointsFieldRequired;

  /// No description provided for @addPointsPointGuideTitle.
  ///
  /// In zh, this message translates to:
  /// **'点位填写指南'**
  String get addPointsPointGuideTitle;

  /// No description provided for @addPointsPointGuideIntro.
  ///
  /// In zh, this message translates to:
  /// **'重点记录现场可识别的信息，方便到达后快速确认位置、场景和拍摄条件。'**
  String get addPointsPointGuideIntro;

  /// No description provided for @addPointsWorkLabel.
  ///
  /// In zh, this message translates to:
  /// **'所属作品'**
  String get addPointsWorkLabel;

  /// No description provided for @addPointsBadgeRequired.
  ///
  /// In zh, this message translates to:
  /// **'必填'**
  String get addPointsBadgeRequired;

  /// No description provided for @addPointsBadgeOptional.
  ///
  /// In zh, this message translates to:
  /// **'选填'**
  String get addPointsBadgeOptional;

  /// No description provided for @addPointsBadgeCoordinatesRequired.
  ///
  /// In zh, this message translates to:
  /// **'坐标必填'**
  String get addPointsBadgeCoordinatesRequired;

  /// No description provided for @addPointsPointGuideWorkBody.
  ///
  /// In zh, this message translates to:
  /// **'选择点位对应的作品。计划中还没有作品时，先填写作品名称、原名和主要地区。'**
  String get addPointsPointGuideWorkBody;

  /// No description provided for @addPointsGuideWorkExample.
  ///
  /// In zh, this message translates to:
  /// **'轻音少女'**
  String get addPointsGuideWorkExample;

  /// No description provided for @addPointsGuideNameLocationTitle.
  ///
  /// In zh, this message translates to:
  /// **'名称与位置说明'**
  String get addPointsGuideNameLocationTitle;

  /// No description provided for @addPointsGuideNameLocationBody.
  ///
  /// In zh, this message translates to:
  /// **'名称优先填写中文常用名；位置说明优先填写当地原语言的地标、建筑或店铺名称，方便现场核对。'**
  String get addPointsGuideNameLocationBody;

  /// No description provided for @addPointsGuideNameLocationExample.
  ///
  /// In zh, this message translates to:
  /// **'东京国际会展中心 / 東京ビッグサイト'**
  String get addPointsGuideNameLocationExample;

  /// No description provided for @addPointsGuideSceneSourceTitle.
  ///
  /// In zh, this message translates to:
  /// **'场景标签与参考来源'**
  String get addPointsGuideSceneSourceTitle;

  /// No description provided for @addPointsGuideSceneSourceBody.
  ///
  /// In zh, this message translates to:
  /// **'场景标签只写集数、时间点或场景编号；参考来源填写该点位原来所在的平台，或原始上传者。'**
  String get addPointsGuideSceneSourceBody;

  /// No description provided for @addPointsGuideSceneSourceExample.
  ///
  /// In zh, this message translates to:
  /// **'EP 1 / 12:32\n示例：小红书@BilyHurington / Bilibili@麦块晓天'**
  String get addPointsGuideSceneSourceExample;

  /// No description provided for @addPointsNotesLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get addPointsNotesLabel;

  /// No description provided for @addPointsGuideNotesBody.
  ///
  /// In zh, this message translates to:
  /// **'记录营业时间、闭店翻修、拍摄限制、推荐机位或其他到访前需要知道的信息。'**
  String get addPointsGuideNotesBody;

  /// No description provided for @addPointsGuideNotesExample.
  ///
  /// In zh, this message translates to:
  /// **'2025年完成翻修；最佳拍摄时间为上午；周末游客较多；'**
  String get addPointsGuideNotesExample;

  /// No description provided for @addPointsGuideCoordinateImageTitle.
  ///
  /// In zh, this message translates to:
  /// **'坐标与参考图'**
  String get addPointsGuideCoordinateImageTitle;

  /// No description provided for @addPointsGuideCoordinateImageBody.
  ///
  /// In zh, this message translates to:
  /// **'优先从地图选择准确位置，也可粘贴纬度、经度。参考图建议使用能清楚辨认构图的原始画面。'**
  String get addPointsGuideCoordinateImageBody;

  /// No description provided for @addPointsGuideCheckMarkerTip.
  ///
  /// In zh, this message translates to:
  /// **'保存前建议核对地图标记是否落在正确建筑或道路一侧；坐标偏差会直接影响导航和现场查找。'**
  String get addPointsGuideCheckMarkerTip;

  /// No description provided for @addPointsGuideGotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get addPointsGuideGotIt;

  /// No description provided for @addPointsWorkGuideTitle.
  ///
  /// In zh, this message translates to:
  /// **'作品填写指南'**
  String get addPointsWorkGuideTitle;

  /// No description provided for @addPointsWorkGuideIntro.
  ///
  /// In zh, this message translates to:
  /// **'填写作品本身的信息，点位名称、场景说明和具体地址请在添加点位时录入。'**
  String get addPointsWorkGuideIntro;

  /// No description provided for @addPointsWorkGuideNameBody.
  ///
  /// In zh, this message translates to:
  /// **'填写常用中文译名或最容易辨认的名称，不要填写集数或具体场景名。'**
  String get addPointsWorkGuideNameBody;

  /// No description provided for @addPointsWorkGuideOriginalTitleBody.
  ///
  /// In zh, this message translates to:
  /// **'可填写官方日文、英文或其他原始标题；没有可靠信息时可以留空。'**
  String get addPointsWorkGuideOriginalTitleBody;

  /// No description provided for @addPointsWorkGuideTypeBody.
  ///
  /// In zh, this message translates to:
  /// **'选择最接近作品发行形式的类型，方便在作品列表中辨认和筛选。'**
  String get addPointsWorkGuideTypeBody;

  /// No description provided for @addPointsGuideWorkTypeExample.
  ///
  /// In zh, this message translates to:
  /// **'动画'**
  String get addPointsGuideWorkTypeExample;

  /// No description provided for @addPointsWorkGuideRegionBody.
  ///
  /// In zh, this message translates to:
  /// **'填写主要发生地或取景城市，可使用“城市 / 区域”的简洁格式；留空时沿用当前计划地区。'**
  String get addPointsWorkGuideRegionBody;

  /// No description provided for @addPointsWorkGuideRegionExample.
  ///
  /// In zh, this message translates to:
  /// **'京都市 / 宇治市'**
  String get addPointsWorkGuideRegionExample;

  /// No description provided for @addPointsWorkGuideFooter.
  ///
  /// In zh, this message translates to:
  /// **'保存作品后，表单会清空以便继续添加。作品不会自动生成点位，可随后使用“手动添加点位”录入巡礼地点。'**
  String get addPointsWorkGuideFooter;

  /// No description provided for @addPointsGuideExample.
  ///
  /// In zh, this message translates to:
  /// **'示例：{example}'**
  String addPointsGuideExample(String example);

  /// No description provided for @addPointsLatitudeAlsoRequired.
  ///
  /// In zh, this message translates to:
  /// **'请同时填写纬度'**
  String get addPointsLatitudeAlsoRequired;

  /// No description provided for @addPointsLongitudeAlsoRequired.
  ///
  /// In zh, this message translates to:
  /// **'请同时填写经度'**
  String get addPointsLongitudeAlsoRequired;

  /// No description provided for @addPointsLatitudeInvalid.
  ///
  /// In zh, this message translates to:
  /// **'纬度格式不正确'**
  String get addPointsLatitudeInvalid;

  /// No description provided for @addPointsLongitudeInvalid.
  ///
  /// In zh, this message translates to:
  /// **'经度格式不正确'**
  String get addPointsLongitudeInvalid;

  /// No description provided for @addPointsQuickManualAddPoint.
  ///
  /// In zh, this message translates to:
  /// **'快速手动添加点位'**
  String get addPointsQuickManualAddPoint;

  /// No description provided for @addPointsSelectWorkRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择作品'**
  String get addPointsSelectWorkRequired;

  /// No description provided for @addPointsPointNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get addPointsPointNameLabel;

  /// No description provided for @addPointsPointNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：东京国际会展中心'**
  String get addPointsPointNameHint;

  /// No description provided for @addPointsCoordinateLabel.
  ///
  /// In zh, this message translates to:
  /// **'坐标位置'**
  String get addPointsCoordinateLabel;

  /// No description provided for @addPointsLatitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get addPointsLatitude;

  /// No description provided for @addPointsLongitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get addPointsLongitude;

  /// No description provided for @addPointsLatitudeHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：35.712576'**
  String get addPointsLatitudeHint;

  /// No description provided for @addPointsLongitudeHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：139.722166'**
  String get addPointsLongitudeHint;

  /// No description provided for @addPointsPickFromMap.
  ///
  /// In zh, this message translates to:
  /// **'从地图选择'**
  String get addPointsPickFromMap;

  /// No description provided for @addPointsPickFromMapShort.
  ///
  /// In zh, this message translates to:
  /// **'地图选择'**
  String get addPointsPickFromMapShort;

  /// No description provided for @addPointsPickFromMapSemantic.
  ///
  /// In zh, this message translates to:
  /// **'从地图选择坐标'**
  String get addPointsPickFromMapSemantic;

  /// No description provided for @addPointsPasteCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'粘贴剪贴板坐标'**
  String get addPointsPasteCoordinates;

  /// No description provided for @addPointsSavePoint.
  ///
  /// In zh, this message translates to:
  /// **'保存点位'**
  String get addPointsSavePoint;

  /// No description provided for @addPointsQuickGuideTitle.
  ///
  /// In zh, this message translates to:
  /// **'快速添加填写指南'**
  String get addPointsQuickGuideTitle;

  /// No description provided for @addPointsQuickGuideIntro.
  ///
  /// In zh, this message translates to:
  /// **'先录入最基本的信息，之后可从点位编辑页继续补充位置说明、场景标签、参考来源、备注和参考图。'**
  String get addPointsQuickGuideIntro;

  /// No description provided for @addPointsQuickGuideWorkBody.
  ///
  /// In zh, this message translates to:
  /// **'选择点位对应的已有作品。若列表中没有目标作品，请先返回添加内容页添加作品。'**
  String get addPointsQuickGuideWorkBody;

  /// No description provided for @addPointsQuickGuideNameBody.
  ///
  /// In zh, this message translates to:
  /// **'填写便于识别和搜索的中文常用名称，后续可在编辑页修改。'**
  String get addPointsQuickGuideNameBody;

  /// No description provided for @addPointsGuidePointNameExample.
  ///
  /// In zh, this message translates to:
  /// **'东京国际会展中心'**
  String get addPointsGuidePointNameExample;

  /// No description provided for @addPointsQuickGuideCoordinateBody.
  ///
  /// In zh, this message translates to:
  /// **'暂时不知道准确位置时可以留空；填写时需同时提供纬度和经度，也可从地图选择或粘贴坐标。'**
  String get addPointsQuickGuideCoordinateBody;

  /// No description provided for @addPointsSaveUnconfirmed.
  ///
  /// In zh, this message translates to:
  /// **'保存结果未确认，请返回并刷新计划，检查点位是否已添加。'**
  String get addPointsSaveUnconfirmed;

  /// No description provided for @addPointsReferenceImageReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'参考图读取失败，请重新选择。'**
  String get addPointsReferenceImageReadFailed;

  /// No description provided for @addPointsEditPoint.
  ///
  /// In zh, this message translates to:
  /// **'编辑点位'**
  String get addPointsEditPoint;

  /// No description provided for @addPointsManualAddPoint.
  ///
  /// In zh, this message translates to:
  /// **'手动添加点位'**
  String get addPointsManualAddPoint;

  /// No description provided for @addPointsEditing.
  ///
  /// In zh, this message translates to:
  /// **'修改：{name}'**
  String addPointsEditing(String name);

  /// No description provided for @addPointsLocationNoteLabel.
  ///
  /// In zh, this message translates to:
  /// **'位置说明'**
  String get addPointsLocationNoteLabel;

  /// No description provided for @addPointsLocationNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：東京ビッグサイト'**
  String get addPointsLocationNoteHint;

  /// No description provided for @addPointsSceneTagLabel.
  ///
  /// In zh, this message translates to:
  /// **'集数/场景标签'**
  String get addPointsSceneTagLabel;

  /// No description provided for @addPointsSceneTagHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：EP 1 / 12:32'**
  String get addPointsSceneTagHint;

  /// No description provided for @addPointsReferenceSourceLabel.
  ///
  /// In zh, this message translates to:
  /// **'参考来源'**
  String get addPointsReferenceSourceLabel;

  /// No description provided for @addPointsReferenceSourceHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：小红书@BilyHurington / Bilibili@麦块晓天'**
  String get addPointsReferenceSourceHint;

  /// No description provided for @addPointsNotesHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：2025年完成翻修；最佳拍摄时间为上午；周末游客较多'**
  String get addPointsNotesHint;

  /// No description provided for @addPointsSaveChanges.
  ///
  /// In zh, this message translates to:
  /// **'保存修改'**
  String get addPointsSaveChanges;

  /// No description provided for @addPointsLatitudeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写纬度'**
  String get addPointsLatitudeRequired;

  /// No description provided for @addPointsLongitudeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写经度'**
  String get addPointsLongitudeRequired;

  /// No description provided for @addPointsCoordinateInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效坐标'**
  String get addPointsCoordinateInvalid;

  /// No description provided for @addPointsPickCoordinateTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择点位坐标'**
  String get addPointsPickCoordinateTitle;

  /// No description provided for @addPointsExitMapPick.
  ///
  /// In zh, this message translates to:
  /// **'关闭地图选点'**
  String get addPointsExitMapPick;

  /// No description provided for @addPointsStartMapPick.
  ///
  /// In zh, this message translates to:
  /// **'在地图上选点'**
  String get addPointsStartMapPick;

  /// No description provided for @addPointsMapPickHint.
  ///
  /// In zh, this message translates to:
  /// **'点击地图任意位置设置点位坐标'**
  String get addPointsMapPickHint;

  /// No description provided for @addPointsMapPickIdleHint.
  ///
  /// In zh, this message translates to:
  /// **'先点击右上角选点按钮，再点击地图设置坐标'**
  String get addPointsMapPickIdleHint;

  /// No description provided for @addPointsMapAdjustHint.
  ///
  /// In zh, this message translates to:
  /// **'点击地图可继续调整位置\n{coordinates}'**
  String addPointsMapAdjustHint(String coordinates);

  /// No description provided for @addPointsMapPickTitle.
  ///
  /// In zh, this message translates to:
  /// **'地图选点'**
  String get addPointsMapPickTitle;

  /// No description provided for @addPointsUse.
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get addPointsUse;

  /// No description provided for @addPointsLinkedWorks.
  ///
  /// In zh, this message translates to:
  /// **'已关联作品'**
  String get addPointsLinkedWorks;

  /// No description provided for @addPointsLinkedWorksSummary.
  ///
  /// In zh, this message translates to:
  /// **'共 {workCount} 部作品，{pointCount} 个点位'**
  String addPointsLinkedWorksSummary(int workCount, int pointCount);

  /// No description provided for @addPointsManageWorks.
  ///
  /// In zh, this message translates to:
  /// **'管理作品'**
  String get addPointsManageWorks;

  /// No description provided for @addPointsNoLinkedWorks.
  ///
  /// In zh, this message translates to:
  /// **'还没有关联作品，可从 Bangumi 搜索或手动添加。'**
  String get addPointsNoLinkedWorks;

  /// No description provided for @addPointsAddFromBangumi.
  ///
  /// In zh, this message translates to:
  /// **'从Bangumi添加'**
  String get addPointsAddFromBangumi;

  /// No description provided for @addPointsAddFromBangumiSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'自动获取信息'**
  String get addPointsAddFromBangumiSubtitle;

  /// No description provided for @addPointsManualAddWorkSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'未收录时使用'**
  String get addPointsManualAddWorkSubtitle;

  /// No description provided for @addPointsViewFullImage.
  ///
  /// In zh, this message translates to:
  /// **'查看大图'**
  String get addPointsViewFullImage;

  /// No description provided for @addPointsNoReferenceImage.
  ///
  /// In zh, this message translates to:
  /// **'暂无参考图'**
  String get addPointsNoReferenceImage;

  /// No description provided for @addPointsReferenceImageLabel.
  ///
  /// In zh, this message translates to:
  /// **'参考图片'**
  String get addPointsReferenceImageLabel;

  /// No description provided for @addPointsReferenceImagePending.
  ///
  /// In zh, this message translates to:
  /// **'已选择新图片，保存后生效。'**
  String get addPointsReferenceImagePending;

  /// No description provided for @addPointsReferenceImageCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前参考图，重新选择后需保存才会生效。'**
  String get addPointsReferenceImageCurrent;

  /// No description provided for @addPointsReferenceImageOptional.
  ///
  /// In zh, this message translates to:
  /// **'可选，保存时会复制到 App 本地目录。'**
  String get addPointsReferenceImageOptional;

  /// No description provided for @addPointsReselectImage.
  ///
  /// In zh, this message translates to:
  /// **'重新选择'**
  String get addPointsReselectImage;

  /// No description provided for @addPointsUploadReferenceImage.
  ///
  /// In zh, this message translates to:
  /// **'上传参考图'**
  String get addPointsUploadReferenceImage;

  /// No description provided for @addPointsRemoveImage.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get addPointsRemoveImage;

  /// No description provided for @addPointsAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加'**
  String get addPointsAdded;

  /// No description provided for @addPointsAdd.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get addPointsAdd;

  /// No description provided for @addPointsSearchHelpTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索说明'**
  String get addPointsSearchHelpTitle;

  /// No description provided for @addPointsSearchHelpBody.
  ///
  /// In zh, this message translates to:
  /// **'输入作品名后搜索，选择结果即可加入当前计划。'**
  String get addPointsSearchHelpBody;

  /// No description provided for @addPointsBangumiNetworkNote.
  ///
  /// In zh, this message translates to:
  /// **'Bangumi需要国际网络环境才能正常搜索。'**
  String get addPointsBangumiNetworkNote;

  /// No description provided for @addPointsRecommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get addPointsRecommended;

  /// No description provided for @addPointsQuickManualSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'只填写作品、名称和可选坐标'**
  String get addPointsQuickManualSubtitle;

  /// No description provided for @addPointsAddWorkFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先添加作品'**
  String get addPointsAddWorkFirst;

  /// No description provided for @addPointsManualAddPointSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手动输入点位信息，逐个添加'**
  String get addPointsManualAddPointSubtitle;

  /// No description provided for @groupAnchorPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择关键点'**
  String get groupAnchorPickerTitle;

  /// No description provided for @groupAnchorPickerExitMapPick.
  ///
  /// In zh, this message translates to:
  /// **'关闭地图点选'**
  String get groupAnchorPickerExitMapPick;

  /// No description provided for @groupAnchorPickerStartMapPick.
  ///
  /// In zh, this message translates to:
  /// **'在地图上选点'**
  String get groupAnchorPickerStartMapPick;

  /// No description provided for @groupAnchorPickerEnterCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'输入经纬度'**
  String get groupAnchorPickerEnterCoordinates;

  /// No description provided for @groupAnchorPickerClearSelection.
  ///
  /// In zh, this message translates to:
  /// **'清除选点'**
  String get groupAnchorPickerClearSelection;

  /// No description provided for @groupAnchorPickerClearMessage.
  ///
  /// In zh, this message translates to:
  /// **'将清除当前选择的关键点，可继续在本页重新选择。'**
  String get groupAnchorPickerClearMessage;

  /// No description provided for @groupAnchorPickerManualAnchor.
  ///
  /// In zh, this message translates to:
  /// **'手动关键点'**
  String get groupAnchorPickerManualAnchor;

  /// No description provided for @groupAnchorPickerSelectPoint.
  ///
  /// In zh, this message translates to:
  /// **'选择点位'**
  String get groupAnchorPickerSelectPoint;

  /// No description provided for @groupAnchorPickerNoneSelected.
  ///
  /// In zh, this message translates to:
  /// **'尚未选择关键点'**
  String get groupAnchorPickerNoneSelected;

  /// No description provided for @groupAnchorPickerMapPickHint.
  ///
  /// In zh, this message translates to:
  /// **'点击地图任意位置设置关键点'**
  String get groupAnchorPickerMapPickHint;

  /// No description provided for @groupAnchorPickerIdleHint.
  ///
  /// In zh, this message translates to:
  /// **'可点选点位、地图或输入经纬度'**
  String get groupAnchorPickerIdleHint;

  /// No description provided for @pointManagerSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count}'**
  String pointManagerSelectedCount(int count);

  /// No description provided for @pointManagerGroupManagement.
  ///
  /// In zh, this message translates to:
  /// **'片区管理'**
  String get pointManagerGroupManagement;

  /// No description provided for @pointManagerMoveGroupFailed.
  ///
  /// In zh, this message translates to:
  /// **'移动片区失败'**
  String get pointManagerMoveGroupFailed;

  /// No description provided for @pointManagerMoveToGroup.
  ///
  /// In zh, this message translates to:
  /// **'移动到片区'**
  String get pointManagerMoveToGroup;

  /// No description provided for @pointManagerMoveToGroupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择一个片区作为当前点位所属片区'**
  String get pointManagerMoveToGroupSubtitle;

  /// No description provided for @pointManagerNotInGroup.
  ///
  /// In zh, this message translates to:
  /// **'未分入片区'**
  String get pointManagerNotInGroup;

  /// No description provided for @pointManagerPointOrderSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位顺序保存失败'**
  String get pointManagerPointOrderSaveFailed;

  /// No description provided for @pointManagerBatchDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'批量删除点位'**
  String get pointManagerBatchDeleteTitle;

  /// No description provided for @pointManagerBatchDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'将从计划中删除 {countText}。'**
  String pointManagerBatchDeleteMessage(String countText);

  /// No description provided for @pointManagerSpotCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位'**
  String pointManagerSpotCount(int count);

  /// No description provided for @pointManagerBatchDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量删除失败'**
  String get pointManagerBatchDeleteFailed;

  /// No description provided for @pointManagerNearestAssign.
  ///
  /// In zh, this message translates to:
  /// **'最近分配'**
  String get pointManagerNearestAssign;

  /// No description provided for @pointManagerBoxAssign.
  ///
  /// In zh, this message translates to:
  /// **'框选分配'**
  String get pointManagerBoxAssign;

  /// No description provided for @pointManagerSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get pointManagerSelectAll;

  /// No description provided for @pointManagerMove.
  ///
  /// In zh, this message translates to:
  /// **'移动'**
  String get pointManagerMove;

  /// No description provided for @coordinateInputClipboardReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法读取剪贴板。'**
  String get coordinateInputClipboardReadFailed;

  /// No description provided for @coordinateInputClipboardNoCoordinate.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中没有可识别的坐标。'**
  String get coordinateInputClipboardNoCoordinate;

  /// No description provided for @coordinateInputInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效经纬度'**
  String get coordinateInputInvalid;

  /// No description provided for @coordinateInputTitle.
  ///
  /// In zh, this message translates to:
  /// **'输入经纬度'**
  String get coordinateInputTitle;

  /// No description provided for @coordinateInputLatitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get coordinateInputLatitude;

  /// No description provided for @coordinateInputLongitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get coordinateInputLongitude;

  /// No description provided for @coordinateInputConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get coordinateInputConfirm;

  /// No description provided for @planGroupUtilsOrderPending.
  ///
  /// In zh, this message translates to:
  /// **'待整理'**
  String get planGroupUtilsOrderPending;

  /// No description provided for @planGroupUtilsOrderManual.
  ///
  /// In zh, this message translates to:
  /// **'手动'**
  String get planGroupUtilsOrderManual;

  /// No description provided for @planGroupUtilsOrderUnordered.
  ///
  /// In zh, this message translates to:
  /// **'无序'**
  String get planGroupUtilsOrderUnordered;

  /// No description provided for @planGroupUtilsAwaitingGroup.
  ///
  /// In zh, this message translates to:
  /// **'等待分入片区'**
  String get planGroupUtilsAwaitingGroup;

  /// No description provided for @planGroupUtilsAnchorUnset.
  ///
  /// In zh, this message translates to:
  /// **'未设置关键点'**
  String get planGroupUtilsAnchorUnset;

  /// No description provided for @planGroupUtilsAnchor.
  ///
  /// In zh, this message translates to:
  /// **'关键点：{name}'**
  String planGroupUtilsAnchor(String name);

  /// No description provided for @planGroupUtilsUngrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get planGroupUtilsUngrouped;

  /// No description provided for @planGroupPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择区域'**
  String get planGroupPickerTitle;

  /// No description provided for @planGroupPickerCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个区域'**
  String planGroupPickerCount(int count);

  /// No description provided for @planGroupPickerNewGroup.
  ///
  /// In zh, this message translates to:
  /// **'新建片区'**
  String get planGroupPickerNewGroup;

  /// No description provided for @planManagerSwitchFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换计划失败，请稍后重试。'**
  String get planManagerSwitchFailed;

  /// No description provided for @planManagerAreaNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置区域'**
  String get planManagerAreaNotSet;

  /// No description provided for @planManagerDeletePlan.
  ///
  /// In zh, this message translates to:
  /// **'删除计划'**
  String get planManagerDeletePlan;

  /// No description provided for @planManagerCopyFailed.
  ///
  /// In zh, this message translates to:
  /// **'复制计划失败，请稍后重试。'**
  String get planManagerCopyFailed;

  /// No description provided for @planManagerSaveOrderFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存计划顺序失败，已恢复原来的顺序。'**
  String get planManagerSaveOrderFailed;

  /// No description provided for @planManagerReorderTitle.
  ///
  /// In zh, this message translates to:
  /// **'调整计划顺序'**
  String get planManagerReorderTitle;

  /// No description provided for @planManagerTitle.
  ///
  /// In zh, this message translates to:
  /// **'计划列表'**
  String get planManagerTitle;

  /// No description provided for @planManagerDoneSorting.
  ///
  /// In zh, this message translates to:
  /// **'完成排序'**
  String get planManagerDoneSorting;

  /// No description provided for @planManagerSortPlans.
  ///
  /// In zh, this message translates to:
  /// **'计划排序'**
  String get planManagerSortPlans;

  /// No description provided for @planManagerSkillLead.
  ///
  /// In zh, this message translates to:
  /// **'不想手动整理点位？'**
  String get planManagerSkillLead;

  /// No description provided for @planManagerAllPlans.
  ///
  /// In zh, this message translates to:
  /// **'全部计划'**
  String get planManagerAllPlans;

  /// No description provided for @planManagerEditInfo.
  ///
  /// In zh, this message translates to:
  /// **'编辑计划信息'**
  String get planManagerEditInfo;

  /// No description provided for @planManagerPlanName.
  ///
  /// In zh, this message translates to:
  /// **'计划名称'**
  String get planManagerPlanName;

  /// No description provided for @planManagerAreaLabel.
  ///
  /// In zh, this message translates to:
  /// **'地区 / 区域'**
  String get planManagerAreaLabel;

  /// No description provided for @planManagerNewPlan.
  ///
  /// In zh, this message translates to:
  /// **'新建计划'**
  String get planManagerNewPlan;

  /// No description provided for @planManagerPlanInfo.
  ///
  /// In zh, this message translates to:
  /// **'计划信息'**
  String get planManagerPlanInfo;

  /// No description provided for @planManagerNoWorks.
  ///
  /// In zh, this message translates to:
  /// **'暂无作品'**
  String get planManagerNoWorks;

  /// No description provided for @planManagerCurrentPlan.
  ///
  /// In zh, this message translates to:
  /// **'当前计划'**
  String get planManagerCurrentPlan;

  /// No description provided for @planManagerDragSort.
  ///
  /// In zh, this message translates to:
  /// **'拖动排序'**
  String get planManagerDragSort;

  /// No description provided for @planManagerMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多计划操作'**
  String get planManagerMoreActions;

  /// No description provided for @planManagerImportExport.
  ///
  /// In zh, this message translates to:
  /// **'导入导出'**
  String get planManagerImportExport;

  /// No description provided for @planManagerCopyPlan.
  ///
  /// In zh, this message translates to:
  /// **'复制计划'**
  String get planManagerCopyPlan;

  /// No description provided for @planManagerReload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载计划'**
  String get planManagerReload;

  /// No description provided for @planManagerNewPlanName.
  ///
  /// In zh, this message translates to:
  /// **'新巡礼计划 {number}'**
  String planManagerNewPlanName(int number);

  /// No description provided for @planManagerDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除「{name}」及其中的点位、片区、作品和巡礼记录。只属于这个计划的巡礼照片、调色图和参考图文件也会一并删除；其他计划或记录仍在使用的文件会保留。'**
  String planManagerDeleteMessage(String name);

  /// No description provided for @planManagerCopyName.
  ///
  /// In zh, this message translates to:
  /// **'{name} 副本'**
  String planManagerCopyName(String name);

  /// No description provided for @planManagerCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制「{name}」'**
  String planManagerCopied(String name);

  /// No description provided for @planManagerPlanSummary.
  ///
  /// In zh, this message translates to:
  /// **'{area}  /  {spotCount} 个点位  /  {workCount} 部作品'**
  String planManagerPlanSummary(String area, int spotCount, int workCount);

  /// No description provided for @planManagerPlanCopyText.
  ///
  /// In zh, this message translates to:
  /// **'{name}\n{area}\n{spotCount} 个点位\n{workCount} 部作品'**
  String planManagerPlanCopyText(
    String name,
    String area,
    int spotCount,
    int workCount,
  );

  /// No description provided for @planMemoUnsavedChanges.
  ///
  /// In zh, this message translates to:
  /// **'未保存的修改'**
  String get planMemoUnsavedChanges;

  /// No description provided for @planMemoImageUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'备忘录不支持图片：{label}'**
  String planMemoImageUnsupported(String label);

  /// No description provided for @planMemoDiscardTitle.
  ///
  /// In zh, this message translates to:
  /// **'放弃未保存内容？'**
  String get planMemoDiscardTitle;

  /// No description provided for @planMemoDiscardMessage.
  ///
  /// In zh, this message translates to:
  /// **'当前备忘录还有未保存的修改。'**
  String get planMemoDiscardMessage;

  /// No description provided for @planMemoDiscard.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get planMemoDiscard;

  /// No description provided for @planMemoKeepEditing.
  ///
  /// In zh, this message translates to:
  /// **'继续编辑'**
  String get planMemoKeepEditing;

  /// No description provided for @planMemoDiscardNotice.
  ///
  /// In zh, this message translates to:
  /// **'未保存的修改不会被保留'**
  String get planMemoDiscardNotice;

  /// No description provided for @planMemoSavingWait.
  ///
  /// In zh, this message translates to:
  /// **'正在保存备忘录，请稍候'**
  String get planMemoSavingWait;

  /// No description provided for @planMemoSavedEditsPending.
  ///
  /// In zh, this message translates to:
  /// **'已保存，后续输入仍待保存'**
  String get planMemoSavedEditsPending;

  /// No description provided for @planMemoSaved.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录已保存'**
  String get planMemoSaved;

  /// No description provided for @planMemoSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录保存失败'**
  String get planMemoSaveFailed;

  /// No description provided for @planMemoTaskSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'待办状态保存失败'**
  String get planMemoTaskSaveFailed;

  /// No description provided for @planMemoHeading.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get planMemoHeading;

  /// No description provided for @planMemoBoldPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'加粗文字'**
  String get planMemoBoldPlaceholder;

  /// No description provided for @planMemoListPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'列表项'**
  String get planMemoListPlaceholder;

  /// No description provided for @planMemoTaskPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'待办事项'**
  String get planMemoTaskPlaceholder;

  /// No description provided for @planMemoQuotePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'引用内容'**
  String get planMemoQuotePlaceholder;

  /// No description provided for @planMemoLinkPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'链接文字'**
  String get planMemoLinkPlaceholder;

  /// No description provided for @planMemoCode.
  ///
  /// In zh, this message translates to:
  /// **'代码'**
  String get planMemoCode;

  /// No description provided for @planMemoInvalidLink.
  ///
  /// In zh, this message translates to:
  /// **'链接格式不正确'**
  String get planMemoInvalidLink;

  /// No description provided for @planMemoOpenLinkFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接'**
  String get planMemoOpenLinkFailed;

  /// No description provided for @planMemoTitle.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录'**
  String get planMemoTitle;

  /// No description provided for @planMemoEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get planMemoEdit;

  /// No description provided for @planMemoContent.
  ///
  /// In zh, this message translates to:
  /// **'备忘录内容'**
  String get planMemoContent;

  /// No description provided for @planMemoHint.
  ///
  /// In zh, this message translates to:
  /// **'可以记录交通、预约、补拍事项、同行安排等。'**
  String get planMemoHint;

  /// No description provided for @planMemoBold.
  ///
  /// In zh, this message translates to:
  /// **'加粗'**
  String get planMemoBold;

  /// No description provided for @planMemoList.
  ///
  /// In zh, this message translates to:
  /// **'列表'**
  String get planMemoList;

  /// No description provided for @planMemoTask.
  ///
  /// In zh, this message translates to:
  /// **'待办'**
  String get planMemoTask;

  /// No description provided for @planMemoQuote.
  ///
  /// In zh, this message translates to:
  /// **'引用'**
  String get planMemoQuote;

  /// No description provided for @planMemoDivider.
  ///
  /// In zh, this message translates to:
  /// **'分割线'**
  String get planMemoDivider;

  /// No description provided for @planMemoLink.
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get planMemoLink;

  /// No description provided for @planMemoUncheck.
  ///
  /// In zh, this message translates to:
  /// **'取消勾选'**
  String get planMemoUncheck;

  /// No description provided for @planMemoMarkDone.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get planMemoMarkDone;

  /// No description provided for @planMemoSuggestTransport.
  ///
  /// In zh, this message translates to:
  /// **'交通安排'**
  String get planMemoSuggestTransport;

  /// No description provided for @planMemoSuggestTransportDetail.
  ///
  /// In zh, this message translates to:
  /// **'如车次、换乘方案、出发时间等'**
  String get planMemoSuggestTransportDetail;

  /// No description provided for @planMemoSuggestHotel.
  ///
  /// In zh, this message translates to:
  /// **'酒店预约'**
  String get planMemoSuggestHotel;

  /// No description provided for @planMemoSuggestHotelDetail.
  ///
  /// In zh, this message translates to:
  /// **'酒店地址、入住时间、联系方式等'**
  String get planMemoSuggestHotelDetail;

  /// No description provided for @planMemoSuggestTickets.
  ///
  /// In zh, this message translates to:
  /// **'活动门票'**
  String get planMemoSuggestTickets;

  /// No description provided for @planMemoSuggestTicketsDetail.
  ///
  /// In zh, this message translates to:
  /// **'活动门票、预约时间、注意事项等'**
  String get planMemoSuggestTicketsDetail;

  /// No description provided for @planMemoSuggestShooting.
  ///
  /// In zh, this message translates to:
  /// **'拍摄计划'**
  String get planMemoSuggestShooting;

  /// No description provided for @planMemoSuggestShootingDetail.
  ///
  /// In zh, this message translates to:
  /// **'拍摄地点、时间、天气备选方案等'**
  String get planMemoSuggestShootingDetail;

  /// No description provided for @planMemoSuggestNotes.
  ///
  /// In zh, this message translates to:
  /// **'注意事项'**
  String get planMemoSuggestNotes;

  /// No description provided for @planMemoSuggestNotesDetail.
  ///
  /// In zh, this message translates to:
  /// **'携带物品、预算、当地注意事项等'**
  String get planMemoSuggestNotesDetail;

  /// No description provided for @planMemoEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有计划备忘'**
  String get planMemoEmptyTitle;

  /// No description provided for @planMemoEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'记录本次巡礼的重要事项'**
  String get planMemoEmptyBody;

  /// No description provided for @planMemoSuggestionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'可记录内容'**
  String get planMemoSuggestionsTitle;

  /// No description provided for @planMemoStart.
  ///
  /// In zh, this message translates to:
  /// **'开始记录'**
  String get planMemoStart;

  /// No description provided for @nearestGroupAssignUngroupedSpots.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个未分组点位'**
  String nearestGroupAssignUngroupedSpots(int count);

  /// No description provided for @nearestGroupAssignConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'将把 {spots}分配到最近的片区关键点，最大距离为 {distance}。'**
  String nearestGroupAssignConfirmMessage(String spots, String distance);

  /// No description provided for @nearestGroupAssignDone.
  ///
  /// In zh, this message translates to:
  /// **'已分配 {count} 个点位'**
  String nearestGroupAssignDone(int count);

  /// No description provided for @nearestGroupAssignDoneDistanceUnsaved.
  ///
  /// In zh, this message translates to:
  /// **'已分配 {count} 个点位，距离设置未保存'**
  String nearestGroupAssignDoneDistanceUnsaved(int count);

  /// No description provided for @nearestGroupAssignBoxConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'将把 {spots}移动到「{area}」。'**
  String nearestGroupAssignBoxConfirmMessage(String spots, String area);

  /// No description provided for @nearestGroupAssignAreaCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个片区'**
  String nearestGroupAssignAreaCount(int count);

  /// No description provided for @nearestGroupAssignBoxStatus.
  ///
  /// In zh, this message translates to:
  /// **'已框选 {selected} / 待分配 {ungrouped}'**
  String nearestGroupAssignBoxStatus(int selected, int ungrouped);

  /// No description provided for @nearestGroupAssignMaxDistance.
  ///
  /// In zh, this message translates to:
  /// **'最大距离 {distance}'**
  String nearestGroupAssignMaxDistance(String distance);

  /// No description provided for @nearestGroupAssignAssignableCount.
  ///
  /// In zh, this message translates to:
  /// **'可分配 {assignable}/{ungrouped}'**
  String nearestGroupAssignAssignableCount(int assignable, int ungrouped);

  /// No description provided for @nearestGroupAssignCurrentDistance.
  ///
  /// In zh, this message translates to:
  /// **'当前 {distance}'**
  String nearestGroupAssignCurrentDistance(String distance);

  /// No description provided for @nearestGroupAssignInRange.
  ///
  /// In zh, this message translates to:
  /// **'在最大距离范围内'**
  String get nearestGroupAssignInRange;

  /// No description provided for @nearestGroupAssignOutOfRange.
  ///
  /// In zh, this message translates to:
  /// **'超出最大距离'**
  String get nearestGroupAssignOutOfRange;

  /// No description provided for @nearestGroupAssignUngroupedHint.
  ///
  /// In zh, this message translates to:
  /// **'未分组 {count} 个 · 点击地图点位查看详情'**
  String nearestGroupAssignUngroupedHint(int count);

  /// No description provided for @nearestGroupAssignTitle.
  ///
  /// In zh, this message translates to:
  /// **'最近分配'**
  String get nearestGroupAssignTitle;

  /// No description provided for @nearestGroupAssignNoneInRange.
  ///
  /// In zh, this message translates to:
  /// **'当前距离内没有可分配点位'**
  String get nearestGroupAssignNoneInRange;

  /// No description provided for @nearestGroupAssignConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认最近分配'**
  String get nearestGroupAssignConfirmTitle;

  /// No description provided for @nearestGroupAssignStart.
  ///
  /// In zh, this message translates to:
  /// **'开始分配'**
  String get nearestGroupAssignStart;

  /// No description provided for @nearestGroupAssignFailed.
  ///
  /// In zh, this message translates to:
  /// **'最近分配失败'**
  String get nearestGroupAssignFailed;

  /// No description provided for @nearestGroupAssignFinishFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先完成片区分配'**
  String get nearestGroupAssignFinishFirst;

  /// No description provided for @nearestGroupAssignBoxTitle.
  ///
  /// In zh, this message translates to:
  /// **'框选分配'**
  String get nearestGroupAssignBoxTitle;

  /// No description provided for @nearestGroupAssignBoxSelected.
  ///
  /// In zh, this message translates to:
  /// **'已框选'**
  String get nearestGroupAssignBoxSelected;

  /// No description provided for @nearestGroupAssignNotBoxSelected.
  ///
  /// In zh, this message translates to:
  /// **'未框选'**
  String get nearestGroupAssignNotBoxSelected;

  /// No description provided for @nearestGroupAssignCreateAreaFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区创建失败'**
  String get nearestGroupAssignCreateAreaFailed;

  /// No description provided for @nearestGroupAssignCreateAreaFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先创建片区'**
  String get nearestGroupAssignCreateAreaFirst;

  /// No description provided for @nearestGroupAssignBoxNoUngrouped.
  ///
  /// In zh, this message translates to:
  /// **'框选范围内没有未分组点位'**
  String get nearestGroupAssignBoxNoUngrouped;

  /// No description provided for @nearestGroupAssignBoxConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认框选分配'**
  String get nearestGroupAssignBoxConfirmTitle;

  /// No description provided for @nearestGroupAssignAssign.
  ///
  /// In zh, this message translates to:
  /// **'分配'**
  String get nearestGroupAssignAssign;

  /// No description provided for @nearestGroupAssignBoxFailed.
  ///
  /// In zh, this message translates to:
  /// **'框选分配失败'**
  String get nearestGroupAssignBoxFailed;

  /// No description provided for @nearestGroupAssignChooseArea.
  ///
  /// In zh, this message translates to:
  /// **'选择片区'**
  String get nearestGroupAssignChooseArea;

  /// No description provided for @nearestGroupAssignNewArea.
  ///
  /// In zh, this message translates to:
  /// **'新建片区'**
  String get nearestGroupAssignNewArea;

  /// No description provided for @nearestGroupAssignAreaNameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'片区名不能为空'**
  String get nearestGroupAssignAreaNameEmpty;

  /// No description provided for @nearestGroupAssignAreaName.
  ///
  /// In zh, this message translates to:
  /// **'片区名称'**
  String get nearestGroupAssignAreaName;

  /// No description provided for @nearestGroupAssignCreate.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get nearestGroupAssignCreate;

  /// No description provided for @nearestGroupAssignEndBox.
  ///
  /// In zh, this message translates to:
  /// **'结束框选'**
  String get nearestGroupAssignEndBox;

  /// No description provided for @nearestGroupAssignBox.
  ///
  /// In zh, this message translates to:
  /// **'框选'**
  String get nearestGroupAssignBox;

  /// No description provided for @nearestGroupAssignEnd.
  ///
  /// In zh, this message translates to:
  /// **'结束'**
  String get nearestGroupAssignEnd;

  /// No description provided for @nearestGroupAssignStartBox.
  ///
  /// In zh, this message translates to:
  /// **'开始框选'**
  String get nearestGroupAssignStartBox;

  /// No description provided for @nearestGroupAssignAssigning.
  ///
  /// In zh, this message translates to:
  /// **'分配中'**
  String get nearestGroupAssignAssigning;

  /// No description provided for @nearestGroupAssignAssigningSpots.
  ///
  /// In zh, this message translates to:
  /// **'正在分配'**
  String get nearestGroupAssignAssigningSpots;

  /// No description provided for @nearestGroupAssignAssignSelected.
  ///
  /// In zh, this message translates to:
  /// **'分配选中点位'**
  String get nearestGroupAssignAssignSelected;

  /// No description provided for @nearestGroupAssignExplain.
  ///
  /// In zh, this message translates to:
  /// **'未分组点位会分配到距离最近、且在最大距离范围内的片区关键点。'**
  String get nearestGroupAssignExplain;

  /// No description provided for @nearestGroupAssignNoAnchor.
  ///
  /// In zh, this message translates to:
  /// **'没有可用片区关键点'**
  String get nearestGroupAssignNoAnchor;

  /// No description provided for @nearestGroupAssignSetAnchorFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先在片区管理中设置关键点'**
  String get nearestGroupAssignSetAnchorFirst;

  /// No description provided for @nearestGroupAssignAssignableSpot.
  ///
  /// In zh, this message translates to:
  /// **'可分配点位'**
  String get nearestGroupAssignAssignableSpot;

  /// No description provided for @nearestGroupAssignOutOfRangeSpot.
  ///
  /// In zh, this message translates to:
  /// **'距离外点位'**
  String get nearestGroupAssignOutOfRangeSpot;

  /// No description provided for @planCacheFullImageCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张'**
  String planCacheFullImageCount(int count);

  /// No description provided for @planCacheFullReferencesMessage.
  ///
  /// In zh, this message translates to:
  /// **'将缓存当前计划中 {images}完整参考图，可能需要较长时间和网络流量。'**
  String planCacheFullReferencesMessage(String images);

  /// No description provided for @planAreaProgress.
  ///
  /// In zh, this message translates to:
  /// **'{anchor} · {completed}/{total} 完成 · {order}'**
  String planAreaProgress(
    String anchor,
    int completed,
    int total,
    String order,
  );

  /// No description provided for @planSummary.
  ///
  /// In zh, this message translates to:
  /// **'{area} / {spotCount} 个点位 / {works}'**
  String planSummary(String area, int spotCount, String works);

  /// No description provided for @planWorkCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 部作品'**
  String planWorkCount(int count);

  /// No description provided for @planAddSpots.
  ///
  /// In zh, this message translates to:
  /// **'添加点位'**
  String get planAddSpots;

  /// No description provided for @planHideActions.
  ///
  /// In zh, this message translates to:
  /// **'收起计划操作'**
  String get planHideActions;

  /// No description provided for @planShowActions.
  ///
  /// In zh, this message translates to:
  /// **'展开计划操作'**
  String get planShowActions;

  /// No description provided for @planCreateAreaFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区创建失败，请稍后重试。'**
  String get planCreateAreaFailed;

  /// No description provided for @planNoReferencesToCache.
  ///
  /// In zh, this message translates to:
  /// **'当前计划没有需要缓存的参考图'**
  String get planNoReferencesToCache;

  /// No description provided for @planCacheFullReferencesTitle.
  ///
  /// In zh, this message translates to:
  /// **'缓存完整参考图'**
  String get planCacheFullReferencesTitle;

  /// No description provided for @planStartCaching.
  ///
  /// In zh, this message translates to:
  /// **'开始缓存'**
  String get planStartCaching;

  /// No description provided for @planCacheWifiNotice.
  ///
  /// In zh, this message translates to:
  /// **'建议在 Wi-Fi 环境下进行缓存'**
  String get planCacheWifiNotice;

  /// No description provided for @planNewArea.
  ///
  /// In zh, this message translates to:
  /// **'新建片区'**
  String get planNewArea;

  /// No description provided for @planAreaName.
  ///
  /// In zh, this message translates to:
  /// **'片区名称'**
  String get planAreaName;

  /// No description provided for @planCreate.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get planCreate;

  /// No description provided for @planSwitchPlan.
  ///
  /// In zh, this message translates to:
  /// **'计划列表'**
  String get planSwitchPlan;

  /// No description provided for @planCacheReferences.
  ///
  /// In zh, this message translates to:
  /// **'缓存参考图'**
  String get planCacheReferences;

  /// No description provided for @planActionMemo.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录'**
  String get planActionMemo;

  /// No description provided for @planActionImportExport.
  ///
  /// In zh, this message translates to:
  /// **'导入导出'**
  String get planActionImportExport;

  /// No description provided for @planPreviousArea.
  ///
  /// In zh, this message translates to:
  /// **'上一个片区'**
  String get planPreviousArea;

  /// No description provided for @planNextArea.
  ///
  /// In zh, this message translates to:
  /// **'下一个片区'**
  String get planNextArea;

  /// No description provided for @planHideMap.
  ///
  /// In zh, this message translates to:
  /// **'收起地图'**
  String get planHideMap;

  /// No description provided for @planMap.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get planMap;

  /// No description provided for @planSortDefaultOrder.
  ///
  /// In zh, this message translates to:
  /// **'默认计划顺序'**
  String get planSortDefaultOrder;

  /// No description provided for @planSortByDistanceFromHere.
  ///
  /// In zh, this message translates to:
  /// **'按距离当前位置'**
  String get planSortByDistanceFromHere;

  /// No description provided for @planSortDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认计划'**
  String get planSortDefault;

  /// No description provided for @planSortDistance.
  ///
  /// In zh, this message translates to:
  /// **'按距离'**
  String get planSortDistance;

  /// No description provided for @planSortReversed.
  ///
  /// In zh, this message translates to:
  /// **'反序'**
  String get planSortReversed;

  /// No description provided for @planSortForward.
  ///
  /// In zh, this message translates to:
  /// **'正序'**
  String get planSortForward;

  /// No description provided for @planSortFarToNear.
  ///
  /// In zh, this message translates to:
  /// **'远到近'**
  String get planSortFarToNear;

  /// No description provided for @planSortNearToFar.
  ///
  /// In zh, this message translates to:
  /// **'近到远'**
  String get planSortNearToFar;

  /// No description provided for @planHideLocation.
  ///
  /// In zh, this message translates to:
  /// **'隐藏当前位置'**
  String get planHideLocation;

  /// No description provided for @planShowLocation.
  ///
  /// In zh, this message translates to:
  /// **'显示当前位置'**
  String get planShowLocation;

  /// No description provided for @planNoSpotsYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有点位'**
  String get planNoSpotsYet;

  /// No description provided for @planOnboardingSpotsTitle.
  ///
  /// In zh, this message translates to:
  /// **'选点位'**
  String get planOnboardingSpotsTitle;

  /// No description provided for @planOnboardingSpotsBody.
  ///
  /// In zh, this message translates to:
  /// **'在地图上点选点位并导入，作品会自动加入这个计划。'**
  String get planOnboardingSpotsBody;

  /// No description provided for @planUndoCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'撤回打卡'**
  String get planUndoCheckIn;

  /// No description provided for @planComplete.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get planComplete;

  /// No description provided for @planShootReference.
  ///
  /// In zh, this message translates to:
  /// **'拍摄参考'**
  String get planShootReference;

  /// No description provided for @anitabiMapImportAddAllMessage.
  ///
  /// In zh, this message translates to:
  /// **'将把当前作品中 {count} 个还不在计划里的点位加入计划，并暂时放在未分组。'**
  String anitabiMapImportAddAllMessage(int count);

  /// No description provided for @anitabiMapImportImporting.
  ///
  /// In zh, this message translates to:
  /// **'正在导入 {count} 个点位...'**
  String anitabiMapImportImporting(int count);

  /// No description provided for @anitabiMapImportCachingThumbnails.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存缩略图 {processed}/{total}，成功 {succeeded}'**
  String anitabiMapImportCachingThumbnails(
    int processed,
    int total,
    int succeeded,
  );

  /// No description provided for @anitabiMapImportImportedPartialCache.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个点位，缩略图缓存 {cached}/{count}，其余稍后会自动补齐。'**
  String anitabiMapImportImportedPartialCache(int count, int cached);

  /// No description provided for @anitabiMapImportBoxHint.
  ///
  /// In zh, this message translates to:
  /// **'在地图上拖出一个框来选择点位'**
  String get anitabiMapImportBoxHint;

  /// No description provided for @anitabiMapImportBoxCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位 · {newCount} 个新点位'**
  String anitabiMapImportBoxCount(int count, int newCount);

  /// No description provided for @anitabiMapImportBoxChooseArea.
  ///
  /// In zh, this message translates to:
  /// **'选择片区'**
  String get anitabiMapImportBoxChooseArea;

  /// No description provided for @anitabiMapImportBoxAreaSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'新点位会导入到这个片区，已在计划里的点位会移到这里'**
  String get anitabiMapImportBoxAreaSubtitle;

  /// No description provided for @anitabiMapImportBoxApply.
  ///
  /// In zh, this message translates to:
  /// **'放入片区'**
  String get anitabiMapImportBoxApply;

  /// No description provided for @anitabiMapImportAssigned.
  ///
  /// In zh, this message translates to:
  /// **'已将 {count} 个点位分配到「{area}」'**
  String anitabiMapImportAssigned(int count, String area);

  /// No description provided for @anitabiMapImportDetailPartial.
  ///
  /// In zh, this message translates to:
  /// **'当前只取得 {loaded} / 共 {expected} 个点位。请重新加载，或检查网络是否能访问 Anitabi 地图数据。'**
  String anitabiMapImportDetailPartial(int loaded, int expected);

  /// No description provided for @anitabiMapImportSpotCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位'**
  String anitabiMapImportSpotCount(int count);

  /// No description provided for @anitabiMapImportShownCount.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {imported} / 当前显示 {shown}'**
  String anitabiMapImportShownCount(int imported, int shown);

  /// No description provided for @anitabiMapImportShownCountOfTotal.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {imported} / 当前显示 {shown} / 共 {total}'**
  String anitabiMapImportShownCountOfTotal(int imported, int shown, int total);

  /// No description provided for @anitabiMapImportOpenAppFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开{app}。'**
  String anitabiMapImportOpenAppFailed(String app);

  /// No description provided for @anitabiMapImportNoImageSpots.
  ///
  /// In zh, this message translates to:
  /// **'当前作品共有 {count} 个点位，但没有可导入的带图参考点位。'**
  String anitabiMapImportNoImageSpots(int count);

  /// No description provided for @anitabiMapImportWorkNoSpots.
  ///
  /// In zh, this message translates to:
  /// **'「{title}」暂无可导入的 Anitabi 点位。'**
  String anitabiMapImportWorkNoSpots(String title);

  /// No description provided for @anitabiMapImportSettingsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'设置保存失败'**
  String get anitabiMapImportSettingsSaveFailed;

  /// No description provided for @anitabiMapImportTryLater.
  ///
  /// In zh, this message translates to:
  /// **'请稍后重试'**
  String get anitabiMapImportTryLater;

  /// No description provided for @anitabiMapImportClearingCache.
  ///
  /// In zh, this message translates to:
  /// **'正在清除缓存并重新加载 Anitabi 点位...'**
  String get anitabiMapImportClearingCache;

  /// No description provided for @anitabiMapImportManualWorkNoId.
  ///
  /// In zh, this message translates to:
  /// **'手动添加的作品没有 Bangumi ID，无法从 Anitabi 地图导入点位。'**
  String get anitabiMapImportManualWorkNoId;

  /// No description provided for @anitabiMapImportManualWorkState.
  ///
  /// In zh, this message translates to:
  /// **'手动添加的作品没有 Bangumi ID，无法从 Anitabi 地图导入点位。\n\n请通过 Bangumi/Anitabi 搜索添加作品，或使用手动添加点位。'**
  String get anitabiMapImportManualWorkState;

  /// No description provided for @anitabiMapImportAddedContinue.
  ///
  /// In zh, this message translates to:
  /// **'已加入计划，可继续选择点位。'**
  String get anitabiMapImportAddedContinue;

  /// No description provided for @anitabiMapImportSpotImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位导入失败，请稍后重试。'**
  String get anitabiMapImportSpotImportFailed;

  /// No description provided for @anitabiMapImportAddAll.
  ///
  /// In zh, this message translates to:
  /// **'添加所有点位'**
  String get anitabiMapImportAddAll;

  /// No description provided for @anitabiMapImportAddAllConfirm.
  ///
  /// In zh, this message translates to:
  /// **'添加全部'**
  String get anitabiMapImportAddAllConfirm;

  /// No description provided for @anitabiMapImportAddedAll.
  ///
  /// In zh, this message translates to:
  /// **'已添加所有未加入的点位。'**
  String get anitabiMapImportAddedAll;

  /// No description provided for @anitabiMapImportBulkFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量导入失败，请稍后重试。'**
  String get anitabiMapImportBulkFailed;

  /// No description provided for @anitabiMapImportAddedBox.
  ///
  /// In zh, this message translates to:
  /// **'已添加框选点位。'**
  String get anitabiMapImportAddedBox;

  /// No description provided for @anitabiMapImportBoxFailed.
  ///
  /// In zh, this message translates to:
  /// **'框选点位导入失败，请稍后重试。'**
  String get anitabiMapImportBoxFailed;

  /// No description provided for @anitabiMapImportOrganizeOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位已导入，但整理流程打开失败，可以稍后在计划中调整片区。'**
  String get anitabiMapImportOrganizeOpenFailed;

  /// No description provided for @anitabiMapImportAssignToArea.
  ///
  /// In zh, this message translates to:
  /// **'分配到片区'**
  String get anitabiMapImportAssignToArea;

  /// No description provided for @anitabiMapImportAssignToAreaSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择一个片区作为刚导入点位的所属片区'**
  String get anitabiMapImportAssignToAreaSubtitle;

  /// No description provided for @anitabiMapImportNotInArea.
  ///
  /// In zh, this message translates to:
  /// **'未分入片区'**
  String get anitabiMapImportNotInArea;

  /// No description provided for @anitabiMapImportSelectedArea.
  ///
  /// In zh, this message translates to:
  /// **'所选片区'**
  String get anitabiMapImportSelectedArea;

  /// No description provided for @anitabiMapImportAssignFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位分配失败，请稍后重试。'**
  String get anitabiMapImportAssignFailed;

  /// No description provided for @anitabiMapImportCreateAreaFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区创建失败，请稍后重试。'**
  String get anitabiMapImportCreateAreaFailed;

  /// No description provided for @anitabiMapImportThumbnailMarkers.
  ///
  /// In zh, this message translates to:
  /// **'缩略图标记'**
  String get anitabiMapImportThumbnailMarkers;

  /// No description provided for @anitabiMapImportOnlyNotAdded.
  ///
  /// In zh, this message translates to:
  /// **'只看未加入'**
  String get anitabiMapImportOnlyNotAdded;

  /// No description provided for @anitabiMapImportOnlyNotAddedDesc.
  ///
  /// In zh, this message translates to:
  /// **'隐藏已加入计划的点位'**
  String get anitabiMapImportOnlyNotAddedDesc;

  /// No description provided for @anitabiMapImportAreaBounds.
  ///
  /// In zh, this message translates to:
  /// **'片区范围'**
  String get anitabiMapImportAreaBounds;

  /// No description provided for @anitabiMapImportAreaBoundsDesc.
  ///
  /// In zh, this message translates to:
  /// **'显示计划中已有的片区'**
  String get anitabiMapImportAreaBoundsDesc;

  /// No description provided for @anitabiMapImportClustering.
  ///
  /// In zh, this message translates to:
  /// **'自动聚合密集点位'**
  String get anitabiMapImportClustering;

  /// No description provided for @anitabiMapImportAnitabiSpot.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位'**
  String get anitabiMapImportAnitabiSpot;

  /// No description provided for @anitabiMapImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'从作品地图导入'**
  String get anitabiMapImportTitle;

  /// No description provided for @anitabiMapImportLayers.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get anitabiMapImportLayers;

  /// No description provided for @anitabiMapImportClearCacheReload.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存并重新加载 Anitabi 点位'**
  String get anitabiMapImportClearCacheReload;

  /// No description provided for @anitabiMapImportAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入'**
  String get anitabiMapImportAdded;

  /// No description provided for @anitabiMapImportErrorDataUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 地图数据无法加载'**
  String get anitabiMapImportErrorDataUnavailable;

  /// No description provided for @anitabiMapImportErrorWorkNotFound.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 中没有找到这个作品'**
  String get anitabiMapImportErrorWorkNotFound;

  /// No description provided for @anitabiMapImportErrorNoPoints.
  ///
  /// In zh, this message translates to:
  /// **'当前作品暂无 Anitabi 点位'**
  String get anitabiMapImportErrorNoPoints;

  /// No description provided for @anitabiMapImportErrorPartial.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位只加载到一部分'**
  String get anitabiMapImportErrorPartial;

  /// No description provided for @anitabiMapImportError404.
  ///
  /// In zh, this message translates to:
  /// **'这个 Bangumi 条目暂无 Anitabi 地图数据'**
  String get anitabiMapImportError404;

  /// No description provided for @anitabiMapImportErrorPointNotFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到这个 Anitabi 点位'**
  String get anitabiMapImportErrorPointNotFound;

  /// No description provided for @anitabiMapImportErrorGeneric.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位加载失败'**
  String get anitabiMapImportErrorGeneric;

  /// No description provided for @anitabiMapImportDetailDataUnavailableWeb.
  ///
  /// In zh, this message translates to:
  /// **'可能是 Anitabi 地图数据缓存版本不一致，或当前预览服务网络请求被拦截。请清除缓存并重新加载 Anitabi 点位。'**
  String get anitabiMapImportDetailDataUnavailableWeb;

  /// No description provided for @anitabiMapImportDetailDataUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'无法读取 Anitabi 地图索引。请检查网络连接，或清除缓存并重新加载 Anitabi 点位。'**
  String get anitabiMapImportDetailDataUnavailable;

  /// No description provided for @anitabiMapImportDetailWorkNotFound.
  ///
  /// In zh, this message translates to:
  /// **'这个 Bangumi 条目在 Anitabi 地图数据中没有对应作品。可以尝试添加同名动画、原作或其它关联条目。'**
  String get anitabiMapImportDetailWorkNotFound;

  /// No description provided for @anitabiMapImportDetailNoPoints.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 中能找到这个作品，但当前还没有可导入的地图点位。'**
  String get anitabiMapImportDetailNoPoints;

  /// No description provided for @anitabiMapImportDetail404.
  ///
  /// In zh, this message translates to:
  /// **'可以尝试在作品管理中添加同名的原作、游戏或其他关联条目。'**
  String get anitabiMapImportDetail404;

  /// No description provided for @anitabiMapImportDetailPointNotFound.
  ///
  /// In zh, this message translates to:
  /// **'链接里的点位 ID 可能已失效，或 Anitabi 地图数据尚未同步。'**
  String get anitabiMapImportDetailPointNotFound;

  /// No description provided for @anitabiMapImportDetailGeneric.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络后重试，或稍后再重新加载。'**
  String get anitabiMapImportDetailGeneric;

  /// No description provided for @anitabiMapImportOrganizeTitle.
  ///
  /// In zh, this message translates to:
  /// **'整理刚导入的点位'**
  String get anitabiMapImportOrganizeTitle;

  /// No description provided for @anitabiMapImportOrganizeLead.
  ///
  /// In zh, this message translates to:
  /// **'已导入 '**
  String get anitabiMapImportOrganizeLead;

  /// No description provided for @anitabiMapImportOrganizeTail.
  ///
  /// In zh, this message translates to:
  /// **'，并暂时放在未分组。可以直接分配到片区，或按最近关键点快速分配。'**
  String get anitabiMapImportOrganizeTail;

  /// No description provided for @anitabiMapImportNearestAssign.
  ///
  /// In zh, this message translates to:
  /// **'最近分配'**
  String get anitabiMapImportNearestAssign;

  /// No description provided for @anitabiMapImportLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后'**
  String get anitabiMapImportLater;

  /// No description provided for @anitabiMapImportAreaNameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'片区名不能为空'**
  String get anitabiMapImportAreaNameEmpty;

  /// No description provided for @anitabiMapImportNewArea.
  ///
  /// In zh, this message translates to:
  /// **'新建片区'**
  String get anitabiMapImportNewArea;

  /// No description provided for @anitabiMapImportAreaName.
  ///
  /// In zh, this message translates to:
  /// **'片区名称'**
  String get anitabiMapImportAreaName;

  /// No description provided for @anitabiMapImportCreate.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get anitabiMapImportCreate;

  /// No description provided for @anitabiMapImportImportedSpot.
  ///
  /// In zh, this message translates to:
  /// **'已导入点位'**
  String get anitabiMapImportImportedSpot;

  /// No description provided for @anitabiMapImportImportableSpot.
  ///
  /// In zh, this message translates to:
  /// **'可导入点位'**
  String get anitabiMapImportImportableSpot;

  /// No description provided for @anitabiMapImportLoadingSpots.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 Anitabi 点位'**
  String get anitabiMapImportLoadingSpots;

  /// No description provided for @anitabiMapImportExitBox.
  ///
  /// In zh, this message translates to:
  /// **'退出框选'**
  String get anitabiMapImportExitBox;

  /// No description provided for @anitabiMapImportBoxSelect.
  ///
  /// In zh, this message translates to:
  /// **'框选点位'**
  String get anitabiMapImportBoxSelect;

  /// No description provided for @anitabiMapImportSpotName.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get anitabiMapImportSpotName;

  /// No description provided for @anitabiMapImportSpotInfo.
  ///
  /// In zh, this message translates to:
  /// **'点位信息'**
  String get anitabiMapImportSpotInfo;

  /// No description provided for @anitabiMapImportSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get anitabiMapImportSource;

  /// No description provided for @anitabiMapImportNavigate.
  ///
  /// In zh, this message translates to:
  /// **'导航'**
  String get anitabiMapImportNavigate;

  /// No description provided for @anitabiMapImportOpenNavigation.
  ///
  /// In zh, this message translates to:
  /// **'打开导航'**
  String get anitabiMapImportOpenNavigation;

  /// No description provided for @anitabiMapImportInPlan.
  ///
  /// In zh, this message translates to:
  /// **'已加入计划'**
  String get anitabiMapImportInPlan;

  /// No description provided for @anitabiMapImportAddToPlan.
  ///
  /// In zh, this message translates to:
  /// **'加入计划'**
  String get anitabiMapImportAddToPlan;

  /// No description provided for @anitabiMapImportAddShort.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get anitabiMapImportAddShort;

  /// No description provided for @anitabiMapImportScene.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get anitabiMapImportScene;

  /// No description provided for @anitabiMapImportNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get anitabiMapImportNote;

  /// No description provided for @anitabiMapImportCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'坐标'**
  String get anitabiMapImportCoordinates;

  /// No description provided for @anitabiMapImportTapSpotHint.
  ///
  /// In zh, this message translates to:
  /// **'点击地图上的点位查看缩略图和详情。'**
  String get anitabiMapImportTapSpotHint;

  /// No description provided for @anitabiMapImportNoImportableSpots.
  ///
  /// In zh, this message translates to:
  /// **'当前作品没有可导入的 Anitabi 点位。'**
  String get anitabiMapImportNoImportableSpots;

  /// No description provided for @anitabiMapImportNoWorks.
  ///
  /// In zh, this message translates to:
  /// **'还没有作品'**
  String get anitabiMapImportNoWorks;

  /// No description provided for @anitabiMapImportFromBangumiTitle.
  ///
  /// In zh, this message translates to:
  /// **'找到作品'**
  String get anitabiMapImportFromBangumiTitle;

  /// No description provided for @anitabiMapImportFromBangumiBody.
  ///
  /// In zh, this message translates to:
  /// **'在 Bangumi 搜索作品，或粘贴从 anitabi.cn 复制的链接。作品的点位会显示在地图上，导入点位时作品会自动加入计划。'**
  String get anitabiMapImportFromBangumiBody;

  /// No description provided for @anitabiMapImportLoadingWorks.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 Anitabi 作品和点位'**
  String get anitabiMapImportLoadingWorks;

  /// No description provided for @planGroupManagerTitle.
  ///
  /// In zh, this message translates to:
  /// **'片区管理'**
  String get planGroupManagerTitle;

  /// No description provided for @planGroupManagerNewArea.
  ///
  /// In zh, this message translates to:
  /// **'新建片区'**
  String get planGroupManagerNewArea;

  /// No description provided for @planGroupManagerCreate.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get planGroupManagerCreate;

  /// No description provided for @planGroupManagerCreateFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区创建失败'**
  String get planGroupManagerCreateFailed;

  /// No description provided for @planGroupManagerRenameTitle.
  ///
  /// In zh, this message translates to:
  /// **'重命名片区'**
  String get planGroupManagerRenameTitle;

  /// No description provided for @planGroupManagerRenameFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区改名失败'**
  String get planGroupManagerRenameFailed;

  /// No description provided for @planGroupManagerOrderModeSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'排序方式保存失败'**
  String get planGroupManagerOrderModeSaveFailed;

  /// No description provided for @planGroupManagerAnchorSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'关键点保存失败'**
  String get planGroupManagerAnchorSaveFailed;

  /// No description provided for @planGroupManagerDeleteArea.
  ///
  /// In zh, this message translates to:
  /// **'删除片区'**
  String get planGroupManagerDeleteArea;

  /// No description provided for @planGroupManagerDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除「{name}」，其中 {count} 个点位会移入未分配点位。'**
  String planGroupManagerDeleteMessage(String name, int count);

  /// No description provided for @planGroupManagerDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区删除失败'**
  String get planGroupManagerDeleteFailed;

  /// No description provided for @planGroupManagerReorderFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区顺序保存失败'**
  String get planGroupManagerReorderFailed;

  /// No description provided for @planGroupManagerUngroupedSpots.
  ///
  /// In zh, this message translates to:
  /// **'未分配点位'**
  String get planGroupManagerUngroupedSpots;

  /// No description provided for @planGroupManagerUnknownArea.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get planGroupManagerUnknownArea;

  /// No description provided for @planGroupManagerNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'片区名不能为空'**
  String get planGroupManagerNameRequired;

  /// No description provided for @planGroupManagerNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'片区名称'**
  String get planGroupManagerNameLabel;

  /// No description provided for @planGroupManagerSummary.
  ///
  /// In zh, this message translates to:
  /// **'{groupCount} 个片区 · {pointCount} 个点位'**
  String planGroupManagerSummary(int groupCount, int pointCount);

  /// No description provided for @planGroupManagerManualOrder.
  ///
  /// In zh, this message translates to:
  /// **'手动排序'**
  String get planGroupManagerManualOrder;

  /// No description provided for @planGroupManagerUnordered.
  ///
  /// In zh, this message translates to:
  /// **'无序'**
  String get planGroupManagerUnordered;

  /// No description provided for @planGroupManagerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'空'**
  String get planGroupManagerEmpty;

  /// No description provided for @planGroupManagerAnchorLabel.
  ///
  /// In zh, this message translates to:
  /// **'关键点 · {name}'**
  String planGroupManagerAnchorLabel(String name);

  /// No description provided for @planGroupManagerNoAnchor.
  ///
  /// In zh, this message translates to:
  /// **'未设置关键点'**
  String get planGroupManagerNoAnchor;

  /// No description provided for @planGroupManagerAreaActions.
  ///
  /// In zh, this message translates to:
  /// **'片区操作'**
  String get planGroupManagerAreaActions;

  /// No description provided for @planGroupManagerRename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get planGroupManagerRename;

  /// No description provided for @planGroupManagerSetAnchor.
  ///
  /// In zh, this message translates to:
  /// **'设置关键点'**
  String get planGroupManagerSetAnchor;

  /// No description provided for @planGroupManagerSwitchToUnordered.
  ///
  /// In zh, this message translates to:
  /// **'切换为无序'**
  String get planGroupManagerSwitchToUnordered;

  /// No description provided for @planGroupManagerSwitchToManualOrder.
  ///
  /// In zh, this message translates to:
  /// **'切换为手动排序'**
  String get planGroupManagerSwitchToManualOrder;

  /// No description provided for @planGroupManagerUngroupedWaiting.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位等待整理'**
  String planGroupManagerUngroupedWaiting(int count);

  /// No description provided for @workManagerTitle.
  ///
  /// In zh, this message translates to:
  /// **'作品管理'**
  String get workManagerTitle;

  /// No description provided for @workManagerDeleteWork.
  ///
  /// In zh, this message translates to:
  /// **'删除作品'**
  String get workManagerDeleteWork;

  /// No description provided for @workManagerDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除「{title}」。'**
  String workManagerDeleteMessage(String title);

  /// No description provided for @workManagerDeleteMessageWithPoints.
  ///
  /// In zh, this message translates to:
  /// **'将删除「{title}」，并同时移除 {count} 个相关点位和对应记录。'**
  String workManagerDeleteMessageWithPoints(String title, int count);

  /// No description provided for @workManagerDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'作品删除失败'**
  String get workManagerDeleteFailed;

  /// No description provided for @workManagerAddFromBangumi.
  ///
  /// In zh, this message translates to:
  /// **'从Bangumi添加'**
  String get workManagerAddFromBangumi;

  /// No description provided for @workManagerAddFromBangumiHint.
  ///
  /// In zh, this message translates to:
  /// **'自动获取信息'**
  String get workManagerAddFromBangumiHint;

  /// No description provided for @workManagerAddManually.
  ///
  /// In zh, this message translates to:
  /// **'手动添加作品'**
  String get workManagerAddManually;

  /// No description provided for @workManagerAddManuallyHint.
  ///
  /// In zh, this message translates to:
  /// **'未收录时使用'**
  String get workManagerAddManuallyHint;

  /// No description provided for @workManagerCopyTitle.
  ///
  /// In zh, this message translates to:
  /// **'作品名称'**
  String get workManagerCopyTitle;

  /// No description provided for @workManagerCopyInfo.
  ///
  /// In zh, this message translates to:
  /// **'作品信息'**
  String get workManagerCopyInfo;

  /// No description provided for @workManagerMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get workManagerMoreActions;

  /// No description provided for @workManagerPointsAddedOfTotal.
  ///
  /// In zh, this message translates to:
  /// **'已加入 {added} · 共 {total} 点位'**
  String workManagerPointsAddedOfTotal(int added, int total);

  /// No description provided for @workManagerPointsAddedOfUnknown.
  ///
  /// In zh, this message translates to:
  /// **'已加入 {added} · 共 … 点位'**
  String workManagerPointsAddedOfUnknown(int added);

  /// No description provided for @workManagerPointsAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入 {added} 点位'**
  String workManagerPointsAdded(int added);

  /// No description provided for @workManagerManualBadge.
  ///
  /// In zh, this message translates to:
  /// **'手动添加'**
  String get workManagerManualBadge;

  /// No description provided for @workManagerEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有作品'**
  String get workManagerEmptyTitle;

  /// No description provided for @workManagerOnboardingBangumiTitle.
  ///
  /// In zh, this message translates to:
  /// **'从Bangumi导入'**
  String get workManagerOnboardingBangumiTitle;

  /// No description provided for @workManagerOnboardingBangumiBody.
  ///
  /// In zh, this message translates to:
  /// **'点击上方按钮可从Bangumi搜索你想导入的作品并导入。之后你可以在“查找作品点位”直接查看对应作品在Anitabi上的点位。'**
  String get workManagerOnboardingBangumiBody;

  /// No description provided for @workManagerOnboardingManualBody.
  ///
  /// In zh, this message translates to:
  /// **'若Bangumi未收录你想要添加到作品，你可以通过“手动添加”将作品加入到计划内。之后你可以通过“手动添加点位”自主上传想要巡礼的点位。'**
  String get workManagerOnboardingManualBody;

  /// No description provided for @pilgrimageModelsSubjectBook.
  ///
  /// In zh, this message translates to:
  /// **'书籍'**
  String get pilgrimageModelsSubjectBook;

  /// No description provided for @pilgrimageModelsSubjectAnime.
  ///
  /// In zh, this message translates to:
  /// **'动画'**
  String get pilgrimageModelsSubjectAnime;

  /// No description provided for @pilgrimageModelsSubjectMusic.
  ///
  /// In zh, this message translates to:
  /// **'音乐'**
  String get pilgrimageModelsSubjectMusic;

  /// No description provided for @pilgrimageModelsSubjectGame.
  ///
  /// In zh, this message translates to:
  /// **'游戏'**
  String get pilgrimageModelsSubjectGame;

  /// No description provided for @pilgrimageModelsSubjectReal.
  ///
  /// In zh, this message translates to:
  /// **'三次元'**
  String get pilgrimageModelsSubjectReal;

  /// No description provided for @pilgrimageModelsPaletteCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get pilgrimageModelsPaletteCustom;

  /// No description provided for @pilgrimageModelsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get pilgrimageModelsThemeLight;

  /// No description provided for @pilgrimageModelsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get pilgrimageModelsThemeDark;

  /// No description provided for @pilgrimageModelsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get pilgrimageModelsThemeSystem;

  /// No description provided for @pilgrimageModelsAspectAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get pilgrimageModelsAspectAuto;

  /// No description provided for @pilgrimageModelsAspectNative.
  ///
  /// In zh, this message translates to:
  /// **'原生比例'**
  String get pilgrimageModelsAspectNative;

  /// No description provided for @pilgrimageModelsAspectCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get pilgrimageModelsAspectCustom;

  /// No description provided for @pilgrimageModelsNavAmap.
  ///
  /// In zh, this message translates to:
  /// **'高德地图'**
  String get pilgrimageModelsNavAmap;

  /// No description provided for @pilgrimageModelsNavBaiduMaps.
  ///
  /// In zh, this message translates to:
  /// **'百度地图'**
  String get pilgrimageModelsNavBaiduMaps;

  /// No description provided for @pilgrimageModelsLocationAskOnFirstCapture.
  ///
  /// In zh, this message translates to:
  /// **'首次拍摄时询问'**
  String get pilgrimageModelsLocationAskOnFirstCapture;

  /// No description provided for @pilgrimageModelsLocationDisabled.
  ///
  /// In zh, this message translates to:
  /// **'不记录定位'**
  String get pilgrimageModelsLocationDisabled;

  /// No description provided for @pilgrimageModelsLocationUseRecent.
  ///
  /// In zh, this message translates to:
  /// **'使用最近一次定位'**
  String get pilgrimageModelsLocationUseRecent;

  /// No description provided for @pilgrimageModelsLocationWaitOnConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'确认记录时获取定位（推荐）'**
  String get pilgrimageModelsLocationWaitOnConfirmation;

  /// No description provided for @referenceCacheProgressRetryAll.
  ///
  /// In zh, this message translates to:
  /// **'重试全部'**
  String get referenceCacheProgressRetryAll;

  /// No description provided for @referenceCacheProgressRetryFailed.
  ///
  /// In zh, this message translates to:
  /// **'重试失败'**
  String get referenceCacheProgressRetryFailed;

  /// No description provided for @referenceCacheProgressInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'缓存中断，请重试；已保存的图片不会删除。'**
  String get referenceCacheProgressInterrupted;

  /// No description provided for @referenceCacheProgressTip.
  ///
  /// In zh, this message translates to:
  /// **'提示：缓存过程中请保持网络连接，避免切换页面或锁屏。'**
  String get referenceCacheProgressTip;

  /// No description provided for @referenceCacheProgressRunning.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存参考图...'**
  String get referenceCacheProgressRunning;

  /// No description provided for @referenceCacheProgressDone.
  ///
  /// In zh, this message translates to:
  /// **'参考图缓存完成'**
  String get referenceCacheProgressDone;

  /// No description provided for @referenceCacheProgressFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'参考图缓存失败'**
  String get referenceCacheProgressFailedTitle;

  /// No description provided for @referenceCacheProgressSuccessSummary.
  ///
  /// In zh, this message translates to:
  /// **'{succeeded} / {total} 张成功，已保存到本地'**
  String referenceCacheProgressSuccessSummary(int succeeded, int total);

  /// No description provided for @referenceCacheProgressPartialSummary.
  ///
  /// In zh, this message translates to:
  /// **'{succeeded} / {total} 张成功 · {failed} 张失败'**
  String referenceCacheProgressPartialSummary(
    int succeeded,
    int total,
    int failed,
  );

  /// No description provided for @referenceFullCacheRunnerNothing.
  ///
  /// In zh, this message translates to:
  /// **'当前计划没有需要缓存的参考图'**
  String get referenceFullCacheRunnerNothing;

  /// No description provided for @referenceFullCacheRunnerDone.
  ///
  /// In zh, this message translates to:
  /// **'已缓存 {succeeded}/{total} 张完整参考图'**
  String referenceFullCacheRunnerDone(int succeeded, int total);

  /// No description provided for @referenceFullCacheRunnerDoneWithFailures.
  ///
  /// In zh, this message translates to:
  /// **'已缓存 {succeeded}/{total} 张完整参考图，失败 {failed} 张'**
  String referenceFullCacheRunnerDoneWithFailures(
    int succeeded,
    int total,
    int failed,
  );

  /// No description provided for @referenceFullCacheRunnerRunning.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存完整参考图 {processed}/{total}，成功 {succeeded}'**
  String referenceFullCacheRunnerRunning(
    int processed,
    int total,
    int succeeded,
  );

  /// No description provided for @pilgrimageWorkDropdownManual.
  ///
  /// In zh, this message translates to:
  /// **'手动'**
  String get pilgrimageWorkDropdownManual;

  /// No description provided for @pilgrimageWorkDropdownWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get pilgrimageWorkDropdownWork;

  /// No description provided for @pilgrimageWorkCoverLabel.
  ///
  /// In zh, this message translates to:
  /// **'{title}封面'**
  String pilgrimageWorkCoverLabel(String title);

  /// No description provided for @valhallaServiceConfigUrlIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'请输入完整的服务地址'**
  String get valhallaServiceConfigUrlIncomplete;

  /// No description provided for @valhallaServiceConfigUrlScheme.
  ///
  /// In zh, this message translates to:
  /// **'服务地址仅支持 HTTP 或 HTTPS'**
  String get valhallaServiceConfigUrlScheme;

  /// No description provided for @anitabiServiceConfigInvalidHttps.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 HTTPS 地址'**
  String get anitabiServiceConfigInvalidHttps;

  /// No description provided for @anitabiServiceConfigNoExtras.
  ///
  /// In zh, this message translates to:
  /// **'地址不能包含账号、查询参数或片段'**
  String get anitabiServiceConfigNoExtras;

  /// No description provided for @anitabiServiceConfigNoLocal.
  ///
  /// In zh, this message translates to:
  /// **'不能使用本机或局域网地址'**
  String get anitabiServiceConfigNoLocal;

  /// No description provided for @bangumiApiClientNoRegion.
  ///
  /// In zh, this message translates to:
  /// **'未设置地区'**
  String get bangumiApiClientNoRegion;

  /// No description provided for @anitabiEndpointSyncUpdated.
  ///
  /// In zh, this message translates to:
  /// **'已更新服务地址'**
  String get anitabiEndpointSyncUpdated;

  /// No description provided for @anitabiEndpointSyncUnchanged.
  ///
  /// In zh, this message translates to:
  /// **'服务地址已是最新'**
  String get anitabiEndpointSyncUnchanged;

  /// No description provided for @anitabiEndpointSyncOffline.
  ///
  /// In zh, this message translates to:
  /// **'无法获取远程配置，请检查网络'**
  String get anitabiEndpointSyncOffline;

  /// No description provided for @anitabiEndpointSyncInvalid.
  ///
  /// In zh, this message translates to:
  /// **'远程配置无效，已保留当前地址'**
  String get anitabiEndpointSyncInvalid;

  /// No description provided for @anitabiEndpointSyncVerificationFailed.
  ///
  /// In zh, this message translates to:
  /// **'新地址暂不可用，已保留当前地址'**
  String get anitabiEndpointSyncVerificationFailed;

  /// No description provided for @anitabiEndpointSyncRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'检查过于频繁，稍后再试'**
  String get anitabiEndpointSyncRateLimited;

  /// No description provided for @anitabiEndpointSyncDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已关闭自动更新'**
  String get anitabiEndpointSyncDisabled;

  /// No description provided for @boundedImageFileStubUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'此平台无法读取此本地图片；原件未更改'**
  String get boundedImageFileStubUnsupported;

  /// No description provided for @anitabiClientNoRegion.
  ///
  /// In zh, this message translates to:
  /// **'未设置地区'**
  String get anitabiClientNoRegion;

  /// No description provided for @anitabiClientDefaultSpotName.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位'**
  String get anitabiClientDefaultSpotName;

  /// No description provided for @anitabiClientPointNotFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到对应的 Anitabi 点位'**
  String get anitabiClientPointNotFound;

  /// No description provided for @boundedImageDecoderEncodedTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'图片文件 {length} 字节超过读取预算 {maxBytes} 字节；原件未更改，可保存或导出原件'**
  String boundedImageDecoderEncodedTooLarge(int length, int maxBytes);

  /// No description provided for @boundedImageDecoderSizeUnreadable.
  ///
  /// In zh, this message translates to:
  /// **'无法读取图片尺寸'**
  String get boundedImageDecoderSizeUnreadable;

  /// No description provided for @boundedImageDecoderSourceTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'图片 {width} x {height} 超过来源预算（16000000 像素，单边 16384）；原件未更改，可保存或导出原件'**
  String boundedImageDecoderSourceTooLarge(int width, int height);

  /// No description provided for @boundedImageDecoderInvalidMetadata.
  ///
  /// In zh, this message translates to:
  /// **'图片尺寸元数据无效或不一致；原件未更改'**
  String get boundedImageDecoderInvalidMetadata;

  /// No description provided for @boundedImageDecoderUnsupportedFormat.
  ///
  /// In zh, this message translates to:
  /// **'此平台暂不能安全预览此图片格式；原件未更改'**
  String get boundedImageDecoderUnsupportedFormat;

  /// No description provided for @boundedImageDecoderMetadataMismatch.
  ///
  /// In zh, this message translates to:
  /// **'图片尺寸元数据不一致；原件未更改'**
  String get boundedImageDecoderMetadataMismatch;

  /// No description provided for @boundedImageDecoderAnimatedFrameTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'动画首帧尺寸超过此处理预算；原件未更改'**
  String get boundedImageDecoderAnimatedFrameTooLarge;

  /// No description provided for @boundedImageDecoderTargetUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'平台无法满足图片处理尺寸预算'**
  String get boundedImageDecoderTargetUnsupported;

  /// No description provided for @sqlitePilgrimageRepositoryImportedPlan.
  ///
  /// In zh, this message translates to:
  /// **'导入的巡礼计划'**
  String get sqlitePilgrimageRepositoryImportedPlan;

  /// No description provided for @sqlitePilgrimageRepositoryUnknownWork.
  ///
  /// In zh, this message translates to:
  /// **'未知作品'**
  String get sqlitePilgrimageRepositoryUnknownWork;

  /// No description provided for @sqlitePilgrimageRepositoryNoRegion.
  ///
  /// In zh, this message translates to:
  /// **'未设置地区'**
  String get sqlitePilgrimageRepositoryNoRegion;

  /// No description provided for @samplePilgrimageRepositoryImportedPlan.
  ///
  /// In zh, this message translates to:
  /// **'导入的巡礼计划'**
  String get samplePilgrimageRepositoryImportedPlan;

  /// No description provided for @desktopRepositoryStateDefaultPlan.
  ///
  /// In zh, this message translates to:
  /// **'桌面端计划'**
  String get desktopRepositoryStateDefaultPlan;

  /// No description provided for @desktopRepositoryStateDefaultWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get desktopRepositoryStateDefaultWork;

  /// No description provided for @desktopRepositoryStateDefaultGroup.
  ///
  /// In zh, this message translates to:
  /// **'分组'**
  String get desktopRepositoryStateDefaultGroup;

  /// No description provided for @desktopRepositoryStateUnknownWork.
  ///
  /// In zh, this message translates to:
  /// **'未知作品'**
  String get desktopRepositoryStateUnknownWork;

  /// No description provided for @desktopRepositoryStateDefaultSpot.
  ///
  /// In zh, this message translates to:
  /// **'点位'**
  String get desktopRepositoryStateDefaultSpot;

  /// No description provided for @tauriBridgeWebAssetTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'图片超过读取预算 {maxBytes} 字节；原件未更改（{error}）'**
  String tauriBridgeWebAssetTooLarge(int maxBytes, String error);

  /// No description provided for @appShellSettingsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'设置保存失败'**
  String get appShellSettingsSaveFailed;

  /// No description provided for @appShellSettingsSaveFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'修改未能保存，请稍后重试'**
  String get appShellSettingsSaveFailedHint;

  /// No description provided for @appShellReadingPlanFile.
  ///
  /// In zh, this message translates to:
  /// **'正在读取计划文件…'**
  String get appShellReadingPlanFile;

  /// No description provided for @appShellPlanImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划文件导入失败'**
  String get appShellPlanImportFailed;

  /// No description provided for @appShellNavPlan.
  ///
  /// In zh, this message translates to:
  /// **'计划'**
  String get appShellNavPlan;

  /// No description provided for @appShellNavMap.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get appShellNavMap;

  /// No description provided for @appShellNavRecords.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get appShellNavRecords;

  /// No description provided for @appShellNavSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get appShellNavSettings;

  /// No description provided for @appShellLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划加载失败'**
  String get appShellLoadFailed;

  /// No description provided for @appShellLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载巡礼计划'**
  String get appShellLoading;

  /// No description provided for @appShellLoadFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'请稍后重试。'**
  String get appShellLoadFailedHint;

  /// No description provided for @appShellLoadingHint.
  ///
  /// In zh, this message translates to:
  /// **'准备今日点位和当前目标。'**
  String get appShellLoadingHint;

  /// No description provided for @mainOpenDirectoryFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开目录：{error}'**
  String mainOpenDirectoryFailed(String error);

  /// No description provided for @mainStartupFailed.
  ///
  /// In zh, this message translates to:
  /// **'Koma 启动失败'**
  String get mainStartupFailed;

  /// No description provided for @mainStartupFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'用户数据没有被删除。请重试，或打开日志目录查看 startup.log。'**
  String get mainStartupFailedHint;

  /// No description provided for @mainOpenLogFolder.
  ///
  /// In zh, this message translates to:
  /// **'打开日志目录'**
  String get mainOpenLogFolder;

  /// No description provided for @mainOpenDataFolder.
  ///
  /// In zh, this message translates to:
  /// **'打开数据目录'**
  String get mainOpenDataFolder;

  /// No description provided for @mainErrorDetails.
  ///
  /// In zh, this message translates to:
  /// **'错误详情'**
  String get mainErrorDetails;

  /// No description provided for @pointDetailReplacingReference.
  ///
  /// In zh, this message translates to:
  /// **'正在替换参考图...'**
  String get pointDetailReplacingReference;

  /// No description provided for @pointDetailReplaceReferenceFailed.
  ///
  /// In zh, this message translates to:
  /// **'参考图替换失败，请稍后重试。'**
  String get pointDetailReplaceReferenceFailed;

  /// No description provided for @pointDetailReplaceReferenceCanceled.
  ///
  /// In zh, this message translates to:
  /// **'参考图替换已取消'**
  String get pointDetailReplaceReferenceCanceled;

  /// No description provided for @pointDetailReferenceReplaced.
  ///
  /// In zh, this message translates to:
  /// **'已替换参考图'**
  String get pointDetailReferenceReplaced;

  /// No description provided for @pointDetailOpenNavigationFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开{app}。'**
  String pointDetailOpenNavigationFailed(String app);

  /// No description provided for @pointDetailMoveToArea.
  ///
  /// In zh, this message translates to:
  /// **'移动到片区'**
  String get pointDetailMoveToArea;

  /// No description provided for @pointDetailMoveToAreaHint.
  ///
  /// In zh, this message translates to:
  /// **'选择一个片区作为当前点位所属片区'**
  String get pointDetailMoveToAreaHint;

  /// No description provided for @pointDetailNotInArea.
  ///
  /// In zh, this message translates to:
  /// **'未分入片区'**
  String get pointDetailNotInArea;

  /// No description provided for @pointDetailCopySpotName.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get pointDetailCopySpotName;

  /// No description provided for @pointDetailWorkLabel.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get pointDetailWorkLabel;

  /// No description provided for @pointDetailSceneLabel.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get pointDetailSceneLabel;

  /// No description provided for @pointDetailCoordinatesLabel.
  ///
  /// In zh, this message translates to:
  /// **'坐标'**
  String get pointDetailCoordinatesLabel;

  /// No description provided for @pointDetailCoordinatesMissing.
  ///
  /// In zh, this message translates to:
  /// **'待补充'**
  String get pointDetailCoordinatesMissing;

  /// No description provided for @pointDetailReferenceLabel.
  ///
  /// In zh, this message translates to:
  /// **'参考'**
  String get pointDetailReferenceLabel;

  /// No description provided for @pointDetailSourceLabel.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get pointDetailSourceLabel;

  /// No description provided for @pointDetailLinkLabel.
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get pointDetailLinkLabel;

  /// No description provided for @pointDetailNoteLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get pointDetailNoteLabel;

  /// No description provided for @pointDetailManualSource.
  ///
  /// In zh, this message translates to:
  /// **'手动录入 / {reference}'**
  String pointDetailManualSource(String reference);

  /// No description provided for @pointDetailUndoCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'撤回打卡'**
  String get pointDetailUndoCheckIn;

  /// No description provided for @pointDetailMarkDone.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get pointDetailMarkDone;

  /// No description provided for @pointDetailUnknownArea.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get pointDetailUnknownArea;

  /// No description provided for @pointDetailNoAnchor.
  ///
  /// In zh, this message translates to:
  /// **'未设置关键点'**
  String get pointDetailNoAnchor;

  /// No description provided for @pointDetailDeleteSpot.
  ///
  /// In zh, this message translates to:
  /// **'删除点位'**
  String get pointDetailDeleteSpot;

  /// No description provided for @pointDetailDeleteSpotMessage.
  ///
  /// In zh, this message translates to:
  /// **'将从计划中删除“{name}”。已有巡礼记录及照片将保留。'**
  String pointDetailDeleteSpotMessage(String name);

  /// No description provided for @pointDetailDeleteSpotFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除点位失败，请稍后重试。'**
  String get pointDetailDeleteSpotFailed;

  /// No description provided for @pointDetailDeletingSpot.
  ///
  /// In zh, this message translates to:
  /// **'正在删除点位'**
  String get pointDetailDeletingSpot;

  /// No description provided for @pointDetailSpotDeleted.
  ///
  /// In zh, this message translates to:
  /// **'点位已删除'**
  String get pointDetailSpotDeleted;

  /// No description provided for @pointDetailNavigate.
  ///
  /// In zh, this message translates to:
  /// **'导航'**
  String get pointDetailNavigate;

  /// No description provided for @pointDetailNoCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'坐标待补充'**
  String get pointDetailNoCoordinates;

  /// No description provided for @pointDetailShootReference.
  ///
  /// In zh, this message translates to:
  /// **'拍摄参考'**
  String get pointDetailShootReference;

  /// No description provided for @pointDetailShootShort.
  ///
  /// In zh, this message translates to:
  /// **'拍摄'**
  String get pointDetailShootShort;

  /// No description provided for @pointDetailSetCurrent.
  ///
  /// In zh, this message translates to:
  /// **'设为当前'**
  String get pointDetailSetCurrent;

  /// No description provided for @pointDetailSetCurrentShort.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get pointDetailSetCurrentShort;

  /// No description provided for @pointDetailSetCurrentTarget.
  ///
  /// In zh, this message translates to:
  /// **'设为当前目标'**
  String get pointDetailSetCurrentTarget;

  /// No description provided for @pointDetailEditSpot.
  ///
  /// In zh, this message translates to:
  /// **'编辑点位'**
  String get pointDetailEditSpot;

  /// No description provided for @pointDetailReplace.
  ///
  /// In zh, this message translates to:
  /// **'替换'**
  String get pointDetailReplace;

  /// No description provided for @pointDetailArea.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get pointDetailArea;

  /// No description provided for @pointDetailAreaAnchor.
  ///
  /// In zh, this message translates to:
  /// **'片区关键点'**
  String get pointDetailAreaAnchor;

  /// No description provided for @pointDetailChange.
  ///
  /// In zh, this message translates to:
  /// **'更改'**
  String get pointDetailChange;

  /// No description provided for @pointDetailStatusCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前目标'**
  String get pointDetailStatusCurrent;

  /// No description provided for @pointDetailStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get pointDetailStatusCompleted;

  /// No description provided for @pointDetailStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待访问'**
  String get pointDetailStatusPending;

  /// No description provided for @pointDetailRecordsCount.
  ///
  /// In zh, this message translates to:
  /// **'本点记录 {count}'**
  String pointDetailRecordsCount(int count);

  /// No description provided for @pointDetailAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get pointDetailAll;

  /// No description provided for @importExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入导出'**
  String get importExportTitle;

  /// No description provided for @importExportImportSection.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importExportImportSection;

  /// No description provided for @importExportImportSubtitleIos.
  ///
  /// In zh, this message translates to:
  /// **'从文件、聊天、浏览器或网盘等位置用 Koma 打开 .sjhplan。'**
  String get importExportImportSubtitleIos;

  /// No description provided for @importExportImportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择 .sjhplan 文件，先预览内容再导入。'**
  String get importExportImportSubtitle;

  /// No description provided for @importExportReading.
  ///
  /// In zh, this message translates to:
  /// **'读取中...'**
  String get importExportReading;

  /// No description provided for @importExportOpenFromOtherApp.
  ///
  /// In zh, this message translates to:
  /// **'从其他 App 打开 .sjhplan'**
  String get importExportOpenFromOtherApp;

  /// No description provided for @importExportImportFile.
  ///
  /// In zh, this message translates to:
  /// **'导入 Koma 文件'**
  String get importExportImportFile;

  /// No description provided for @importExportOpenFromOtherAppSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在文件、聊天、浏览器下载页或网盘中选择 .sjhplan，然后分享或用 Koma 打开。'**
  String get importExportOpenFromOtherAppSubtitle;

  /// No description provided for @importExportImportFileSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'支持 v2 数据包和旧版 v1 JSON 计划包。'**
  String get importExportImportFileSubtitle;

  /// No description provided for @importExportImportFromLink.
  ///
  /// In zh, this message translates to:
  /// **'从链接导入'**
  String get importExportImportFromLink;

  /// No description provided for @importExportImportFromLinkSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 GitHub 发布或 .sjhplan / .zip 下载链接，下载后预览导入。'**
  String get importExportImportFromLinkSubtitle;

  /// No description provided for @importExportPackageSection.
  ///
  /// In zh, this message translates to:
  /// **'Koma 数据包'**
  String get importExportPackageSection;

  /// No description provided for @importExportPackageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'新版 .sjhplan，内部为 zip，包含 manifest.json。'**
  String get importExportPackageSubtitle;

  /// No description provided for @importExportMyMapsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出点位 CSV。图片写成链接，可按 Type 列设置样式。'**
  String get importExportMyMapsSubtitle;

  /// No description provided for @importExportMyMapsExport.
  ///
  /// In zh, this message translates to:
  /// **'导出 My Maps CSV'**
  String get importExportMyMapsExport;

  /// No description provided for @importExportMyMapsExportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'前 6 列贴近示例格式，作品、集数、来源等拆成独立列。'**
  String get importExportMyMapsExportSubtitle;

  /// No description provided for @importExportExportCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消导出'**
  String get importExportExportCanceled;

  /// No description provided for @importExportReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入文件读取失败'**
  String get importExportReadFailed;

  /// No description provided for @importExportIosHelpMessage.
  ///
  /// In zh, this message translates to:
  /// **'请在文件、聊天、浏览器下载页、网盘或其他保存位置找到 .sjhplan 文件，然后点开文件，或使用分享/更多菜单选择 Koma。\n\nKoma 收到文件后会自动进入导入预览页面。若列表里没有 Koma，可以先把文件保存到“文件”App，再长按文件选择分享或打开方式。'**
  String get importExportIosHelpMessage;

  /// No description provided for @importExportShareText.
  ///
  /// In zh, this message translates to:
  /// **'Koma数据包：{planName}'**
  String importExportShareText(String planName);

  /// No description provided for @importExportPackageExported.
  ///
  /// In zh, this message translates to:
  /// **'数据包已导出'**
  String get importExportPackageExported;

  /// No description provided for @importExportMissingAssetsTitle.
  ///
  /// In zh, this message translates to:
  /// **'部分本地资源缺失'**
  String get importExportMissingAssetsTitle;

  /// No description provided for @importExportContinueExport.
  ///
  /// In zh, this message translates to:
  /// **'继续导出'**
  String get importExportContinueExport;

  /// No description provided for @importExportMissingAssetsNotice.
  ///
  /// In zh, this message translates to:
  /// **'缺失资源不会进入数据包，导入后对应图片可能无法显示'**
  String get importExportMissingAssetsNotice;

  /// No description provided for @importExportMyMapsShareText.
  ///
  /// In zh, this message translates to:
  /// **'Koma My Maps CSV：{planName}'**
  String importExportMyMapsShareText(String planName);

  /// No description provided for @importExportPendingCoordinateWarning.
  ///
  /// In zh, this message translates to:
  /// **'存在坐标待补充的点位'**
  String get importExportPendingCoordinateWarning;

  /// No description provided for @importExportMyMapsExported.
  ///
  /// In zh, this message translates to:
  /// **'My Maps CSV 已导出'**
  String get importExportMyMapsExported;

  /// No description provided for @importExportExporting.
  ///
  /// In zh, this message translates to:
  /// **'正在导出...'**
  String get importExportExporting;

  /// No description provided for @importExportExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get importExportExportFailed;

  /// No description provided for @importExportTryAgainLater.
  ///
  /// In zh, this message translates to:
  /// **'请稍后重试'**
  String get importExportTryAgainLater;

  /// No description provided for @importExportSavedLocally.
  ///
  /// In zh, this message translates to:
  /// **'已保存到本地'**
  String get importExportSavedLocally;

  /// No description provided for @importExportShared.
  ///
  /// In zh, this message translates to:
  /// **'已通过系统分享送出'**
  String get importExportShared;

  /// No description provided for @importExportSomeAssetsSkipped.
  ///
  /// In zh, this message translates to:
  /// **'部分资源未能加入'**
  String get importExportSomeAssetsSkipped;

  /// No description provided for @importExportWarnUserReferenceMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张本地上传参考图缺失'**
  String importExportWarnUserReferenceMissing(int count);

  /// No description provided for @importExportWarnThumbnailMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张缩略图未加入'**
  String importExportWarnThumbnailMissing(int count);

  /// No description provided for @importExportWarnFullReferenceDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张完整参考图下载失败'**
  String importExportWarnFullReferenceDownloadFailed(int count);

  /// No description provided for @importExportWarnFullReferenceMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张完整参考图缺失'**
  String importExportWarnFullReferenceMissing(int count);

  /// No description provided for @importExportWarnVisitPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张巡礼照片缺失'**
  String importExportWarnVisitPhotoMissing(int count);

  /// No description provided for @importExportWarnGradedPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张调色照片缺失'**
  String importExportWarnGradedPhotoMissing(int count);

  /// No description provided for @importExportWarnPendingCoordinate.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个坐标待补充点位未导出'**
  String importExportWarnPendingCoordinate(int count);

  /// No description provided for @importExportWarningSeparator.
  ///
  /// In zh, this message translates to:
  /// **'，'**
  String get importExportWarningSeparator;

  /// No description provided for @importExportAreaCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个片区'**
  String importExportAreaCount(int count);

  /// No description provided for @importExportSpotCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位'**
  String importExportSpotCount(int count);

  /// No description provided for @importExportPlanOnly.
  ///
  /// In zh, this message translates to:
  /// **'纯计划'**
  String get importExportPlanOnly;

  /// No description provided for @importExportPlanWithRecords.
  ///
  /// In zh, this message translates to:
  /// **'计划+记录'**
  String get importExportPlanWithRecords;

  /// No description provided for @importExportIncludeFullReference.
  ///
  /// In zh, this message translates to:
  /// **'包含完整参考图缓存'**
  String get importExportIncludeFullReference;

  /// No description provided for @importExportIncludeFullReferenceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启后才会把完整参考图写入数据包；默认仍会包含缩略图和用户自己添加的参考图。'**
  String get importExportIncludeFullReferenceSubtitle;

  /// No description provided for @importExportExportingButton.
  ///
  /// In zh, this message translates to:
  /// **'导出中...'**
  String get importExportExportingButton;

  /// No description provided for @importExportExportPackage.
  ///
  /// In zh, this message translates to:
  /// **'导出 Koma 数据包'**
  String get importExportExportPackage;

  /// No description provided for @importExportEstimating.
  ///
  /// In zh, this message translates to:
  /// **'正在估算数据包大小...'**
  String get importExportEstimating;

  /// No description provided for @importExportEstimateUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：暂时无法估算'**
  String get importExportEstimateUnavailable;

  /// No description provided for @planExportSizeEstimatorThumbnailsNotCached.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张缩略图未缓存，不会进入数据包'**
  String planExportSizeEstimatorThumbnailsNotCached(int count);

  /// No description provided for @planExportSizeEstimatorFullReferencesToDownload.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张完整参考图将在导出时下载'**
  String planExportSizeEstimatorFullReferencesToDownload(int count);

  /// No description provided for @planExportSizeEstimatorUserReferencesMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张本地上传参考图文件缺失，导出后无法恢复'**
  String planExportSizeEstimatorUserReferencesMissing(int count);

  /// No description provided for @planExportSizeEstimatorVisitPhotosMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张巡礼照片文件缺失'**
  String planExportSizeEstimatorVisitPhotosMissing(int count);

  /// No description provided for @planExportSizeEstimatorGradedPhotosMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张调色照片文件缺失'**
  String planExportSizeEstimatorGradedPhotosMissing(int count);

  /// No description provided for @planExportSizeEstimatorUnknownLocalAssets.
  ///
  /// In zh, this message translates to:
  /// **'部分本地资源无法读取，实际包体可能变化'**
  String get planExportSizeEstimatorUnknownLocalAssets;

  /// No description provided for @planExportSizeEstimatorLabelWithDetails.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：至少约 {size}，{details}'**
  String planExportSizeEstimatorLabelWithDetails(String size, String details);

  /// No description provided for @planExportSizeEstimatorDetailSeparator.
  ///
  /// In zh, this message translates to:
  /// **'；'**
  String get planExportSizeEstimatorDetailSeparator;

  /// No description provided for @planExportSizeEstimatorLabel.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：约 {size}'**
  String planExportSizeEstimatorLabel(String size);

  /// No description provided for @planImportPreviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入内容'**
  String get planImportPreviewTitle;

  /// No description provided for @planImportPreviewChooseContent.
  ///
  /// In zh, this message translates to:
  /// **'选择导入内容'**
  String get planImportPreviewChooseContent;

  /// No description provided for @planImportPreviewChooseContentSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导入前不会修改当前数据。'**
  String get planImportPreviewChooseContentSubtitle;

  /// No description provided for @planImportPreviewPlanStructure.
  ///
  /// In zh, this message translates to:
  /// **'计划结构'**
  String get planImportPreviewPlanStructure;

  /// No description provided for @planImportPreviewPlanStructureSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'作品、片区、点位、完成状态和当前目标。'**
  String get planImportPreviewPlanStructureSubtitle;

  /// No description provided for @planImportPreviewRecords.
  ///
  /// In zh, this message translates to:
  /// **'拍摄记录'**
  String get planImportPreviewRecords;

  /// No description provided for @planImportPreviewRecordsLegacy.
  ///
  /// In zh, this message translates to:
  /// **'v1 文件不包含照片资源，仅导入计划结构。'**
  String get planImportPreviewRecordsLegacy;

  /// No description provided for @planImportPreviewRecordsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条记录，包含照片路径和调色参数。'**
  String planImportPreviewRecordsCount(int count);

  /// No description provided for @planImportPreviewRecordsNone.
  ///
  /// In zh, this message translates to:
  /// **'这个包里没有拍摄记录。'**
  String get planImportPreviewRecordsNone;

  /// No description provided for @planImportPreviewAssets.
  ///
  /// In zh, this message translates to:
  /// **'图片和资源文件'**
  String get planImportPreviewAssets;

  /// No description provided for @planImportPreviewPackageNotes.
  ///
  /// In zh, this message translates to:
  /// **'包内提示'**
  String get planImportPreviewPackageNotes;

  /// No description provided for @planImportPreviewPackageNotesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出时记录的缺失或兼容信息。'**
  String get planImportPreviewPackageNotesSubtitle;

  /// No description provided for @planImportPreviewImporting.
  ///
  /// In zh, this message translates to:
  /// **'导入中...'**
  String get planImportPreviewImporting;

  /// No description provided for @planImportPreviewImportSelected.
  ///
  /// In zh, this message translates to:
  /// **'导入所选内容'**
  String get planImportPreviewImportSelected;

  /// No description provided for @planImportPreviewImportedUnconfirmed.
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{name}」，资源确认未完成'**
  String planImportPreviewImportedUnconfirmed(String name);

  /// No description provided for @planImportPreviewImported.
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{name}」'**
  String planImportPreviewImported(String name);

  /// No description provided for @planImportPreviewImportedPartial.
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{name}」，部分资源未恢复'**
  String planImportPreviewImportedPartial(String name);

  /// No description provided for @planImportPreviewCleanupIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'导入未确认完成，已保留资源以避免误删'**
  String get planImportPreviewCleanupIncomplete;

  /// No description provided for @planImportPreviewFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get planImportPreviewFailed;

  /// No description provided for @planImportPreviewNoAssets.
  ///
  /// In zh, this message translates to:
  /// **'这个包里没有可恢复的资源文件。'**
  String get planImportPreviewNoAssets;

  /// No description provided for @planImportPreviewNoRestorableAssets.
  ///
  /// In zh, this message translates to:
  /// **'包内记录了资源，但没有可恢复的资源文件。'**
  String get planImportPreviewNoRestorableAssets;

  /// No description provided for @planImportPreviewAssetsUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'包内有 {count} 个资源文件；当前平台暂不支持恢复包内资源。'**
  String planImportPreviewAssetsUnsupported(int count);

  /// No description provided for @planImportPreviewAssetsRestore.
  ///
  /// In zh, this message translates to:
  /// **'包内有 {count} 个资源文件，将恢复到本机存储。'**
  String planImportPreviewAssetsRestore(int count);

  /// No description provided for @planImportPreviewStatWorks.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get planImportPreviewStatWorks;

  /// No description provided for @planImportPreviewStatAreas.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get planImportPreviewStatAreas;

  /// No description provided for @planImportPreviewStatSpots.
  ///
  /// In zh, this message translates to:
  /// **'点位'**
  String get planImportPreviewStatSpots;

  /// No description provided for @planImportPreviewStatRecords.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get planImportPreviewStatRecords;

  /// No description provided for @planImportPreviewStatFiles.
  ///
  /// In zh, this message translates to:
  /// **'资源'**
  String get planImportPreviewStatFiles;

  /// No description provided for @planImportPreviewStatVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get planImportPreviewStatVersion;

  /// No description provided for @planImportPreviewStatExported.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get planImportPreviewStatExported;

  /// No description provided for @planLinkImportNoPlanFilesInRelease.
  ///
  /// In zh, this message translates to:
  /// **'这个发布中没有 .sjhplan 或 .zip 文件'**
  String get planLinkImportNoPlanFilesInRelease;

  /// No description provided for @planLinkImportChooseArchiveEntry.
  ///
  /// In zh, this message translates to:
  /// **'压缩包里有多个计划，选择要导入的一个'**
  String get planLinkImportChooseArchiveEntry;

  /// No description provided for @planLinkImportArchiveHasNoPlan.
  ///
  /// In zh, this message translates to:
  /// **'压缩包里没有 .sjhplan 计划文件'**
  String get planLinkImportArchiveHasNoPlan;

  /// No description provided for @planLinkImportNotAPlanPackage.
  ///
  /// In zh, this message translates to:
  /// **'下载的文件不是 Koma 计划包'**
  String get planLinkImportNotAPlanPackage;

  /// No description provided for @planLinkImportReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取失败，请重试'**
  String get planLinkImportReadFailed;

  /// No description provided for @planLinkImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'从链接导入'**
  String get planLinkImportTitle;

  /// No description provided for @planLinkImportIntro.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 GitHub 发布页面或计划文件的下载链接，Koma 会下载计划并打开导入预览。'**
  String get planLinkImportIntro;

  /// No description provided for @planLinkImportWebUnavailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'网页版无法直接下载'**
  String get planLinkImportWebUnavailableTitle;

  /// No description provided for @planLinkImportWebUnavailableSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请先在浏览器中下载 .sjhplan 或 .zip，再回到“导入导出”，用“导入 Koma 文件”导入。'**
  String get planLinkImportWebUnavailableSubtitle;

  /// No description provided for @planLinkImportLinkLabel.
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get planLinkImportLinkLabel;

  /// No description provided for @planLinkImportPaste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get planLinkImportPaste;

  /// No description provided for @planLinkImportReadLink.
  ///
  /// In zh, this message translates to:
  /// **'读取链接'**
  String get planLinkImportReadLink;

  /// No description provided for @planLinkImportHelp.
  ///
  /// In zh, this message translates to:
  /// **'支持：\n• GitHub 发布页面或仓库链接（自动列出最新发布中的计划文件）\n• GitHub 发布中的文件下载链接\n• 其他 https:// 开头的 .sjhplan 或 .zip 直链\n.zip 中可以带说明等其他文件，Koma 只读取其中的 .sjhplan。下载会连接你输入的地址（以及它跳转到的下载服务器）；GitHub 发布或仓库链接还会向 api.github.com 查询发布中的文件。'**
  String get planLinkImportHelp;

  /// No description provided for @planLinkImportResolving.
  ///
  /// In zh, this message translates to:
  /// **'正在查找发布中的计划文件…'**
  String get planLinkImportResolving;

  /// No description provided for @planLinkImportChooseFile.
  ///
  /// In zh, this message translates to:
  /// **'选择要导入的文件'**
  String get planLinkImportChooseFile;

  /// No description provided for @planLinkImportArchiveTag.
  ///
  /// In zh, this message translates to:
  /// **'压缩包'**
  String get planLinkImportArchiveTag;

  /// No description provided for @planLinkImportDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载 {name}'**
  String planLinkImportDownloading(String name);

  /// No description provided for @planLinkImportDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'已下载 {size}'**
  String planLinkImportDownloaded(String size);

  /// No description provided for @planLinkImportReadingPlan.
  ///
  /// In zh, this message translates to:
  /// **'正在读取计划…'**
  String get planLinkImportReadingPlan;

  /// No description provided for @planLinkEnterLink.
  ///
  /// In zh, this message translates to:
  /// **'请输入链接'**
  String get planLinkEnterLink;

  /// No description provided for @planLinkUnrecognized.
  ///
  /// In zh, this message translates to:
  /// **'无法识别这个链接'**
  String get planLinkUnrecognized;

  /// No description provided for @planLinkHttpsOnly.
  ///
  /// In zh, this message translates to:
  /// **'只支持 https:// 开头的链接'**
  String get planLinkHttpsOnly;

  /// No description provided for @planLinkLatestRelease.
  ///
  /// In zh, this message translates to:
  /// **'{repository} 最新发布'**
  String planLinkLatestRelease(String repository);

  /// No description provided for @planLinkReleaseUnreadable.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 返回的发布信息无法读取'**
  String get planLinkReleaseUnreadable;

  /// No description provided for @planLinkTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'文件超过 128 MB 上限，无法导入'**
  String get planLinkTooLarge;

  /// No description provided for @planLinkNotPublic.
  ///
  /// In zh, this message translates to:
  /// **'不支持本机或局域网地址'**
  String get planLinkNotPublic;

  /// No description provided for @planLinkFileNotFound.
  ///
  /// In zh, this message translates to:
  /// **'链接指向的文件不存在（HTTP 404）'**
  String get planLinkFileNotFound;

  /// No description provided for @planLinkServerRefused.
  ///
  /// In zh, this message translates to:
  /// **'服务器拒绝了下载（HTTP {status}），请稍后再试'**
  String planLinkServerRefused(String status);

  /// No description provided for @planLinkDownloadFailedStatus.
  ///
  /// In zh, this message translates to:
  /// **'下载失败（HTTP {status}）'**
  String planLinkDownloadFailedStatus(String status);

  /// No description provided for @planLinkReleaseNotFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到这个发布：仓库可能是私有的、还没有发布版本，或只有预发布版本（请粘贴具体发布页链接）'**
  String get planLinkReleaseNotFound;

  /// No description provided for @planLinkGitHubRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 请求过于频繁，请稍后再试'**
  String get planLinkGitHubRateLimited;

  /// No description provided for @planLinkReleaseFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 发布信息读取失败（HTTP {status}）'**
  String planLinkReleaseFetchFailed(String status);

  /// No description provided for @planLinkCannotReachGitHub.
  ///
  /// In zh, this message translates to:
  /// **'无法连接 GitHub，请检查网络后重试'**
  String get planLinkCannotReachGitHub;

  /// No description provided for @planLinkDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败，请检查网络后重试'**
  String get planLinkDownloadFailed;

  /// No description provided for @planLinkServiceIoTempFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法创建临时文件，请检查存储空间'**
  String get planLinkServiceIoTempFileFailed;

  /// No description provided for @planLinkServiceIoSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法保存下载的文件，请检查存储空间'**
  String get planLinkServiceIoSaveFailed;

  /// No description provided for @planLinkServiceWebUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'网页版无法直接下载，请先下载文件，再用“导入 Koma 文件”导入'**
  String get planLinkServiceWebUnavailable;

  /// No description provided for @incomingPlanFileTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'导入超限：计划文件超过 {limit} MiB 上限。请拆分计划或减少打包图片后重试。'**
  String incomingPlanFileTooLarge(String limit);

  /// No description provided for @incomingPlanFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划文件导入失败'**
  String get incomingPlanFileFailed;

  /// No description provided for @planImportPackageLimitExceeded.
  ///
  /// In zh, this message translates to:
  /// **'导入超限：{resource} 为 {actual}，上限 {limit}。请拆分计划或减少打包图片后重试。'**
  String planImportPackageLimitExceeded(
    String resource,
    String actual,
    String limit,
  );

  /// No description provided for @planImportPackageResourceEntryBytes.
  ///
  /// In zh, this message translates to:
  /// **'单文件解压字节数'**
  String get planImportPackageResourceEntryBytes;

  /// No description provided for @planImportPackageResourceJsonBytes.
  ///
  /// In zh, this message translates to:
  /// **'JSON 字节数'**
  String get planImportPackageResourceJsonBytes;

  /// No description provided for @planImportPackageResourceExpandedBytes.
  ///
  /// In zh, this message translates to:
  /// **'总解压字节数'**
  String get planImportPackageResourceExpandedBytes;

  /// No description provided for @planImportPackageResourceArchiveBytes.
  ///
  /// In zh, this message translates to:
  /// **'压缩包字节数'**
  String get planImportPackageResourceArchiveBytes;

  /// No description provided for @planImportPackageResourcePlanFileBytes.
  ///
  /// In zh, this message translates to:
  /// **'计划文件字节数'**
  String get planImportPackageResourcePlanFileBytes;

  /// No description provided for @planImportPackageResourceZipEntries.
  ///
  /// In zh, this message translates to:
  /// **'ZIP 条目数'**
  String get planImportPackageResourceZipEntries;

  /// No description provided for @planImportPackageResourceImagePixels.
  ///
  /// In zh, this message translates to:
  /// **'图片像素（{width} x {height} x {frames} 帧）'**
  String planImportPackageResourceImagePixels(
    String width,
    String height,
    String frames,
  );

  /// No description provided for @planImportPackageV2Label.
  ///
  /// In zh, this message translates to:
  /// **'v2 数据包'**
  String get planImportPackageV2Label;

  /// No description provided for @planImportPackageInvalidCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位坐标无效，已改为待补充坐标'**
  String planImportPackageInvalidCoordinates(int count);

  /// No description provided for @planImportPackageUnnamedArea.
  ///
  /// In zh, this message translates to:
  /// **'未命名片区'**
  String get planImportPackageUnnamedArea;

  /// No description provided for @planPackageDefaultPlanName.
  ///
  /// In zh, this message translates to:
  /// **'导入的巡礼计划'**
  String get planPackageDefaultPlanName;

  /// No description provided for @planPackageNoArea.
  ///
  /// In zh, this message translates to:
  /// **'未设置区域'**
  String get planPackageNoArea;

  /// No description provided for @planPackageUnknownWork.
  ///
  /// In zh, this message translates to:
  /// **'未知作品'**
  String get planPackageUnknownWork;

  /// No description provided for @planPackageNoRegion.
  ///
  /// In zh, this message translates to:
  /// **'未设置地区'**
  String get planPackageNoRegion;

  /// No description provided for @planPackageUnnamedSpot.
  ///
  /// In zh, this message translates to:
  /// **'未命名点位'**
  String get planPackageUnnamedSpot;

  /// No description provided for @planPackageUnknownReferenceMode.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get planPackageUnknownReferenceMode;

  /// No description provided for @planExportV2DeletedDuringExport.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个文件在导出过程中被删除，未包含在数据包中'**
  String planExportV2DeletedDuringExport(int count);

  /// No description provided for @planExportV2CsvWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get planExportV2CsvWork;

  /// No description provided for @planExportV2CsvArea.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get planExportV2CsvArea;

  /// No description provided for @planExportV2CsvSpotName.
  ///
  /// In zh, this message translates to:
  /// **'点位名'**
  String get planExportV2CsvSpotName;

  /// No description provided for @planExportV2CsvSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'副标题'**
  String get planExportV2CsvSubtitle;

  /// No description provided for @planExportV2CsvLatitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get planExportV2CsvLatitude;

  /// No description provided for @planExportV2CsvLongitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get planExportV2CsvLongitude;

  /// No description provided for @planExportV2CsvEpisode.
  ///
  /// In zh, this message translates to:
  /// **'集数/场景'**
  String get planExportV2CsvEpisode;

  /// No description provided for @planExportV2CsvSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get planExportV2CsvSource;

  /// No description provided for @planExportV2CsvSourceId.
  ///
  /// In zh, this message translates to:
  /// **'来源ID'**
  String get planExportV2CsvSourceId;

  /// No description provided for @planExportV2CsvReferenceUrl.
  ///
  /// In zh, this message translates to:
  /// **'参考图URL'**
  String get planExportV2CsvReferenceUrl;

  /// No description provided for @planExportV2CsvCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get planExportV2CsvCompleted;

  /// No description provided for @planExportV2CsvRecordCount.
  ///
  /// In zh, this message translates to:
  /// **'记录数'**
  String get planExportV2CsvRecordCount;

  /// No description provided for @planExportV2CsvRecordId.
  ///
  /// In zh, this message translates to:
  /// **'记录ID'**
  String get planExportV2CsvRecordId;

  /// No description provided for @planExportV2CsvCapturedAt.
  ///
  /// In zh, this message translates to:
  /// **'拍摄时间'**
  String get planExportV2CsvCapturedAt;

  /// No description provided for @planExportV2CsvReferenceMode.
  ///
  /// In zh, this message translates to:
  /// **'参考模式'**
  String get planExportV2CsvReferenceMode;

  /// No description provided for @planExportV2CsvColorMatched.
  ///
  /// In zh, this message translates to:
  /// **'是否调色'**
  String get planExportV2CsvColorMatched;

  /// No description provided for @planExportV2CsvPhotoFile.
  ///
  /// In zh, this message translates to:
  /// **'照片文件名'**
  String get planExportV2CsvPhotoFile;

  /// No description provided for @planExportV2CsvGradedPhotoFile.
  ///
  /// In zh, this message translates to:
  /// **'调色照片文件名'**
  String get planExportV2CsvGradedPhotoFile;

  /// No description provided for @planExportV2CsvYes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get planExportV2CsvYes;

  /// No description provided for @planExportV2CsvNo.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get planExportV2CsvNo;

  /// No description provided for @planExportV2Ungrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get planExportV2Ungrouped;

  /// No description provided for @planExportV2UnknownArea.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get planExportV2UnknownArea;

  /// No description provided for @myMapsCsvExportUngrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get myMapsCsvExportUngrouped;

  /// No description provided for @colorGradingParamsModeNatural.
  ///
  /// In zh, this message translates to:
  /// **'自然'**
  String get colorGradingParamsModeNatural;

  /// No description provided for @colorGradingParamsModeStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get colorGradingParamsModeStandard;

  /// No description provided for @colorGradingParamsModeStrong.
  ///
  /// In zh, this message translates to:
  /// **'强匹配'**
  String get colorGradingParamsModeStrong;

  /// No description provided for @colorGradingParameterSummaryIntensity.
  ///
  /// In zh, this message translates to:
  /// **'调色强度'**
  String get colorGradingParameterSummaryIntensity;

  /// No description provided for @colorGradingParameterSummaryParameters.
  ///
  /// In zh, this message translates to:
  /// **'调色参数'**
  String get colorGradingParameterSummaryParameters;

  /// No description provided for @colorGradingParameterSummaryView.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get colorGradingParameterSummaryView;

  /// No description provided for @colorGradingParameterSummaryDescription.
  ///
  /// In zh, this message translates to:
  /// **'显示当前调色强度下实际生效的参数。'**
  String get colorGradingParameterSummaryDescription;

  /// No description provided for @colorGradingParameterSummaryBrightness.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get colorGradingParameterSummaryBrightness;

  /// No description provided for @colorGradingParameterSummaryExposure.
  ///
  /// In zh, this message translates to:
  /// **'曝光'**
  String get colorGradingParameterSummaryExposure;

  /// No description provided for @colorGradingParameterSummaryContrast.
  ///
  /// In zh, this message translates to:
  /// **'对比度'**
  String get colorGradingParameterSummaryContrast;

  /// No description provided for @colorGradingParameterSummarySaturation.
  ///
  /// In zh, this message translates to:
  /// **'饱和度'**
  String get colorGradingParameterSummarySaturation;

  /// No description provided for @colorGradingParameterSummaryTemperature.
  ///
  /// In zh, this message translates to:
  /// **'色温'**
  String get colorGradingParameterSummaryTemperature;

  /// No description provided for @colorGradingParameterSummaryTint.
  ///
  /// In zh, this message translates to:
  /// **'色调'**
  String get colorGradingParameterSummaryTint;

  /// No description provided for @colorGradingParameterSummaryHighlights.
  ///
  /// In zh, this message translates to:
  /// **'高光'**
  String get colorGradingParameterSummaryHighlights;

  /// No description provided for @colorGradingParameterSummaryShadows.
  ///
  /// In zh, this message translates to:
  /// **'阴影'**
  String get colorGradingParameterSummaryShadows;

  /// No description provided for @colorGradingParameterSummaryRedShadowCurve.
  ///
  /// In zh, this message translates to:
  /// **'红暗部曲线'**
  String get colorGradingParameterSummaryRedShadowCurve;

  /// No description provided for @colorGradingParameterSummaryRedMidCurve.
  ///
  /// In zh, this message translates to:
  /// **'红中间调曲线'**
  String get colorGradingParameterSummaryRedMidCurve;

  /// No description provided for @colorGradingParameterSummaryRedHighlightCurve.
  ///
  /// In zh, this message translates to:
  /// **'红高光曲线'**
  String get colorGradingParameterSummaryRedHighlightCurve;

  /// No description provided for @colorGradingParameterSummaryGreenShadowCurve.
  ///
  /// In zh, this message translates to:
  /// **'绿暗部曲线'**
  String get colorGradingParameterSummaryGreenShadowCurve;

  /// No description provided for @colorGradingParameterSummaryGreenMidCurve.
  ///
  /// In zh, this message translates to:
  /// **'绿中间调曲线'**
  String get colorGradingParameterSummaryGreenMidCurve;

  /// No description provided for @colorGradingParameterSummaryGreenHighlightCurve.
  ///
  /// In zh, this message translates to:
  /// **'绿高光曲线'**
  String get colorGradingParameterSummaryGreenHighlightCurve;

  /// No description provided for @colorGradingParameterSummaryBlueShadowCurve.
  ///
  /// In zh, this message translates to:
  /// **'蓝暗部曲线'**
  String get colorGradingParameterSummaryBlueShadowCurve;

  /// No description provided for @colorGradingParameterSummaryBlueMidCurve.
  ///
  /// In zh, this message translates to:
  /// **'蓝中间调曲线'**
  String get colorGradingParameterSummaryBlueMidCurve;

  /// No description provided for @colorGradingParameterSummaryBlueHighlightCurve.
  ///
  /// In zh, this message translates to:
  /// **'蓝高光曲线'**
  String get colorGradingParameterSummaryBlueHighlightCurve;

  /// No description provided for @colorGradingAutoMatchFailed.
  ///
  /// In zh, this message translates to:
  /// **'自动调色失败'**
  String get colorGradingAutoMatchFailed;

  /// No description provided for @colorGradingPhotoReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图读取失败'**
  String get colorGradingPhotoReadFailed;

  /// No description provided for @colorGradingNoReferenceForMatch.
  ///
  /// In zh, this message translates to:
  /// **'没有可用于自动调色的参考图'**
  String get colorGradingNoReferenceForMatch;

  /// No description provided for @colorGradingReferenceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'参考图暂不可用，无法自动匹配色调'**
  String get colorGradingReferenceUnavailable;

  /// No description provided for @colorGradingAutoMatchDone.
  ///
  /// In zh, this message translates to:
  /// **'已生成自动调色参数'**
  String get colorGradingAutoMatchDone;

  /// No description provided for @colorGradingSaveFailedOriginalKept.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，原件未更改'**
  String get colorGradingSaveFailedOriginalKept;

  /// No description provided for @colorGradingRestoredOriginal.
  ///
  /// In zh, this message translates to:
  /// **'已还原为原图'**
  String get colorGradingRestoredOriginal;

  /// No description provided for @colorGradingMatchFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先自动匹配色调'**
  String get colorGradingMatchFirst;

  /// No description provided for @colorGradingSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get colorGradingSaveFailed;

  /// No description provided for @colorGradingSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存调色结果'**
  String get colorGradingSaved;

  /// No description provided for @colorGradingResetTitle.
  ///
  /// In zh, this message translates to:
  /// **'重置调色'**
  String get colorGradingResetTitle;

  /// No description provided for @colorGradingResetMessage.
  ///
  /// In zh, this message translates to:
  /// **'将清除当前调色，恢复为原图。'**
  String get colorGradingResetMessage;

  /// No description provided for @colorGradingReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get colorGradingReset;

  /// No description provided for @colorGradingTitle.
  ///
  /// In zh, this message translates to:
  /// **'自动调色'**
  String get colorGradingTitle;

  /// No description provided for @colorGradingMatching.
  ///
  /// In zh, this message translates to:
  /// **'匹配中...'**
  String get colorGradingMatching;

  /// No description provided for @colorGradingAutoMatch.
  ///
  /// In zh, this message translates to:
  /// **'自动匹配色调'**
  String get colorGradingAutoMatch;

  /// No description provided for @colorGradingReference.
  ///
  /// In zh, this message translates to:
  /// **'参考图'**
  String get colorGradingReference;

  /// No description provided for @colorGradingNoReference.
  ///
  /// In zh, this message translates to:
  /// **'没有参考图'**
  String get colorGradingNoReference;

  /// No description provided for @colorGradingOriginal.
  ///
  /// In zh, this message translates to:
  /// **'原图'**
  String get colorGradingOriginal;

  /// No description provided for @colorGradingGraded.
  ///
  /// In zh, this message translates to:
  /// **'调色后'**
  String get colorGradingGraded;

  /// No description provided for @colorGradingShowingOriginal.
  ///
  /// In zh, this message translates to:
  /// **'正在显示原图'**
  String get colorGradingShowingOriginal;

  /// No description provided for @colorGradingHoldForOriginal.
  ///
  /// In zh, this message translates to:
  /// **'按住显示原图'**
  String get colorGradingHoldForOriginal;

  /// No description provided for @colorGradingMatchMode.
  ///
  /// In zh, this message translates to:
  /// **'匹配模式'**
  String get colorGradingMatchMode;

  /// No description provided for @colorGradingParamsReady.
  ///
  /// In zh, this message translates to:
  /// **'已恢复或生成调色参数，可保存结果'**
  String get colorGradingParamsReady;

  /// No description provided for @colorGradingMatchToSave.
  ///
  /// In zh, this message translates to:
  /// **'自动匹配后可保存调色结果'**
  String get colorGradingMatchToSave;

  /// No description provided for @colorGradingToneMatch.
  ///
  /// In zh, this message translates to:
  /// **'色调匹配'**
  String get colorGradingToneMatch;

  /// No description provided for @colorGradingCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get colorGradingCurrent;

  /// No description provided for @colorGradingSaveResult.
  ///
  /// In zh, this message translates to:
  /// **'保存结果'**
  String get colorGradingSaveResult;

  /// No description provided for @colorGradingSaveDescription.
  ///
  /// In zh, this message translates to:
  /// **'保存后记录详情和导出会使用调色后的图片，原图和调色参数会保留。'**
  String get colorGradingSaveDescription;

  /// No description provided for @colorGradingSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中...'**
  String get colorGradingSaving;

  /// No description provided for @colorGradingSaveColorMatch.
  ///
  /// In zh, this message translates to:
  /// **'保存调色结果'**
  String get colorGradingSaveColorMatch;

  /// No description provided for @comparisonExportConfigJpegRecommended.
  ///
  /// In zh, this message translates to:
  /// **'JPEG 推荐 (85)'**
  String get comparisonExportConfigJpegRecommended;

  /// No description provided for @comparisonExportConfigJpegHighQuality.
  ///
  /// In zh, this message translates to:
  /// **'JPEG 高画质 (95)'**
  String get comparisonExportConfigJpegHighQuality;

  /// No description provided for @comparisonExportConfigPngLossless.
  ///
  /// In zh, this message translates to:
  /// **'PNG 无损'**
  String get comparisonExportConfigPngLossless;

  /// No description provided for @comparisonExportConfigWidthAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get comparisonExportConfigWidthAuto;

  /// No description provided for @comparisonExportConfigFieldCapturedAt.
  ///
  /// In zh, this message translates to:
  /// **'拍摄时间'**
  String get comparisonExportConfigFieldCapturedAt;

  /// No description provided for @comparisonExportConfigFieldWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get comparisonExportConfigFieldWork;

  /// No description provided for @comparisonExportConfigFieldPlace.
  ///
  /// In zh, this message translates to:
  /// **'地点'**
  String get comparisonExportConfigFieldPlace;

  /// No description provided for @comparisonExportConfigFieldCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'坐标'**
  String get comparisonExportConfigFieldCoordinates;

  /// No description provided for @comparisonExportConfigFieldScene.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get comparisonExportConfigFieldScene;

  /// No description provided for @comparisonExportConfigEditorColorWhite.
  ///
  /// In zh, this message translates to:
  /// **'白色'**
  String get comparisonExportConfigEditorColorWhite;

  /// No description provided for @comparisonExportConfigEditorColorBlack.
  ///
  /// In zh, this message translates to:
  /// **'黑色'**
  String get comparisonExportConfigEditorColorBlack;

  /// No description provided for @comparisonExportConfigEditorColorTheme.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get comparisonExportConfigEditorColorTheme;

  /// No description provided for @comparisonExportConfigEditorAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get comparisonExportConfigEditorAppearance;

  /// No description provided for @comparisonExportConfigEditorFormat.
  ///
  /// In zh, this message translates to:
  /// **'图片格式与质量'**
  String get comparisonExportConfigEditorFormat;

  /// No description provided for @comparisonExportConfigEditorSummaryWidth.
  ///
  /// In zh, this message translates to:
  /// **'宽度 {width}'**
  String comparisonExportConfigEditorSummaryWidth(String width);

  /// No description provided for @comparisonExportConfigEditorSummaryNoBorder.
  ///
  /// In zh, this message translates to:
  /// **'无边框'**
  String get comparisonExportConfigEditorSummaryNoBorder;

  /// No description provided for @comparisonExportConfigEditorSummaryBorder.
  ///
  /// In zh, this message translates to:
  /// **'边框 {percent}%'**
  String comparisonExportConfigEditorSummaryBorder(String percent);

  /// No description provided for @comparisonExportConfigEditorSummaryLabelsOn.
  ///
  /// In zh, this message translates to:
  /// **'显示标签'**
  String get comparisonExportConfigEditorSummaryLabelsOn;

  /// No description provided for @comparisonExportConfigEditorSummaryLabelsOff.
  ///
  /// In zh, this message translates to:
  /// **'不显示标签'**
  String get comparisonExportConfigEditorSummaryLabelsOff;

  /// No description provided for @comparisonExportConfigEditorSummaryPilgrim.
  ///
  /// In zh, this message translates to:
  /// **'巡礼者 {name}'**
  String comparisonExportConfigEditorSummaryPilgrim(String name);

  /// No description provided for @comparisonExportConfigEditorBorderWidth.
  ///
  /// In zh, this message translates to:
  /// **'边框宽度'**
  String get comparisonExportConfigEditorBorderWidth;

  /// No description provided for @comparisonExportConfigEditorNone.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get comparisonExportConfigEditorNone;

  /// No description provided for @comparisonExportConfigEditorBorderColor.
  ///
  /// In zh, this message translates to:
  /// **'边框颜色'**
  String get comparisonExportConfigEditorBorderColor;

  /// No description provided for @comparisonExportConfigEditorAutoWidthTitle.
  ///
  /// In zh, this message translates to:
  /// **'自动输出宽度'**
  String get comparisonExportConfigEditorAutoWidthTitle;

  /// No description provided for @comparisonExportConfigEditorAutoWidthSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'根据图片尺寸自动确定输出宽度'**
  String get comparisonExportConfigEditorAutoWidthSubtitle;

  /// No description provided for @comparisonExportConfigEditorShowLabelsTitle.
  ///
  /// In zh, this message translates to:
  /// **'显示标签'**
  String get comparisonExportConfigEditorShowLabelsTitle;

  /// No description provided for @comparisonExportConfigEditorShowLabelsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在参考图上显示“参考”字样，在你拍的巡礼图上显示“巡礼”字样'**
  String get comparisonExportConfigEditorShowLabelsSubtitle;

  /// No description provided for @comparisonExportConfigEditorMetadata.
  ///
  /// In zh, this message translates to:
  /// **'元数据'**
  String get comparisonExportConfigEditorMetadata;

  /// No description provided for @comparisonExportConfigEditorShowPilgrimTitle.
  ///
  /// In zh, this message translates to:
  /// **'显示巡礼者名字'**
  String get comparisonExportConfigEditorShowPilgrimTitle;

  /// No description provided for @comparisonExportConfigEditorShowPilgrimSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在图片上显示巡礼者名字'**
  String get comparisonExportConfigEditorShowPilgrimSubtitle;

  /// No description provided for @comparisonExportConfigEditorPilgrimHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入巡礼者名字'**
  String get comparisonExportConfigEditorPilgrimHint;

  /// No description provided for @comparisonExportConfigEditorShowGradingTitle.
  ///
  /// In zh, this message translates to:
  /// **'显示调色参数'**
  String get comparisonExportConfigEditorShowGradingTitle;

  /// No description provided for @comparisonExportConfigEditorShowGradingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在图片底部显示调色相关参数'**
  String get comparisonExportConfigEditorShowGradingSubtitle;

  /// No description provided for @comparisonExportConfigEditorContent.
  ///
  /// In zh, this message translates to:
  /// **'显示内容'**
  String get comparisonExportConfigEditorContent;

  /// No description provided for @comparisonExportBudgetSizeUnfit.
  ///
  /// In zh, this message translates to:
  /// **'对比图尺寸无法满足输出限制：最多 {maxPixels} 像素，最长边 {maxEdge} 像素。'**
  String comparisonExportBudgetSizeUnfit(int maxPixels, int maxEdge);

  /// No description provided for @comparisonExportBudgetTooNarrow.
  ///
  /// In zh, this message translates to:
  /// **'对比图比例过于狭长，无法在 {maxPixels} 像素、最长边 {maxEdge} 像素内完整输出。'**
  String comparisonExportBudgetTooNarrow(int maxPixels, int maxEdge);

  /// No description provided for @comparisonExportSupportShareText.
  ///
  /// In zh, this message translates to:
  /// **'Koma 对比图'**
  String get comparisonExportSupportShareText;

  /// No description provided for @comparisonExportLoadSettingsFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取导出设置失败，请重试。'**
  String get comparisonExportLoadSettingsFailed;

  /// No description provided for @comparisonExportSaveSettingsFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出设置保存失败，导出时将重试。'**
  String get comparisonExportSaveSettingsFailed;

  /// No description provided for @comparisonExportBrowserDownload.
  ///
  /// In zh, this message translates to:
  /// **'对比图已交给浏览器下载'**
  String get comparisonExportBrowserDownload;

  /// No description provided for @comparisonExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，设置或图片未能保存，请重试。'**
  String get comparisonExportFailed;

  /// No description provided for @comparisonExportReferenceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'参考图不可用，无法导出对比图片。'**
  String get comparisonExportReferenceUnavailable;

  /// No description provided for @comparisonExportPhotoUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图不可用，无法导出对比图片。'**
  String get comparisonExportPhotoUnavailable;

  /// No description provided for @comparisonExportBudgetExceeded.
  ///
  /// In zh, this message translates to:
  /// **'图片超过处理预算，原件未更改。'**
  String get comparisonExportBudgetExceeded;

  /// No description provided for @comparisonExportUnsupportedFormat.
  ///
  /// In zh, this message translates to:
  /// **'当前平台不支持处理此图片格式。'**
  String get comparisonExportUnsupportedFormat;

  /// No description provided for @comparisonExportInvalidData.
  ///
  /// In zh, this message translates to:
  /// **'图片数据无法解码。'**
  String get comparisonExportInvalidData;

  /// No description provided for @comparisonExportRenderFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请稍后重试。'**
  String get comparisonExportRenderFailed;

  /// No description provided for @comparisonExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出对比图'**
  String get comparisonExportTitle;

  /// No description provided for @comparisonExportShortLabel.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get comparisonExportShortLabel;

  /// No description provided for @comparisonExportRendererReference.
  ///
  /// In zh, this message translates to:
  /// **'参考'**
  String get comparisonExportRendererReference;

  /// No description provided for @comparisonExportRendererPilgrimage.
  ///
  /// In zh, this message translates to:
  /// **'巡礼'**
  String get comparisonExportRendererPilgrimage;

  /// No description provided for @comparisonExportRendererPilgrim.
  ///
  /// In zh, this message translates to:
  /// **'巡礼者'**
  String get comparisonExportRendererPilgrim;

  /// No description provided for @gallerySaveResultFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请稍后重试。'**
  String get gallerySaveResultFailed;

  /// No description provided for @gallerySaveResultSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相册'**
  String get gallerySaveResultSaved;

  /// No description provided for @gallerySaveResultPermissionTitle.
  ///
  /// In zh, this message translates to:
  /// **'需要相册权限'**
  String get gallerySaveResultPermissionTitle;

  /// No description provided for @gallerySaveResultPermissionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中允许 Koma 添加照片。'**
  String get gallerySaveResultPermissionSubtitle;

  /// No description provided for @gallerySaveResultSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get gallerySaveResultSettings;

  /// No description provided for @photoCompareSliderViewReference.
  ///
  /// In zh, this message translates to:
  /// **'查看参考图'**
  String get photoCompareSliderViewReference;

  /// No description provided for @photoCompareSliderViewPhoto.
  ///
  /// In zh, this message translates to:
  /// **'查看巡礼图'**
  String get photoCompareSliderViewPhoto;

  /// No description provided for @photoCompareSliderSemantics.
  ///
  /// In zh, this message translates to:
  /// **'滑动对比，左侧参考图，右侧巡礼图'**
  String get photoCompareSliderSemantics;

  /// No description provided for @photoCompareSliderReference.
  ///
  /// In zh, this message translates to:
  /// **'参考图'**
  String get photoCompareSliderReference;

  /// No description provided for @photoCompareSliderPhoto.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图'**
  String get photoCompareSliderPhoto;

  /// No description provided for @pointVisitRecordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'点位拍摄记录'**
  String get pointVisitRecordsTitle;

  /// No description provided for @pointVisitRecordsCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, other{条}}'**
  String pointVisitRecordsCountUnit(int count);

  /// No description provided for @pointVisitRecordsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这个点位还没有拍摄记录'**
  String get pointVisitRecordsEmpty;

  /// No description provided for @pointVisitRecordsListLabel.
  ///
  /// In zh, this message translates to:
  /// **'拍摄记录'**
  String get pointVisitRecordsListLabel;

  /// No description provided for @pointVisitRecordsColorMatched.
  ///
  /// In zh, this message translates to:
  /// **'已调色'**
  String get pointVisitRecordsColorMatched;

  /// No description provided for @visitRecordDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录详情'**
  String get visitRecordDetailTitle;

  /// No description provided for @visitRecordDetailDeleteTooltip.
  ///
  /// In zh, this message translates to:
  /// **'删除记录'**
  String get visitRecordDetailDeleteTooltip;

  /// No description provided for @visitRecordDetailCapturedAt.
  ///
  /// In zh, this message translates to:
  /// **'拍摄时间'**
  String get visitRecordDetailCapturedAt;

  /// No description provided for @visitRecordDetailArea.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get visitRecordDetailArea;

  /// No description provided for @visitRecordDetailScene.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get visitRecordDetailScene;

  /// No description provided for @visitRecordDetailDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除记录'**
  String get visitRecordDetailDeleteTitle;

  /// No description provided for @visitRecordDetailDeleteTarget.
  ///
  /// In zh, this message translates to:
  /// **'这条巡礼记录'**
  String get visitRecordDetailDeleteTarget;

  /// No description provided for @visitRecordDetailDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除{target}，不会改变点位完成状态。'**
  String visitRecordDetailDeleteMessage(String target);

  /// No description provided for @visitRecordDetailDeleteFiles.
  ///
  /// In zh, this message translates to:
  /// **'同时删除照片文件'**
  String get visitRecordDetailDeleteFiles;

  /// No description provided for @visitRecordDetailDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除记录失败，照片未删除，请重试'**
  String get visitRecordDetailDeleteFailed;

  /// No description provided for @visitRecordDetailDeletedPartly.
  ///
  /// In zh, this message translates to:
  /// **'记录已删除，部分照片未清理'**
  String get visitRecordDetailDeletedPartly;

  /// No description provided for @visitRecordDetailPhotoUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图不可用，无法导出对比图片。'**
  String get visitRecordDetailPhotoUnavailable;

  /// No description provided for @visitRecordDetailNoPrefsStorage.
  ///
  /// In zh, this message translates to:
  /// **'当前平台暂不支持保存导出偏好。'**
  String get visitRecordDetailNoPrefsStorage;

  /// No description provided for @visitRecordDetailUngrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get visitRecordDetailUngrouped;

  /// No description provided for @visitRecordDetailUnknownArea.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get visitRecordDetailUnknownArea;

  /// No description provided for @visitRecordDetailBrightness.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get visitRecordDetailBrightness;

  /// No description provided for @visitRecordDetailExposure.
  ///
  /// In zh, this message translates to:
  /// **'曝光'**
  String get visitRecordDetailExposure;

  /// No description provided for @visitRecordDetailContrast.
  ///
  /// In zh, this message translates to:
  /// **'对比'**
  String get visitRecordDetailContrast;

  /// No description provided for @visitRecordDetailSaturation.
  ///
  /// In zh, this message translates to:
  /// **'饱和'**
  String get visitRecordDetailSaturation;

  /// No description provided for @visitRecordDetailTemperature.
  ///
  /// In zh, this message translates to:
  /// **'色温'**
  String get visitRecordDetailTemperature;

  /// No description provided for @visitRecordDetailTint.
  ///
  /// In zh, this message translates to:
  /// **'色调'**
  String get visitRecordDetailTint;

  /// No description provided for @visitRecordDetailHighlights.
  ///
  /// In zh, this message translates to:
  /// **'高光'**
  String get visitRecordDetailHighlights;

  /// No description provided for @visitRecordDetailShadows.
  ///
  /// In zh, this message translates to:
  /// **'阴影'**
  String get visitRecordDetailShadows;

  /// No description provided for @visitRecordDetailCurveShadows.
  ///
  /// In zh, this message translates to:
  /// **'{channel}暗'**
  String visitRecordDetailCurveShadows(String channel);

  /// No description provided for @visitRecordDetailCurveMids.
  ///
  /// In zh, this message translates to:
  /// **'{channel}中'**
  String visitRecordDetailCurveMids(String channel);

  /// No description provided for @visitRecordDetailCurveHighlights.
  ///
  /// In zh, this message translates to:
  /// **'{channel}亮'**
  String visitRecordDetailCurveHighlights(String channel);

  /// No description provided for @visitRecordDetailModeStacked.
  ///
  /// In zh, this message translates to:
  /// **'上下'**
  String get visitRecordDetailModeStacked;

  /// No description provided for @visitRecordDetailModeSlider.
  ///
  /// In zh, this message translates to:
  /// **'滑动对比'**
  String get visitRecordDetailModeSlider;

  /// No description provided for @visitRecordDetailReference.
  ///
  /// In zh, this message translates to:
  /// **'参考图'**
  String get visitRecordDetailReference;

  /// No description provided for @visitRecordDetailPhoto.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图'**
  String get visitRecordDetailPhoto;

  /// No description provided for @visitRecordDetailOrphan.
  ///
  /// In zh, this message translates to:
  /// **'这条记录对应的点位已不在当前计划中，照片和导出功能仍然可以使用。'**
  String get visitRecordDetailOrphan;

  /// No description provided for @visitRecordDetailColorMatchTitle.
  ///
  /// In zh, this message translates to:
  /// **'自动调色'**
  String get visitRecordDetailColorMatchTitle;

  /// No description provided for @visitRecordDetailColorMatchSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'优化巡礼照片'**
  String get visitRecordDetailColorMatchSubtitle;

  /// No description provided for @visitRecordDetailExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出对比图'**
  String get visitRecordDetailExportTitle;

  /// No description provided for @visitRecordDetailExportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'生成分享图片'**
  String get visitRecordDetailExportSubtitle;

  /// No description provided for @recordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get recordsTitle;

  /// No description provided for @recordsCollapseAll.
  ///
  /// In zh, this message translates to:
  /// **'收起全部片区'**
  String get recordsCollapseAll;

  /// No description provided for @recordsExpandAll.
  ///
  /// In zh, this message translates to:
  /// **'展开全部片区'**
  String get recordsExpandAll;

  /// No description provided for @recordsUngrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get recordsUngrouped;

  /// No description provided for @recordsUngroupedSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有放入片区的记录'**
  String get recordsUngroupedSubtitle;

  /// No description provided for @recordsOrphan.
  ///
  /// In zh, this message translates to:
  /// **'孤立记录'**
  String get recordsOrphan;

  /// No description provided for @recordsOrphanSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'对应点位已不在当前计划中'**
  String get recordsOrphanSubtitle;

  /// No description provided for @recordsNoCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'坐标待补充'**
  String get recordsNoCoordinates;

  /// No description provided for @recordsUnknownArea.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get recordsUnknownArea;

  /// No description provided for @recordsNoAnchor.
  ///
  /// In zh, this message translates to:
  /// **'未设置关键点'**
  String get recordsNoAnchor;

  /// No description provided for @recordsScopeFilterTooltip.
  ///
  /// In zh, this message translates to:
  /// **'按作品和片区筛选'**
  String get recordsScopeFilterTooltip;

  /// No description provided for @recordsWorks.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get recordsWorks;

  /// No description provided for @recordsAreas.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get recordsAreas;

  /// No description provided for @recordsFilterTitle.
  ///
  /// In zh, this message translates to:
  /// **'筛选记录'**
  String get recordsFilterTitle;

  /// No description provided for @recordsClear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get recordsClear;

  /// No description provided for @recordsScopeSummary.
  ///
  /// In zh, this message translates to:
  /// **'已选：作品 {works} · 片区 {areas}'**
  String recordsScopeSummary(int works, int areas);

  /// No description provided for @recordsAllWorks.
  ///
  /// In zh, this message translates to:
  /// **'全部作品'**
  String get recordsAllWorks;

  /// No description provided for @recordsAllAreas.
  ///
  /// In zh, this message translates to:
  /// **'全部片区'**
  String get recordsAllAreas;

  /// No description provided for @recordsWorksPicked.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 个作品'**
  String recordsWorksPicked(int count);

  /// No description provided for @recordsAreasPicked.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 个片区'**
  String recordsAreasPicked(int count);

  /// No description provided for @recordsApplyAll.
  ///
  /// In zh, this message translates to:
  /// **'应用筛选（全部点位）'**
  String get recordsApplyAll;

  /// No description provided for @recordsApplySelected.
  ///
  /// In zh, this message translates to:
  /// **'应用筛选（已选择）'**
  String get recordsApplySelected;

  /// No description provided for @recordsBackToFilter.
  ///
  /// In zh, this message translates to:
  /// **'返回筛选记录'**
  String get recordsBackToFilter;

  /// No description provided for @recordsSelectWorks.
  ///
  /// In zh, this message translates to:
  /// **'选择作品'**
  String get recordsSelectWorks;

  /// No description provided for @recordsSelectAreas.
  ///
  /// In zh, this message translates to:
  /// **'选择片区'**
  String get recordsSelectAreas;

  /// No description provided for @recordsNoOptions.
  ///
  /// In zh, this message translates to:
  /// **'暂无可筛选项'**
  String get recordsNoOptions;

  /// No description provided for @recordsWorkBadge.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get recordsWorkBadge;

  /// No description provided for @recordsAreaBadge.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get recordsAreaBadge;

  /// No description provided for @recordsWorksChosen.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 个作品'**
  String recordsWorksChosen(int count);

  /// No description provided for @recordsAreasChosen.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 个片区'**
  String recordsAreasChosen(int count);

  /// No description provided for @recordsConfirmCount.
  ///
  /// In zh, this message translates to:
  /// **'确定（{count}）'**
  String recordsConfirmCount(int count);

  /// No description provided for @recordsStatusAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get recordsStatusAll;

  /// No description provided for @recordsStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get recordsStatusCompleted;

  /// No description provided for @recordsStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'未完成'**
  String get recordsStatusPending;

  /// No description provided for @recordsStatusTooltip.
  ///
  /// In zh, this message translates to:
  /// **'按状态筛选'**
  String get recordsStatusTooltip;

  /// No description provided for @recordsSelectStatus.
  ///
  /// In zh, this message translates to:
  /// **'选择状态'**
  String get recordsSelectStatus;

  /// No description provided for @recordsSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索记录'**
  String get recordsSearchHint;

  /// No description provided for @recordsClearSearchTooltip.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get recordsClearSearchTooltip;

  /// No description provided for @recordsPhotos.
  ///
  /// In zh, this message translates to:
  /// **'巡礼照片'**
  String get recordsPhotos;

  /// No description provided for @recordsRecordCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, other{条巡礼记录}}'**
  String recordsRecordCountLabel(int count);

  /// No description provided for @recordsCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get recordsCompleted;

  /// No description provided for @recordsEmptySearchTitle.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关记录'**
  String get recordsEmptySearchTitle;

  /// No description provided for @recordsEmptyFilterTitle.
  ///
  /// In zh, this message translates to:
  /// **'没有符合筛选条件的记录'**
  String get recordsEmptyFilterTitle;

  /// No description provided for @recordsEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有巡礼记录'**
  String get recordsEmptyTitle;

  /// No description provided for @recordsEmptySearchFilterBody.
  ///
  /// In zh, this message translates to:
  /// **'没有与当前关键词和筛选条件同时匹配的点位、作品或场景。试试更换关键词，或重置筛选条件。'**
  String get recordsEmptySearchFilterBody;

  /// No description provided for @recordsEmptySearchBody.
  ///
  /// In zh, this message translates to:
  /// **'没有与当前关键词匹配的点位、作品或场景。试试更换关键词，或清除搜索查看全部记录。'**
  String get recordsEmptySearchBody;

  /// No description provided for @recordsEmptyFilterBody.
  ///
  /// In zh, this message translates to:
  /// **'调整状态、作品或片区筛选条件后再试。'**
  String get recordsEmptyFilterBody;

  /// No description provided for @recordsEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'完成一次点位拍摄后，记录会自动汇总到这里。'**
  String get recordsEmptyBody;

  /// No description provided for @recordsClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索'**
  String get recordsClearSearch;

  /// No description provided for @recordsResetFilters.
  ///
  /// In zh, this message translates to:
  /// **'重置筛选'**
  String get recordsResetFilters;

  /// No description provided for @recordsColorMatched.
  ///
  /// In zh, this message translates to:
  /// **'已调色'**
  String get recordsColorMatched;

  /// No description provided for @copyableTextCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copyableTextCopy;

  /// No description provided for @confirmActionGotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get confirmActionGotIt;

  /// No description provided for @confirmActionIrreversible.
  ///
  /// In zh, this message translates to:
  /// **'此操作无法撤销'**
  String get confirmActionIrreversible;

  /// No description provided for @appBackButtonLabel.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get appBackButtonLabel;

  /// No description provided for @clearAnchorSelectionButtonTooltip.
  ///
  /// In zh, this message translates to:
  /// **'清除选点'**
  String get clearAnchorSelectionButtonTooltip;

  /// No description provided for @inputPaste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get inputPaste;

  /// No description provided for @imageViewerSaveOrShare.
  ///
  /// In zh, this message translates to:
  /// **'保存或分享原件'**
  String get imageViewerSaveOrShare;

  /// No description provided for @imageViewerReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片读取失败'**
  String get imageViewerReadFailed;

  /// No description provided for @imageViewerShareFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开分享'**
  String get imageViewerShareFailed;

  /// No description provided for @imageViewerSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get imageViewerSaveFailed;

  /// No description provided for @imageViewerShareText.
  ///
  /// In zh, this message translates to:
  /// **'Koma 图片'**
  String get imageViewerShareText;

  /// No description provided for @imageViewerSaveCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消保存'**
  String get imageViewerSaveCanceled;

  /// No description provided for @imageViewerSaved.
  ///
  /// In zh, this message translates to:
  /// **'图片已保存'**
  String get imageViewerSaved;

  /// No description provided for @imageViewerLoading.
  ///
  /// In zh, this message translates to:
  /// **'图片加载中'**
  String get imageViewerLoading;

  /// No description provided for @imageViewerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无图片'**
  String get imageViewerEmpty;

  /// No description provided for @imageViewerUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'图片暂不可用'**
  String get imageViewerUnavailable;

  /// No description provided for @imageViewerSaveImage.
  ///
  /// In zh, this message translates to:
  /// **'保存图片'**
  String get imageViewerSaveImage;

  /// No description provided for @imageViewerShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get imageViewerShare;

  /// No description provided for @imageViewerSaveToPhotos.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get imageViewerSaveToPhotos;

  /// No description provided for @boundedImageUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'图片暂不可用'**
  String get boundedImageUnavailable;

  /// No description provided for @boundedImageBadSource.
  ///
  /// In zh, this message translates to:
  /// **'无法读取图片来源'**
  String get boundedImageBadSource;

  /// No description provided for @boundedImageLoading.
  ///
  /// In zh, this message translates to:
  /// **'图片加载中'**
  String get boundedImageLoading;

  /// No description provided for @splitNavigationButtonInApp.
  ///
  /// In zh, this message translates to:
  /// **'应用内导航：{label}'**
  String splitNavigationButtonInApp(String label);

  /// No description provided for @splitNavigationButtonExternal.
  ///
  /// In zh, this message translates to:
  /// **'打开外部地图'**
  String get splitNavigationButtonExternal;

  /// No description provided for @mapThumbnailMarkerTooltip.
  ///
  /// In zh, this message translates to:
  /// **'巡礼点'**
  String get mapThumbnailMarkerTooltip;

  /// No description provided for @referenceImagePlaceholderLoading.
  ///
  /// In zh, this message translates to:
  /// **'参考图加载中'**
  String get referenceImagePlaceholderLoading;

  /// No description provided for @referenceImagePlaceholderUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'参考图暂不可用'**
  String get referenceImagePlaceholderUnavailable;

  /// No description provided for @referenceImagePlaceholderEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无参考图'**
  String get referenceImagePlaceholderEmpty;

  /// No description provided for @routePlannerSkillHintTitle.
  ///
  /// In zh, this message translates to:
  /// **'用 AI 一键规划巡礼行程'**
  String get routePlannerSkillHintTitle;

  /// No description provided for @routePlannerSkillHintDescription.
  ///
  /// In zh, this message translates to:
  /// **'让 ChatGPT、Claude Code、Codex 等 AI 助手调用 MiriaGo 路线规划 Skill。\n它会从 Anitabi、Google My Maps 等来源收集作品点位，自动划分区域、规划路线并生成行程备注；关键步骤会先向你确认，最终导出可直接使用的 .sjhplan 计划包。'**
  String get routePlannerSkillHintDescription;

  /// No description provided for @routePlannerSkillHintOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接'**
  String get routePlannerSkillHintOpenFailed;

  /// No description provided for @routePlannerSkillHintViewGuide.
  ///
  /// In zh, this message translates to:
  /// **'查看使用说明'**
  String get routePlannerSkillHintViewGuide;

  /// No description provided for @routePlannerSkillHintDismissFailed.
  ///
  /// In zh, this message translates to:
  /// **'关闭提示失败，请重试。'**
  String get routePlannerSkillHintDismissFailed;

  /// No description provided for @routePlannerSkillHintTapForGuide.
  ///
  /// In zh, this message translates to:
  /// **'点击查看使用说明'**
  String get routePlannerSkillHintTapForGuide;

  /// No description provided for @routePlannerSkillHintLinkText.
  ///
  /// In zh, this message translates to:
  /// **'用 AI 一键规划行程并生成计划包'**
  String get routePlannerSkillHintLinkText;

  /// No description provided for @currentLocationResolverServiceDisabled.
  ///
  /// In zh, this message translates to:
  /// **'定位服务未开启。'**
  String get currentLocationResolverServiceDisabled;

  /// No description provided for @currentLocationResolverPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'需要定位权限来显示当前位置。'**
  String get currentLocationResolverPermissionDenied;

  /// No description provided for @currentLocationResolverTimeout.
  ///
  /// In zh, this message translates to:
  /// **'定位超时，请稍后重试。'**
  String get currentLocationResolverTimeout;

  /// No description provided for @mapLocationTrackerStopped.
  ///
  /// In zh, this message translates to:
  /// **'定位更新已停止，请点击定位重试。'**
  String get mapLocationTrackerStopped;

  /// No description provided for @mapLocationTrackerStale.
  ///
  /// In zh, this message translates to:
  /// **'暂未收到新的定位，当前位置可能已过期。'**
  String get mapLocationTrackerStale;

  /// No description provided for @mapLocationTrackerServiceDisabled.
  ///
  /// In zh, this message translates to:
  /// **'定位服务未开启，请开启后重试。'**
  String get mapLocationTrackerServiceDisabled;

  /// No description provided for @mapLocationTrackerPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'定位权限不可用，请检查权限后重试。'**
  String get mapLocationTrackerPermissionDenied;

  /// No description provided for @mapLocationTrackerFailed.
  ///
  /// In zh, this message translates to:
  /// **'定位更新失败，请检查权限和定位服务后重试。'**
  String get mapLocationTrackerFailed;

  /// No description provided for @mapLayersPanelTitle.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get mapLayersPanelTitle;

  /// No description provided for @mapLayersPanelCloseLabel.
  ///
  /// In zh, this message translates to:
  /// **'关闭{title}'**
  String mapLayersPanelCloseLabel(String title);

  /// No description provided for @mapTileConfigLibertyDescription.
  ///
  /// In zh, this message translates to:
  /// **'默认样式，信息密度较高。'**
  String get mapTileConfigLibertyDescription;

  /// No description provided for @mapTileConfigBrightDescription.
  ///
  /// In zh, this message translates to:
  /// **'明亮标准样式。'**
  String get mapTileConfigBrightDescription;

  /// No description provided for @mapTileConfigPositronDescription.
  ///
  /// In zh, this message translates to:
  /// **'浅色低干扰样式。'**
  String get mapTileConfigPositronDescription;

  /// No description provided for @mapTileConfigDarkDescription.
  ///
  /// In zh, this message translates to:
  /// **'深色地图样式。'**
  String get mapTileConfigDarkDescription;

  /// No description provided for @mapTileConfigFiordDescription.
  ///
  /// In zh, this message translates to:
  /// **'柔和地形风格。'**
  String get mapTileConfigFiordDescription;

  /// No description provided for @mapTileConfigCustomXyzLabel.
  ///
  /// In zh, this message translates to:
  /// **'自定义 XYZ'**
  String get mapTileConfigCustomXyzLabel;

  /// No description provided for @mapTileConfigCustomMapLibreLabel.
  ///
  /// In zh, this message translates to:
  /// **'自定义 MapLibre'**
  String get mapTileConfigCustomMapLibreLabel;

  /// No description provided for @mapTileConfigOpenFreeMapDescription.
  ///
  /// In zh, this message translates to:
  /// **'默认地图，使用 MapLibre style。'**
  String get mapTileConfigOpenFreeMapDescription;

  /// No description provided for @mapTileConfigOpenStreetMapDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用 OpenStreetMap 标准 XYZ 瓦片。'**
  String get mapTileConfigOpenStreetMapDescription;

  /// No description provided for @mapTileConfigCustomXyzDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用包含 {pattern} 的栅格瓦片 URL。'**
  String mapTileConfigCustomXyzDescription(String pattern);

  /// No description provided for @mapTileConfigCustomMapLibreDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用自定义 MapLibre style URL。'**
  String get mapTileConfigCustomMapLibreDescription;

  /// No description provided for @mapTileConfigCustomXyzInvalid.
  ///
  /// In zh, this message translates to:
  /// **'自定义 XYZ URL 需要包含 {z}、{x}、{y}，并使用 http/https。'**
  String mapTileConfigCustomXyzInvalid(String z, String x, String y);

  /// No description provided for @mapTileConfigCustomMapLibreInvalid.
  ///
  /// In zh, this message translates to:
  /// **'自定义 MapLibre style URL 需要使用 http/https。'**
  String get mapTileConfigCustomMapLibreInvalid;

  /// No description provided for @navigationHeadingStale.
  ///
  /// In zh, this message translates to:
  /// **'上次定位，等待更新'**
  String get navigationHeadingStale;

  /// No description provided for @navigationHeadingNoHeading.
  ///
  /// In zh, this message translates to:
  /// **'当前位置，朝向不可用'**
  String get navigationHeadingNoHeading;

  /// No description provided for @navigationHeadingWithHeading.
  ///
  /// In zh, this message translates to:
  /// **'当前位置，手机朝向'**
  String get navigationHeadingWithHeading;

  /// No description provided for @photoLocationStatusPanelSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get photoLocationStatusPanelSkip;

  /// No description provided for @nativeCameraControllerPermissionRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'相机权限请求失败：{error}'**
  String nativeCameraControllerPermissionRequestFailed(String error);

  /// No description provided for @nativeCameraControllerPermissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要相机权限'**
  String get nativeCameraControllerPermissionRequired;

  /// No description provided for @nativeCameraControllerInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'原生相机初始化失败'**
  String get nativeCameraControllerInitFailed;

  /// No description provided for @nativeCameraControllerInitFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'原生相机初始化失败：{error}'**
  String nativeCameraControllerInitFailedWithError(String error);

  /// No description provided for @photoLocationChoiceTitle.
  ///
  /// In zh, this message translates to:
  /// **'是否在巡礼照片中记录定位？'**
  String get photoLocationChoiceTitle;

  /// No description provided for @photoLocationChoiceChangeLater.
  ///
  /// In zh, this message translates to:
  /// **'以后可以在“拍摄设置”中修改。'**
  String get photoLocationChoiceChangeLater;

  /// No description provided for @photoLocationChoiceNoSpotCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'不会使用点位坐标代替实际定位。'**
  String get photoLocationChoiceNoSpotCoordinates;

  /// No description provided for @photoLocationChoiceRecentTitle.
  ///
  /// In zh, this message translates to:
  /// **'使用最近一次定位'**
  String get photoLocationChoiceRecentTitle;

  /// No description provided for @photoLocationChoiceRecentSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'优先快速写入近期有效定位，没有时获取一次。'**
  String get photoLocationChoiceRecentSubtitle;

  /// No description provided for @photoLocationChoiceConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认记录时获取定位'**
  String get photoLocationChoiceConfirmTitle;

  /// No description provided for @photoLocationChoiceConfirmSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'拍摄后在确认页面等待新定位，适合需要更准确位置时。'**
  String get photoLocationChoiceConfirmSubtitle;

  /// No description provided for @photoLocationChoiceDisabledTitle.
  ///
  /// In zh, this message translates to:
  /// **'不记录定位'**
  String get photoLocationChoiceDisabledTitle;

  /// No description provided for @photoLocationChoiceRecommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get photoLocationChoiceRecommended;

  /// No description provided for @mapMarkerClusteringTapToBrowse.
  ///
  /// In zh, this message translates to:
  /// **'点击浏览'**
  String get mapMarkerClusteringTapToBrowse;

  /// No description provided for @mapMarkerClusteringTapToZoom.
  ///
  /// In zh, this message translates to:
  /// **'点击放大'**
  String get mapMarkerClusteringTapToZoom;

  /// No description provided for @mapMarkerClusteringDone.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get mapMarkerClusteringDone;

  /// No description provided for @mapMarkerClusteringDoneSummary.
  ///
  /// In zh, this message translates to:
  /// **'，其中 {done} 个{doneLabel}'**
  String mapMarkerClusteringDoneSummary(int done, String doneLabel);

  /// No description provided for @mapMarkerClusteringBrowseOverlapping.
  ///
  /// In zh, this message translates to:
  /// **'浏览 {count} 个重合点位'**
  String mapMarkerClusteringBrowseOverlapping(int count);

  /// No description provided for @mapMarkerClusteringSpotCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位'**
  String mapMarkerClusteringSpotCount(int count);

  /// No description provided for @mapMarkerClusteringSemantics.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个聚合点位{doneSummary}，{action}'**
  String mapMarkerClusteringSemantics(
    int count,
    String doneSummary,
    String action,
  );

  /// No description provided for @mapMarkerClusteringTooltipDone.
  ///
  /// In zh, this message translates to:
  /// **'{tooltip} · {done} 个{doneLabel}'**
  String mapMarkerClusteringTooltipDone(
    String tooltip,
    int done,
    String doneLabel,
  );

  /// No description provided for @mapMarkerClusteringPrevious.
  ///
  /// In zh, this message translates to:
  /// **'上一个重合点位'**
  String get mapMarkerClusteringPrevious;

  /// No description provided for @mapMarkerClusteringPager.
  ///
  /// In zh, this message translates to:
  /// **'重合点位  {index} / {total}'**
  String mapMarkerClusteringPager(int index, int total);

  /// No description provided for @mapMarkerClusteringNext.
  ///
  /// In zh, this message translates to:
  /// **'下一个重合点位'**
  String get mapMarkerClusteringNext;

  /// No description provided for @valhallaRouteClientNeedsTwoStops.
  ///
  /// In zh, this message translates to:
  /// **'路线至少需要起点和终点'**
  String get valhallaRouteClientNeedsTwoStops;

  /// No description provided for @valhallaRouteClientTimeout.
  ///
  /// In zh, this message translates to:
  /// **'路径规划服务响应超时，请稍后重试'**
  String get valhallaRouteClientTimeout;

  /// No description provided for @valhallaRouteClientConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法连接路径规划服务：{error}'**
  String valhallaRouteClientConnectionFailed(String error);

  /// No description provided for @valhallaRouteClientRateLimited.
  ///
  /// In zh, this message translates to:
  /// **'路径规划服务请求过于频繁，请稍后重试'**
  String get valhallaRouteClientRateLimited;

  /// No description provided for @valhallaRouteClientServiceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'路径规划服务暂时不可用（{status}）'**
  String valhallaRouteClientServiceUnavailable(int status);

  /// No description provided for @valhallaRouteClientRouteFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法规划这条步行路线（{status}）'**
  String valhallaRouteClientRouteFailed(int status);

  /// No description provided for @valhallaRouteClientStatus.
  ///
  /// In zh, this message translates to:
  /// **'服务返回 {status}'**
  String valhallaRouteClientStatus(int status);

  /// No description provided for @valhallaRouteClientTestTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接测试超时'**
  String get valhallaRouteClientTestTimeout;

  /// No description provided for @valhallaRouteClientBadResponse.
  ///
  /// In zh, this message translates to:
  /// **'路径规划服务返回了无法识别的数据'**
  String get valhallaRouteClientBadResponse;

  /// No description provided for @valhallaRouteClientError170.
  ///
  /// In zh, this message translates to:
  /// **'起点和终点之间没有相连的步行道路'**
  String get valhallaRouteClientError170;

  /// No description provided for @valhallaRouteClientError171.
  ///
  /// In zh, this message translates to:
  /// **'起点或点位附近没有可步行的道路，请换个位置再试'**
  String get valhallaRouteClientError171;

  /// No description provided for @valhallaRouteClientError154.
  ///
  /// In zh, this message translates to:
  /// **'距离超过路径服务的步行路线上限'**
  String get valhallaRouteClientError154;

  /// No description provided for @valhallaRouteClientError442.
  ///
  /// In zh, this message translates to:
  /// **'找不到可步行的路线'**
  String get valhallaRouteClientError442;

  /// No description provided for @valhallaRouteClientStartWalking.
  ///
  /// In zh, this message translates to:
  /// **'开始步行'**
  String get valhallaRouteClientStartWalking;

  /// No description provided for @valhallaRouteClientStartAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}出发'**
  String valhallaRouteClientStartAlong(String road);

  /// No description provided for @valhallaRouteClientHeadRight.
  ///
  /// In zh, this message translates to:
  /// **'向右出发'**
  String get valhallaRouteClientHeadRight;

  /// No description provided for @valhallaRouteClientHeadRightOnto.
  ///
  /// In zh, this message translates to:
  /// **'向右出发，进入{road}'**
  String valhallaRouteClientHeadRightOnto(String road);

  /// No description provided for @valhallaRouteClientHeadLeft.
  ///
  /// In zh, this message translates to:
  /// **'向左出发'**
  String get valhallaRouteClientHeadLeft;

  /// No description provided for @valhallaRouteClientHeadLeftOnto.
  ///
  /// In zh, this message translates to:
  /// **'向左出发，进入{road}'**
  String valhallaRouteClientHeadLeftOnto(String road);

  /// No description provided for @valhallaRouteClientArrive.
  ///
  /// In zh, this message translates to:
  /// **'到达终点'**
  String get valhallaRouteClientArrive;

  /// No description provided for @valhallaRouteClientArriveNear.
  ///
  /// In zh, this message translates to:
  /// **'到达{road}附近的终点'**
  String valhallaRouteClientArriveNear(String road);

  /// No description provided for @valhallaRouteClientContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续前行'**
  String get valhallaRouteClientContinue;

  /// No description provided for @valhallaRouteClientContinueOnto.
  ///
  /// In zh, this message translates to:
  /// **'继续前行，进入{road}'**
  String valhallaRouteClientContinueOnto(String road);

  /// No description provided for @valhallaRouteClientGoStraight.
  ///
  /// In zh, this message translates to:
  /// **'继续直行'**
  String get valhallaRouteClientGoStraight;

  /// No description provided for @valhallaRouteClientGoStraightAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}继续直行'**
  String valhallaRouteClientGoStraightAlong(String road);

  /// No description provided for @valhallaRouteClientBearRight.
  ///
  /// In zh, this message translates to:
  /// **'稍向右转'**
  String get valhallaRouteClientBearRight;

  /// No description provided for @valhallaRouteClientBearRightOnto.
  ///
  /// In zh, this message translates to:
  /// **'稍向右转，进入{road}'**
  String valhallaRouteClientBearRightOnto(String road);

  /// No description provided for @valhallaRouteClientTurnRight.
  ///
  /// In zh, this message translates to:
  /// **'向右转'**
  String get valhallaRouteClientTurnRight;

  /// No description provided for @valhallaRouteClientTurnRightOnto.
  ///
  /// In zh, this message translates to:
  /// **'向右转，进入{road}'**
  String valhallaRouteClientTurnRightOnto(String road);

  /// No description provided for @valhallaRouteClientSharpRight.
  ///
  /// In zh, this message translates to:
  /// **'向右急转'**
  String get valhallaRouteClientSharpRight;

  /// No description provided for @valhallaRouteClientSharpRightOnto.
  ///
  /// In zh, this message translates to:
  /// **'向右急转，进入{road}'**
  String valhallaRouteClientSharpRightOnto(String road);

  /// No description provided for @valhallaRouteClientUTurn.
  ///
  /// In zh, this message translates to:
  /// **'请掉头'**
  String get valhallaRouteClientUTurn;

  /// No description provided for @valhallaRouteClientSharpLeft.
  ///
  /// In zh, this message translates to:
  /// **'向左急转'**
  String get valhallaRouteClientSharpLeft;

  /// No description provided for @valhallaRouteClientSharpLeftOnto.
  ///
  /// In zh, this message translates to:
  /// **'向左急转，进入{road}'**
  String valhallaRouteClientSharpLeftOnto(String road);

  /// No description provided for @valhallaRouteClientTurnLeft.
  ///
  /// In zh, this message translates to:
  /// **'向左转'**
  String get valhallaRouteClientTurnLeft;

  /// No description provided for @valhallaRouteClientTurnLeftOnto.
  ///
  /// In zh, this message translates to:
  /// **'向左转，进入{road}'**
  String valhallaRouteClientTurnLeftOnto(String road);

  /// No description provided for @valhallaRouteClientBearLeft.
  ///
  /// In zh, this message translates to:
  /// **'稍向左转'**
  String get valhallaRouteClientBearLeft;

  /// No description provided for @valhallaRouteClientBearLeftOnto.
  ///
  /// In zh, this message translates to:
  /// **'稍向左转，进入{road}'**
  String valhallaRouteClientBearLeftOnto(String road);

  /// No description provided for @valhallaRouteClientRampStraight.
  ///
  /// In zh, this message translates to:
  /// **'沿匝道直行'**
  String get valhallaRouteClientRampStraight;

  /// No description provided for @valhallaRouteClientRampStraightAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}沿匝道直行'**
  String valhallaRouteClientRampStraightAlong(String road);

  /// No description provided for @valhallaRouteClientRampRight.
  ///
  /// In zh, this message translates to:
  /// **'沿右侧匝道前行'**
  String get valhallaRouteClientRampRight;

  /// No description provided for @valhallaRouteClientRampRightOnto.
  ///
  /// In zh, this message translates to:
  /// **'沿右侧匝道进入{road}'**
  String valhallaRouteClientRampRightOnto(String road);

  /// No description provided for @valhallaRouteClientRampLeft.
  ///
  /// In zh, this message translates to:
  /// **'沿左侧匝道前行'**
  String get valhallaRouteClientRampLeft;

  /// No description provided for @valhallaRouteClientRampLeftOnto.
  ///
  /// In zh, this message translates to:
  /// **'沿左侧匝道进入{road}'**
  String valhallaRouteClientRampLeftOnto(String road);

  /// No description provided for @valhallaRouteClientExitRight.
  ///
  /// In zh, this message translates to:
  /// **'从右侧出口离开'**
  String get valhallaRouteClientExitRight;

  /// No description provided for @valhallaRouteClientExitLeft.
  ///
  /// In zh, this message translates to:
  /// **'从左侧出口离开'**
  String get valhallaRouteClientExitLeft;

  /// No description provided for @valhallaRouteClientStayStraight.
  ///
  /// In zh, this message translates to:
  /// **'保持直行'**
  String get valhallaRouteClientStayStraight;

  /// No description provided for @valhallaRouteClientStayStraightAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}保持直行'**
  String valhallaRouteClientStayStraightAlong(String road);

  /// No description provided for @valhallaRouteClientKeepRight.
  ///
  /// In zh, this message translates to:
  /// **'靠右行走'**
  String get valhallaRouteClientKeepRight;

  /// No description provided for @valhallaRouteClientKeepRightAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}靠右行走'**
  String valhallaRouteClientKeepRightAlong(String road);

  /// No description provided for @valhallaRouteClientKeepLeft.
  ///
  /// In zh, this message translates to:
  /// **'靠左行走'**
  String get valhallaRouteClientKeepLeft;

  /// No description provided for @valhallaRouteClientKeepLeftAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}靠左行走'**
  String valhallaRouteClientKeepLeftAlong(String road);

  /// No description provided for @valhallaRouteClientMerge.
  ///
  /// In zh, this message translates to:
  /// **'汇入道路'**
  String get valhallaRouteClientMerge;

  /// No description provided for @valhallaRouteClientMergeOnto.
  ///
  /// In zh, this message translates to:
  /// **'汇入道路，进入{road}'**
  String valhallaRouteClientMergeOnto(String road);

  /// No description provided for @valhallaRouteClientEnterRoundabout.
  ///
  /// In zh, this message translates to:
  /// **'进入环岛'**
  String get valhallaRouteClientEnterRoundabout;

  /// No description provided for @valhallaRouteClientExitRoundabout.
  ///
  /// In zh, this message translates to:
  /// **'驶出环岛'**
  String get valhallaRouteClientExitRoundabout;

  /// No description provided for @valhallaRouteClientBoardFerry.
  ///
  /// In zh, this message translates to:
  /// **'进入渡轮'**
  String get valhallaRouteClientBoardFerry;

  /// No description provided for @valhallaRouteClientLeaveFerry.
  ///
  /// In zh, this message translates to:
  /// **'离开渡轮'**
  String get valhallaRouteClientLeaveFerry;

  /// No description provided for @valhallaRouteClientTakeTransit.
  ///
  /// In zh, this message translates to:
  /// **'搭乘公共交通'**
  String get valhallaRouteClientTakeTransit;

  /// No description provided for @valhallaRouteClientTransfer.
  ///
  /// In zh, this message translates to:
  /// **'换乘'**
  String get valhallaRouteClientTransfer;

  /// No description provided for @valhallaRouteClientStayOnLine.
  ///
  /// In zh, this message translates to:
  /// **'继续乘坐当前线路'**
  String get valhallaRouteClientStayOnLine;

  /// No description provided for @valhallaRouteClientToTransitConnection.
  ///
  /// In zh, this message translates to:
  /// **'前往公共交通连接点'**
  String get valhallaRouteClientToTransitConnection;

  /// No description provided for @valhallaRouteClientTransitArrive.
  ///
  /// In zh, this message translates to:
  /// **'到达公共交通目的地'**
  String get valhallaRouteClientTransitArrive;

  /// No description provided for @valhallaRouteClientMergeRight.
  ///
  /// In zh, this message translates to:
  /// **'向右汇入道路'**
  String get valhallaRouteClientMergeRight;

  /// No description provided for @valhallaRouteClientMergeRightOnto.
  ///
  /// In zh, this message translates to:
  /// **'向右汇入道路，进入{road}'**
  String valhallaRouteClientMergeRightOnto(String road);

  /// No description provided for @valhallaRouteClientMergeLeft.
  ///
  /// In zh, this message translates to:
  /// **'向左汇入道路'**
  String get valhallaRouteClientMergeLeft;

  /// No description provided for @valhallaRouteClientMergeLeftOnto.
  ///
  /// In zh, this message translates to:
  /// **'向左汇入道路，进入{road}'**
  String valhallaRouteClientMergeLeftOnto(String road);

  /// No description provided for @valhallaRouteClientElevator.
  ///
  /// In zh, this message translates to:
  /// **'乘坐电梯'**
  String get valhallaRouteClientElevator;

  /// No description provided for @valhallaRouteClientStairs.
  ///
  /// In zh, this message translates to:
  /// **'走楼梯'**
  String get valhallaRouteClientStairs;

  /// No description provided for @valhallaRouteClientEscalator.
  ///
  /// In zh, this message translates to:
  /// **'乘坐自动扶梯'**
  String get valhallaRouteClientEscalator;

  /// No description provided for @valhallaRouteClientEnterBuilding.
  ///
  /// In zh, this message translates to:
  /// **'进入建筑'**
  String get valhallaRouteClientEnterBuilding;

  /// No description provided for @valhallaRouteClientExitBuilding.
  ///
  /// In zh, this message translates to:
  /// **'离开建筑'**
  String get valhallaRouteClientExitBuilding;

  /// No description provided for @valhallaRouteClientOtherFloor.
  ///
  /// In zh, this message translates to:
  /// **'前往其他楼层'**
  String get valhallaRouteClientOtherFloor;

  /// No description provided for @valhallaRouteClientParkAndWalk.
  ///
  /// In zh, this message translates to:
  /// **'停放车辆后继续步行'**
  String get valhallaRouteClientParkAndWalk;

  /// No description provided for @valhallaRouteClientContinueAlong.
  ///
  /// In zh, this message translates to:
  /// **'沿{road}继续前行'**
  String valhallaRouteClientContinueAlong(String road);

  /// No description provided for @navigationRouteConfirmLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'路线加载失败，请检查定位和路径服务设置'**
  String get navigationRouteConfirmLoadFailed;

  /// No description provided for @navigationRouteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认路线'**
  String get navigationRouteConfirmTitle;

  /// No description provided for @navigationRouteConfirmChainArea.
  ///
  /// In zh, this message translates to:
  /// **'串联整个片区'**
  String get navigationRouteConfirmChainArea;

  /// No description provided for @navigationRouteConfirmToSelected.
  ///
  /// In zh, this message translates to:
  /// **'导航到选中点'**
  String get navigationRouteConfirmToSelected;

  /// No description provided for @navigationRouteConfirmChainSummary.
  ///
  /// In zh, this message translates to:
  /// **'按顺序连接 {count} 个点位：{stops}'**
  String navigationRouteConfirmChainSummary(int count, String stops);

  /// No description provided for @navigationRouteConfirmDestination.
  ///
  /// In zh, this message translates to:
  /// **'终点：{name}'**
  String navigationRouteConfirmDestination(String name);

  /// No description provided for @navigationRouteConfirmLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在获取当前位置并规划步行路线…'**
  String get navigationRouteConfirmLoading;

  /// No description provided for @navigationRouteConfirmReplan.
  ///
  /// In zh, this message translates to:
  /// **'重新规划路线'**
  String get navigationRouteConfirmReplan;

  /// No description provided for @navigationRouteConfirmExternalShort.
  ///
  /// In zh, this message translates to:
  /// **'外部导航'**
  String get navigationRouteConfirmExternalShort;

  /// No description provided for @navigationRouteConfirmExternalFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开外部地图'**
  String get navigationRouteConfirmExternalFailed;

  /// No description provided for @navigationRouteConfirmStart.
  ///
  /// In zh, this message translates to:
  /// **'开始导航'**
  String get navigationRouteConfirmStart;

  /// No description provided for @navigationRouteConfirmStartArea.
  ///
  /// In zh, this message translates to:
  /// **'串联整个片区导航'**
  String get navigationRouteConfirmStartArea;

  /// No description provided for @navigationRouteConfirmOnlySelected.
  ///
  /// In zh, this message translates to:
  /// **'仅导航到选中点'**
  String get navigationRouteConfirmOnlySelected;

  /// No description provided for @navigationRouteConfirmOnlySelectedShort.
  ///
  /// In zh, this message translates to:
  /// **'仅导航到点位'**
  String get navigationRouteConfirmOnlySelectedShort;

  /// No description provided for @navigationRouteConfirmAreaBadge.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get navigationRouteConfirmAreaBadge;

  /// No description provided for @inAppNavigationLocationStopped.
  ///
  /// In zh, this message translates to:
  /// **'定位更新已停止，请重试。'**
  String get inAppNavigationLocationStopped;

  /// No description provided for @inAppNavigationLocationStale.
  ///
  /// In zh, this message translates to:
  /// **'暂未收到新的定位，当前位置可能已过期。'**
  String get inAppNavigationLocationStale;

  /// No description provided for @inAppNavigationPreciseOff.
  ///
  /// In zh, this message translates to:
  /// **'精确位置已关闭，到达提醒和偏航判断可能不准确。'**
  String get inAppNavigationPreciseOff;

  /// No description provided for @inAppNavigationOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get inAppNavigationOpenSettings;

  /// No description provided for @inAppNavigationRetryLocation.
  ///
  /// In zh, this message translates to:
  /// **'重试定位'**
  String get inAppNavigationRetryLocation;

  /// No description provided for @inAppNavigationOnRoute.
  ///
  /// In zh, this message translates to:
  /// **'路线中'**
  String get inAppNavigationOnRoute;

  /// No description provided for @inAppNavigationFollowRoute.
  ///
  /// In zh, this message translates to:
  /// **'沿路线继续前行'**
  String get inAppNavigationFollowRoute;

  /// No description provided for @inAppNavigationSideRight.
  ///
  /// In zh, this message translates to:
  /// **'，在右侧'**
  String get inAppNavigationSideRight;

  /// No description provided for @inAppNavigationSideLeft.
  ///
  /// In zh, this message translates to:
  /// **'，在左侧'**
  String get inAppNavigationSideLeft;

  /// No description provided for @inAppNavigationArriveDestination.
  ///
  /// In zh, this message translates to:
  /// **'到达终点{side}'**
  String inAppNavigationArriveDestination(String side);

  /// No description provided for @inAppNavigationArriveWaypoint.
  ///
  /// In zh, this message translates to:
  /// **'到达途经点{side}'**
  String inAppNavigationArriveWaypoint(String side);

  /// No description provided for @inAppNavigationArriveDestinationNamed.
  ///
  /// In zh, this message translates to:
  /// **'到达终点 {name}{side}'**
  String inAppNavigationArriveDestinationNamed(String name, String side);

  /// No description provided for @inAppNavigationArriveWaypointNamed.
  ///
  /// In zh, this message translates to:
  /// **'到达途经点 {name}{side}'**
  String inAppNavigationArriveWaypointNamed(String name, String side);

  /// No description provided for @inAppNavigationMeters.
  ///
  /// In zh, this message translates to:
  /// **'{meters}米'**
  String inAppNavigationMeters(int meters);

  /// No description provided for @inAppNavigationKilometers.
  ///
  /// In zh, this message translates to:
  /// **'{km}公里'**
  String inAppNavigationKilometers(String km);

  /// No description provided for @inAppNavigationFinalStop.
  ///
  /// In zh, this message translates to:
  /// **'终点: {name}'**
  String inAppNavigationFinalStop(String name);

  /// No description provided for @inAppNavigationAllStops.
  ///
  /// In zh, this message translates to:
  /// **'全部点位'**
  String get inAppNavigationAllStops;

  /// No description provided for @inAppNavigationStopCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个'**
  String inAppNavigationStopCount(int count);

  /// No description provided for @inAppNavigationArrived.
  ///
  /// In zh, this message translates to:
  /// **'已到达'**
  String get inAppNavigationArrived;

  /// No description provided for @inAppNavigationEndRoute.
  ///
  /// In zh, this message translates to:
  /// **'结束路线'**
  String get inAppNavigationEndRoute;

  /// No description provided for @inAppNavigationCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get inAppNavigationCollapse;

  /// No description provided for @inAppNavigationExpand.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get inAppNavigationExpand;

  /// No description provided for @inAppNavigationMetricArrival.
  ///
  /// In zh, this message translates to:
  /// **'到达'**
  String get inAppNavigationMetricArrival;

  /// No description provided for @inAppNavigationMetricHours.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get inAppNavigationMetricHours;

  /// No description provided for @inAppNavigationMetricKm.
  ///
  /// In zh, this message translates to:
  /// **'公里'**
  String get inAppNavigationMetricKm;

  /// No description provided for @inAppNavigationAreaBadge.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get inAppNavigationAreaBadge;

  /// No description provided for @inAppNavigationRecenter.
  ///
  /// In zh, this message translates to:
  /// **'回到当前位置'**
  String get inAppNavigationRecenter;

  /// No description provided for @inAppNavigationArrivalTitle.
  ///
  /// In zh, this message translates to:
  /// **'到达点位'**
  String get inAppNavigationArrivalTitle;

  /// No description provided for @inAppNavigationOpenCamera.
  ///
  /// In zh, this message translates to:
  /// **'打开相机'**
  String get inAppNavigationOpenCamera;

  /// No description provided for @inAppNavigationRemainingStop.
  ///
  /// In zh, this message translates to:
  /// **'第 {stopNumber} / {remainingCount} 个剩余点位'**
  String inAppNavigationRemainingStop(int stopNumber, int remainingCount);

  /// No description provided for @inAppNavigationNextStop.
  ///
  /// In zh, this message translates to:
  /// **'下一点位 · {subtitle}'**
  String inAppNavigationNextStop(String subtitle);

  /// No description provided for @inAppNavigationGoNext.
  ///
  /// In zh, this message translates to:
  /// **'前往下一点'**
  String get inAppNavigationGoNext;

  /// No description provided for @pilgrimageMapLayerThumbnails.
  ///
  /// In zh, this message translates to:
  /// **'缩略图标记'**
  String get pilgrimageMapLayerThumbnails;

  /// No description provided for @pilgrimageMapLayerAreas.
  ///
  /// In zh, this message translates to:
  /// **'片区范围'**
  String get pilgrimageMapLayerAreas;

  /// No description provided for @pilgrimageMapLayerHideCompleted.
  ///
  /// In zh, this message translates to:
  /// **'隐藏已完成点位'**
  String get pilgrimageMapLayerHideCompleted;

  /// No description provided for @pilgrimageMapLayerClustering.
  ///
  /// In zh, this message translates to:
  /// **'自动聚合密集点位'**
  String get pilgrimageMapLayerClustering;

  /// No description provided for @pilgrimageMapLayerContinuousLocation.
  ///
  /// In zh, this message translates to:
  /// **'持续更新当前位置'**
  String get pilgrimageMapLayerContinuousLocation;

  /// No description provided for @pilgrimageMapLayerContinuousLocationHint.
  ///
  /// In zh, this message translates to:
  /// **'关闭后只在点定位时获取一次位置，更省电'**
  String get pilgrimageMapLayerContinuousLocationHint;

  /// No description provided for @pilgrimageMapOpenAppFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开{app}。'**
  String pilgrimageMapOpenAppFailed(String app);

  /// No description provided for @pilgrimageMapNoSpotsSnack.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有点位。'**
  String get pilgrimageMapNoSpotsSnack;

  /// No description provided for @pilgrimageMapCannotEdit.
  ///
  /// In zh, this message translates to:
  /// **'当前环境无法编辑点位。'**
  String get pilgrimageMapCannotEdit;

  /// No description provided for @pilgrimageMapVisitedLabel.
  ///
  /// In zh, this message translates to:
  /// **'已打卡'**
  String get pilgrimageMapVisitedLabel;

  /// No description provided for @pilgrimageMapCurrentLocation.
  ///
  /// In zh, this message translates to:
  /// **'当前位置'**
  String get pilgrimageMapCurrentLocation;

  /// No description provided for @pilgrimageMapLocate.
  ///
  /// In zh, this message translates to:
  /// **'定位'**
  String get pilgrimageMapLocate;

  /// No description provided for @pilgrimageMapCurrentTarget.
  ///
  /// In zh, this message translates to:
  /// **'当前目标'**
  String get pilgrimageMapCurrentTarget;

  /// No description provided for @pilgrimageMapLayers.
  ///
  /// In zh, this message translates to:
  /// **'图层'**
  String get pilgrimageMapLayers;

  /// No description provided for @pilgrimageMapPointMarker.
  ///
  /// In zh, this message translates to:
  /// **'巡礼点'**
  String get pilgrimageMapPointMarker;

  /// No description provided for @pilgrimageMapCopySpotName.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get pilgrimageMapCopySpotName;

  /// No description provided for @pilgrimageMapCopySpotInfo.
  ///
  /// In zh, this message translates to:
  /// **'点位信息'**
  String get pilgrimageMapCopySpotInfo;

  /// No description provided for @pilgrimageMapNavigate.
  ///
  /// In zh, this message translates to:
  /// **'导航'**
  String get pilgrimageMapNavigate;

  /// No description provided for @pilgrimageMapCoordinatesMissing.
  ///
  /// In zh, this message translates to:
  /// **'坐标待补充'**
  String get pilgrimageMapCoordinatesMissing;

  /// No description provided for @pilgrimageMapCamera.
  ///
  /// In zh, this message translates to:
  /// **'拍摄参考'**
  String get pilgrimageMapCamera;

  /// No description provided for @pilgrimageMapUndoVisit.
  ///
  /// In zh, this message translates to:
  /// **'撤回打卡'**
  String get pilgrimageMapUndoVisit;

  /// No description provided for @pilgrimageMapMarkComplete.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get pilgrimageMapMarkComplete;

  /// No description provided for @pilgrimageMapSetCurrent.
  ///
  /// In zh, this message translates to:
  /// **'设为当前目标'**
  String get pilgrimageMapSetCurrent;

  /// No description provided for @pilgrimageMapEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有点位'**
  String get pilgrimageMapEmptyTitle;

  /// No description provided for @pilgrimageMapEmptyBody.
  ///
  /// In zh, this message translates to:
  /// **'添加点位后会在地图上显示标记。'**
  String get pilgrimageMapEmptyBody;

  /// No description provided for @pilgrimageMapStatusCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get pilgrimageMapStatusCurrent;

  /// No description provided for @pilgrimageMapStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get pilgrimageMapStatusCompleted;

  /// No description provided for @pilgrimageMapStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待访'**
  String get pilgrimageMapStatusPending;

  /// No description provided for @visitRecordConfirmationLocationReady.
  ///
  /// In zh, this message translates to:
  /// **'已获取拍摄位置，保存时写入照片。'**
  String get visitRecordConfirmationLocationReady;

  /// No description provided for @visitRecordConfirmationLocating.
  ///
  /// In zh, this message translates to:
  /// **'正在获取拍摄位置...'**
  String get visitRecordConfirmationLocating;

  /// No description provided for @visitRecordConfirmationLocationFailed.
  ///
  /// In zh, this message translates to:
  /// **'定位获取失败，本次不添加位置，保留照片原有信息。'**
  String get visitRecordConfirmationLocationFailed;

  /// No description provided for @visitRecordConfirmationStorageUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'记录存储不可用，请返回后重试。'**
  String get visitRecordConfirmationStorageUnavailable;

  /// No description provided for @visitRecordConfirmationStageSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存记录中...'**
  String get visitRecordConfirmationStageSaving;

  /// No description provided for @visitRecordConfirmationStageWritingLocation.
  ///
  /// In zh, this message translates to:
  /// **'正在写入照片定位，请稍候...'**
  String get visitRecordConfirmationStageWritingLocation;

  /// No description provided for @visitRecordConfirmationStageBackingUp.
  ///
  /// In zh, this message translates to:
  /// **'备份巡礼照片中...'**
  String get visitRecordConfirmationStageBackingUp;

  /// No description provided for @visitRecordConfirmationStageComparison.
  ///
  /// In zh, this message translates to:
  /// **'生成对比图中...'**
  String get visitRecordConfirmationStageComparison;

  /// No description provided for @visitRecordConfirmationStageUpdatingSpot.
  ///
  /// In zh, this message translates to:
  /// **'更新点位状态中...'**
  String get visitRecordConfirmationStageUpdatingSpot;

  /// No description provided for @visitRecordConfirmationLocationWriteFailed.
  ///
  /// In zh, this message translates to:
  /// **'；定位写入失败，保留照片原有信息'**
  String get visitRecordConfirmationLocationWriteFailed;

  /// No description provided for @visitRecordConfirmationCompleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'；标记完成失败，请在计划中重试'**
  String get visitRecordConfirmationCompleteFailed;

  /// No description provided for @visitRecordConfirmationSaveUncertain.
  ///
  /// In zh, this message translates to:
  /// **'保存结果未确认，请返回记录页检查，勿重复保存。'**
  String get visitRecordConfirmationSaveUncertain;

  /// No description provided for @visitRecordConfirmationSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存记录失败，请重试。'**
  String get visitRecordConfirmationSaveFailed;

  /// No description provided for @visitRecordConfirmationSavingWait.
  ///
  /// In zh, this message translates to:
  /// **'正在保存记录，请稍候。'**
  String get visitRecordConfirmationSavingWait;

  /// No description provided for @visitRecordConfirmationTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认记录'**
  String get visitRecordConfirmationTitle;

  /// No description provided for @visitRecordConfirmationLocationSkipped.
  ///
  /// In zh, this message translates to:
  /// **'已跳过定位，本次不添加位置，保留照片原有信息。'**
  String get visitRecordConfirmationLocationSkipped;

  /// No description provided for @visitRecordConfirmationSavingButton.
  ///
  /// In zh, this message translates to:
  /// **'保存中'**
  String get visitRecordConfirmationSavingButton;

  /// No description provided for @visitRecordConfirmationSave.
  ///
  /// In zh, this message translates to:
  /// **'保存记录'**
  String get visitRecordConfirmationSave;

  /// No description provided for @visitRecordConfirmationSaveAndComplete.
  ///
  /// In zh, this message translates to:
  /// **'保存并标记完成'**
  String get visitRecordConfirmationSaveAndComplete;

  /// No description provided for @visitRecordConfirmationSavedAndCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已保存并标记完成'**
  String get visitRecordConfirmationSavedAndCompleted;

  /// No description provided for @visitRecordConfirmationSaved.
  ///
  /// In zh, this message translates to:
  /// **'记录已保存'**
  String get visitRecordConfirmationSaved;

  /// No description provided for @visitRecordConfirmationBackedUp.
  ///
  /// In zh, this message translates to:
  /// **'，并备份到相册'**
  String get visitRecordConfirmationBackedUp;

  /// No description provided for @visitRecordConfirmationBackupFailed.
  ///
  /// In zh, this message translates to:
  /// **'；相册备份失败'**
  String get visitRecordConfirmationBackupFailed;

  /// No description provided for @visitRecordConfirmationNext.
  ///
  /// In zh, this message translates to:
  /// **'，下一个：{name}'**
  String visitRecordConfirmationNext(String name);

  /// No description provided for @visitRecordConfirmationDetail.
  ///
  /// In zh, this message translates to:
  /// **'，{message}'**
  String visitRecordConfirmationDetail(String message);

  /// No description provided for @visitRecordConfirmationComparisonSaved.
  ///
  /// In zh, this message translates to:
  /// **'，对比图已保存到相册'**
  String get visitRecordConfirmationComparisonSaved;

  /// No description provided for @visitRecordConfirmationComparisonNoReference.
  ///
  /// In zh, this message translates to:
  /// **'，参考图不可用，未生成对比图'**
  String get visitRecordConfirmationComparisonNoReference;

  /// No description provided for @visitRecordConfirmationComparisonNoPhoto.
  ///
  /// In zh, this message translates to:
  /// **'，巡礼图不可用，未生成对比图'**
  String get visitRecordConfirmationComparisonNoPhoto;

  /// No description provided for @visitRecordConfirmationComparisonGalleryFailed.
  ///
  /// In zh, this message translates to:
  /// **'，对比图保存到相册失败'**
  String get visitRecordConfirmationComparisonGalleryFailed;

  /// No description provided for @visitRecordConfirmationComparisonRenderFailed.
  ///
  /// In zh, this message translates to:
  /// **'，对比图生成失败'**
  String get visitRecordConfirmationComparisonRenderFailed;

  /// No description provided for @visitRecordConfirmationSaveToGallery.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get visitRecordConfirmationSaveToGallery;

  /// No description provided for @visitRecordConfirmationReferenceImage.
  ///
  /// In zh, this message translates to:
  /// **'参考图'**
  String get visitRecordConfirmationReferenceImage;

  /// No description provided for @visitRecordConfirmationPilgrimagePhoto.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图'**
  String get visitRecordConfirmationPilgrimagePhoto;

  /// No description provided for @visitRecordConfirmationReferenceMode.
  ///
  /// In zh, this message translates to:
  /// **'参考模式'**
  String get visitRecordConfirmationReferenceMode;

  /// No description provided for @camerawesomeReferenceModeOverlay.
  ///
  /// In zh, this message translates to:
  /// **'叠影'**
  String get camerawesomeReferenceModeOverlay;

  /// No description provided for @camerawesomeReferenceModeSplit.
  ///
  /// In zh, this message translates to:
  /// **'上下'**
  String get camerawesomeReferenceModeSplit;

  /// No description provided for @camerawesomeReferenceModePinned.
  ///
  /// In zh, this message translates to:
  /// **'小窗'**
  String get camerawesomeReferenceModePinned;

  /// No description provided for @camerawesomeReferenceReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'参考图读取失败'**
  String get camerawesomeReferenceReadFailed;

  /// No description provided for @camerawesomeReferenceImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'照片导入失败，请重新选择。'**
  String get camerawesomeReferenceImportFailed;

  /// No description provided for @camerawesomeReferenceReadingRatio.
  ///
  /// In zh, this message translates to:
  /// **'正在读取参考图比例，请稍后拍摄。'**
  String get camerawesomeReferenceReadingRatio;

  /// No description provided for @camerawesomeReferenceNotReady.
  ///
  /// In zh, this message translates to:
  /// **'相机尚未就绪，请稍后再拍。'**
  String get camerawesomeReferenceNotReady;

  /// No description provided for @camerawesomeReferenceCaptureFailed.
  ///
  /// In zh, this message translates to:
  /// **'拍摄失败，请重试。'**
  String get camerawesomeReferenceCaptureFailed;

  /// No description provided for @camerawesomeReferenceBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get camerawesomeReferenceBack;

  /// No description provided for @camerawesomeReferenceReferenceImage.
  ///
  /// In zh, this message translates to:
  /// **'参考图'**
  String get camerawesomeReferenceReferenceImage;

  /// No description provided for @camerawesomeReferenceLandscapeUi.
  ///
  /// In zh, this message translates to:
  /// **'切换横屏 UI'**
  String get camerawesomeReferenceLandscapeUi;

  /// No description provided for @camerawesomeReferencePortraitUi.
  ///
  /// In zh, this message translates to:
  /// **'切换竖屏 UI'**
  String get camerawesomeReferencePortraitUi;

  /// No description provided for @camerawesomeReferenceGalleryImport.
  ///
  /// In zh, this message translates to:
  /// **'相册导入'**
  String get camerawesomeReferenceGalleryImport;

  /// No description provided for @camerawesomeReferenceSwitchLens.
  ///
  /// In zh, this message translates to:
  /// **'切换镜头'**
  String get camerawesomeReferenceSwitchLens;

  /// No description provided for @camerawesomeReferenceReviewPhotos.
  ///
  /// In zh, this message translates to:
  /// **'检查照片'**
  String get camerawesomeReferenceReviewPhotos;

  /// No description provided for @camerawesomeReferenceFlashOff.
  ///
  /// In zh, this message translates to:
  /// **'闪光灯：关闭'**
  String get camerawesomeReferenceFlashOff;

  /// No description provided for @camerawesomeReferenceFlashOn.
  ///
  /// In zh, this message translates to:
  /// **'闪光灯：开启'**
  String get camerawesomeReferenceFlashOn;

  /// No description provided for @camerawesomeReferenceFlashTorch.
  ///
  /// In zh, this message translates to:
  /// **'闪光灯：常亮'**
  String get camerawesomeReferenceFlashTorch;

  /// No description provided for @camerawesomeReferenceFlashAuto.
  ///
  /// In zh, this message translates to:
  /// **'闪光灯：自动'**
  String get camerawesomeReferenceFlashAuto;

  /// No description provided for @camerawesomeReferenceSwitchCamera.
  ///
  /// In zh, this message translates to:
  /// **'切换摄像头'**
  String get camerawesomeReferenceSwitchCamera;

  /// No description provided for @camerawesomeReferenceImportFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册导入'**
  String get camerawesomeReferenceImportFromGallery;

  /// No description provided for @camerawesomeReferenceImport.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get camerawesomeReferenceImport;

  /// No description provided for @camerawesomeReferenceWebPreview.
  ///
  /// In zh, this message translates to:
  /// **'Web 预览不启动实时相机'**
  String get camerawesomeReferenceWebPreview;

  /// No description provided for @camerawesomeReferencePermissionTitle.
  ///
  /// In zh, this message translates to:
  /// **'需要相机权限'**
  String get camerawesomeReferencePermissionTitle;

  /// No description provided for @camerawesomeReferencePermissionBody.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中允许 Koma 使用相机，用于拍摄巡礼照片。'**
  String get camerawesomeReferencePermissionBody;

  /// No description provided for @camerawesomeReferenceOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'打开设置'**
  String get camerawesomeReferenceOpenSettings;

  /// No description provided for @camerawesomeReferencePickFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择照片'**
  String get camerawesomeReferencePickFromGallery;

  /// No description provided for @camerawesomeReferenceUnavailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'相机无法启动'**
  String get camerawesomeReferenceUnavailableTitle;

  /// No description provided for @camerawesomeReferenceUnavailableBody.
  ///
  /// In zh, this message translates to:
  /// **'相机暂时无法使用，请稍后重试。如果问题持续，请重启 Koma。'**
  String get camerawesomeReferenceUnavailableBody;

  /// No description provided for @addPointsPickWork.
  ///
  /// In zh, this message translates to:
  /// **'查看点位'**
  String get addPointsPickWork;

  /// No description provided for @addPointsFindSpots.
  ///
  /// In zh, this message translates to:
  /// **'查找作品点位'**
  String get addPointsFindSpots;

  /// No description provided for @addPointsFindSpotsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索作品或粘贴 Anitabi 链接，在地图上挑选点位'**
  String get addPointsFindSpotsSubtitle;

  /// No description provided for @addPointsOwnSpotsSection.
  ///
  /// In zh, this message translates to:
  /// **'自行添加点位'**
  String get addPointsOwnSpotsSection;

  /// No description provided for @anitabiMapImportSearchWork.
  ///
  /// In zh, this message translates to:
  /// **'搜索作品'**
  String get anitabiMapImportSearchWork;

  /// No description provided for @anitabiMapImportPasteLink.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 Anitabi 链接'**
  String get anitabiMapImportPasteLink;

  /// No description provided for @anitabiMapImportClusterAdded.
  ///
  /// In zh, this message translates to:
  /// **'已加入'**
  String get anitabiMapImportClusterAdded;

  /// No description provided for @navigationRouteConfirmExternalWith.
  ///
  /// In zh, this message translates to:
  /// **'使用 {app} 导航'**
  String navigationRouteConfirmExternalWith(String app);

  /// No description provided for @planOnboardingFindTitle.
  ///
  /// In zh, this message translates to:
  /// **'找作品'**
  String get planOnboardingFindTitle;

  /// No description provided for @planOnboardingFindBody.
  ///
  /// In zh, this message translates to:
  /// **'点击下方“添加点位”，选择“查找作品点位”，搜索作品或粘贴 Anitabi 链接。'**
  String get planOnboardingFindBody;

  /// No description provided for @planOnboardingShootTitle.
  ///
  /// In zh, this message translates to:
  /// **'现场拍摄'**
  String get planOnboardingShootTitle;

  /// No description provided for @planOnboardingShootBody.
  ///
  /// In zh, this message translates to:
  /// **'到达点位后点相机按钮，对照动画画面取景。'**
  String get planOnboardingShootBody;

  /// No description provided for @pointDetailMarkDoneShort.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get pointDetailMarkDoneShort;

  /// No description provided for @pointDetailUndoShort.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get pointDetailUndoShort;

  /// No description provided for @splitNavigationRouteShort.
  ///
  /// In zh, this message translates to:
  /// **'路线'**
  String get splitNavigationRouteShort;

  /// No description provided for @splitNavigationMapsShort.
  ///
  /// In zh, this message translates to:
  /// **'导航'**
  String get splitNavigationMapsShort;

  /// No description provided for @appShellNoPlansTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有计划'**
  String get appShellNoPlansTitle;

  /// No description provided for @appShellNoPlansBody.
  ///
  /// In zh, this message translates to:
  /// **'创建一个巡礼计划，把想去的作品点位加进来。'**
  String get appShellNoPlansBody;

  /// No description provided for @appShellCreatePlan.
  ///
  /// In zh, this message translates to:
  /// **'创建计划'**
  String get appShellCreatePlan;

  /// No description provided for @appShellCreatePlanFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划创建失败，请重试'**
  String get appShellCreatePlanFailed;

  /// No description provided for @appShellNewPlan.
  ///
  /// In zh, this message translates to:
  /// **'新建计划'**
  String get appShellNewPlan;

  /// No description provided for @planManagerDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除计划失败，请重试'**
  String get planManagerDeleteFailed;

  /// No description provided for @paletteFjord.
  ///
  /// In zh, this message translates to:
  /// **'峡湾蓝'**
  String get paletteFjord;

  /// No description provided for @paletteSpruce.
  ///
  /// In zh, this message translates to:
  /// **'云杉'**
  String get paletteSpruce;

  /// No description provided for @paletteMoss.
  ///
  /// In zh, this message translates to:
  /// **'苔绿'**
  String get paletteMoss;

  /// No description provided for @paletteLake.
  ///
  /// In zh, this message translates to:
  /// **'湖蓝'**
  String get paletteLake;

  /// No description provided for @paletteInk.
  ///
  /// In zh, this message translates to:
  /// **'墨色'**
  String get paletteInk;

  /// No description provided for @planAreaEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这个片区还没有点位，左右切换查看其他片区。'**
  String get planAreaEmpty;

  /// No description provided for @planManagerOpenPlan.
  ///
  /// In zh, this message translates to:
  /// **'打开计划'**
  String get planManagerOpenPlan;

  /// No description provided for @planManagerEditDetails.
  ///
  /// In zh, this message translates to:
  /// **'编辑详情'**
  String get planManagerEditDetails;

  /// No description provided for @planManagerDetails.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get planManagerDetails;

  /// No description provided for @planManagerNoDetails.
  ///
  /// In zh, this message translates to:
  /// **'暂无详情'**
  String get planManagerNoDetails;

  /// No description provided for @planManagerFactSpots.
  ///
  /// In zh, this message translates to:
  /// **'点位'**
  String get planManagerFactSpots;

  /// No description provided for @planManagerFactAreas.
  ///
  /// In zh, this message translates to:
  /// **'区域'**
  String get planManagerFactAreas;

  /// No description provided for @planManagerFactCreated.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get planManagerFactCreated;

  /// No description provided for @planManagerFactUpdated.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get planManagerFactUpdated;

  /// No description provided for @planManagerSpotsDone.
  ///
  /// In zh, this message translates to:
  /// **'{total} · 已完成 {done}'**
  String planManagerSpotsDone(int total, int done);

  /// No description provided for @planEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get planEdit;

  /// No description provided for @planEditDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get planEditDone;

  /// No description provided for @planEditMarkVisited.
  ///
  /// In zh, this message translates to:
  /// **'已到访'**
  String get planEditMarkVisited;

  /// No description provided for @anitabiMapImportBoxArea.
  ///
  /// In zh, this message translates to:
  /// **'区域'**
  String get anitabiMapImportBoxArea;
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
