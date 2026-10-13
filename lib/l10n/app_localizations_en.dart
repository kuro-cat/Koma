// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get appLoading => 'Loading Koma...';

  @override
  String get alignPhotoTitle => 'Align & crop';

  @override
  String get alignPhotoAction => 'Align & crop';

  @override
  String get alignPhotoActionSubtitle => 'Line up with the frame';

  @override
  String get alignPhotoHint =>
      'Pinch and drag the photo until it lines up with the frame';

  @override
  String get alignPhotoFrameOpacity => 'Frame';

  @override
  String get alignPhotoRotation => 'Rotate';

  @override
  String get alignPhotoDifference => 'Difference blend';

  @override
  String get alignPhotoDifferenceHint => 'Areas that line up turn dark';

  @override
  String get alignPhotoReset => 'Re-center';

  @override
  String get alignPhotoSave => 'Save crop';

  @override
  String get alignPhotoSaving => 'Saving...';

  @override
  String get alignPhotoSaved => 'Crop saved';

  @override
  String get alignPhotoSaveFailed =>
      'Couldn\'t save. The original is unchanged.';

  @override
  String get alignPhotoRemoveTitle => 'Remove crop';

  @override
  String get alignPhotoRemoveMessage =>
      'The photo goes back to the uncropped original. Color matching is re-applied.';

  @override
  String get alignPhotoRemoveConfirm => 'Remove';

  @override
  String get alignPhotoRemoved => 'Crop removed';

  @override
  String get alignPhotoNoPhoto => 'The pilgrimage photo is unavailable';

  @override
  String get alignPhotoNoReference =>
      'This record has no reference image to align to';

  @override
  String settingsResetMessage(String target) {
    return '$target will be restored to defaults.';
  }

  @override
  String settingsAnitabiRestoreMessage(String target) {
    return '$target will be restored to the official defaults.';
  }

  @override
  String settingsDesktopLauncherAvailable(String platform, String mode) {
    return 'Desktop launcher: available / $platform / $mode';
  }

  @override
  String settingsReferenceImageScale(int percent) {
    return 'Reference image size $percent%';
  }

  @override
  String settingsCameraZoomRange(String min, String max) {
    return 'Camera zoom ${min}x - ${max}x';
  }

  @override
  String settingsRemoteConfigApplied(int version) {
    return 'Remote configuration v$version applied';
  }

  @override
  String settingsRemoteLastCheck(String applied, String time) {
    return '$applied · Last checked $time';
  }

  @override
  String settingsRemoteLastCheckResult(
    String applied,
    String time,
    String result,
  ) {
    return '$applied · Last checked $time, $result';
  }

  @override
  String settingsMapSource(String name) {
    return 'Map source $name';
  }

  @override
  String settingsOpenFreeMapStyle(String name) {
    return 'OpenFreeMap style $name';
  }

  @override
  String settingsXyzUrlHelper(String z, String x, String y) {
    return 'The URL must contain $z, $x and $y.';
  }

  @override
  String settingsAnitabiImageSource(String name) {
    return 'Anitabi image source $name';
  }

  @override
  String settingsCountValue(int count) {
    return '$count';
  }

  @override
  String settingsNavigationApp(String name) {
    return 'Navigation app $name';
  }

  @override
  String settingsZoomLevel(int level) {
    return 'Level $level';
  }

  @override
  String settingsThumbnailThresholdSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Thumbnails show when at most $count spots are in view; otherwise only dots are shown.',
      one:
          'Thumbnails show when at most 1 spot is in view; otherwise only dots are shown.',
    );
    return '$_temp0';
  }

  @override
  String settingsSelectedPlans(int selected, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$selected / $total plans selected',
      one: '$selected / 1 plan selected',
    );
    return '$_temp0';
  }

  @override
  String settingsPlanSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String settingsCleaningProgress(int completed, int total) {
    return 'Clearing $completed / $total...';
  }

  @override
  String settingsClearReferenceCacheMessage(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This deletes $count downloaded cache files, about $size.',
      one: 'This deletes 1 downloaded cache file, about $size.',
    );
    return '$_temp0 Locally uploaded images and images imported from plan packages are not deleted.';
  }

  @override
  String settingsCacheCleared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cleared $count cache files',
      one: 'Cleared 1 cache file',
    );
    return '$_temp0';
  }

  @override
  String settingsFreedSpace(String size) {
    return 'Freed $size';
  }

  @override
  String settingsCacheClearFailedFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files couldn\'t be cleared',
      one: '1 file couldn\'t be cleared',
    );
    return '$_temp0';
  }

  @override
  String settingsHueSaturationValue(int hue, int saturation) {
    return 'Hue $hue degrees, saturation $saturation%';
  }

  @override
  String settingsProbeSucceeded(int ms) {
    return 'OK · ${ms}ms';
  }

  @override
  String settingsImageSourceAutoDescription(String official, String mirror) {
    return 'Uses $official first, then tries $mirror if it fails.';
  }

  @override
  String settingsImageSourceFixedDescription(String url) {
    return 'Always uses $url.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsResetTitle => 'Reset settings';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceSubtitle =>
      'Theme color, light/dark mode, scale and display';

  @override
  String get settingsThemeColor => 'Theme color';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsCameraTitle => 'Camera';

  @override
  String get settingsCameraSubtitle =>
      'Photo ratio, reference image ratio and backup';

  @override
  String get settingsCaptureAspectRatio => 'Photo ratio';

  @override
  String get settingsCameraZoom => 'Camera zoom';

  @override
  String get settingsPhotoBackup => 'Photo backup';

  @override
  String get settingsSavePhotoToGallery => 'Save pilgrimage photos to gallery';

  @override
  String get settingsComparisonTitle => 'Comparison images';

  @override
  String get settingsComparisonSubtitle =>
      'Export style and auto save to gallery';

  @override
  String get settingsAutoSaveComparison => 'Auto save comparison images';

  @override
  String get settingsAutoSaveComparisonSubtitle =>
      'Save to gallery when saving a record';

  @override
  String get settingsDataSourceTitle => 'Data sources';

  @override
  String get settingsDataSourceSubtitle => 'Map source, image source and more';

  @override
  String get settingsMapDisplayTitle => 'Map display';

  @override
  String get settingsMapDisplaySubtitle =>
      'Spots, areas, clustering and thumbnails';

  @override
  String get settingsClearCacheTitle => 'Clear cache';

  @override
  String get settingsFullReferenceCache => 'Full reference image cache';

  @override
  String get settingsDesktopTitle => 'Desktop';

  @override
  String get settingsDesktopSubtitle => 'Launcher, data directory and more';

  @override
  String get settingsAboutTitle => 'About Koma';

  @override
  String get settingsAboutSubtitle => 'Version, open source license and more';

  @override
  String get settingsResetTarget => 'All appearance, camera and map settings';

  @override
  String get settingsReset => 'Reset';

  @override
  String get settingsResetNotice =>
      'You can still adjust each setting afterwards';

  @override
  String get settingsResetDone => 'Settings reset';

  @override
  String get settingsDesktopLauncherChecking => 'Desktop launcher: checking';

  @override
  String get settingsDesktopLauncherUnavailable =>
      'Desktop launcher: unavailable';

  @override
  String get settingsDesktopSystemDataDir => 'System data directory';

  @override
  String get settingsDesktopPortableDir => 'Portable directory';

  @override
  String get settingsDesktopAppDataDir => 'App data directory';

  @override
  String get settingsUrlLabel => 'URL';

  @override
  String get settingsThemeModeSubtitle =>
      'Light or dark appearance across the app';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsFollowSystem => 'System';

  @override
  String get settingsThemeColorSubtitle => 'Color scheme across the app';

  @override
  String get settingsPageScale => 'Page scale';

  @override
  String get settingsPageScaleSubtitle =>
      'Adjust the overall UI size (reference images are not affected)';

  @override
  String get settingsFontSmall => 'Small';

  @override
  String get settingsFontStandard => 'Standard';

  @override
  String get settingsFontLarge => 'Large';

  @override
  String get settingsFontExtraLarge => 'Largest';

  @override
  String get settingsPersonalization => 'Personalization';

  @override
  String get settingsShowAreaProgress => 'Show area progress bars';

  @override
  String get settingsShowAreaProgressSubtitle =>
      'Show a progress background for unfinished areas in the area picker. Finished areas only show a check mark.';

  @override
  String get settingsDismissPlanActions =>
      'Tap outside to collapse plan actions';

  @override
  String get settingsDismissPlanActionsSubtitle =>
      'After opening plan actions, tap an empty space outside the panel to collapse them';

  @override
  String get settingsCaptureAspectRatioHint =>
      'Auto follows the reference image ratio when possible. A fixed ratio always shoots at that ratio.';

  @override
  String get settingsFallbackAspectRatio => 'Ratio without a reference image';

  @override
  String get settingsFallbackAspectRatioHint =>
      'Used when the photo aspect ratio is Auto and there is no reference image to match.';

  @override
  String get settingsPhotoLocation => 'Photo location';

  @override
  String get settingsPhotoBackupSubtitle =>
      'Also back up the pilgrimage photo when saving a record.';

  @override
  String get settingsPhotoLocationAskDescription =>
      'Choose on the first shutter press. The location is only written to the photo; spot coordinates are not used.';

  @override
  String get settingsPhotoLocationDisabledDescription =>
      'Don\'t request location permission and don\'t write GPS data to photos.';

  @override
  String get settingsPhotoLocationRecentDescription =>
      'Use the device\'s most recent valid location when shooting. If none is available, try to get one.';

  @override
  String get settingsPhotoLocationConfirmDescription =>
      'Get a fresh location on the record confirmation page after shooting. Saving is allowed once it succeeds or fails.';

  @override
  String get settingsPhotoLocationBadgeAsk => 'Ask';

  @override
  String get settingsPhotoLocationBadgeOff => 'Off';

  @override
  String get settingsPhotoLocationBadgeRecent => 'Recent';

  @override
  String get settingsRecommended => 'Recommended';

  @override
  String get settingsPhotoLocationConfirmLabel =>
      'Get location when confirming the record';

  @override
  String get settingsAnitabiUrlHelper =>
      'Only publicly accessible HTTPS base addresses. Don\'t include API paths or parameters.';

  @override
  String get settingsSaveFailed => 'Couldn\'t save settings';

  @override
  String get settingsTryAgainLater => 'Please try again later';

  @override
  String get settingsRestoreDefaultAddresses => 'Restore default addresses';

  @override
  String get settingsAnitabiRestoreTarget => 'All Anitabi service addresses';

  @override
  String get settingsRestoreDefault => 'Restore default';

  @override
  String get settingsAnitabiRestoreNotice =>
      'Current custom addresses won\'t be kept';

  @override
  String get settingsAnitabiSite => 'Main site';

  @override
  String get settingsAnitabiStaticData => 'Static map data';

  @override
  String get settingsAnitabiApi => 'Data API';

  @override
  String get settingsAnitabiOfficialImage => 'Official image service';

  @override
  String get settingsAnitabiMirrorImage => 'Backup image service';

  @override
  String get settingsAnitabiServices => 'Anitabi service addresses';

  @override
  String get settingsServiceAddresses => 'Service addresses';

  @override
  String get settingsTestingConnections => 'Testing connections...';

  @override
  String get settingsTestAllConnections => 'Test all connections';

  @override
  String get settingsAddressAutoUpdate => 'Auto update addresses';

  @override
  String get settingsAddressAutoUpdateDescription =>
      'When Anitabi can\'t be reached, read the latest service addresses from the MiriaGo repository and switch once they are verified. Custom addresses are never changed.';

  @override
  String get settingsChecking => 'Checking...';

  @override
  String get settingsCheckNow => 'Check for updates now';

  @override
  String get settingsRemoteConfigNotApplied =>
      'No remote configuration applied';

  @override
  String get settingsRoutingConnectionOk => 'Routing service connected';

  @override
  String get settingsRoutingConnectionFailed =>
      'Couldn\'t connect to the routing service';

  @override
  String get settingsCustomXyzUrlNotSet => 'No custom XYZ URL set';

  @override
  String get settingsCustomXyzUrl => 'Custom XYZ URL';

  @override
  String get settingsInvalidUrl => 'Invalid URL format';

  @override
  String get settingsMapLibreStyleUrlNotSet => 'No MapLibre style URL set';

  @override
  String get settingsMapLibreStyleUrlHelper =>
      'The URL must point to a publicly readable style JSON.';

  @override
  String get settingsAnitabiServicesHint =>
      'Adjust these if the service domains change. Standard image links in plans are not rewritten.';

  @override
  String get settingsConcurrentImageLoads => 'Concurrent image requests';

  @override
  String get settingsConcurrentImageLoadsSubtitle =>
      'Thumbnails and full reference images are requested this many at a time. Higher values may be faster but use more network and memory.';

  @override
  String get settingsWalkingRoutes => 'Walking routes';

  @override
  String get settingsValhallaAddress => 'Valhalla service address';

  @override
  String get settingsValhallaHelper =>
      'Used for in-app walking routes. Public services have no availability guarantee.';

  @override
  String get settingsTestConnection => 'Test connection';

  @override
  String get settingsTest => 'Test';

  @override
  String get settingsTestValhallaConnection => 'Test Valhalla connection';

  @override
  String get settingsRestoreDefaultValhalla =>
      'Restore default Valhalla address';

  @override
  String get settingsValhallaPrivacy =>
      'Only route coordinates are sent. Plans, works and photos are never uploaded.';

  @override
  String get settingsBaseMapBrightness => 'Base map brightness';

  @override
  String get settingsFollowTheme => 'Follow theme';

  @override
  String get settingsBaseMapBrightnessHint =>
      'Applies to OpenFreeMap. Dark always stays dark; other map sources keep their original style.';

  @override
  String get settingsCurrentLocation => 'Current location';

  @override
  String get settingsContinuousLocation => 'Keep current location updated';

  @override
  String get settingsContinuousLocationSubtitle =>
      'Updates continuously once location is on. When off, location is only fetched when you tap the location button.';

  @override
  String get settingsMapZoom => 'Map zoom';

  @override
  String get settingsMaxZoom => 'Maximum zoom';

  @override
  String get settingsMaxZoomHint => 'The maximum zoom level for all maps.';

  @override
  String get settingsMapMarkers => 'Map markers';

  @override
  String get settingsHideCompletedSpots => 'Hide completed spots';

  @override
  String get settingsHideCompletedSpotsSubtitle =>
      'Spots marked as completed are hidden on the map. Turn off to see all spots.';

  @override
  String get settingsMarkerSize => 'Map marker size';

  @override
  String get settingsMarkerSizeSubtitle =>
      'Scales spots, thumbnails, cluster markers, current location and area anchors together.';

  @override
  String get settingsAreaRange => 'Area range';

  @override
  String get settingsAreaRadius => 'Area radius';

  @override
  String get settingsAreaRadiusSubtitle =>
      'How far each spot extends outward to form the area outline on the map.';

  @override
  String get settingsSpotClustering => 'Spot clustering';

  @override
  String get settingsAutoCluster => 'Cluster dense spots automatically';

  @override
  String get settingsAutoClusterSubtitle =>
      'Only merges how markers are drawn. Spot data, selection and import are not affected.';

  @override
  String get settingsClusterRadius => 'Cluster radius';

  @override
  String get settingsClusterRadiusSubtitle =>
      'Spots close together on screen are merged into one marker with a count.';

  @override
  String get settingsClusterMaxZoom => 'Stop clustering at zoom';

  @override
  String get settingsClusterMaxZoomSubtitle =>
      'Beyond this zoom level, every spot is shown individually.';

  @override
  String get settingsMapThumbnails => 'Map thumbnails';

  @override
  String get settingsThumbnailThreshold => 'Thumbnail threshold';

  @override
  String get settingsThumbnailThresholdHint =>
      'With a threshold of 0, no thumbnails are shown on the map.';

  @override
  String get settingsPlans => 'Plans';

  @override
  String get settingsPlansLoadFailed => 'Couldn\'t load plans';

  @override
  String get settingsSelectPlans => 'Select plans';

  @override
  String get settingsSelectAll => 'Select all';

  @override
  String get settingsClearSelection => 'Clear selection';

  @override
  String get settingsClearDownloadedReferenceCache =>
      'Clear downloaded reference image cache';

  @override
  String get settingsCacheScanFailed => 'Cache scan failed';

  @override
  String get settingsNoCacheToClear =>
      'The selected plans have no downloaded cache to clear';

  @override
  String get settingsClearReferenceCacheTitle => 'Clear reference image cache?';

  @override
  String get settingsClear => 'Clear';

  @override
  String get settingsLauncher => 'Launcher';

  @override
  String get settingsAppInfo => 'App info';

  @override
  String get settingsAppTagline =>
      'Anime pilgrimage planner and photo reference tool';

  @override
  String get settingsCurrentVersion => 'Current version';

  @override
  String get settingsLoading => 'Loading...';

  @override
  String get settingsAuthor => 'Author';

  @override
  String get settingsSourceRepository => 'Source repository';

  @override
  String get settingsLicense => 'Open source license';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsViewPrivacyPolicy => 'View privacy policy';

  @override
  String get settingsDataAndCopyright => 'Data and copyright';

  @override
  String get settingsMap => 'Map';

  @override
  String get settingsMapDataDescription =>
      'Use OpenFreeMap, OpenStreetMap or a custom map service.';

  @override
  String get settingsWorks => 'Works';

  @override
  String get settingsWorksDataDescription =>
      'Work search data comes from Bangumi.';

  @override
  String get settingsPilgrimageContent => 'Pilgrimage content';

  @override
  String get settingsPilgrimageContentDescription =>
      'Pilgrimage spots and reference images come from Anitabi.';

  @override
  String get settingsImageSource => 'Image source';

  @override
  String get settingsImageSourceDescription =>
      'The image source setting only changes the domain used. Remote links always keep the default Anitabi format.';

  @override
  String get settingsCopyright => 'Copyright';

  @override
  String get settingsCopyrightDescription =>
      'Third-party data, screenshots and images belong to their original platforms, contributors or rights holders.';

  @override
  String get settingsAspectAuto => 'Auto';

  @override
  String get settingsAspectNative => 'Native';

  @override
  String get settingsCustom => 'Custom';

  @override
  String get settingsAspectWidescreen => 'Widescreen';

  @override
  String get settingsAspectCinema => 'Cinema';

  @override
  String get settingsAspectClassic => 'Classic';

  @override
  String get settingsAspectCamera => 'Camera';

  @override
  String get settingsAspectPortrait => 'Portrait';

  @override
  String get settingsAspectFullScreen => 'Full screen';

  @override
  String get settingsAspectVertical => 'Vertical';

  @override
  String get settingsAspectSquare => 'Square';

  @override
  String get settingsAspectCustomShort => 'Custom';

  @override
  String get settingsDecrease => 'Decrease';

  @override
  String get settingsIncrease => 'Increase';

  @override
  String get settingsCacheContents => 'Cache contents';

  @override
  String get settingsFullReferenceCacheSubtitle =>
      'Clears the full reference images used by the camera reference and the full-size viewer. The thumbnail cache is kept so lists and maps load quickly.';

  @override
  String get settingsCustomAspectRatio => 'Custom ratio';

  @override
  String get settingsWidth => 'Width';

  @override
  String get settingsHeight => 'Height';

  @override
  String get settingsEnterValidRatio => 'Enter a valid ratio';

  @override
  String get settingsEnterColorName => 'Enter a color name';

  @override
  String get settingsCustomThemeColor => 'Custom theme color';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsColorCode => 'Color code';

  @override
  String get settingsAdd => 'Add';

  @override
  String get settingsHueSaturation => 'Hue and saturation';

  @override
  String get settingsBrightness => 'Brightness';

  @override
  String get settingsSourceDefault => 'Default';

  @override
  String get settingsSourceRemote => 'Remote';

  @override
  String get settingsProbeFailed => 'Failed';

  @override
  String get settingsNavDefault => 'Default';

  @override
  String get settingsNavPopularInChina => 'Popular in China';

  @override
  String get settingsNavIosNative => 'iOS native';

  @override
  String get settingsNavCity => 'City navigation';

  @override
  String get settingsNavGoogleDescription =>
      'The navigation button opens walking directions with official Google Maps URLs.';

  @override
  String get settingsNavAppleDescription =>
      'The navigation button opens walking directions with Apple Map Links.';

  @override
  String get settingsNavAmapDescription =>
      'The navigation button opens walking directions with the Amap URI API, using WGS84 coordinates.';

  @override
  String get settingsNavBaiduDescription =>
      'The navigation button opens walking directions with the Baidu Maps URI API, using WGS84 coordinates.';

  @override
  String get settingsMapRecommendedDefault => 'Recommended';

  @override
  String get settingsMapStandardTiles => 'Standard tiles';

  @override
  String get settingsMapTileTemplate => 'Tile template';

  @override
  String get settingsMapStyleUrl => 'Style URL';

  @override
  String get settingsAnitabiSummaryCustom =>
      'Customized, tap to manage all services';

  @override
  String get settingsAnitabiSummaryRemote =>
      'Using remotely updated addresses, tap to manage all services';

  @override
  String get settingsAnitabiSummaryDefault =>
      'Using default addresses, tap to manage all services';

  @override
  String get settingsImageSourceAuto => 'Automatic';

  @override
  String get settingsImageSourceOfficial => 'Official default';

  @override
  String get settingsImageSourceMirror => 'Backup';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicyLoading => 'Loading privacy policy...';

  @override
  String get privacyPolicyLoadFailed => 'Couldn\'t load the privacy policy';

  @override
  String get addPointsClipboardReadFailed => 'Couldn\'t read the clipboard.';

  @override
  String get addPointsClipboardNoCoordinate =>
      'No valid coordinates in the clipboard.';

  @override
  String get addPointsCoordinateFilled => 'Coordinates filled in.';

  @override
  String get addPointsTitle => 'Add content';

  @override
  String get addPointsRoutePlannerLead => 'Too many spots to sort one by one? ';

  @override
  String get addPointsManualEntryReference => 'Manual entry';

  @override
  String get addPointsPointSaveFailed =>
      'Couldn\'t save the spot. Please try again later.';

  @override
  String addPointsWorkAdded(String title) {
    return 'Added \"$title\".';
  }

  @override
  String get addPointsWorkAddFailed =>
      'Couldn\'t add the work. Please try again later.';

  @override
  String get addPointsSearchBangumiTitle => 'Search Bangumi';

  @override
  String get addPointsWorkNameLabel => 'Work name';

  @override
  String get addPointsWorkNameSearchHint => 'e.g. K-On!';

  @override
  String get addPointsClearSearch => 'Clear search';

  @override
  String get addPointsSearching => 'Searching...';

  @override
  String get addPointsSearchWorks => 'Search works';

  @override
  String get addPointsBangumiSearchFailed =>
      'Bangumi search failed. Check your network and try again.';

  @override
  String get addPointsFilterWorkTypes => 'Filter work types';

  @override
  String addPointsSelectedTypeCount(int count) {
    return '$count selected';
  }

  @override
  String get addPointsLinkClipboardReadFailed =>
      'Couldn\'t read the clipboard. Paste the Anitabi link manually.';

  @override
  String get addPointsLinkClipboardEmpty =>
      'No usable Anitabi link in the clipboard.';

  @override
  String get addPointsLinkImportTitle => 'Import Anitabi link';

  @override
  String addPointsAddingTo(String planName) {
    return 'Adding to: $planName';
  }

  @override
  String get addPointsAnitabiLinkLabel => 'Anitabi link';

  @override
  String get addPointsAnitabiLinkHint => 'Paste an Anitabi work or spot link';

  @override
  String get addPointsClearInput => 'Clear';

  @override
  String get addPointsPaste => 'Paste';

  @override
  String get addPointsOpenAnitabiSpots => 'Open Anitabi spots';

  @override
  String get addPointsLinkRequired => 'Enter an Anitabi link';

  @override
  String get addPointsLinkInvalid => 'Enter a valid Anitabi map link';

  @override
  String get addPointsLinkMissingWorkId =>
      'The link has no work ID. Open the work on Anitabi first, then copy the link';

  @override
  String get addPointsLinkExampleTitle => 'Valid link example';

  @override
  String get addPointsLinkExampleBody =>
      'If the link has a work ID, only that work is loaded.\nIf it also has a spot ID, that spot is selected automatically.\nFor a link without a work ID, open the work on Anitabi first and copy the link again.';

  @override
  String get addPointsLinkExampleBangumiIdNote => 'Bangumi work ID (required)';

  @override
  String get addPointsLinkExampleSpotIdNote => 'Anitabi spot ID (optional)';

  @override
  String get addPointsWorkSaveFailed =>
      'Couldn\'t save the work. Please try again later.';

  @override
  String get addPointsManualAddWork => 'Manual';

  @override
  String get addPointsFillingGuide => 'Filling guide';

  @override
  String get addPointsWorkNameHint => 'Enter the work\'s name';

  @override
  String get addPointsOriginalTitleLabel => 'Original title';

  @override
  String get addPointsOriginalTitleHint =>
      'Enter the original title (e.g. Japanese/English)';

  @override
  String get addPointsWorkTypeLabel => 'Work type';

  @override
  String get addPointsMainRegionLabel => 'Main region';

  @override
  String get addPointsMainRegionHint =>
      'Region where the work is set or filmed';

  @override
  String get addPointsSaving => 'Saving...';

  @override
  String get addPointsSaveWork => 'Save work';

  @override
  String get addPointsFieldRequired => 'This field is required';

  @override
  String get addPointsPointGuideTitle => 'Spot filling guide';

  @override
  String get addPointsPointGuideIntro =>
      'Focus on details you can recognize on site, so you can quickly confirm the location, scene and shooting conditions when you arrive.';

  @override
  String get addPointsWorkLabel => 'Work';

  @override
  String get addPointsBadgeRequired => 'Required';

  @override
  String get addPointsBadgeOptional => 'Optional';

  @override
  String get addPointsBadgeCoordinatesRequired => 'Coordinates required';

  @override
  String get addPointsPointGuideWorkBody =>
      'Choose the work this spot belongs to. If the plan has no works yet, fill in the work name, original title and main region first.';

  @override
  String get addPointsGuideWorkExample => 'K-On!';

  @override
  String get addPointsGuideNameLocationTitle => 'Name and location note';

  @override
  String get addPointsGuideNameLocationBody =>
      'Use the commonly used name. For the location note, prefer the landmark, building or shop name in the local language so it is easy to check on site.';

  @override
  String get addPointsGuideNameLocationExample => 'Tokyo Big Sight / 東京ビッグサイト';

  @override
  String get addPointsGuideSceneSourceTitle => 'Scene tag and reference source';

  @override
  String get addPointsGuideSceneSourceBody =>
      'The scene tag holds only the episode, timestamp or scene number. The reference source is the platform the spot came from, or the original uploader.';

  @override
  String get addPointsGuideSceneSourceExample =>
      'EP 1 / 12:32\nExample: Xiaohongshu@BilyHurington / Bilibili@麦块晓天';

  @override
  String get addPointsNotesLabel => 'Notes';

  @override
  String get addPointsGuideNotesBody =>
      'Opening hours, closures for renovation, photo restrictions, recommended angles, or anything else to know before visiting.';

  @override
  String get addPointsGuideNotesExample =>
      'Renovated in 2025; best shot in the morning; crowded on weekends;';

  @override
  String get addPointsGuideCoordinateImageTitle =>
      'Coordinates and reference image';

  @override
  String get addPointsGuideCoordinateImageBody =>
      'Pick the exact position on the map, or paste the latitude and longitude. For the reference image, use an original frame where the composition is easy to recognize.';

  @override
  String get addPointsGuideCheckMarkerTip =>
      'Before saving, check that the map marker sits on the right building or side of the road. Wrong coordinates affect navigation and finding the spot on site.';

  @override
  String get addPointsGuideGotIt => 'Got it';

  @override
  String get addPointsWorkGuideTitle => 'Work filling guide';

  @override
  String get addPointsWorkGuideIntro =>
      'Fill in details about the work itself. Enter spot names, scene notes and addresses when adding spots.';

  @override
  String get addPointsWorkGuideNameBody =>
      'Use the common translated title or the most recognizable name. Don\'t include episodes or scene names.';

  @override
  String get addPointsWorkGuideOriginalTitleBody =>
      'The official Japanese, English or other original title. Leave it empty if you are not sure.';

  @override
  String get addPointsWorkGuideTypeBody =>
      'Choose the type closest to how the work was released, so it is easy to find and filter in the work list.';

  @override
  String get addPointsGuideWorkTypeExample => 'Anime';

  @override
  String get addPointsWorkGuideRegionBody =>
      'Where the work is set or filmed, in a short \"City / Area\" format. If empty, the plan\'s region is used.';

  @override
  String get addPointsWorkGuideRegionExample => 'Kyoto / Uji';

  @override
  String get addPointsWorkGuideFooter =>
      'After saving, the form clears so you can add more. Works don\'t create spots automatically; use \"Add spot manually\" to add pilgrimage locations.';

  @override
  String addPointsGuideExample(String example) {
    return 'Example: $example';
  }

  @override
  String get addPointsLatitudeAlsoRequired => 'Also enter the latitude';

  @override
  String get addPointsLongitudeAlsoRequired => 'Also enter the longitude';

  @override
  String get addPointsLatitudeInvalid => 'Invalid latitude format';

  @override
  String get addPointsLongitudeInvalid => 'Invalid longitude format';

  @override
  String get addPointsQuickManualAddPoint => 'Quick add spot';

  @override
  String get addPointsSelectWorkRequired => 'Select a work';

  @override
  String get addPointsPointNameLabel => 'Spot name';

  @override
  String get addPointsPointNameHint => 'e.g. Tokyo Big Sight';

  @override
  String get addPointsCoordinateLabel => 'Coordinates';

  @override
  String get addPointsLatitude => 'Latitude';

  @override
  String get addPointsLongitude => 'Longitude';

  @override
  String get addPointsLatitudeHint => 'e.g. 35.712576';

  @override
  String get addPointsLongitudeHint => 'e.g. 139.722166';

  @override
  String get addPointsPickFromMap => 'Pick from map';

  @override
  String get addPointsPickFromMapShort => 'Map';

  @override
  String get addPointsPickFromMapSemantic => 'Pick coordinates from map';

  @override
  String get addPointsPasteCoordinates => 'Paste coordinates from clipboard';

  @override
  String get addPointsSavePoint => 'Save spot';

  @override
  String get addPointsQuickGuideTitle => 'Quick add guide';

  @override
  String get addPointsQuickGuideIntro =>
      'Enter the basics first. You can add the location note, scene tag, reference source, notes and reference image later on the spot edit page.';

  @override
  String get addPointsQuickGuideWorkBody =>
      'Choose an existing work for this spot. If it isn\'t listed, go back to Add content and add the work first.';

  @override
  String get addPointsQuickGuideNameBody =>
      'Use a common name that is easy to recognize and search. You can change it later on the edit page.';

  @override
  String get addPointsGuidePointNameExample => 'Tokyo Big Sight';

  @override
  String get addPointsQuickGuideCoordinateBody =>
      'Leave it empty if you don\'t know the exact position yet. If you fill it in, enter both latitude and longitude, or pick from the map or paste coordinates.';

  @override
  String get addPointsSaveUnconfirmed =>
      'Couldn\'t confirm the save. Go back, refresh the plan and check whether the spot was added.';

  @override
  String get addPointsReferenceImageReadFailed =>
      'Couldn\'t read the reference image. Please choose it again.';

  @override
  String get addPointsEditPoint => 'Edit spot';

  @override
  String get addPointsManualAddPoint => 'Add spot manually';

  @override
  String addPointsEditing(String name) {
    return 'Editing: $name';
  }

  @override
  String get addPointsLocationNoteLabel => 'Location note';

  @override
  String get addPointsLocationNoteHint => 'e.g. 東京ビッグサイト';

  @override
  String get addPointsSceneTagLabel => 'Episode/scene tag';

  @override
  String get addPointsSceneTagHint => 'e.g. EP 1 / 12:32';

  @override
  String get addPointsReferenceSourceLabel => 'Reference source';

  @override
  String get addPointsReferenceSourceHint =>
      'e.g. Xiaohongshu@BilyHurington / Bilibili@麦块晓天';

  @override
  String get addPointsNotesHint =>
      'e.g. Renovated in 2025; best shot in the morning; crowded on weekends';

  @override
  String get addPointsSaveChanges => 'Save changes';

  @override
  String get addPointsLatitudeRequired => 'Enter the latitude';

  @override
  String get addPointsLongitudeRequired => 'Enter the longitude';

  @override
  String get addPointsCoordinateInvalid => 'Enter valid coordinates';

  @override
  String get addPointsPickCoordinateTitle => 'Pick spot coordinates';

  @override
  String get addPointsExitMapPick => 'Stop picking on map';

  @override
  String get addPointsStartMapPick => 'Pick on map';

  @override
  String get addPointsMapPickHint =>
      'Tap anywhere on the map to set the spot\'s coordinates';

  @override
  String get addPointsMapPickIdleHint =>
      'Tap the pick button at the top right, then tap the map to set coordinates';

  @override
  String addPointsMapAdjustHint(String coordinates) {
    return 'Tap the map to adjust the position\n$coordinates';
  }

  @override
  String get addPointsMapPickTitle => 'Pick on map';

  @override
  String get addPointsUse => 'Use';

  @override
  String get addPointsLinkedWorks => 'Linked works';

  @override
  String addPointsLinkedWorksSummary(int workCount, int pointCount) {
    String _temp0 = intl.Intl.pluralLogic(
      workCount,
      locale: localeName,
      other: '$workCount works',
      one: '1 work',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pointCount,
      locale: localeName,
      other: '$pointCount spots',
      one: '1 spot',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get addPointsManageWorks => 'Manage works';

  @override
  String get addPointsNoLinkedWorks =>
      'No linked works yet. Search Bangumi or add one manually.';

  @override
  String get addPointsAddFromBangumi => 'Bangumi';

  @override
  String get addPointsAddFromBangumiSubtitle => 'Search and add';

  @override
  String get addPointsManualAddWorkSubtitle => 'If it\'s not listed';

  @override
  String get addPointsViewFullImage => 'View full image';

  @override
  String get addPointsNoReferenceImage => 'No reference image';

  @override
  String get addPointsReferenceImageLabel => 'Reference image';

  @override
  String get addPointsReferenceImagePending =>
      'New image selected. It applies after saving.';

  @override
  String get addPointsReferenceImageCurrent =>
      'Current reference image. A new choice applies after saving.';

  @override
  String get addPointsReferenceImageOptional =>
      'Optional. It is copied into the app\'s local folder when saved.';

  @override
  String get addPointsReselectImage => 'Choose again';

  @override
  String get addPointsUploadReferenceImage => 'Upload reference image';

  @override
  String get addPointsRemoveImage => 'Remove';

  @override
  String get addPointsAdded => 'Added';

  @override
  String get addPointsAdd => 'Add';

  @override
  String get addPointsSearchHelpTitle => 'Search tips';

  @override
  String get addPointsSearchHelpBody =>
      'Search by work name, then pick a result to add it to this plan.';

  @override
  String get addPointsBangumiNetworkNote =>
      'Bangumi search needs an international network connection.';

  @override
  String get addPointsRecommended => 'Recommended';

  @override
  String get addPointsQuickManualSubtitle =>
      'Just the work, name and optional coordinates';

  @override
  String get addPointsAddWorkFirst => 'Add a work first';

  @override
  String get addPointsManualAddPointSubtitle =>
      'Enter spot details by hand, one at a time';

  @override
  String get groupAnchorPickerTitle => 'Choose anchor';

  @override
  String get groupAnchorPickerExitMapPick => 'Stop picking on map';

  @override
  String get groupAnchorPickerStartMapPick => 'Pick on map';

  @override
  String get groupAnchorPickerEnterCoordinates => 'Enter coordinates';

  @override
  String get groupAnchorPickerClearSelection => 'Clear selection';

  @override
  String get groupAnchorPickerClearMessage =>
      'This clears the selected anchor. You can choose again on this page.';

  @override
  String get groupAnchorPickerManualAnchor => 'Manual anchor';

  @override
  String get groupAnchorPickerSelectPoint => 'Select spot';

  @override
  String get groupAnchorPickerNoneSelected => 'No anchor selected';

  @override
  String get groupAnchorPickerMapPickHint =>
      'Tap anywhere on the map to set the anchor';

  @override
  String get groupAnchorPickerIdleHint =>
      'Tap a spot or the map, or enter coordinates';

  @override
  String pointManagerSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get pointManagerGroupManagement => 'Manage areas';

  @override
  String get pointManagerMoveGroupFailed => 'Couldn\'t move the area';

  @override
  String get pointManagerMoveToGroup => 'Move to area';

  @override
  String get pointManagerMoveToGroupSubtitle =>
      'Choose the area this spot belongs to';

  @override
  String get pointManagerNotInGroup => 'Not in an area';

  @override
  String get pointManagerPointOrderSaveFailed =>
      'Couldn\'t save the spot order';

  @override
  String get pointManagerBatchDeleteTitle => 'Delete spots';

  @override
  String pointManagerBatchDeleteMessage(String countText) {
    return '$countText will be removed from the plan.';
  }

  @override
  String pointManagerSpotCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String get pointManagerBatchDeleteFailed => 'Couldn\'t delete the spots';

  @override
  String get pointManagerNearestAssign => 'Assign nearest';

  @override
  String get pointManagerBoxAssign => 'Box assign';

  @override
  String get pointManagerSelectAll => 'Select all';

  @override
  String get pointManagerMove => 'Move';

  @override
  String get coordinateInputClipboardReadFailed =>
      'Couldn\'t read the clipboard.';

  @override
  String get coordinateInputClipboardNoCoordinate =>
      'No recognizable coordinates in the clipboard.';

  @override
  String get coordinateInputInvalid => 'Enter valid coordinates';

  @override
  String get coordinateInputTitle => 'Enter coordinates';

  @override
  String get coordinateInputLatitude => 'Latitude';

  @override
  String get coordinateInputLongitude => 'Longitude';

  @override
  String get coordinateInputConfirm => 'OK';

  @override
  String get planGroupUtilsOrderPending => 'To sort';

  @override
  String get planGroupUtilsOrderManual => 'Manual';

  @override
  String get planGroupUtilsOrderUnordered => 'Unordered';

  @override
  String get planGroupUtilsAwaitingGroup => 'Not in an area yet';

  @override
  String get planGroupUtilsAnchorUnset => 'No anchor set';

  @override
  String planGroupUtilsAnchor(String name) {
    return 'Anchor: $name';
  }

  @override
  String get planGroupUtilsUngrouped => 'Ungrouped';

  @override
  String get planGroupPickerTitle => 'Choose area';

  @override
  String planGroupPickerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas',
      one: '1 area',
    );
    return '$_temp0';
  }

  @override
  String get planGroupPickerNewGroup => 'New area';

  @override
  String get planManagerSwitchFailed =>
      'Couldn\'t switch plans. Please try again later.';

  @override
  String get planManagerDeletePlan => 'Delete plan';

  @override
  String get planManagerCopyFailed =>
      'Couldn\'t copy the plan. Please try again later.';

  @override
  String get planManagerSaveOrderFailed =>
      'Couldn\'t save the plan order. The previous order was restored.';

  @override
  String get planManagerReorderTitle => 'Reorder plans';

  @override
  String get planManagerTitle => 'All plans';

  @override
  String get planManagerDoneSorting => 'Done sorting';

  @override
  String get planManagerSortPlans => 'Sort plans';

  @override
  String get planManagerSkillLead => 'Don\'t want to organize spots by hand? ';

  @override
  String get planManagerAllPlans => 'All plans';

  @override
  String get planManagerEditInfo => 'Edit plan info';

  @override
  String get planManagerPlanName => 'Plan name';

  @override
  String get planManagerNewPlan => 'New plan';

  @override
  String get planManagerPlanInfo => 'Plan info';

  @override
  String get planManagerNoWorks => 'No works yet';

  @override
  String get planManagerCurrentPlan => 'Current plan';

  @override
  String get planManagerDragSort => 'Drag to sort';

  @override
  String get planManagerMoreActions => 'More plan actions';

  @override
  String get planManagerImportExport => 'Import / export';

  @override
  String get planManagerCopyPlan => 'Copy plan';

  @override
  String get planManagerReload => 'Reload plans';

  @override
  String planManagerNewPlanName(int number) {
    return 'New plan $number';
  }

  @override
  String planManagerDeleteMessage(String name) {
    return 'This deletes \"$name\" and its spots, areas, works and pilgrimage records. Pilgrimage photos, color-matched images and reference images used only by this plan are deleted too; files still used by other plans or records are kept.';
  }

  @override
  String planManagerCopyName(String name) {
    return '$name copy';
  }

  @override
  String planManagerCopied(String name) {
    return 'Copied \"$name\"';
  }

  @override
  String planManagerPlanSummary(int spotCount, int workCount) {
    String _temp0 = intl.Intl.pluralLogic(
      spotCount,
      locale: localeName,
      other: '$spotCount spots',
      one: '1 spot',
    );
    String _temp1 = intl.Intl.pluralLogic(
      workCount,
      locale: localeName,
      other: '$workCount works',
      one: '1 work',
    );
    return '$_temp0  /  $_temp1';
  }

  @override
  String get planMemoUnsavedChanges => 'Unsaved changes';

  @override
  String planMemoImageUnsupported(String label) {
    return 'Memos don\'t support images: $label';
  }

  @override
  String get planMemoDiscardTitle => 'Discard unsaved changes?';

  @override
  String get planMemoDiscardMessage => 'This memo has unsaved changes.';

  @override
  String get planMemoDiscard => 'Discard';

  @override
  String get planMemoKeepEditing => 'Keep editing';

  @override
  String get planMemoDiscardNotice => 'Unsaved changes will not be kept';

  @override
  String get planMemoSavingWait => 'Saving the memo, please wait';

  @override
  String get planMemoSavedEditsPending =>
      'Saved. Newer edits still need saving';

  @override
  String get planMemoSaved => 'Plan memo saved';

  @override
  String get planMemoSaveFailed => 'Couldn\'t save the plan memo';

  @override
  String get planMemoTaskSaveFailed => 'Couldn\'t save the to-do state';

  @override
  String get planMemoHeading => 'Heading';

  @override
  String get planMemoBoldPlaceholder => 'Bold text';

  @override
  String get planMemoListPlaceholder => 'List item';

  @override
  String get planMemoTaskPlaceholder => 'To-do item';

  @override
  String get planMemoQuotePlaceholder => 'Quoted text';

  @override
  String get planMemoLinkPlaceholder => 'Link text';

  @override
  String get planMemoCode => 'Code';

  @override
  String get planMemoInvalidLink => 'Invalid link format';

  @override
  String get planMemoOpenLinkFailed => 'Couldn\'t open the link';

  @override
  String get planMemoTitle => 'Plan memo';

  @override
  String get planMemoEdit => 'Edit';

  @override
  String get planMemoContent => 'Memo content';

  @override
  String get planMemoHint =>
      'Note transport, bookings, reshoots, travel companions and more.';

  @override
  String get planMemoBold => 'Bold';

  @override
  String get planMemoList => 'List';

  @override
  String get planMemoTask => 'To-do';

  @override
  String get planMemoQuote => 'Quote';

  @override
  String get planMemoDivider => 'Divider';

  @override
  String get planMemoLink => 'Link';

  @override
  String get planMemoUncheck => 'Uncheck';

  @override
  String get planMemoMarkDone => 'Mark as done';

  @override
  String get planMemoSuggestTransport => 'Transport';

  @override
  String get planMemoSuggestTransportDetail =>
      'Train numbers, transfers, departure times, etc.';

  @override
  String get planMemoSuggestHotel => 'Hotel booking';

  @override
  String get planMemoSuggestHotelDetail =>
      'Hotel address, check-in time, contact details, etc.';

  @override
  String get planMemoSuggestTickets => 'Event tickets';

  @override
  String get planMemoSuggestTicketsDetail =>
      'Event tickets, booking times, things to watch for, etc.';

  @override
  String get planMemoSuggestShooting => 'Shooting plan';

  @override
  String get planMemoSuggestShootingDetail =>
      'Shooting locations, times, bad-weather backups, etc.';

  @override
  String get planMemoSuggestNotes => 'Things to note';

  @override
  String get planMemoSuggestNotesDetail =>
      'What to bring, budget, local tips, etc.';

  @override
  String get planMemoEmptyTitle => 'No plan memo yet';

  @override
  String get planMemoEmptyBody =>
      'Note the important things for this pilgrimage';

  @override
  String get planMemoSuggestionsTitle => 'Ideas for what to note';

  @override
  String get planMemoStart => 'Start writing';

  @override
  String nearestGroupAssignUngroupedSpots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungrouped spots',
      one: '1 ungrouped spot',
    );
    return '$_temp0';
  }

  @override
  String nearestGroupAssignConfirmMessage(String spots, String distance) {
    return '$spots will be assigned to the nearest area anchor, up to $distance away.';
  }

  @override
  String nearestGroupAssignDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'Assigned $_temp0';
  }

  @override
  String nearestGroupAssignDoneDistanceUnsaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'Assigned $_temp0. The distance setting wasn\'t saved';
  }

  @override
  String nearestGroupAssignBoxConfirmMessage(String spots, String area) {
    return '$spots will be moved to \"$area\".';
  }

  @override
  String nearestGroupAssignAreaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas',
      one: '1 area',
    );
    return '$_temp0';
  }

  @override
  String nearestGroupAssignBoxStatus(int selected, int ungrouped) {
    return 'Selected $selected / unassigned $ungrouped';
  }

  @override
  String nearestGroupAssignMaxDistance(String distance) {
    return 'Max distance $distance';
  }

  @override
  String nearestGroupAssignAssignableCount(int assignable, int ungrouped) {
    return 'Assignable $assignable/$ungrouped';
  }

  @override
  String nearestGroupAssignCurrentDistance(String distance) {
    return 'Current $distance';
  }

  @override
  String get nearestGroupAssignInRange => 'Within max distance';

  @override
  String get nearestGroupAssignOutOfRange => 'Beyond max distance';

  @override
  String nearestGroupAssignUngroupedHint(int count) {
    return '$count ungrouped · tap a spot on the map for details';
  }

  @override
  String get nearestGroupAssignTitle => 'Assign to nearest';

  @override
  String get nearestGroupAssignNoneInRange =>
      'No spots to assign within this distance';

  @override
  String get nearestGroupAssignConfirmTitle => 'Assign to nearest?';

  @override
  String get nearestGroupAssignStart => 'Start assigning';

  @override
  String get nearestGroupAssignFailed => 'Couldn\'t assign to nearest';

  @override
  String get nearestGroupAssignFinishFirst => 'Finish assigning areas first';

  @override
  String get nearestGroupAssignBoxTitle => 'Assign by box selection';

  @override
  String get nearestGroupAssignBoxSelected => 'Selected';

  @override
  String get nearestGroupAssignNotBoxSelected => 'Not selected';

  @override
  String get nearestGroupAssignCreateAreaFailed => 'Couldn\'t create the area';

  @override
  String get nearestGroupAssignCreateAreaFirst => 'Create an area first';

  @override
  String get nearestGroupAssignBoxNoUngrouped =>
      'No ungrouped spots in the selection';

  @override
  String get nearestGroupAssignBoxConfirmTitle => 'Assign selected spots?';

  @override
  String get nearestGroupAssignAssign => 'Assign';

  @override
  String get nearestGroupAssignBoxFailed =>
      'Couldn\'t assign the selected spots';

  @override
  String get nearestGroupAssignChooseArea => 'Choose area';

  @override
  String get nearestGroupAssignNewArea => 'New area';

  @override
  String get nearestGroupAssignAreaNameEmpty => 'Area name can\'t be empty';

  @override
  String get nearestGroupAssignAreaName => 'Area name';

  @override
  String get nearestGroupAssignCreate => 'Create';

  @override
  String get nearestGroupAssignEndBox => 'End selection';

  @override
  String get nearestGroupAssignBox => 'Box select';

  @override
  String get nearestGroupAssignEnd => 'End';

  @override
  String get nearestGroupAssignStartBox => 'Start box selection';

  @override
  String get nearestGroupAssignAssigning => 'Assigning';

  @override
  String get nearestGroupAssignAssigningSpots => 'Assigning spots';

  @override
  String get nearestGroupAssignAssignSelected => 'Assign selected spots';

  @override
  String get nearestGroupAssignExplain =>
      'Ungrouped spots go to the nearest area anchor within the max distance.';

  @override
  String get nearestGroupAssignNoAnchor => 'No area anchor available';

  @override
  String get nearestGroupAssignSetAnchorFirst =>
      'Set anchors in area management first';

  @override
  String get nearestGroupAssignAssignableSpot => 'Assignable spot';

  @override
  String get nearestGroupAssignOutOfRangeSpot => 'Out-of-range spot';

  @override
  String planCacheFullImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count full reference images',
      one: '1 full reference image',
    );
    return '$_temp0';
  }

  @override
  String planCacheFullReferencesMessage(String images) {
    return 'This caches $images for the current plan. It can take a while and use a lot of data.';
  }

  @override
  String planAreaProgress(
    String anchor,
    int completed,
    int total,
    String order,
  ) {
    return '$anchor · $completed/$total done · $order';
  }

  @override
  String planSummary(int spotCount, String works) {
    String _temp0 = intl.Intl.pluralLogic(
      spotCount,
      locale: localeName,
      other: '$spotCount spots',
      one: '1 spot',
    );
    return '$_temp0 / $works';
  }

  @override
  String planWorkCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count works',
      one: '1 work',
    );
    return '$_temp0';
  }

  @override
  String get planAddSpots => 'Add spots';

  @override
  String get planHideActions => 'Hide plan actions';

  @override
  String get planShowActions => 'Show plan actions';

  @override
  String get planCreateAreaFailed =>
      'Couldn\'t create the area. Please try again later.';

  @override
  String get planNoReferencesToCache =>
      'This plan has no reference images to cache';

  @override
  String get planCacheFullReferencesTitle => 'Cache full reference images';

  @override
  String get planStartCaching => 'Start caching';

  @override
  String get planCacheWifiNotice => 'Wi-Fi is recommended for caching';

  @override
  String get planNewArea => 'New area';

  @override
  String get planAreaName => 'Area name';

  @override
  String get planCreate => 'Create';

  @override
  String get planSwitchPlan => 'All plans';

  @override
  String get planCacheReferences => 'Cache images';

  @override
  String get planActionMemo => 'Plan memo';

  @override
  String get planActionImportExport => 'Import / export';

  @override
  String get planPreviousArea => 'Previous area';

  @override
  String get planNextArea => 'Next area';

  @override
  String get planHideMap => 'Hide map';

  @override
  String get planMap => 'Map';

  @override
  String get planSortDefaultOrder => 'Default plan order';

  @override
  String get planSortByDistanceFromHere => 'By distance from current location';

  @override
  String get planSortDefault => 'Plan order';

  @override
  String get planSortDistance => 'Distance';

  @override
  String get planSortReversed => 'Reversed';

  @override
  String get planSortForward => 'In order';

  @override
  String get planSortFarToNear => 'Far to near';

  @override
  String get planSortNearToFar => 'Near to far';

  @override
  String get planHideLocation => 'Hide current location';

  @override
  String get planShowLocation => 'Show current location';

  @override
  String get planNoSpotsYet => 'No spots yet';

  @override
  String get planOnboardingSpotsTitle => 'Pick spots';

  @override
  String get planOnboardingSpotsBody =>
      'Tap spots on the map to import them. The anime is added to this plan for you.';

  @override
  String get planUndoCheckIn => 'Undo check-in';

  @override
  String get planComplete => 'Complete';

  @override
  String get planShootReference => 'Shoot with reference';

  @override
  String anitabiMapImportAddAllMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'This adds $_temp0 from this work that aren\'t in the plan yet. They stay ungrouped for now.';
  }

  @override
  String anitabiMapImportImporting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'Importing $_temp0...';
  }

  @override
  String anitabiMapImportCachingThumbnails(
    int processed,
    int total,
    int succeeded,
  ) {
    return 'Caching thumbnails $processed/$total, $succeeded succeeded';
  }

  @override
  String anitabiMapImportImportedPartialCache(int count, int cached) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'Imported $_temp0, cached $cached/$count thumbnails. The rest will be filled in automatically later.';
  }

  @override
  String get anitabiMapImportBoxHint => 'Drag a box on the map to select spots';

  @override
  String anitabiMapImportBoxCount(int count, int newCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0 · $newCount new';
  }

  @override
  String get anitabiMapImportBoxChooseArea => 'Choose area';

  @override
  String get anitabiMapImportBoxAreaSubtitle =>
      'New spots are imported into it; spots already in the plan move to it';

  @override
  String get anitabiMapImportBoxApply => 'Put in area';

  @override
  String anitabiMapImportAssigned(int count, String area) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'Assigned $_temp0 to \"$area\"';
  }

  @override
  String anitabiMapImportDetailPartial(int loaded, int expected) {
    return 'Only $loaded of $expected spots were loaded. Reload, or check that your network can reach the Anitabi map data.';
  }

  @override
  String anitabiMapImportSpotCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String anitabiMapImportShownCount(int imported, int shown) {
    return 'Imported $imported / showing $shown';
  }

  @override
  String anitabiMapImportShownCountOfTotal(int imported, int shown, int total) {
    return 'Imported $imported / showing $shown / $total total';
  }

  @override
  String anitabiMapImportOpenAppFailed(String app) {
    return 'Couldn\'t open $app.';
  }

  @override
  String anitabiMapImportNoImageSpots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return 'This work has $_temp0, but none with reference images to import.';
  }

  @override
  String anitabiMapImportWorkNoSpots(String title) {
    return '\"$title\" has no Anitabi spots to import yet.';
  }

  @override
  String get anitabiMapImportSettingsSaveFailed => 'Couldn\'t save settings';

  @override
  String get anitabiMapImportTryLater => 'Please try again later';

  @override
  String get anitabiMapImportClearingCache =>
      'Clearing the cache and reloading Anitabi spots...';

  @override
  String get anitabiMapImportManualWorkNoId =>
      'Manually added works have no Bangumi ID, so their spots can\'t be imported from the Anitabi map.';

  @override
  String get anitabiMapImportManualWorkState =>
      'Manually added works have no Bangumi ID, so their spots can\'t be imported from the Anitabi map.\n\nAdd works through Bangumi/Anitabi search, or add spots manually.';

  @override
  String get anitabiMapImportAddedContinue =>
      'Added to the plan. You can keep picking spots.';

  @override
  String get anitabiMapImportSpotImportFailed =>
      'Couldn\'t import the spot. Please try again later.';

  @override
  String get anitabiMapImportAddAll => 'Add all spots';

  @override
  String get anitabiMapImportAddAllConfirm => 'Add all';

  @override
  String get anitabiMapImportAddedAll => 'Added all remaining spots.';

  @override
  String get anitabiMapImportBulkFailed =>
      'Bulk import failed. Please try again later.';

  @override
  String get anitabiMapImportAddedBox => 'Added the selected spots.';

  @override
  String get anitabiMapImportBoxFailed =>
      'Couldn\'t import the selected spots. Please try again later.';

  @override
  String get anitabiMapImportOrganizeOpenFailed =>
      'Spots imported, but the organize step couldn\'t open. You can adjust areas in the plan later.';

  @override
  String get anitabiMapImportAssignToArea => 'Assign to area';

  @override
  String get anitabiMapImportAssignToAreaSubtitle =>
      'Choose an area for the spots you just imported';

  @override
  String get anitabiMapImportNotInArea => 'Not in an area';

  @override
  String get anitabiMapImportSelectedArea => 'Selected area';

  @override
  String get anitabiMapImportAssignFailed =>
      'Couldn\'t assign the spots. Please try again later.';

  @override
  String get anitabiMapImportCreateAreaFailed =>
      'Couldn\'t create the area. Please try again later.';

  @override
  String get anitabiMapImportThumbnailMarkers => 'Thumbnail markers';

  @override
  String get anitabiMapImportOnlyNotAdded => 'Only spots not added';

  @override
  String get anitabiMapImportOnlyNotAddedDesc =>
      'Hide spots already in the plan';

  @override
  String get anitabiMapImportAreaBounds => 'Area outlines';

  @override
  String get anitabiMapImportAreaBoundsDesc =>
      'Show the plan\'s existing areas';

  @override
  String get anitabiMapImportClustering => 'Cluster dense spots';

  @override
  String get anitabiMapImportAnitabiSpot => 'Anitabi spot';

  @override
  String get anitabiMapImportTitle => 'Import spots';

  @override
  String get anitabiMapImportLayers => 'Layers';

  @override
  String get anitabiMapImportClearCacheReload =>
      'Clear cache and reload Anitabi spots';

  @override
  String get anitabiMapImportAdded => 'Added';

  @override
  String get anitabiMapImportErrorDataUnavailable =>
      'Anitabi map data couldn\'t be loaded';

  @override
  String get anitabiMapImportErrorWorkNotFound =>
      'This work wasn\'t found on Anitabi';

  @override
  String get anitabiMapImportErrorNoPoints =>
      'This work has no Anitabi spots yet';

  @override
  String get anitabiMapImportErrorPartial =>
      'Only some Anitabi spots were loaded';

  @override
  String get anitabiMapImportError404 =>
      'This Bangumi entry has no Anitabi map data yet';

  @override
  String get anitabiMapImportErrorPointNotFound =>
      'This Anitabi spot wasn\'t found';

  @override
  String get anitabiMapImportErrorGeneric => 'Couldn\'t load Anitabi spots';

  @override
  String get anitabiMapImportDetailDataUnavailableWeb =>
      'The cached Anitabi map data may be out of date, or the preview server\'s network requests may be blocked. Clear the cache and reload Anitabi spots.';

  @override
  String get anitabiMapImportDetailDataUnavailable =>
      'Couldn\'t read the Anitabi map index. Check your network connection, or clear the cache and reload Anitabi spots.';

  @override
  String get anitabiMapImportDetailWorkNotFound =>
      'This Bangumi entry has no matching work in the Anitabi map data. Try adding the anime, original work or another related entry with the same name.';

  @override
  String get anitabiMapImportDetailNoPoints =>
      'This work is on Anitabi, but it has no map spots to import yet.';

  @override
  String get anitabiMapImportDetail404 =>
      'Try adding the original work, game or another related entry with the same name in work management.';

  @override
  String get anitabiMapImportDetailPointNotFound =>
      'The spot ID in the link may be outdated, or the Anitabi map data hasn\'t synced yet.';

  @override
  String get anitabiMapImportDetailGeneric =>
      'Check your network and try again, or reload later.';

  @override
  String get anitabiMapImportOrganizeTitle =>
      'Organize the spots you just imported';

  @override
  String get anitabiMapImportOrganizeLead => 'Imported ';

  @override
  String get anitabiMapImportOrganizeTail =>
      '. They stay ungrouped for now. Assign them to an area, or quickly assign each to the nearest anchor.';

  @override
  String get anitabiMapImportNearestAssign => 'Assign to nearest';

  @override
  String get anitabiMapImportLater => 'Later';

  @override
  String get anitabiMapImportAreaNameEmpty => 'Area name can\'t be empty';

  @override
  String get anitabiMapImportNewArea => 'New area';

  @override
  String get anitabiMapImportAreaName => 'Area name';

  @override
  String get anitabiMapImportCreate => 'Create';

  @override
  String get anitabiMapImportImportedSpot => 'Imported spot';

  @override
  String get anitabiMapImportImportableSpot => 'Importable spot';

  @override
  String get anitabiMapImportLoadingSpots => 'Loading Anitabi spots';

  @override
  String get anitabiMapImportExitBox => 'Exit box selection';

  @override
  String get anitabiMapImportBoxSelect => 'Box select spots';

  @override
  String get anitabiMapImportSpotName => 'Spot name';

  @override
  String get anitabiMapImportSpotInfo => 'Spot info';

  @override
  String get anitabiMapImportSource => 'Source';

  @override
  String get anitabiMapImportNavigate => 'Navigate';

  @override
  String get anitabiMapImportOpenNavigation => 'Open navigation';

  @override
  String get anitabiMapImportInPlan => 'In plan';

  @override
  String get anitabiMapImportAddToPlan => 'Add to plan';

  @override
  String get anitabiMapImportAddShort => 'Add';

  @override
  String get anitabiMapImportScene => 'Scene';

  @override
  String get anitabiMapImportNote => 'Note';

  @override
  String get anitabiMapImportCoordinates => 'Coordinates';

  @override
  String get anitabiMapImportTapSpotHint =>
      'Tap a spot on the map to see its thumbnail and details.';

  @override
  String get anitabiMapImportNoImportableSpots =>
      'This work has no Anitabi spots to import.';

  @override
  String get anitabiMapImportNoWorks => 'No works yet';

  @override
  String get anitabiMapImportFromBangumiTitle => 'Find an anime';

  @override
  String get anitabiMapImportFromBangumiBody =>
      'Search Bangumi for the anime, or paste a link copied from anitabi.cn. Its spots show on this map, and the anime joins your plan when you import spots.';

  @override
  String get anitabiMapImportLoadingWorks => 'Loading Anitabi works and spots';

  @override
  String get planGroupManagerTitle => 'Manage areas';

  @override
  String get planGroupManagerNewArea => 'New area';

  @override
  String get planGroupManagerCreate => 'Create';

  @override
  String get planGroupManagerCreateFailed => 'Couldn\'t create area';

  @override
  String get planGroupManagerRenameTitle => 'Rename area';

  @override
  String get planGroupManagerRenameFailed => 'Couldn\'t rename area';

  @override
  String get planGroupManagerOrderModeSaveFailed => 'Couldn\'t save sort mode';

  @override
  String get planGroupManagerAnchorSaveFailed => 'Couldn\'t save anchor';

  @override
  String get planGroupManagerDeleteArea => 'Delete area';

  @override
  String planGroupManagerDeleteMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete \"$name\"? Its $count spots will move to ungrouped spots.',
      one: 'Delete \"$name\"? Its 1 spot will move to ungrouped spots.',
    );
    return '$_temp0';
  }

  @override
  String get planGroupManagerDeleteFailed => 'Couldn\'t delete area';

  @override
  String get planGroupManagerReorderFailed => 'Couldn\'t save area order';

  @override
  String get planGroupManagerUngroupedSpots => 'Ungrouped spots';

  @override
  String get planGroupManagerUnknownArea => 'Unknown area';

  @override
  String get planGroupManagerNameRequired => 'Area name can\'t be empty';

  @override
  String get planGroupManagerNameLabel => 'Area name';

  @override
  String planGroupManagerSummary(int groupCount, int pointCount) {
    String _temp0 = intl.Intl.pluralLogic(
      groupCount,
      locale: localeName,
      other: '$groupCount areas',
      one: '1 area',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pointCount,
      locale: localeName,
      other: '$pointCount spots',
      one: '1 spot',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get planGroupManagerManualOrder => 'Manual order';

  @override
  String get planGroupManagerUnordered => 'Unordered';

  @override
  String get planGroupManagerEmpty => 'Empty';

  @override
  String planGroupManagerAnchorLabel(String name) {
    return 'Anchor · $name';
  }

  @override
  String get planGroupManagerNoAnchor => 'No anchor set';

  @override
  String get planGroupManagerAreaActions => 'Area actions';

  @override
  String get planGroupManagerRename => 'Rename';

  @override
  String get planGroupManagerSetAnchor => 'Set anchor';

  @override
  String get planGroupManagerSwitchToUnordered => 'Switch to unordered';

  @override
  String get planGroupManagerSwitchToManualOrder => 'Switch to manual order';

  @override
  String planGroupManagerUngroupedWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots to organize',
      one: '1 spot to organize',
    );
    return '$_temp0';
  }

  @override
  String get workManagerTitle => 'Manage works';

  @override
  String get workManagerDeleteWork => 'Delete work';

  @override
  String workManagerDeleteMessage(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String workManagerDeleteMessageWithPoints(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Delete \"$title\"? This also removes its $count related spots and their records.',
      one:
          'Delete \"$title\"? This also removes its 1 related spot and its records.',
    );
    return '$_temp0';
  }

  @override
  String get workManagerDeleteFailed => 'Couldn\'t delete work';

  @override
  String get workManagerAddFromBangumi => 'Bangumi';

  @override
  String get workManagerAddFromBangumiHint => 'Search and add';

  @override
  String get workManagerAddManually => 'Manual';

  @override
  String get workManagerAddManuallyHint => 'If it\'s not listed';

  @override
  String get workManagerCopyTitle => 'Work title';

  @override
  String get workManagerCopyInfo => 'Work info';

  @override
  String get workManagerMoreActions => 'More actions';

  @override
  String workManagerPointsAddedOfTotal(int added, int total) {
    return '$added/$total spots';
  }

  @override
  String workManagerPointsAddedOfUnknown(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added spots added',
      one: '1 spot added',
    );
    return '$_temp0';
  }

  @override
  String workManagerPointsAdded(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added spots added',
      one: '1 spot added',
    );
    return '$_temp0';
  }

  @override
  String get workManagerManualBadge => 'Manual';

  @override
  String get workManagerEmptyTitle => 'No works yet';

  @override
  String get workManagerOnboardingBangumiTitle => 'Import from Bangumi';

  @override
  String get workManagerOnboardingBangumiBody =>
      'Tap the button above to search Bangumi for a work and add it. Then use \"Find anime spots\" to see its spots on Anitabi.';

  @override
  String get workManagerOnboardingManualBody =>
      'If Bangumi doesn\'t list the work you want, tap \"Manual\" to add it to the plan. Then use \"Add spot manually\" to add the spots you want to visit.';

  @override
  String get pilgrimageModelsSubjectBook => 'Book';

  @override
  String get pilgrimageModelsSubjectAnime => 'Anime';

  @override
  String get pilgrimageModelsSubjectMusic => 'Music';

  @override
  String get pilgrimageModelsSubjectGame => 'Game';

  @override
  String get pilgrimageModelsSubjectReal => 'Live';

  @override
  String get pilgrimageModelsPaletteCustom => 'Custom';

  @override
  String get pilgrimageModelsThemeLight => 'Light';

  @override
  String get pilgrimageModelsThemeDark => 'Dark';

  @override
  String get pilgrimageModelsThemeSystem => 'System';

  @override
  String get pilgrimageModelsAspectAuto => 'Auto';

  @override
  String get pilgrimageModelsAspectNative => 'Native';

  @override
  String get pilgrimageModelsAspectCustom => 'Custom';

  @override
  String get pilgrimageModelsNavAmap => 'Amap';

  @override
  String get pilgrimageModelsNavBaiduMaps => 'Baidu Maps';

  @override
  String get pilgrimageModelsLocationAskOnFirstCapture =>
      'Ask on first capture';

  @override
  String get pilgrimageModelsLocationDisabled => 'Don\'t record location';

  @override
  String get pilgrimageModelsLocationUseRecent => 'Use last known location';

  @override
  String get pilgrimageModelsLocationWaitOnConfirmation =>
      'Get location when saving the record (recommended)';

  @override
  String get referenceCacheProgressRetryAll => 'Retry all';

  @override
  String get referenceCacheProgressRetryFailed => 'Retry failed';

  @override
  String get referenceCacheProgressInterrupted =>
      'Caching was interrupted. Please retry; saved images are kept.';

  @override
  String get referenceCacheProgressTip =>
      'Stay online while caching. Locking the screen may pause it.';

  @override
  String get referenceCacheProgressBackground => 'Run in background';

  @override
  String get referenceCacheProgressRunning => 'Caching reference images...';

  @override
  String get referenceCacheProgressDone => 'Reference images cached';

  @override
  String get referenceCacheProgressFailedTitle =>
      'Couldn\'t cache reference images';

  @override
  String referenceCacheProgressSuccessSummary(int succeeded, int total) {
    return '$succeeded / $total succeeded, saved on this device';
  }

  @override
  String referenceCacheProgressPartialSummary(
    int succeeded,
    int total,
    int failed,
  ) {
    return '$succeeded / $total succeeded · $failed failed';
  }

  @override
  String get referenceFullCacheRunnerNothing =>
      'This plan has no reference images to cache';

  @override
  String referenceFullCacheRunnerDone(int succeeded, int total) {
    return 'Cached $succeeded/$total full reference images';
  }

  @override
  String referenceFullCacheRunnerDoneWithFailures(
    int succeeded,
    int total,
    int failed,
  ) {
    return 'Cached $succeeded/$total full reference images, $failed failed';
  }

  @override
  String referenceFullCacheRunnerRunning(
    int processed,
    int total,
    int succeeded,
  ) {
    return 'Caching full reference images $processed/$total, $succeeded succeeded';
  }

  @override
  String get pilgrimageWorkDropdownManual => 'Manual';

  @override
  String get pilgrimageWorkDropdownWork => 'Work';

  @override
  String pilgrimageWorkCoverLabel(String title) {
    return '$title cover';
  }

  @override
  String get valhallaServiceConfigUrlIncomplete => 'Enter the full service URL';

  @override
  String get valhallaServiceConfigUrlScheme =>
      'The service URL must use HTTP or HTTPS';

  @override
  String get anitabiServiceConfigInvalidHttps => 'Enter a valid HTTPS URL';

  @override
  String get anitabiServiceConfigNoExtras =>
      'The URL can\'t include credentials, query parameters or fragments';

  @override
  String get anitabiServiceConfigNoLocal =>
      'Local or LAN addresses aren\'t allowed';

  @override
  String get bangumiApiClientNoRegion => 'No region set';

  @override
  String get anitabiEndpointSyncUpdated => 'Service URLs updated';

  @override
  String get anitabiEndpointSyncUnchanged => 'Service URLs are up to date';

  @override
  String get anitabiEndpointSyncOffline =>
      'Couldn\'t fetch the remote config. Check your connection.';

  @override
  String get anitabiEndpointSyncInvalid =>
      'The remote config is invalid; kept the current URLs';

  @override
  String get anitabiEndpointSyncVerificationFailed =>
      'The new URLs aren\'t reachable yet; kept the current URLs';

  @override
  String get anitabiEndpointSyncRateLimited =>
      'Checked too often. Try again later.';

  @override
  String get anitabiEndpointSyncDisabled => 'Auto update is off';

  @override
  String get boundedImageFileStubUnsupported =>
      'This platform can\'t read this local image; the original is unchanged';

  @override
  String get anitabiClientNoRegion => 'No region set';

  @override
  String get anitabiClientDefaultSpotName => 'Anitabi spot';

  @override
  String get anitabiClientPointNotFound => 'No matching Anitabi spot found';

  @override
  String boundedImageDecoderEncodedTooLarge(int length, int maxBytes) {
    return 'The image file is $length bytes, over the $maxBytes-byte read limit. The original is unchanged; you can save or export it.';
  }

  @override
  String get boundedImageDecoderSizeUnreadable =>
      'Couldn\'t read the image size';

  @override
  String boundedImageDecoderSourceTooLarge(int width, int height) {
    return 'The image is $width x $height, over the source limit (16,000,000 pixels, 16384 per side). The original is unchanged; you can save or export it.';
  }

  @override
  String get boundedImageDecoderInvalidMetadata =>
      'The image size metadata is invalid or inconsistent; the original is unchanged';

  @override
  String get boundedImageDecoderUnsupportedFormat =>
      'This platform can\'t safely preview this image format yet; the original is unchanged';

  @override
  String get boundedImageDecoderMetadataMismatch =>
      'The image size metadata is inconsistent; the original is unchanged';

  @override
  String get boundedImageDecoderAnimatedFrameTooLarge =>
      'The first animation frame is over the processing limit; the original is unchanged';

  @override
  String get boundedImageDecoderTargetUnsupported =>
      'This platform can\'t meet the image processing size limit';

  @override
  String get sqlitePilgrimageRepositoryImportedPlan => 'Imported plan';

  @override
  String get sqlitePilgrimageRepositoryUnknownWork => 'Unknown work';

  @override
  String get sqlitePilgrimageRepositoryNoRegion => 'No region set';

  @override
  String get samplePilgrimageRepositoryImportedPlan => 'Imported plan';

  @override
  String get desktopRepositoryStateDefaultPlan => 'Desktop plan';

  @override
  String get desktopRepositoryStateDefaultWork => 'Work';

  @override
  String get desktopRepositoryStateDefaultGroup => 'Group';

  @override
  String get desktopRepositoryStateUnknownWork => 'Unknown work';

  @override
  String get desktopRepositoryStateDefaultSpot => 'Spot';

  @override
  String tauriBridgeWebAssetTooLarge(int maxBytes, String error) {
    return 'The image is over the $maxBytes-byte read limit; the original is unchanged ($error)';
  }

  @override
  String get appShellSettingsSaveFailed => 'Couldn\'t save settings';

  @override
  String get appShellSettingsSaveFailedHint =>
      'Your changes weren\'t saved. Please try again later.';

  @override
  String get appShellReadingPlanFile => 'Reading plan file...';

  @override
  String get appShellPlanImportFailed => 'Couldn\'t import the plan file';

  @override
  String get appShellNavPlan => 'Plan';

  @override
  String get appShellNavMap => 'Map';

  @override
  String get appShellNavRecords => 'Records';

  @override
  String get appShellNavSettings => 'Settings';

  @override
  String get appShellLoadFailed => 'Couldn\'t load plans';

  @override
  String get appShellLoading => 'Loading pilgrimage plans';

  @override
  String get appShellLoadFailedHint => 'Please try again later.';

  @override
  String mainOpenDirectoryFailed(String error) {
    return 'Couldn\'t open the folder: $error';
  }

  @override
  String get mainStartupFailed => 'Koma failed to start';

  @override
  String get mainStartupFailedHint =>
      'Your data has not been deleted. Retry, or open the log folder and check startup.log.';

  @override
  String get mainOpenLogFolder => 'Open log folder';

  @override
  String get mainOpenDataFolder => 'Open data folder';

  @override
  String get mainErrorDetails => 'Error details';

  @override
  String get pointDetailReplacingReference => 'Replacing reference image...';

  @override
  String get pointDetailReplaceReferenceFailed =>
      'Couldn\'t replace the reference image. Please try again later.';

  @override
  String get pointDetailReplaceReferenceCanceled =>
      'Reference image replacement canceled';

  @override
  String get pointDetailReferenceReplaced => 'Reference image replaced';

  @override
  String pointDetailOpenNavigationFailed(String app) {
    return 'Couldn\'t open $app.';
  }

  @override
  String get pointDetailMoveToArea => 'Move to area';

  @override
  String get pointDetailMoveToAreaHint =>
      'Choose the area this spot belongs to';

  @override
  String get pointDetailNotInArea => 'Not in an area';

  @override
  String get pointDetailCopySpotName => 'Spot name';

  @override
  String get pointDetailWorkLabel => 'Work';

  @override
  String get pointDetailSceneLabel => 'Scene';

  @override
  String get pointDetailCoordinatesLabel => 'Coords';

  @override
  String get pointDetailCoordinatesMissing => 'Not set';

  @override
  String get pointDetailReferenceLabel => 'Ref';

  @override
  String get pointDetailSourceLabel => 'Source';

  @override
  String get pointDetailLinkLabel => 'Link';

  @override
  String get pointDetailNoteLabel => 'Note';

  @override
  String pointDetailManualSource(String reference) {
    return 'Manual entry / $reference';
  }

  @override
  String get pointDetailUndoCheckIn => 'Undo check-in';

  @override
  String get pointDetailMarkDone => 'Mark visited';

  @override
  String get pointDetailUnknownArea => 'Unknown area';

  @override
  String get pointDetailNoAnchor => 'No anchor set';

  @override
  String get pointDetailDeleteSpot => 'Delete spot';

  @override
  String pointDetailDeleteSpotMessage(String name) {
    return 'Remove \"$name\" from the plan? Existing pilgrimage records and photos are kept.';
  }

  @override
  String get pointDetailDeleteSpotFailed =>
      'Couldn\'t delete the spot. Please try again later.';

  @override
  String get pointDetailDeletingSpot => 'Deleting spot...';

  @override
  String get pointDetailSpotDeleted => 'Spot deleted';

  @override
  String get pointDetailNavigate => 'Navigate';

  @override
  String get pointDetailNoCoordinates => 'No coordinates yet';

  @override
  String get pointDetailShootReference => 'Shoot with reference';

  @override
  String get pointDetailShootShort => 'Shoot';

  @override
  String get pointDetailSetCurrent => 'Set as next stop';

  @override
  String get pointDetailSetCurrentShort => 'Next stop';

  @override
  String get pointDetailSetCurrentTarget => 'Set as next stop';

  @override
  String get pointDetailEditSpot => 'Edit spot';

  @override
  String get pointDetailReplace => 'Replace';

  @override
  String get pointDetailArea => 'Area';

  @override
  String get pointDetailAreaAnchor => 'Area anchor';

  @override
  String get pointDetailChange => 'Change';

  @override
  String get pointDetailStatusCurrent => 'Next stop';

  @override
  String get pointDetailStatusCompleted => 'Completed';

  @override
  String get pointDetailStatusPending => 'To visit';

  @override
  String pointDetailRecordsCount(int count) {
    return 'Records here $count';
  }

  @override
  String get pointDetailAll => 'All';

  @override
  String get importExportTitle => 'Import & export';

  @override
  String get importExportImportSection => 'Import';

  @override
  String get importExportImportSubtitleIos =>
      'Open a .sjhplan with Koma from Files, a chat, a browser or a cloud drive.';

  @override
  String get importExportImportSubtitle =>
      'Pick a .sjhplan file and preview it before importing.';

  @override
  String get importExportReading => 'Reading...';

  @override
  String get importExportOpenFromOtherApp => 'Open a .sjhplan from another app';

  @override
  String get importExportImportFile => 'Import a Koma file';

  @override
  String get importExportOpenFromOtherAppSubtitle =>
      'Find the .sjhplan in Files, a chat, a browser download page or a cloud drive, then share it to Koma or open it with Koma.';

  @override
  String get importExportImportFileSubtitle =>
      'Supports v2 data packages and legacy v1 JSON plan files.';

  @override
  String get importExportImportFromLink => 'Import from link';

  @override
  String get importExportImportFromLinkSubtitle =>
      'Paste a GitHub release or a .sjhplan / .zip download link to download and preview it.';

  @override
  String get importExportPackageSection => 'Koma data package';

  @override
  String get importExportPackageSubtitle =>
      'The new .sjhplan format: a zip containing manifest.json.';

  @override
  String get importExportMyMapsSubtitle =>
      'Exports spots as CSV. Images become links, and you can style spots by the Type column.';

  @override
  String get importExportMyMapsExport => 'Export My Maps CSV';

  @override
  String get importExportMyMapsExportSubtitle =>
      'The first 6 columns follow the sample format. Work, episode, source and more get their own columns.';

  @override
  String get importExportExportCanceled => 'Export canceled';

  @override
  String get importExportReadFailed => 'Couldn\'t read the import file';

  @override
  String get importExportIosHelpMessage =>
      'Find the .sjhplan file in Files, a chat, a browser download page, a cloud drive or wherever it\'s saved, then tap it or choose Koma from the Share or More menu.\n\nKoma opens the import preview once it receives the file. If Koma isn\'t listed, save the file to the Files app first, then long-press it and choose Share or Open with.';

  @override
  String importExportShareText(String planName) {
    return 'Koma data package: $planName';
  }

  @override
  String get importExportPackageExported => 'Data package exported';

  @override
  String get importExportMissingAssetsTitle => 'Some local files are missing';

  @override
  String get importExportContinueExport => 'Export anyway';

  @override
  String get importExportMissingAssetsNotice =>
      'Missing files won\'t be included, so those images may not show after import';

  @override
  String importExportMyMapsShareText(String planName) {
    return 'Koma My Maps CSV: $planName';
  }

  @override
  String get importExportPendingCoordinateWarning =>
      'Some spots still need coordinates';

  @override
  String get importExportMyMapsExported => 'My Maps CSV exported';

  @override
  String get importExportExporting => 'Exporting...';

  @override
  String get importExportExportFailed => 'Export failed';

  @override
  String get importExportTryAgainLater => 'Please try again later';

  @override
  String get importExportSavedLocally => 'Saved to this device';

  @override
  String get importExportShared => 'Sent via the share sheet';

  @override
  String get importExportSomeAssetsSkipped =>
      'Some files couldn\'t be included';

  @override
  String importExportWarnUserReferenceMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uploaded reference images missing',
      one: '1 uploaded reference image missing',
    );
    return '$_temp0';
  }

  @override
  String importExportWarnThumbnailMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thumbnails not included',
      one: '1 thumbnail not included',
    );
    return '$_temp0';
  }

  @override
  String importExportWarnFullReferenceDownloadFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count full reference images failed to download',
      one: '1 full reference image failed to download',
    );
    return '$_temp0';
  }

  @override
  String importExportWarnFullReferenceMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count full reference images missing',
      one: '1 full reference image missing',
    );
    return '$_temp0';
  }

  @override
  String importExportWarnVisitPhotoMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pilgrimage photos missing',
      one: '1 pilgrimage photo missing',
    );
    return '$_temp0';
  }

  @override
  String importExportWarnGradedPhotoMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count color-matched photos missing',
      one: '1 color-matched photo missing',
    );
    return '$_temp0';
  }

  @override
  String importExportWarnPendingCoordinate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots without coordinates not exported',
      one: '1 spot without coordinates not exported',
    );
    return '$_temp0';
  }

  @override
  String get importExportWarningSeparator => ', ';

  @override
  String importExportAreaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas',
      one: '1 area',
    );
    return '$_temp0';
  }

  @override
  String importExportSpotCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String get importExportPlanOnly => 'Plan only';

  @override
  String get importExportPlanWithRecords => 'Plan + records';

  @override
  String get importExportIncludeFullReference =>
      'Include full reference image cache';

  @override
  String get importExportIncludeFullReferenceSubtitle =>
      'Turn on to add full reference images to the package. Thumbnails and reference images you added yourself are always included.';

  @override
  String get importExportExportingButton => 'Exporting...';

  @override
  String get importExportExportPackage => 'Export Koma data package';

  @override
  String get importExportEstimating => 'Estimating package size...';

  @override
  String get importExportEstimateUnavailable =>
      'Estimated package size: can\'t estimate right now';

  @override
  String planExportSizeEstimatorThumbnailsNotCached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thumbnails aren\'t cached and won\'t be included',
      one: '1 thumbnail isn\'t cached and won\'t be included',
    );
    return '$_temp0';
  }

  @override
  String planExportSizeEstimatorFullReferencesToDownload(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count full reference images will be downloaded during export',
      one: '1 full reference image will be downloaded during export',
    );
    return '$_temp0';
  }

  @override
  String planExportSizeEstimatorUserReferencesMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count uploaded reference image files are missing and can\'t be restored after export',
      one:
          '1 uploaded reference image file is missing and can\'t be restored after export',
    );
    return '$_temp0';
  }

  @override
  String planExportSizeEstimatorVisitPhotosMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pilgrimage photo files are missing',
      one: '1 pilgrimage photo file is missing',
    );
    return '$_temp0';
  }

  @override
  String planExportSizeEstimatorGradedPhotosMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count color-matched photo files are missing',
      one: '1 color-matched photo file is missing',
    );
    return '$_temp0';
  }

  @override
  String get planExportSizeEstimatorUnknownLocalAssets =>
      'Some local files couldn\'t be read, so the actual size may differ';

  @override
  String planExportSizeEstimatorLabelWithDetails(String size, String details) {
    return 'Estimated package size: at least about $size. $details';
  }

  @override
  String get planExportSizeEstimatorDetailSeparator => '; ';

  @override
  String planExportSizeEstimatorLabel(String size) {
    return 'Estimated package size: about $size';
  }

  @override
  String get planImportPreviewTitle => 'Import contents';

  @override
  String get planImportPreviewChooseContent => 'Choose what to import';

  @override
  String get planImportPreviewChooseContentSubtitle =>
      'Nothing changes until you import.';

  @override
  String get planImportPreviewPlanStructure => 'Plan structure';

  @override
  String get planImportPreviewPlanStructureSubtitle =>
      'Works, areas, spots, completion status and next stop.';

  @override
  String get planImportPreviewRecords => 'Records';

  @override
  String get planImportPreviewRecordsLegacy =>
      'v1 files contain no photos, so only the plan structure is imported.';

  @override
  String planImportPreviewRecordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records, with photo paths and color match settings.',
      one: '1 record, with photo paths and color match settings.',
    );
    return '$_temp0';
  }

  @override
  String get planImportPreviewRecordsNone => 'This package has no records.';

  @override
  String get planImportPreviewAssets => 'Images and files';

  @override
  String get planImportPreviewPackageNotes => 'Package notes';

  @override
  String get planImportPreviewPackageNotesSubtitle =>
      'Missing-file and compatibility notes recorded at export.';

  @override
  String get planImportPreviewImporting => 'Importing...';

  @override
  String get planImportPreviewImportSelected => 'Import selected';

  @override
  String planImportPreviewImportedUnconfirmed(String name) {
    return 'Imported plan \"$name\", but file confirmation didn\'t finish';
  }

  @override
  String planImportPreviewImported(String name) {
    return 'Imported plan \"$name\"';
  }

  @override
  String planImportPreviewImportedPartial(String name) {
    return 'Imported plan \"$name\", but some files weren\'t restored';
  }

  @override
  String get planImportPreviewCleanupIncomplete =>
      'Import not confirmed. Files were kept so nothing is deleted by mistake';

  @override
  String get planImportPreviewFailed => 'Import failed';

  @override
  String get planImportPreviewNoAssets =>
      'This package has no files to restore.';

  @override
  String get planImportPreviewNoRestorableAssets =>
      'The package lists files but contains none that can be restored.';

  @override
  String planImportPreviewAssetsUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The package has $count files, but this platform can\'t restore package files yet.',
      one:
          'The package has 1 file, but this platform can\'t restore package files yet.',
    );
    return '$_temp0';
  }

  @override
  String planImportPreviewAssetsRestore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The package has $count files, which will be restored to this device.',
      one: 'The package has 1 file, which will be restored to this device.',
    );
    return '$_temp0';
  }

  @override
  String get planImportPreviewStatWorks => 'Works';

  @override
  String get planImportPreviewStatAreas => 'Areas';

  @override
  String get planImportPreviewStatSpots => 'Spots';

  @override
  String get planImportPreviewStatRecords => 'Records';

  @override
  String get planImportPreviewStatFiles => 'Files';

  @override
  String get planImportPreviewStatVersion => 'Version';

  @override
  String get planImportPreviewStatExported => 'Exported';

  @override
  String get planLinkImportNoPlanFilesInRelease =>
      'This release has no .sjhplan or .zip files';

  @override
  String get planLinkImportChooseArchiveEntry =>
      'The archive has several plans. Choose one to import';

  @override
  String get planLinkImportArchiveHasNoPlan =>
      'The archive has no .sjhplan plan file';

  @override
  String get planLinkImportNotAPlanPackage =>
      'The downloaded file isn\'t a Koma plan package';

  @override
  String get planLinkImportReadFailed => 'Couldn\'t read it. Please try again';

  @override
  String get planLinkImportTitle => 'Import from link';

  @override
  String get planLinkImportIntro =>
      'Paste a GitHub release page or a plan file download link. Koma downloads the plan and opens the import preview.';

  @override
  String get planLinkImportWebUnavailableTitle =>
      'The web version can\'t download directly';

  @override
  String get planLinkImportWebUnavailableSubtitle =>
      'Download the .sjhplan or .zip in your browser first, then go back to \"Import & export\" and use \"Import a Koma file\".';

  @override
  String get planLinkImportLinkLabel => 'Link';

  @override
  String get planLinkImportPaste => 'Paste';

  @override
  String get planLinkImportReadLink => 'Read link';

  @override
  String get planLinkImportHelp =>
      'Supported:\n• GitHub release pages or repository links (lists the plan files in the latest release)\n• File download links from a GitHub release\n• Other https:// direct links to a .sjhplan or .zip\nA .zip may also contain other files such as a readme; Koma only reads the .sjhplan in it. Downloading connects to the address you enter (and any download server it redirects to). GitHub release or repository links also ask api.github.com for the files in the release.';

  @override
  String get planLinkImportResolving =>
      'Looking for plan files in the release…';

  @override
  String get planLinkImportChooseFile => 'Choose a file to import';

  @override
  String get planLinkImportArchiveTag => 'Archive';

  @override
  String planLinkImportDownloading(String name) {
    return 'Downloading $name';
  }

  @override
  String planLinkImportDownloaded(String size) {
    return 'Downloaded $size';
  }

  @override
  String get planLinkImportReadingPlan => 'Reading plan…';

  @override
  String get planLinkEnterLink => 'Enter a link';

  @override
  String get planLinkUnrecognized => 'Can\'t recognize this link';

  @override
  String get planLinkHttpsOnly =>
      'Only links starting with https:// are supported';

  @override
  String planLinkLatestRelease(String repository) {
    return '$repository latest release';
  }

  @override
  String get planLinkReleaseUnreadable =>
      'Couldn\'t read the release info returned by GitHub';

  @override
  String get planLinkTooLarge =>
      'The file is over the 128 MB limit and can\'t be imported';

  @override
  String get planLinkNotPublic => 'Local and LAN addresses aren\'t supported';

  @override
  String get planLinkFileNotFound =>
      'The linked file doesn\'t exist (HTTP 404)';

  @override
  String planLinkServerRefused(String status) {
    return 'The server refused the download (HTTP $status). Please try again later';
  }

  @override
  String planLinkDownloadFailedStatus(String status) {
    return 'Download failed (HTTP $status)';
  }

  @override
  String get planLinkReleaseNotFound =>
      'Release not found. The repository may be private, have no releases yet, or only have pre-releases (paste the link of a specific release page)';

  @override
  String get planLinkGitHubRateLimited =>
      'Too many requests to GitHub. Please try again later';

  @override
  String planLinkReleaseFetchFailed(String status) {
    return 'Couldn\'t load the GitHub release (HTTP $status)';
  }

  @override
  String get planLinkCannotReachGitHub =>
      'Can\'t reach GitHub. Check your connection and try again';

  @override
  String get planLinkDownloadFailed =>
      'Download failed. Check your connection and try again';

  @override
  String get planLinkServiceIoTempFileFailed =>
      'Can\'t create a temporary file. Check your storage space';

  @override
  String get planLinkServiceIoSaveFailed =>
      'Can\'t save the downloaded file. Check your storage space';

  @override
  String get planLinkServiceWebUnavailable =>
      'The web version can\'t download directly. Download the file first, then use \"Import a Koma file\"';

  @override
  String incomingPlanFileTooLarge(String limit) {
    return 'Import limit exceeded: the plan file is over the $limit MiB limit. Split the plan or pack fewer images and try again.';
  }

  @override
  String get incomingPlanFileFailed => 'Couldn\'t import the plan file';

  @override
  String planImportPackageLimitExceeded(
    String resource,
    String actual,
    String limit,
  ) {
    return 'Import limit exceeded: $resource is $actual, the limit is $limit. Split the plan or pack fewer images and try again.';
  }

  @override
  String get planImportPackageResourceEntryBytes =>
      'uncompressed bytes per file';

  @override
  String get planImportPackageResourceJsonBytes => 'JSON bytes';

  @override
  String get planImportPackageResourceExpandedBytes =>
      'total uncompressed bytes';

  @override
  String get planImportPackageResourceArchiveBytes => 'archive bytes';

  @override
  String get planImportPackageResourcePlanFileBytes => 'plan file bytes';

  @override
  String get planImportPackageResourceZipEntries => 'ZIP entries';

  @override
  String planImportPackageResourceImagePixels(
    String width,
    String height,
    String frames,
  ) {
    return 'image pixels ($width x $height x $frames frames)';
  }

  @override
  String get planImportPackageV2Label => 'v2 data package';

  @override
  String planImportPackageInvalidCoordinates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots had invalid coordinates and now need coordinates',
      one: '1 spot had invalid coordinates and now needs coordinates',
    );
    return '$_temp0';
  }

  @override
  String get planImportPackageUnnamedArea => 'Unnamed area';

  @override
  String get planPackageDefaultPlanName => 'Imported pilgrimage plan';

  @override
  String get planPackageNoArea => 'No area set';

  @override
  String get planPackageUnknownWork => 'Unknown work';

  @override
  String get planPackageNoRegion => 'No region set';

  @override
  String get planPackageUnnamedSpot => 'Unnamed spot';

  @override
  String get planPackageUnknownReferenceMode => 'Unknown';

  @override
  String planExportV2DeletedDuringExport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count files were deleted during export and aren\'t in the package',
      one: '1 file was deleted during export and isn\'t in the package',
    );
    return '$_temp0';
  }

  @override
  String get planExportV2CsvWork => 'Work';

  @override
  String get planExportV2CsvArea => 'Area';

  @override
  String get planExportV2CsvSpotName => 'Spot name';

  @override
  String get planExportV2CsvSubtitle => 'Subtitle';

  @override
  String get planExportV2CsvLatitude => 'Latitude';

  @override
  String get planExportV2CsvLongitude => 'Longitude';

  @override
  String get planExportV2CsvEpisode => 'Episode/scene';

  @override
  String get planExportV2CsvSource => 'Source';

  @override
  String get planExportV2CsvSourceId => 'Source ID';

  @override
  String get planExportV2CsvReferenceUrl => 'Reference image URL';

  @override
  String get planExportV2CsvCompleted => 'Completed';

  @override
  String get planExportV2CsvRecordCount => 'Records';

  @override
  String get planExportV2CsvRecordId => 'Record ID';

  @override
  String get planExportV2CsvCapturedAt => 'Captured at';

  @override
  String get planExportV2CsvReferenceMode => 'Reference mode';

  @override
  String get planExportV2CsvColorMatched => 'Color matched';

  @override
  String get planExportV2CsvPhotoFile => 'Photo file';

  @override
  String get planExportV2CsvGradedPhotoFile => 'Color-matched photo file';

  @override
  String get planExportV2CsvYes => 'Yes';

  @override
  String get planExportV2CsvNo => 'No';

  @override
  String get planExportV2Ungrouped => 'Ungrouped';

  @override
  String get planExportV2UnknownArea => 'Unknown area';

  @override
  String get myMapsCsvExportUngrouped => 'Ungrouped';

  @override
  String get colorGradingParamsModeNatural => 'Natural';

  @override
  String get colorGradingParamsModeStandard => 'Standard';

  @override
  String get colorGradingParamsModeStrong => 'Strong';

  @override
  String get colorGradingParameterSummaryIntensity => 'Color match strength';

  @override
  String get colorGradingParameterSummaryParameters => 'Color match settings';

  @override
  String get colorGradingParameterSummaryView => 'View';

  @override
  String get colorGradingParameterSummaryDescription =>
      'Shows the values in effect at the current strength.';

  @override
  String get colorGradingParameterSummaryBrightness => 'Brightness';

  @override
  String get colorGradingParameterSummaryExposure => 'Exposure';

  @override
  String get colorGradingParameterSummaryContrast => 'Contrast';

  @override
  String get colorGradingParameterSummarySaturation => 'Saturation';

  @override
  String get colorGradingParameterSummaryTemperature => 'Temperature';

  @override
  String get colorGradingParameterSummaryTint => 'Tint';

  @override
  String get colorGradingParameterSummaryHighlights => 'Highlights';

  @override
  String get colorGradingParameterSummaryShadows => 'Shadows';

  @override
  String get colorGradingParameterSummaryRedShadowCurve => 'Red shadows curve';

  @override
  String get colorGradingParameterSummaryRedMidCurve => 'Red midtones curve';

  @override
  String get colorGradingParameterSummaryRedHighlightCurve =>
      'Red highlights curve';

  @override
  String get colorGradingParameterSummaryGreenShadowCurve =>
      'Green shadows curve';

  @override
  String get colorGradingParameterSummaryGreenMidCurve =>
      'Green midtones curve';

  @override
  String get colorGradingParameterSummaryGreenHighlightCurve =>
      'Green highlights curve';

  @override
  String get colorGradingParameterSummaryBlueShadowCurve =>
      'Blue shadows curve';

  @override
  String get colorGradingParameterSummaryBlueMidCurve => 'Blue midtones curve';

  @override
  String get colorGradingParameterSummaryBlueHighlightCurve =>
      'Blue highlights curve';

  @override
  String get colorGradingAutoMatchFailed => 'Auto color match failed';

  @override
  String get colorGradingPhotoReadFailed =>
      'Couldn\'t read the pilgrimage photo';

  @override
  String get colorGradingNoReferenceForMatch =>
      'No reference image to color match against';

  @override
  String get colorGradingReferenceUnavailable =>
      'The reference image isn\'t available, so auto color match can\'t run';

  @override
  String get colorGradingAutoMatchDone => 'Auto color match settings created';

  @override
  String get colorGradingSaveFailedOriginalKept =>
      'Save failed. The original is unchanged';

  @override
  String get colorGradingRestoredOriginal => 'Restored the original photo';

  @override
  String get colorGradingMatchFirst => 'Run auto color match first';

  @override
  String get colorGradingSaveFailed => 'Save failed';

  @override
  String get colorGradingSaved => 'Color match saved';

  @override
  String get colorGradingResetTitle => 'Reset color match';

  @override
  String get colorGradingResetMessage =>
      'This clears the current color match and restores the original photo.';

  @override
  String get colorGradingReset => 'Reset';

  @override
  String get colorGradingTitle => 'Auto color match';

  @override
  String get colorGradingMatching => 'Matching...';

  @override
  String get colorGradingAutoMatch => 'Auto color match';

  @override
  String get colorGradingReference => 'Reference image';

  @override
  String get colorGradingNoReference => 'No reference image';

  @override
  String get colorGradingOriginal => 'Original';

  @override
  String get colorGradingGraded => 'Color matched';

  @override
  String get colorGradingShowingOriginal => 'Showing original';

  @override
  String get colorGradingHoldForOriginal => 'Hold to show original';

  @override
  String get colorGradingMatchMode => 'Match mode';

  @override
  String get colorGradingParamsReady =>
      'Color match settings are ready to save';

  @override
  String get colorGradingMatchToSave =>
      'Run auto color match, then save the result';

  @override
  String get colorGradingToneMatch => 'Tone match';

  @override
  String get colorGradingCurrent => 'Current';

  @override
  String get colorGradingSaveResult => 'Save result';

  @override
  String get colorGradingSaveDescription =>
      'After saving, record details and exports use the color-matched photo. The original and the settings are kept.';

  @override
  String get colorGradingSaving => 'Saving...';

  @override
  String get colorGradingSaveColorMatch => 'Save color match';

  @override
  String get comparisonExportConfigJpegRecommended => 'JPEG recommended (85)';

  @override
  String get comparisonExportConfigJpegHighQuality => 'JPEG high quality (95)';

  @override
  String get comparisonExportConfigPngLossless => 'PNG lossless';

  @override
  String get comparisonExportConfigWidthAuto => 'Auto';

  @override
  String get comparisonExportConfigFieldCapturedAt => 'Taken at';

  @override
  String get comparisonExportConfigFieldWork => 'Work';

  @override
  String get comparisonExportConfigFieldPlace => 'Place';

  @override
  String get comparisonExportConfigFieldCoordinates => 'Coordinates';

  @override
  String get comparisonExportConfigFieldScene => 'Scene';

  @override
  String get comparisonExportConfigEditorColorWhite => 'White';

  @override
  String get comparisonExportConfigEditorColorBlack => 'Black';

  @override
  String get comparisonExportConfigEditorColorTheme => 'Theme';

  @override
  String get comparisonExportConfigEditorAppearance => 'Appearance';

  @override
  String get comparisonExportConfigEditorFormat => 'Image format and quality';

  @override
  String comparisonExportConfigEditorSummaryWidth(String width) {
    return 'Width $width';
  }

  @override
  String get comparisonExportConfigEditorSummaryNoBorder => 'No border';

  @override
  String comparisonExportConfigEditorSummaryBorder(String percent) {
    return 'Border $percent%';
  }

  @override
  String get comparisonExportConfigEditorSummaryLabelsOn => 'Labels on';

  @override
  String get comparisonExportConfigEditorSummaryLabelsOff => 'Labels off';

  @override
  String comparisonExportConfigEditorSummaryPilgrim(String name) {
    return 'Pilgrim $name';
  }

  @override
  String get comparisonExportConfigEditorBorderWidth => 'Border width';

  @override
  String get comparisonExportConfigEditorNone => 'None';

  @override
  String get comparisonExportConfigEditorBorderColor => 'Border color';

  @override
  String get comparisonExportConfigEditorAutoWidthTitle => 'Auto output width';

  @override
  String get comparisonExportConfigEditorAutoWidthSubtitle =>
      'Pick the output width from the image size';

  @override
  String get comparisonExportConfigEditorShowLabelsTitle => 'Show labels';

  @override
  String get comparisonExportConfigEditorShowLabelsSubtitle =>
      'Mark the reference image \"Reference\" and your pilgrimage photo \"Pilgrimage\"';

  @override
  String get comparisonExportConfigEditorMetadata => 'Metadata';

  @override
  String get comparisonExportConfigEditorShowPilgrimTitle =>
      'Show pilgrim name';

  @override
  String get comparisonExportConfigEditorShowPilgrimSubtitle =>
      'Show the pilgrim name on the image';

  @override
  String get comparisonExportConfigEditorPilgrimHint => 'Enter pilgrim name';

  @override
  String get comparisonExportConfigEditorShowGradingTitle =>
      'Show color match settings';

  @override
  String get comparisonExportConfigEditorShowGradingSubtitle =>
      'Show color match settings at the bottom of the image';

  @override
  String get comparisonExportConfigEditorContent => 'Content';

  @override
  String comparisonExportBudgetSizeUnfit(int maxPixels, int maxEdge) {
    return 'The comparison image cannot fit the output limits: at most $maxPixels pixels, $maxEdge pixels on the longest side.';
  }

  @override
  String comparisonExportBudgetTooNarrow(int maxPixels, int maxEdge) {
    return 'The comparison image is too long and narrow to fit within $maxPixels pixels and $maxEdge pixels on the longest side.';
  }

  @override
  String get comparisonExportSupportShareText => 'Koma comparison image';

  @override
  String get comparisonExportLoadSettingsFailed =>
      'Couldn\'t load export settings. Try again.';

  @override
  String get comparisonExportSaveSettingsFailed =>
      'Couldn\'t save export settings. They will be saved again on export.';

  @override
  String get comparisonExportBrowserDownload =>
      'Comparison image sent to the browser for download';

  @override
  String get comparisonExportFailed =>
      'Export failed. Settings or image were not saved. Try again.';

  @override
  String get comparisonExportReferenceUnavailable =>
      'Reference image unavailable. Can\'t export the comparison image.';

  @override
  String get comparisonExportPhotoUnavailable =>
      'Pilgrimage photo unavailable. Can\'t export the comparison image.';

  @override
  String get comparisonExportBudgetExceeded =>
      'The image is too large to process. The original is unchanged.';

  @override
  String get comparisonExportUnsupportedFormat =>
      'This image format isn\'t supported on this platform.';

  @override
  String get comparisonExportInvalidData =>
      'The image data couldn\'t be decoded.';

  @override
  String get comparisonExportRenderFailed => 'Export failed. Try again later.';

  @override
  String get comparisonExportTitle => 'Export comparison image';

  @override
  String get comparisonExportShortLabel => 'Export';

  @override
  String get comparisonExportRendererReference => 'Reference';

  @override
  String get comparisonExportRendererPilgrimage => 'Pilgrimage';

  @override
  String get comparisonExportRendererPilgrim => 'Pilgrim';

  @override
  String get gallerySaveResultFailed => 'Save failed. Try again later.';

  @override
  String get gallerySaveResultSaved => 'Saved to photos';

  @override
  String get gallerySaveResultPermissionTitle => 'Photo access needed';

  @override
  String get gallerySaveResultPermissionSubtitle =>
      'Allow Koma to add photos in system settings.';

  @override
  String get gallerySaveResultSettings => 'Settings';

  @override
  String get photoCompareSliderViewReference => 'View reference image';

  @override
  String get photoCompareSliderViewPhoto => 'View pilgrimage photo';

  @override
  String get photoCompareSliderSemantics =>
      'Slide to compare: reference image on the left, pilgrimage photo on the right';

  @override
  String get photoCompareSliderReference => 'Reference';

  @override
  String get photoCompareSliderPhoto => 'Pilgrimage';

  @override
  String get pointVisitRecordsTitle => 'Spot records';

  @override
  String pointVisitRecordsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'records',
      one: 'record',
    );
    return '$_temp0';
  }

  @override
  String get pointVisitRecordsEmpty => 'No records for this spot yet';

  @override
  String get pointVisitRecordsListLabel => 'Records';

  @override
  String get pointVisitRecordsColorMatched => 'Color matched';

  @override
  String get visitRecordDetailTitle => 'Record details';

  @override
  String get visitRecordDetailDeleteTooltip => 'Delete record';

  @override
  String get visitRecordDetailCapturedAt => 'Taken at';

  @override
  String get visitRecordDetailArea => 'Area';

  @override
  String get visitRecordDetailScene => 'Scene';

  @override
  String get visitRecordDetailDeleteTitle => 'Delete record';

  @override
  String get visitRecordDetailDeleteTarget => 'this pilgrimage record';

  @override
  String visitRecordDetailDeleteMessage(String target) {
    return 'Deletes $target. The spot\'s completion status won\'t change.';
  }

  @override
  String get visitRecordDetailDeleteFiles => 'Also delete photo files';

  @override
  String get visitRecordDetailDeleteFailed =>
      'Couldn\'t delete the record. Photos were kept. Try again';

  @override
  String get visitRecordDetailDeletedPartly =>
      'Record deleted, but some photos were not cleaned up';

  @override
  String get visitRecordDetailPhotoUnavailable =>
      'Pilgrimage photo unavailable. Can\'t export the comparison image.';

  @override
  String get visitRecordDetailNoPrefsStorage =>
      'Saving export preferences isn\'t supported on this platform yet.';

  @override
  String get visitRecordDetailUngrouped => 'Ungrouped';

  @override
  String get visitRecordDetailUnknownArea => 'Unknown area';

  @override
  String get visitRecordDetailBrightness => 'Brightness';

  @override
  String get visitRecordDetailExposure => 'Exposure';

  @override
  String get visitRecordDetailContrast => 'Contrast';

  @override
  String get visitRecordDetailSaturation => 'Saturation';

  @override
  String get visitRecordDetailTemperature => 'Temperature';

  @override
  String get visitRecordDetailTint => 'Tint';

  @override
  String get visitRecordDetailHighlights => 'Highlights';

  @override
  String get visitRecordDetailShadows => 'Shadows';

  @override
  String visitRecordDetailCurveShadows(String channel) {
    return '$channel shadows';
  }

  @override
  String visitRecordDetailCurveMids(String channel) {
    return '$channel mids';
  }

  @override
  String visitRecordDetailCurveHighlights(String channel) {
    return '$channel highlights';
  }

  @override
  String get visitRecordDetailModeStacked => 'Stacked';

  @override
  String get visitRecordDetailModeSlider => 'Slider';

  @override
  String get visitRecordDetailReference => 'Reference image';

  @override
  String get visitRecordDetailPhoto => 'Pilgrimage photo';

  @override
  String get visitRecordDetailOrphan =>
      'This record\'s spot is no longer in the current plan. Photos and export still work.';

  @override
  String get visitRecordDetailColorMatchTitle => 'Auto color match';

  @override
  String get visitRecordDetailColorMatchSubtitle => 'Enhance pilgrimage photo';

  @override
  String get visitRecordDetailExportTitle => 'Export comparison';

  @override
  String get visitRecordDetailExportSubtitle => 'Create a shareable image';

  @override
  String get recordsTitle => 'Records';

  @override
  String get recordsCollapseAll => 'Collapse all areas';

  @override
  String get recordsExpandAll => 'Expand all areas';

  @override
  String get recordsUngrouped => 'Ungrouped';

  @override
  String get recordsUngroupedSubtitle => 'Records not in an area yet';

  @override
  String get recordsOrphan => 'Orphaned records';

  @override
  String get recordsOrphanSubtitle =>
      'Their spots are no longer in the current plan';

  @override
  String get recordsNoCoordinates => 'Coordinates missing';

  @override
  String get recordsUnknownArea => 'Unknown area';

  @override
  String get recordsNoAnchor => 'No anchor set';

  @override
  String get recordsScopeFilterTooltip => 'Filter by work and area';

  @override
  String get recordsWorks => 'Works';

  @override
  String get recordsAreas => 'Areas';

  @override
  String get recordsFilterTitle => 'Filter records';

  @override
  String get recordsClear => 'Clear';

  @override
  String recordsScopeSummary(int works, int areas) {
    return 'Selected: $works works · $areas areas';
  }

  @override
  String get recordsAllWorks => 'All works';

  @override
  String get recordsAllAreas => 'All areas';

  @override
  String recordsWorksPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count works selected',
      one: '1 work selected',
    );
    return '$_temp0';
  }

  @override
  String recordsAreasPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas selected',
      one: '1 area selected',
    );
    return '$_temp0';
  }

  @override
  String get recordsApplyAll => 'Apply filter (all spots)';

  @override
  String get recordsApplySelected => 'Apply filter (selected)';

  @override
  String get recordsBackToFilter => 'Back to filters';

  @override
  String get recordsSelectWorks => 'Select works';

  @override
  String get recordsSelectAreas => 'Select areas';

  @override
  String get recordsNoOptions => 'Nothing to filter';

  @override
  String get recordsWorkBadge => 'Work';

  @override
  String get recordsAreaBadge => 'Area';

  @override
  String recordsWorksChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count works selected',
      one: '1 work selected',
    );
    return '$_temp0';
  }

  @override
  String recordsAreasChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas selected',
      one: '1 area selected',
    );
    return '$_temp0';
  }

  @override
  String recordsConfirmCount(int count) {
    return 'Confirm ($count)';
  }

  @override
  String get recordsStatusAll => 'All';

  @override
  String get recordsStatusCompleted => 'Completed';

  @override
  String get recordsStatusPending => 'Not completed';

  @override
  String get recordsStatusTooltip => 'Filter by status';

  @override
  String get recordsSelectStatus => 'Select status';

  @override
  String get recordsSearchHint => 'Search';

  @override
  String get recordsClearSearchTooltip => 'Clear search';

  @override
  String get recordsPhotos => 'Pilgrimage photos';

  @override
  String recordsRecordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pilgrimage records',
      one: 'pilgrimage record',
    );
    return '$_temp0';
  }

  @override
  String get recordsCompleted => 'Completed';

  @override
  String get recordsEmptySearchTitle => 'No matching records';

  @override
  String get recordsEmptyFilterTitle => 'No records match the filters';

  @override
  String get recordsEmptyTitle => 'No pilgrimage records yet';

  @override
  String get recordsEmptySearchFilterBody =>
      'No spots, works or scenes match both the search and the filters. Try another search or reset the filters.';

  @override
  String get recordsEmptySearchBody =>
      'No spots, works or scenes match the search. Try another search or clear it to see all records.';

  @override
  String get recordsEmptyFilterBody =>
      'Adjust the status, work or area filters and try again.';

  @override
  String get recordsEmptyBody =>
      'Records show up here after you photograph a spot.';

  @override
  String get recordsClearSearch => 'Clear search';

  @override
  String get recordsResetFilters => 'Reset filters';

  @override
  String get recordsColorMatched => 'Color matched';

  @override
  String get copyableTextCopy => 'Copy';

  @override
  String get confirmActionGotIt => 'Got it';

  @override
  String get confirmActionIrreversible => 'This can\'t be undone';

  @override
  String get appBackButtonLabel => 'Back';

  @override
  String get clearAnchorSelectionButtonTooltip => 'Clear selection';

  @override
  String get inputPaste => 'Paste';

  @override
  String get imageViewerSaveOrShare => 'Save or share original';

  @override
  String get imageViewerReadFailed => 'Couldn\'t read the image';

  @override
  String get imageViewerShareFailed => 'Couldn\'t open sharing';

  @override
  String get imageViewerSaveFailed => 'Save failed';

  @override
  String get imageViewerShareText => 'Koma image';

  @override
  String get imageViewerSaveCanceled => 'Save canceled';

  @override
  String get imageViewerSaved => 'Image saved';

  @override
  String get imageViewerLoading => 'Loading image';

  @override
  String get imageViewerEmpty => 'No image';

  @override
  String get imageViewerUnavailable => 'Image unavailable';

  @override
  String get imageViewerSaveImage => 'Save image';

  @override
  String get imageViewerShare => 'Share';

  @override
  String get imageViewerSaveToPhotos => 'Save to photos';

  @override
  String get boundedImageUnavailable => 'Image unavailable';

  @override
  String get boundedImageBadSource => 'Couldn\'t read the image source';

  @override
  String get boundedImageLoading => 'Loading image';

  @override
  String splitNavigationButtonInApp(String label) {
    return 'In-app navigation: $label';
  }

  @override
  String get splitNavigationButtonExternal => 'Open in maps app';

  @override
  String get mapThumbnailMarkerTooltip => 'Pilgrimage spot';

  @override
  String get referenceImagePlaceholderLoading => 'Loading reference image';

  @override
  String get referenceImagePlaceholderUnavailable =>
      'Reference image unavailable';

  @override
  String get referenceImagePlaceholderEmpty => 'No reference image';

  @override
  String get routePlannerSkillHintTitle => 'Plan your pilgrimage with AI';

  @override
  String get routePlannerSkillHintDescription =>
      'Let an AI assistant such as ChatGPT, Claude Code or Codex use the MiriaGo route planner Skill.\nIt collects spots for a work from sources like Anitabi and Google My Maps, splits them into areas, plans routes and writes trip notes. It checks with you at key steps, then exports a ready-to-use .sjhplan plan file.';

  @override
  String get routePlannerSkillHintOpenFailed => 'Couldn\'t open the link';

  @override
  String get routePlannerSkillHintViewGuide => 'View guide';

  @override
  String get routePlannerSkillHintDismissFailed =>
      'Couldn\'t dismiss the tip. Try again.';

  @override
  String get routePlannerSkillHintTapForGuide => 'Tap to view the guide';

  @override
  String get routePlannerSkillHintLinkText =>
      'Plan the trip with AI and get a plan file';

  @override
  String get currentLocationResolverServiceDisabled =>
      'Location services are off.';

  @override
  String get currentLocationResolverPermissionDenied =>
      'Location permission is needed to show your current location.';

  @override
  String get currentLocationResolverTimeout =>
      'Location timed out. Try again later.';

  @override
  String get mapLocationTrackerStopped =>
      'Location updates stopped. Tap the location button to retry.';

  @override
  String get mapLocationTrackerStale =>
      'No new location yet. Your current location may be out of date.';

  @override
  String get mapLocationTrackerServiceDisabled =>
      'Location services are off. Turn them on and try again.';

  @override
  String get mapLocationTrackerPermissionDenied =>
      'Location permission is unavailable. Check permissions and try again.';

  @override
  String get mapLocationTrackerFailed =>
      'Location update failed. Check permissions and location services, then try again.';

  @override
  String get mapLayersPanelTitle => 'Layers';

  @override
  String mapLayersPanelCloseLabel(String title) {
    return 'Close $title';
  }

  @override
  String get mapTileConfigLibertyDescription =>
      'Default style with dense detail.';

  @override
  String get mapTileConfigBrightDescription => 'Bright standard style.';

  @override
  String get mapTileConfigPositronDescription =>
      'Light, low-distraction style.';

  @override
  String get mapTileConfigDarkDescription => 'Dark map style.';

  @override
  String get mapTileConfigFiordDescription => 'Soft terrain style.';

  @override
  String get mapTileConfigCustomXyzLabel => 'Custom XYZ';

  @override
  String get mapTileConfigCustomMapLibreLabel => 'Custom MapLibre';

  @override
  String get mapTileConfigOpenFreeMapDescription =>
      'Default map, uses a MapLibre style.';

  @override
  String get mapTileConfigOpenStreetMapDescription =>
      'Uses standard OpenStreetMap XYZ tiles.';

  @override
  String mapTileConfigCustomXyzDescription(String pattern) {
    return 'Uses a raster tile URL containing $pattern.';
  }

  @override
  String get mapTileConfigCustomMapLibreDescription =>
      'Uses a custom MapLibre style URL.';

  @override
  String mapTileConfigCustomXyzInvalid(String z, String x, String y) {
    return 'Custom XYZ URL must contain $z, $x and $y and use http/https.';
  }

  @override
  String get mapTileConfigCustomMapLibreInvalid =>
      'Custom MapLibre style URL must use http/https.';

  @override
  String get navigationHeadingStale =>
      'Last known location, waiting for update';

  @override
  String get navigationHeadingNoHeading =>
      'Current location, heading unavailable';

  @override
  String get navigationHeadingWithHeading => 'Current location, phone heading';

  @override
  String get photoLocationStatusPanelSkip => 'Skip';

  @override
  String nativeCameraControllerPermissionRequestFailed(String error) {
    return 'Camera permission request failed: $error';
  }

  @override
  String get nativeCameraControllerPermissionRequired =>
      'Camera permission required';

  @override
  String get nativeCameraControllerInitFailed =>
      'Native camera failed to start';

  @override
  String nativeCameraControllerInitFailedWithError(String error) {
    return 'Native camera failed to start: $error';
  }

  @override
  String get photoLocationChoiceTitle => 'Save location in pilgrimage photos?';

  @override
  String get photoLocationChoiceChangeLater =>
      'You can change this later in Settings > Camera.';

  @override
  String get photoLocationChoiceNoSpotCoordinates =>
      'Spot coordinates are never used in place of your actual location.';

  @override
  String get photoLocationChoiceRecentTitle => 'Use most recent location';

  @override
  String get photoLocationChoiceRecentSubtitle =>
      'Quickly saves a recent valid location, or gets one if there is none.';

  @override
  String get photoLocationChoiceConfirmTitle =>
      'Get location when confirming the record';

  @override
  String get photoLocationChoiceConfirmSubtitle =>
      'Waits for a fresh location on the confirmation page after the shot. Best when you need a more accurate position.';

  @override
  String get photoLocationChoiceDisabledTitle => 'Don\'t save location';

  @override
  String get photoLocationChoiceRecommended => 'Recommended';

  @override
  String get mapMarkerClusteringTapToBrowse => 'tap to browse';

  @override
  String get mapMarkerClusteringTapToZoom => 'tap to zoom in';

  @override
  String get mapMarkerClusteringDone => 'done';

  @override
  String mapMarkerClusteringDoneSummary(int done, String doneLabel) {
    return ', $done $doneLabel';
  }

  @override
  String mapMarkerClusteringBrowseOverlapping(int count) {
    return 'Browse $count overlapping spots';
  }

  @override
  String mapMarkerClusteringSpotCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String mapMarkerClusteringSemantics(
    int count,
    String doneSummary,
    String action,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clustered spots',
      one: '1 clustered spot',
    );
    return '$_temp0$doneSummary, $action';
  }

  @override
  String mapMarkerClusteringTooltipDone(
    String tooltip,
    int done,
    String doneLabel,
  ) {
    return '$tooltip · $done $doneLabel';
  }

  @override
  String get mapMarkerClusteringPrevious => 'Previous overlapping spot';

  @override
  String mapMarkerClusteringPager(int index, int total) {
    return 'Overlapping spots  $index / $total';
  }

  @override
  String get mapMarkerClusteringNext => 'Next overlapping spot';

  @override
  String get valhallaRouteClientNeedsTwoStops =>
      'A route needs at least a start and a destination';

  @override
  String get valhallaRouteClientTimeout =>
      'The routing service timed out. Try again later';

  @override
  String valhallaRouteClientConnectionFailed(String error) {
    return 'Can\'t connect to the routing service: $error';
  }

  @override
  String get valhallaRouteClientRateLimited =>
      'Too many requests to the routing service. Try again later';

  @override
  String valhallaRouteClientServiceUnavailable(int status) {
    return 'The routing service is temporarily unavailable ($status)';
  }

  @override
  String valhallaRouteClientRouteFailed(int status) {
    return 'Can\'t plan this walking route ($status)';
  }

  @override
  String valhallaRouteClientStatus(int status) {
    return 'Service returned $status';
  }

  @override
  String get valhallaRouteClientTestTimeout => 'Connection test timed out';

  @override
  String get valhallaRouteClientBadResponse =>
      'The routing service returned unrecognized data';

  @override
  String get valhallaRouteClientError170 =>
      'No connected walking path between the start and destination';

  @override
  String get valhallaRouteClientError171 =>
      'No walkable road near the start or spot. Try a different position';

  @override
  String get valhallaRouteClientError154 =>
      'The distance exceeds the routing service\'s walking route limit';

  @override
  String get valhallaRouteClientError442 => 'No walking route found';

  @override
  String get valhallaRouteClientStartWalking => 'Start walking';

  @override
  String valhallaRouteClientStartAlong(String road) {
    return 'Start along $road';
  }

  @override
  String get valhallaRouteClientHeadRight => 'Head right';

  @override
  String valhallaRouteClientHeadRightOnto(String road) {
    return 'Head right onto $road';
  }

  @override
  String get valhallaRouteClientHeadLeft => 'Head left';

  @override
  String valhallaRouteClientHeadLeftOnto(String road) {
    return 'Head left onto $road';
  }

  @override
  String get valhallaRouteClientArrive => 'Arrive at your destination';

  @override
  String valhallaRouteClientArriveNear(String road) {
    return 'Arrive at your destination near $road';
  }

  @override
  String get valhallaRouteClientContinue => 'Continue';

  @override
  String valhallaRouteClientContinueOnto(String road) {
    return 'Continue onto $road';
  }

  @override
  String get valhallaRouteClientGoStraight => 'Go straight';

  @override
  String valhallaRouteClientGoStraightAlong(String road) {
    return 'Go straight along $road';
  }

  @override
  String get valhallaRouteClientBearRight => 'Bear right';

  @override
  String valhallaRouteClientBearRightOnto(String road) {
    return 'Bear right onto $road';
  }

  @override
  String get valhallaRouteClientTurnRight => 'Turn right';

  @override
  String valhallaRouteClientTurnRightOnto(String road) {
    return 'Turn right onto $road';
  }

  @override
  String get valhallaRouteClientSharpRight => 'Make a sharp right';

  @override
  String valhallaRouteClientSharpRightOnto(String road) {
    return 'Make a sharp right onto $road';
  }

  @override
  String get valhallaRouteClientUTurn => 'Make a U-turn';

  @override
  String get valhallaRouteClientSharpLeft => 'Make a sharp left';

  @override
  String valhallaRouteClientSharpLeftOnto(String road) {
    return 'Make a sharp left onto $road';
  }

  @override
  String get valhallaRouteClientTurnLeft => 'Turn left';

  @override
  String valhallaRouteClientTurnLeftOnto(String road) {
    return 'Turn left onto $road';
  }

  @override
  String get valhallaRouteClientBearLeft => 'Bear left';

  @override
  String valhallaRouteClientBearLeftOnto(String road) {
    return 'Bear left onto $road';
  }

  @override
  String get valhallaRouteClientRampStraight => 'Take the ramp straight ahead';

  @override
  String valhallaRouteClientRampStraightAlong(String road) {
    return 'Take the ramp straight ahead along $road';
  }

  @override
  String get valhallaRouteClientRampRight => 'Take the ramp on the right';

  @override
  String valhallaRouteClientRampRightOnto(String road) {
    return 'Take the ramp on the right onto $road';
  }

  @override
  String get valhallaRouteClientRampLeft => 'Take the ramp on the left';

  @override
  String valhallaRouteClientRampLeftOnto(String road) {
    return 'Take the ramp on the left onto $road';
  }

  @override
  String get valhallaRouteClientExitRight => 'Take the exit on the right';

  @override
  String get valhallaRouteClientExitLeft => 'Take the exit on the left';

  @override
  String get valhallaRouteClientStayStraight => 'Stay straight';

  @override
  String valhallaRouteClientStayStraightAlong(String road) {
    return 'Stay straight along $road';
  }

  @override
  String get valhallaRouteClientKeepRight => 'Keep right';

  @override
  String valhallaRouteClientKeepRightAlong(String road) {
    return 'Keep right along $road';
  }

  @override
  String get valhallaRouteClientKeepLeft => 'Keep left';

  @override
  String valhallaRouteClientKeepLeftAlong(String road) {
    return 'Keep left along $road';
  }

  @override
  String get valhallaRouteClientMerge => 'Merge';

  @override
  String valhallaRouteClientMergeOnto(String road) {
    return 'Merge onto $road';
  }

  @override
  String get valhallaRouteClientEnterRoundabout => 'Enter the roundabout';

  @override
  String get valhallaRouteClientExitRoundabout => 'Exit the roundabout';

  @override
  String get valhallaRouteClientBoardFerry => 'Board the ferry';

  @override
  String get valhallaRouteClientLeaveFerry => 'Leave the ferry';

  @override
  String get valhallaRouteClientTakeTransit => 'Take public transit';

  @override
  String get valhallaRouteClientTransfer => 'Transfer';

  @override
  String get valhallaRouteClientStayOnLine => 'Stay on the current line';

  @override
  String get valhallaRouteClientToTransitConnection =>
      'Head to the transit connection';

  @override
  String get valhallaRouteClientTransitArrive => 'Arrive at your transit stop';

  @override
  String get valhallaRouteClientMergeRight => 'Merge right';

  @override
  String valhallaRouteClientMergeRightOnto(String road) {
    return 'Merge right onto $road';
  }

  @override
  String get valhallaRouteClientMergeLeft => 'Merge left';

  @override
  String valhallaRouteClientMergeLeftOnto(String road) {
    return 'Merge left onto $road';
  }

  @override
  String get valhallaRouteClientElevator => 'Take the elevator';

  @override
  String get valhallaRouteClientStairs => 'Take the stairs';

  @override
  String get valhallaRouteClientEscalator => 'Take the escalator';

  @override
  String get valhallaRouteClientEnterBuilding => 'Enter the building';

  @override
  String get valhallaRouteClientExitBuilding => 'Exit the building';

  @override
  String get valhallaRouteClientOtherFloor => 'Go to another floor';

  @override
  String get valhallaRouteClientParkAndWalk => 'Park and continue on foot';

  @override
  String valhallaRouteClientContinueAlong(String road) {
    return 'Continue along $road';
  }

  @override
  String get navigationRouteConfirmLoadFailed =>
      'Couldn\'t load the route. Check location and routing service settings';

  @override
  String get navigationRouteConfirmTitle => 'Confirm route';

  @override
  String get navigationRouteConfirmChainArea => 'Route through the whole area';

  @override
  String get navigationRouteConfirmToSelected =>
      'Navigate to the selected spot';

  @override
  String navigationRouteConfirmChainSummary(int count, String stops) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visits $count spots in order: $stops',
      one: 'Visits 1 spot in order: $stops',
    );
    return '$_temp0';
  }

  @override
  String navigationRouteConfirmDestination(String name) {
    return 'Destination: $name';
  }

  @override
  String get navigationRouteConfirmLoading =>
      'Getting your location and planning a walking route...';

  @override
  String get navigationRouteConfirmReplan => 'Replan route';

  @override
  String get navigationRouteConfirmExternalShort => 'External';

  @override
  String get navigationRouteConfirmExternalFailed =>
      'Couldn\'t open the external map app';

  @override
  String get navigationRouteConfirmStart => 'Start navigation';

  @override
  String get navigationRouteConfirmStartArea =>
      'Navigate through the whole area';

  @override
  String get navigationRouteConfirmOnlySelected =>
      'Navigate to selected spot only';

  @override
  String get navigationRouteConfirmOnlySelectedShort => 'Spot only';

  @override
  String get navigationRouteConfirmAreaBadge => 'Area';

  @override
  String get inAppNavigationLocationStopped =>
      'Location updates stopped. Try again.';

  @override
  String get inAppNavigationLocationStale =>
      'No new location yet. Your current location may be out of date.';

  @override
  String get inAppNavigationPreciseOff =>
      'Precise location is off. Arrival alerts and off-route detection may be inaccurate.';

  @override
  String get inAppNavigationOpenSettings => 'Settings';

  @override
  String get inAppNavigationRetryLocation => 'Retry location';

  @override
  String get inAppNavigationOnRoute => 'On route';

  @override
  String get inAppNavigationFollowRoute => 'Continue along the route';

  @override
  String get inAppNavigationSideRight => ', on the right';

  @override
  String get inAppNavigationSideLeft => ', on the left';

  @override
  String inAppNavigationArriveDestination(String side) {
    return 'Arrive at your destination$side';
  }

  @override
  String inAppNavigationArriveWaypoint(String side) {
    return 'Arrive at the waypoint$side';
  }

  @override
  String inAppNavigationArriveDestinationNamed(String name, String side) {
    return 'Arrive at $name$side';
  }

  @override
  String inAppNavigationArriveWaypointNamed(String name, String side) {
    return 'Arrive at waypoint $name$side';
  }

  @override
  String inAppNavigationMeters(int meters) {
    return '$meters m';
  }

  @override
  String inAppNavigationKilometers(String km) {
    return '$km km';
  }

  @override
  String inAppNavigationFinalStop(String name) {
    return 'Destination: $name';
  }

  @override
  String get inAppNavigationAllStops => 'All spots';

  @override
  String inAppNavigationStopCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots',
      one: '1 spot',
    );
    return '$_temp0';
  }

  @override
  String get inAppNavigationArrived => 'I\'ve arrived';

  @override
  String get inAppNavigationEndRoute => 'End route';

  @override
  String get inAppNavigationCollapse => 'Collapse';

  @override
  String get inAppNavigationExpand => 'Expand';

  @override
  String get inAppNavigationMetricArrival => 'arrival';

  @override
  String get inAppNavigationMetricHours => 'hrs';

  @override
  String get inAppNavigationMetricKm => 'km';

  @override
  String get inAppNavigationAreaBadge => 'Area';

  @override
  String get inAppNavigationRecenter => 'Back to current location';

  @override
  String get inAppNavigationArrivalTitle => 'Arrived at spot';

  @override
  String get inAppNavigationOpenCamera => 'Open camera';

  @override
  String inAppNavigationRemainingStop(int stopNumber, int remainingCount) {
    return 'Spot $stopNumber of $remainingCount remaining';
  }

  @override
  String inAppNavigationNextStop(String subtitle) {
    return 'Next spot · $subtitle';
  }

  @override
  String get inAppNavigationGoNext => 'Go to next spot';

  @override
  String get pilgrimageMapLayerThumbnails => 'Thumbnail markers';

  @override
  String get pilgrimageMapLayerAreas => 'Area outlines';

  @override
  String get pilgrimageMapLayerHideCompleted => 'Hide completed spots';

  @override
  String get pilgrimageMapLayerClustering => 'Cluster nearby spots';

  @override
  String get pilgrimageMapLayerContinuousLocation => 'Keep updating location';

  @override
  String get pilgrimageMapLayerContinuousLocationHint =>
      'When off, location is only fetched when you tap the location button. Saves battery.';

  @override
  String pilgrimageMapOpenAppFailed(String app) {
    return 'Couldn\'t open $app.';
  }

  @override
  String get pilgrimageMapNoSpotsSnack => 'This plan has no spots yet.';

  @override
  String get pilgrimageMapCannotEdit => 'Spots can\'t be edited here.';

  @override
  String get pilgrimageMapVisitedLabel => 'visited';

  @override
  String get pilgrimageMapCurrentLocation => 'Current location';

  @override
  String get pilgrimageMapLocate => 'My location';

  @override
  String get pilgrimageMapCurrentTarget => 'Next stop';

  @override
  String get pilgrimageMapLayers => 'Layers';

  @override
  String get pilgrimageMapPointMarker => 'Pilgrimage spot';

  @override
  String get pilgrimageMapCopySpotName => 'Spot name';

  @override
  String get pilgrimageMapCopySpotInfo => 'Spot info';

  @override
  String get pilgrimageMapNavigate => 'Navigate';

  @override
  String get pilgrimageMapCoordinatesMissing => 'No coordinates yet';

  @override
  String get pilgrimageMapCamera => 'Reference camera';

  @override
  String get pilgrimageMapUndoVisit => 'Undo visit';

  @override
  String get pilgrimageMapMarkComplete => 'Mark complete';

  @override
  String get pilgrimageMapSetCurrent => 'Set as next stop';

  @override
  String get pilgrimageMapEmptyTitle => 'This plan has no spots yet';

  @override
  String get pilgrimageMapEmptyBody => 'Add spots to see markers on the map.';

  @override
  String get pilgrimageMapStatusCurrent => 'Current';

  @override
  String get pilgrimageMapStatusCompleted => 'Done';

  @override
  String get pilgrimageMapStatusPending => 'To visit';

  @override
  String get visitRecordConfirmationLocationReady =>
      'Location found. It will be written to the photo when you save.';

  @override
  String get visitRecordConfirmationLocating => 'Getting photo location...';

  @override
  String get visitRecordConfirmationLocationFailed =>
      'Couldn\'t get location. No location will be added; the photo\'s original info is kept.';

  @override
  String get visitRecordConfirmationStorageUnavailable =>
      'Record storage is unavailable. Go back and try again.';

  @override
  String get visitRecordConfirmationStageSaving => 'Saving record...';

  @override
  String get visitRecordConfirmationStageWritingLocation =>
      'Writing location to photo, please wait...';

  @override
  String get visitRecordConfirmationStageBackingUp =>
      'Backing up pilgrimage photo...';

  @override
  String get visitRecordConfirmationStageComparison =>
      'Creating comparison image...';

  @override
  String get visitRecordConfirmationStageUpdatingSpot =>
      'Updating spot status...';

  @override
  String get visitRecordConfirmationLocationWriteFailed =>
      '; couldn\'t write location, the photo\'s original info is kept';

  @override
  String get visitRecordConfirmationCompleteFailed =>
      '; couldn\'t mark complete, try again from the plan';

  @override
  String get visitRecordConfirmationSaveUncertain =>
      'Couldn\'t confirm the save. Check the records page before saving again.';

  @override
  String get visitRecordConfirmationSaveFailed =>
      'Couldn\'t save the record. Try again.';

  @override
  String get visitRecordConfirmationSavingWait => 'Saving record, please wait.';

  @override
  String get visitRecordConfirmationTitle => 'Confirm record';

  @override
  String get visitRecordConfirmationLocationSkipped =>
      'Location skipped. No location will be added; the photo\'s original info is kept.';

  @override
  String get visitRecordConfirmationSavingButton => 'Saving';

  @override
  String get visitRecordConfirmationSave => 'Save record';

  @override
  String get visitRecordConfirmationSaveAndComplete => 'Save and mark complete';

  @override
  String get visitRecordConfirmationSavedAndCompleted =>
      'Saved and marked complete';

  @override
  String get visitRecordConfirmationSaved => 'Record saved';

  @override
  String get visitRecordConfirmationBackedUp => ', backed up to gallery';

  @override
  String get visitRecordConfirmationBackupFailed => '; gallery backup failed';

  @override
  String visitRecordConfirmationNext(String name) {
    return ', next: $name';
  }

  @override
  String visitRecordConfirmationDetail(String message) {
    return ', $message';
  }

  @override
  String get visitRecordConfirmationComparisonSaved =>
      ', comparison image saved to gallery';

  @override
  String get visitRecordConfirmationComparisonNoReference =>
      ', reference image unavailable, no comparison image created';

  @override
  String get visitRecordConfirmationComparisonNoPhoto =>
      ', pilgrimage photo unavailable, no comparison image created';

  @override
  String get visitRecordConfirmationComparisonGalleryFailed =>
      ', couldn\'t save comparison image to gallery';

  @override
  String get visitRecordConfirmationComparisonRenderFailed =>
      ', couldn\'t create comparison image';

  @override
  String get visitRecordConfirmationSaveToGallery => 'Save to gallery';

  @override
  String get visitRecordConfirmationReferenceImage => 'Reference image';

  @override
  String get visitRecordConfirmationPilgrimagePhoto => 'Pilgrimage photo';

  @override
  String get visitRecordConfirmationReferenceMode => 'Reference mode';

  @override
  String get camerawesomeReferenceModeOverlay => 'Overlay';

  @override
  String get camerawesomeReferenceModeSplit => 'Stacked';

  @override
  String get camerawesomeReferenceModePinned => 'Mini view';

  @override
  String get camerawesomeReferenceReadFailed =>
      'Couldn\'t read the reference image';

  @override
  String get camerawesomeReferenceImportFailed =>
      'Couldn\'t import the photo. Choose again.';

  @override
  String get camerawesomeReferenceReadingRatio =>
      'Reading the reference image aspect ratio. Take the shot in a moment.';

  @override
  String get camerawesomeReferenceNotReady =>
      'The camera isn\'t ready yet. Try again in a moment.';

  @override
  String get camerawesomeReferenceCaptureFailed => 'Capture failed. Try again.';

  @override
  String get camerawesomeReferenceBack => 'Back';

  @override
  String get camerawesomeReferenceReferenceImage => 'Reference image';

  @override
  String get camerawesomeReferenceLandscapeUi => 'Switch to landscape UI';

  @override
  String get camerawesomeReferencePortraitUi => 'Switch to portrait UI';

  @override
  String get camerawesomeReferenceGalleryImport => 'Import from gallery';

  @override
  String get camerawesomeReferenceSwitchLens => 'Switch lens';

  @override
  String get camerawesomeReferenceReviewPhotos => 'Review photos';

  @override
  String get camerawesomeReferenceFlashOff => 'Flash: off';

  @override
  String get camerawesomeReferenceFlashOn => 'Flash: on';

  @override
  String get camerawesomeReferenceFlashTorch => 'Flash: torch';

  @override
  String get camerawesomeReferenceFlashAuto => 'Flash: auto';

  @override
  String get camerawesomeReferenceSwitchCamera => 'Switch camera';

  @override
  String get camerawesomeReferenceImportFromGallery => 'Import from gallery';

  @override
  String get camerawesomeReferenceImport => 'Import';

  @override
  String get camerawesomeReferenceWebPreview =>
      'The live camera doesn\'t start in the web preview';

  @override
  String get camerawesomeReferencePermissionTitle =>
      'Camera permission required';

  @override
  String get camerawesomeReferencePermissionBody =>
      'Allow Koma to use the camera in system settings to take pilgrimage photos.';

  @override
  String get camerawesomeReferenceOpenSettings => 'Open settings';

  @override
  String get camerawesomeReferencePickFromGallery =>
      'Choose a photo from gallery';

  @override
  String get camerawesomeReferenceUnavailableTitle => 'Camera can\'t start';

  @override
  String get camerawesomeReferenceUnavailableBody =>
      'The camera is unavailable right now. Try again later. If the problem continues, restart Koma.';

  @override
  String get addPointsPickWork => 'View spots';

  @override
  String get addPointsFindSpots => 'Find anime spots';

  @override
  String get addPointsFindSpotsSubtitle =>
      'Search an anime or paste an Anitabi link, then pick spots on the map';

  @override
  String get addPointsOwnSpotsSection => 'Add your own spots';

  @override
  String get anitabiMapImportSearchWork => 'Search for an anime';

  @override
  String get anitabiMapImportPasteLink => 'Paste Anitabi link';

  @override
  String get anitabiMapImportClusterAdded => 'added';

  @override
  String navigationRouteConfirmExternalWith(String app) {
    return 'Navigate with $app';
  }

  @override
  String get planOnboardingFindTitle => 'Find an anime';

  @override
  String get planOnboardingFindBody =>
      'Tap Add spots below, then Find anime spots. Search for the anime or paste an Anitabi link.';

  @override
  String get planOnboardingShootTitle => 'Shoot on site';

  @override
  String get planOnboardingShootBody =>
      'At each spot, tap the camera button and line your shot up with the anime frame.';

  @override
  String get pointDetailMarkDoneShort => 'Visited';

  @override
  String get pointDetailUndoShort => 'Undo';

  @override
  String get splitNavigationRouteShort => 'Route';

  @override
  String get splitNavigationMapsShort => 'Maps';

  @override
  String get appShellNoPlansTitle => 'No plans yet';

  @override
  String get appShellNoPlansBody =>
      'Create a plan, then add the anime spots you want to visit.';

  @override
  String get appShellCreatePlan => 'Create plan';

  @override
  String get appShellCreatePlanFailed =>
      'Couldn\'t create the plan. Please try again.';

  @override
  String get appShellNewPlan => 'New plan';

  @override
  String get planManagerDeleteFailed =>
      'Couldn\'t delete the plan. Please try again.';

  @override
  String get paletteFjord => 'Fjord';

  @override
  String get paletteSpruce => 'Spruce';

  @override
  String get paletteMoss => 'Moss';

  @override
  String get paletteLake => 'Lake';

  @override
  String get paletteInk => 'Ink';

  @override
  String get planAreaEmpty =>
      'No spots in this area. Use the arrows to see the others.';

  @override
  String get planManagerOpenPlan => 'Open plan';

  @override
  String get planManagerEditDetails => 'Edit details';

  @override
  String get planManagerDetails => 'Details';

  @override
  String get planManagerNoDetails => 'No details yet';

  @override
  String get planManagerFactSpots => 'Spots';

  @override
  String get planManagerFactAreas => 'Areas';

  @override
  String get planManagerFactCreated => 'Created';

  @override
  String get planManagerFactUpdated => 'Updated';

  @override
  String planManagerSpotsDone(int total, int done) {
    return '$total · $done done';
  }

  @override
  String get planEdit => 'Edit';

  @override
  String get planEditDone => 'Done';

  @override
  String get planEditMarkVisited => 'Visited';

  @override
  String get anitabiMapImportBoxArea => 'Area';

  @override
  String get settingsBasedOn => 'Based on';
}
