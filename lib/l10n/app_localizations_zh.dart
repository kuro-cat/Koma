// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRetry => '重试';

  @override
  String get commonClose => '关闭';

  @override
  String get appLoading => '正在加载 Koma...';

  @override
  String get alignPhotoTitle => '对齐裁剪';

  @override
  String get alignPhotoAction => '对齐裁剪';

  @override
  String get alignPhotoActionSubtitle => '与参考图对齐';

  @override
  String get alignPhotoHint => '双指缩放、拖动照片，让它与参考图重合';

  @override
  String get alignPhotoFrameOpacity => '参考图';

  @override
  String get alignPhotoRotation => '旋转';

  @override
  String get alignPhotoDifference => '差值叠加';

  @override
  String get alignPhotoDifferenceHint => '重合的地方会变暗';

  @override
  String get alignPhotoReset => '重新居中';

  @override
  String get alignPhotoSave => '保存裁剪';

  @override
  String get alignPhotoSaving => '保存中...';

  @override
  String get alignPhotoSaved => '已保存裁剪';

  @override
  String get alignPhotoSaveFailed => '保存失败，原图未更改';

  @override
  String get alignPhotoRemoveTitle => '移除裁剪';

  @override
  String get alignPhotoRemoveMessage => '将恢复为未裁剪的原图，调色会重新应用。';

  @override
  String get alignPhotoRemoveConfirm => '移除';

  @override
  String get alignPhotoRemoved => '已移除裁剪';

  @override
  String get alignPhotoNoPhoto => '巡礼照片不可用';

  @override
  String get alignPhotoNoReference => '这条记录没有参考图，无法对齐';

  @override
  String settingsResetMessage(String target) {
    return '$target将恢复为默认值。';
  }

  @override
  String settingsAnitabiRestoreMessage(String target) {
    return '将把$target恢复为官方默认值。';
  }

  @override
  String settingsDesktopLauncherAvailable(String platform, String mode) {
    return '桌面启动器 可用 / $platform / $mode';
  }

  @override
  String settingsReferenceImageScale(int percent) {
    return '参考图显示 $percent%';
  }

  @override
  String settingsCameraZoomRange(String min, String max) {
    return '相机缩放 ${min}x - ${max}x';
  }

  @override
  String settingsRemoteConfigApplied(int version) {
    return '已应用远程配置 v$version';
  }

  @override
  String settingsRemoteLastCheck(String applied, String time) {
    return '$applied · 上次检查 $time';
  }

  @override
  String settingsRemoteLastCheckResult(
    String applied,
    String time,
    String result,
  ) {
    return '$applied · 上次检查 $time，$result';
  }

  @override
  String settingsMapSource(String name) {
    return '地图源 $name';
  }

  @override
  String settingsOpenFreeMapStyle(String name) {
    return 'OpenFreeMap 样式 $name';
  }

  @override
  String settingsXyzUrlHelper(String z, String x, String y) {
    return 'URL 需要包含 $z、$x、$y。';
  }

  @override
  String settingsAnitabiImageSource(String name) {
    return 'Anitabi 图片源 $name';
  }

  @override
  String settingsCountValue(int count) {
    return '$count 个';
  }

  @override
  String settingsNavigationApp(String name) {
    return '导航地图 $name';
  }

  @override
  String settingsZoomLevel(int level) {
    return '$level 级';
  }

  @override
  String settingsThumbnailThresholdSubtitle(int count) {
    return '视图内点位不超过 $count 个时显示缩略图；超过时仅显示圆点。';
  }

  @override
  String settingsSelectedPlans(int selected, int total) {
    return '已选择 $selected / $total 个计划';
  }

  @override
  String settingsPlanSummary(int count) {
    return '$count 个点位';
  }

  @override
  String settingsCleaningProgress(int completed, int total) {
    return '正在清理 $completed / $total';
  }

  @override
  String settingsClearReferenceCacheMessage(int count, String size) {
    return '将删除 $count 个下载缓存，约 $size。本地上传图片和计划包导入图片不会被删除。';
  }

  @override
  String settingsCacheCleared(int count) {
    return '已清理 $count 个缓存文件';
  }

  @override
  String settingsFreedSpace(String size) {
    return '释放 $size';
  }

  @override
  String settingsCacheClearFailedFiles(int count) {
    return '$count 个文件清理失败';
  }

  @override
  String settingsHueSaturationValue(int hue, int saturation) {
    return '色相 $hue 度，饱和度 $saturation%';
  }

  @override
  String settingsProbeSucceeded(int ms) {
    return '成功 · ${ms}ms';
  }

  @override
  String settingsImageSourceAutoDescription(String official, String mirror) {
    return '优先使用 $official；失败后尝试 $mirror。';
  }

  @override
  String settingsImageSourceFixedDescription(String url) {
    return '固定使用 $url。';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsResetTitle => '恢复初始设置';

  @override
  String get settingsAppearanceTitle => '外观设置';

  @override
  String get settingsAppearanceSubtitle => '主题色、深浅色、缩放、显示等';

  @override
  String get settingsThemeColor => '主题色';

  @override
  String get settingsThemeMode => '主题模式';

  @override
  String get settingsCameraTitle => '拍摄设置';

  @override
  String get settingsCameraSubtitle => '照片比例、参考图比例、备份等';

  @override
  String get settingsCaptureAspectRatio => '拍摄图片比例';

  @override
  String get settingsCameraZoom => '相机缩放';

  @override
  String get settingsPhotoBackup => '照片备份';

  @override
  String get settingsSavePhotoToGallery => '保存巡礼照片到相册';

  @override
  String get settingsComparisonTitle => '对比图设置';

  @override
  String get settingsComparisonSubtitle => '导出样式、自动保存到相册';

  @override
  String get settingsAutoSaveComparison => '自动保存对比图';

  @override
  String get settingsAutoSaveComparisonSubtitle => '保存记录时保存到相册';

  @override
  String get settingsDataSourceTitle => '数据源设置';

  @override
  String get settingsDataSourceSubtitle => '地图源、图片源等';

  @override
  String get settingsMapDisplayTitle => '地图显示';

  @override
  String get settingsMapDisplaySubtitle => '点位、片区、聚合与缩略图';

  @override
  String get settingsClearCacheTitle => '清除缓存';

  @override
  String get settingsFullReferenceCache => '完整参考图缓存';

  @override
  String get settingsDesktopTitle => '桌面端';

  @override
  String get settingsDesktopSubtitle => '启动器、数据目录等';

  @override
  String get settingsAboutTitle => '关于 Koma';

  @override
  String get settingsAboutSubtitle => '版本信息、开源许可等';

  @override
  String get settingsResetTarget => '所有外观、拍摄和地图设置';

  @override
  String get settingsReset => '恢复';

  @override
  String get settingsResetNotice => '恢复后仍可重新调整各项设置';

  @override
  String get settingsResetDone => '已恢复初始设置';

  @override
  String get settingsDesktopLauncherChecking => '桌面启动器 检查中';

  @override
  String get settingsDesktopLauncherUnavailable => '桌面启动器 不可用';

  @override
  String get settingsDesktopSystemDataDir => '系统数据目录';

  @override
  String get settingsDesktopPortableDir => '便携目录';

  @override
  String get settingsDesktopAppDataDir => '应用数据目录';

  @override
  String get settingsUrlLabel => 'URL 地址';

  @override
  String get settingsThemeModeSubtitle => '影响应用整体浅色或深色显示';

  @override
  String get settingsLight => '浅色';

  @override
  String get settingsDark => '深色';

  @override
  String get settingsFollowSystem => '跟随系统';

  @override
  String get settingsThemeColorSubtitle => '影响应用整体配色';

  @override
  String get settingsPageScale => '页面缩放';

  @override
  String get settingsPageScaleSubtitle => '调整界面整体大小（不影响参考图）';

  @override
  String get settingsFontSmall => '小';

  @override
  String get settingsFontStandard => '标准';

  @override
  String get settingsFontLarge => '大';

  @override
  String get settingsFontExtraLarge => '特大';

  @override
  String get settingsPersonalization => '个性化功能配置';

  @override
  String get settingsShowAreaProgress => '显示片区进度条';

  @override
  String get settingsShowAreaProgressSubtitle =>
      '在片区选择弹窗中显示未完成片区的进度背景；完成后仅显示对勾。';

  @override
  String get settingsDismissPlanActions => '点击空白收回计划操作';

  @override
  String get settingsDismissPlanActionsSubtitle => '展开计划操作后，点击面板外的空白区域自动收回';

  @override
  String get settingsCaptureAspectRatioHint => '自动会优先跟随参考图比例；选择固定比例后会按该比例拍摄。';

  @override
  String get settingsFallbackAspectRatio => '无参考图时比例';

  @override
  String get settingsFallbackAspectRatioHint => '拍摄图片比例为自动、且没有参考图可对齐时使用。';

  @override
  String get settingsPhotoLocation => '照片定位信息';

  @override
  String get settingsPhotoBackupSubtitle => '保存记录时同时备份一张巡礼照片。';

  @override
  String get settingsPhotoLocationAskDescription =>
      '第一次按下快门时选择。定位仅写入照片，不使用点位坐标。';

  @override
  String get settingsPhotoLocationDisabledDescription =>
      '不申请照片定位权限，也不向照片写入 GPS 信息。';

  @override
  String get settingsPhotoLocationRecentDescription =>
      '拍摄时优先使用设备最近的有效定位；没有可用定位时尝试获取一次。';

  @override
  String get settingsPhotoLocationConfirmDescription =>
      '拍摄后在确认记录页面获取新定位，完成或失败后再允许保存。';

  @override
  String get settingsPhotoLocationBadgeAsk => '询问';

  @override
  String get settingsPhotoLocationBadgeOff => '关闭';

  @override
  String get settingsPhotoLocationBadgeRecent => '最近';

  @override
  String get settingsRecommended => '推荐';

  @override
  String get settingsPhotoLocationConfirmLabel => '确认记录时获取定位';

  @override
  String get settingsAnitabiUrlHelper => '仅支持公开可访问的 HTTPS 基础地址，不要填写接口路径参数。';

  @override
  String get settingsSaveFailed => '设置保存失败';

  @override
  String get settingsTryAgainLater => '请稍后重试';

  @override
  String get settingsRestoreDefaultAddresses => '恢复默认地址';

  @override
  String get settingsAnitabiRestoreTarget => '全部 Anitabi 服务地址';

  @override
  String get settingsRestoreDefault => '恢复默认';

  @override
  String get settingsAnitabiRestoreNotice => '当前自定义地址不会被保留';

  @override
  String get settingsAnitabiSite => '主站地址';

  @override
  String get settingsAnitabiStaticData => '静态地图数据';

  @override
  String get settingsAnitabiApi => '数据 API';

  @override
  String get settingsAnitabiOfficialImage => '官方图片服务';

  @override
  String get settingsAnitabiMirrorImage => '备用图片服务';

  @override
  String get settingsAnitabiServices => 'Anitabi 服务地址';

  @override
  String get settingsServiceAddresses => '服务地址';

  @override
  String get settingsTestingConnections => '正在测试连接';

  @override
  String get settingsTestAllConnections => '测试全部连接';

  @override
  String get settingsAddressAutoUpdate => '地址自动更新';

  @override
  String get settingsAddressAutoUpdateDescription =>
      '连接 Anitabi 失败时，从 MiriaGo 仓库读取最新服务地址，验证可用后再替换。自定义的地址不会被改动。';

  @override
  String get settingsChecking => '正在检查';

  @override
  String get settingsCheckNow => '立即检查更新';

  @override
  String get settingsRemoteConfigNotApplied => '尚未应用远程配置';

  @override
  String get settingsRoutingConnectionOk => '路径规划服务连接正常';

  @override
  String get settingsRoutingConnectionFailed => '路径规划服务连接失败';

  @override
  String get settingsCustomXyzUrlNotSet => '未设置自定义 XYZ URL';

  @override
  String get settingsCustomXyzUrl => '自定义 XYZ URL';

  @override
  String get settingsInvalidUrl => 'URL 格式无效';

  @override
  String get settingsMapLibreStyleUrlNotSet => '未设置 MapLibre style URL';

  @override
  String get settingsMapLibreStyleUrlHelper => 'URL 需要指向可公开读取的 style JSON。';

  @override
  String get settingsAnitabiServicesHint => '服务域名变化时可单独调整，不会改写计划中的标准图片链接。';

  @override
  String get settingsConcurrentImageLoads => '图片同时请求数';

  @override
  String get settingsConcurrentImageLoadsSubtitle =>
      '缩略图和完整参考图均按此数量并发请求。数值越大速度可能越快，但网络和内存占用也更高。';

  @override
  String get settingsWalkingRoutes => '步行路径规划';

  @override
  String get settingsValhallaAddress => 'Valhalla 服务地址';

  @override
  String get settingsValhallaHelper => '用于应用内步行路线规划。公开服务没有可用性保证。';

  @override
  String get settingsTestConnection => '测试连接';

  @override
  String get settingsTest => '测试';

  @override
  String get settingsTestValhallaConnection => '测试 Valhalla 连接';

  @override
  String get settingsRestoreDefaultValhalla => '恢复默认 Valhalla 地址';

  @override
  String get settingsValhallaPrivacy => '仅发送路线坐标，不会上传计划、作品或照片信息。';

  @override
  String get settingsBaseMapBrightness => '底图明暗';

  @override
  String get settingsFollowTheme => '跟随主题';

  @override
  String get settingsBaseMapBrightnessHint =>
      '适用于 OpenFreeMap；Dark 始终使用深色，其他地图源保留原始样式。';

  @override
  String get settingsCurrentLocation => '当前位置';

  @override
  String get settingsContinuousLocation => '持续更新当前位置';

  @override
  String get settingsContinuousLocationSubtitle => '开启定位后持续更新；关闭时仅在点击定位时获取一次。';

  @override
  String get settingsMapZoom => '地图缩放';

  @override
  String get settingsMaxZoom => '最大缩放倍率';

  @override
  String get settingsMaxZoomHint => '控制所有地图能够放大的最大级别。';

  @override
  String get settingsMapMarkers => '地图标记';

  @override
  String get settingsHideCompletedSpots => '隐藏已完成点位';

  @override
  String get settingsHideCompletedSpotsSubtitle =>
      '在地图页不显示已标记完成的点位。关闭后仍可在地图上看到全部点位。';

  @override
  String get settingsMarkerSize => '地图标记大小';

  @override
  String get settingsMarkerSizeSubtitle => '统一调整点位、缩略图、聚合标记、当前位置和片区关键点的大小。';

  @override
  String get settingsAreaRange => '片区范围';

  @override
  String get settingsAreaRadius => '片区范围半径';

  @override
  String get settingsAreaRadiusSubtitle => '每个点位向外扩张的距离，用于生成地图上的片区轮廓。';

  @override
  String get settingsSpotClustering => '地图点位聚合';

  @override
  String get settingsAutoCluster => '自动聚合密集点位';

  @override
  String get settingsAutoClusterSubtitle => '仅合并地图标记的显示；点位数据、选择和导入功能不受影响。';

  @override
  String get settingsClusterRadius => '聚合范围';

  @override
  String get settingsClusterRadiusSubtitle => '屏幕上相距较近的点位会合并为一个带数量的聚合标记。';

  @override
  String get settingsClusterMaxZoom => '停止聚合级别';

  @override
  String get settingsClusterMaxZoomSubtitle => '地图放大超过该级别后显示每个原始点位。';

  @override
  String get settingsMapThumbnails => '地图缩略图';

  @override
  String get settingsThumbnailThreshold => '缩略图显示阈值';

  @override
  String get settingsThumbnailThresholdHint => '阈值为 0 时不会在地图上显示缩略图。';

  @override
  String get settingsPlans => '计划';

  @override
  String get settingsPlansLoadFailed => '计划列表读取失败';

  @override
  String get settingsSelectPlans => '选择计划';

  @override
  String get settingsSelectAll => '全选';

  @override
  String get settingsClearSelection => '清空';

  @override
  String get settingsClearDownloadedReferenceCache => '清除下载的参考图缓存';

  @override
  String get settingsCacheScanFailed => '缓存扫描失败';

  @override
  String get settingsNoCacheToClear => '所选计划没有可清理的下载缓存';

  @override
  String get settingsClearReferenceCacheTitle => '清除参考图缓存？';

  @override
  String get settingsClear => '清除';

  @override
  String get settingsLauncher => '启动器';

  @override
  String get settingsAppInfo => '应用信息';

  @override
  String get settingsAppTagline => '动漫圣地巡礼计划与拍摄参考工具';

  @override
  String get settingsCurrentVersion => '当前版本';

  @override
  String get settingsLoading => '读取中';

  @override
  String get settingsAuthor => '作者';

  @override
  String get settingsSourceRepository => '开源仓库';

  @override
  String get settingsLicense => '开源许可';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsViewPrivacyPolicy => '查看隐私政策';

  @override
  String get settingsDataAndCopyright => '数据与版权';

  @override
  String get settingsMap => '地图';

  @override
  String get settingsMapDataDescription =>
      '可使用 OpenFreeMap、OpenStreetMap 或自定义地图服务。';

  @override
  String get settingsWorks => '作品';

  @override
  String get settingsWorksDataDescription => '作品搜索数据来自 Bangumi。';

  @override
  String get settingsPilgrimageContent => '巡礼内容';

  @override
  String get settingsPilgrimageContentDescription => '巡礼点位与参考图来自 Anitabi。';

  @override
  String get settingsImageSource => '图片源';

  @override
  String get settingsImageSourceDescription =>
      '图片源设置只影响访问域名，远端链接统一保留 Anitabi 默认格式。';

  @override
  String get settingsCopyright => '版权归属';

  @override
  String get settingsCopyrightDescription => '第三方数据、截图和图片版权归原平台、贡献者或权利方所有。';

  @override
  String get settingsAspectAuto => '自动';

  @override
  String get settingsAspectNative => '原生';

  @override
  String get settingsCustom => '自定义';

  @override
  String get settingsAspectWidescreen => '宽屏';

  @override
  String get settingsAspectCinema => '电影';

  @override
  String get settingsAspectClassic => '经典';

  @override
  String get settingsAspectCamera => '相机';

  @override
  String get settingsAspectPortrait => '竖屏';

  @override
  String get settingsAspectFullScreen => '全面屏';

  @override
  String get settingsAspectVertical => '竖幅';

  @override
  String get settingsAspectSquare => '方形';

  @override
  String get settingsAspectCustomShort => '自定';

  @override
  String get settingsDecrease => '减少';

  @override
  String get settingsIncrease => '增加';

  @override
  String get settingsCacheContents => '缓存内容';

  @override
  String get settingsFullReferenceCacheSubtitle =>
      '清除相机参考和大图查看使用的完整参考图。缩略图缓存会保留，以保持列表和地图加载速度。';

  @override
  String get settingsCustomAspectRatio => '自定义比例';

  @override
  String get settingsWidth => '宽';

  @override
  String get settingsHeight => '高';

  @override
  String get settingsEnterValidRatio => '请输入有效比例';

  @override
  String get settingsEnterColorName => '请输入颜色名称';

  @override
  String get settingsCustomThemeColor => '自定义主题色';

  @override
  String get settingsName => '名称';

  @override
  String get settingsColorCode => '色号';

  @override
  String get settingsAdd => '添加';

  @override
  String get settingsHueSaturation => '色相和饱和度';

  @override
  String get settingsBrightness => '明度';

  @override
  String get settingsSourceDefault => '默认';

  @override
  String get settingsSourceRemote => '远程配置';

  @override
  String get settingsProbeFailed => '失败';

  @override
  String get settingsNavDefault => '默认选项';

  @override
  String get settingsNavPopularInChina => '国内常用';

  @override
  String get settingsNavIosNative => 'iOS 原生';

  @override
  String get settingsNavCity => '城市导航';

  @override
  String get settingsNavGoogleDescription =>
      '导航按钮会通过 Google Maps 官方 Maps URL 打开步行路线。';

  @override
  String get settingsNavAppleDescription => '导航按钮会通过 Apple Map Links 打开步行路线。';

  @override
  String get settingsNavAmapDescription =>
      '导航按钮会通过高德 URI API 打开步行路线，并使用 WGS84 坐标。';

  @override
  String get settingsNavBaiduDescription =>
      '导航按钮会通过百度地图 URI API 打开步行路线，并使用 WGS84 坐标。';

  @override
  String get settingsMapRecommendedDefault => '推荐默认';

  @override
  String get settingsMapStandardTiles => '标准瓦片';

  @override
  String get settingsMapTileTemplate => '瓦片模板';

  @override
  String get settingsMapStyleUrl => '样式 URL';

  @override
  String get settingsAnitabiSummaryCustom => '已自定义，点击管理全部服务';

  @override
  String get settingsAnitabiSummaryRemote => '使用远程更新的地址，点击管理全部服务';

  @override
  String get settingsAnitabiSummaryDefault => '使用默认地址，点击管理全部服务';

  @override
  String get settingsImageSourceAuto => '自动选择';

  @override
  String get settingsImageSourceOfficial => '官方默认';

  @override
  String get settingsImageSourceMirror => '备用源';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicyLoading => '正在读取隐私政策...';

  @override
  String get privacyPolicyLoadFailed => '隐私政策读取失败';

  @override
  String get addPointsClipboardReadFailed => '无法读取剪贴板。';

  @override
  String get addPointsClipboardNoCoordinate => '剪贴板中没有有效坐标。';

  @override
  String get addPointsCoordinateFilled => '已填入坐标。';

  @override
  String get addPointsTitle => '添加内容';

  @override
  String get addPointsRoutePlannerLead => '点位很多、懒得逐个整理？';

  @override
  String get addPointsManualEntryReference => '手动录入';

  @override
  String get addPointsPointSaveFailed => '点位保存失败，请稍后重试。';

  @override
  String addPointsWorkAdded(String title) {
    return '已添加「$title」。';
  }

  @override
  String get addPointsWorkAddFailed => '作品添加失败，请稍后重试。';

  @override
  String get addPointsSearchBangumiTitle => '搜索 Bangumi';

  @override
  String get addPointsWorkNameLabel => '作品名称';

  @override
  String get addPointsWorkNameSearchHint => '例如：轻音少女';

  @override
  String get addPointsClearSearch => '清空搜索';

  @override
  String get addPointsSearching => '搜索中';

  @override
  String get addPointsSearchWorks => '搜索作品';

  @override
  String get addPointsBangumiSearchFailed => 'Bangumi 搜索失败，请检查网络后重试。';

  @override
  String get addPointsFilterWorkTypes => '筛选作品类型';

  @override
  String addPointsSelectedTypeCount(int count) {
    return '已选 $count 项';
  }

  @override
  String get addPointsLinkClipboardReadFailed => '无法读取剪贴板，请手动粘贴 Anitabi 链接。';

  @override
  String get addPointsLinkClipboardEmpty => '剪贴板中没有可用的 Anitabi 链接。';

  @override
  String get addPointsLinkImportTitle => 'Anitabi 链接导入';

  @override
  String addPointsAddingTo(String planName) {
    return '加入到：$planName';
  }

  @override
  String get addPointsAnitabiLinkLabel => 'Anitabi 链接';

  @override
  String get addPointsAnitabiLinkHint => '粘贴 Anitabi 作品或点位链接';

  @override
  String get addPointsClearInput => '清除搜索框';

  @override
  String get addPointsPaste => '粘贴';

  @override
  String get addPointsOpenAnitabiSpots => '打开 Anitabi 点位';

  @override
  String get addPointsLinkRequired => '请输入 Anitabi 链接';

  @override
  String get addPointsLinkInvalid => '请输入有效的 Anitabi 地图链接';

  @override
  String get addPointsLinkMissingWorkId => '链接缺少作品 ID，请先在 Anitabi 进入对应作品后复制链接';

  @override
  String get addPointsLinkExampleTitle => '有效链接示例';

  @override
  String get addPointsLinkExampleBody =>
      '如果链接里包含作品 ID，会只加载对应作品；\n如果还包含点位 ID，会自动选中该点位。\n没有作品 ID 的链接需要先在 Anitabi 中进入对应作品后重新复制。';

  @override
  String get addPointsLinkExampleBangumiIdNote => 'Bangumi 作品 ID（必须）';

  @override
  String get addPointsLinkExampleSpotIdNote => 'Anitabi 点位 ID（可选）';

  @override
  String get addPointsWorkSaveFailed => '作品保存失败，请稍后重试。';

  @override
  String get addPointsManualAddWork => '手动添加作品';

  @override
  String get addPointsFillingGuide => '填写指南';

  @override
  String get addPointsWorkNameHint => '请输入作品的中文名称';

  @override
  String get addPointsOriginalTitleLabel => '作品原名';

  @override
  String get addPointsOriginalTitleHint => '请输入作品的原名（如日文/英文）';

  @override
  String get addPointsWorkTypeLabel => '作品类型';

  @override
  String get addPointsMainRegionLabel => '主要地区';

  @override
  String get addPointsMainRegionHint => '输入作品主要发生或取景的地区';

  @override
  String get addPointsSaving => '保存中';

  @override
  String get addPointsSaveWork => '保存作品';

  @override
  String get addPointsFieldRequired => '请填写此项';

  @override
  String get addPointsPointGuideTitle => '点位填写指南';

  @override
  String get addPointsPointGuideIntro => '重点记录现场可识别的信息，方便到达后快速确认位置、场景和拍摄条件。';

  @override
  String get addPointsWorkLabel => '所属作品';

  @override
  String get addPointsBadgeRequired => '必填';

  @override
  String get addPointsBadgeOptional => '选填';

  @override
  String get addPointsBadgeCoordinatesRequired => '坐标必填';

  @override
  String get addPointsPointGuideWorkBody =>
      '选择点位对应的作品。计划中还没有作品时，先填写作品名称、原名和主要地区。';

  @override
  String get addPointsGuideWorkExample => '轻音少女';

  @override
  String get addPointsGuideNameLocationTitle => '名称与位置说明';

  @override
  String get addPointsGuideNameLocationBody =>
      '名称优先填写中文常用名；位置说明优先填写当地原语言的地标、建筑或店铺名称，方便现场核对。';

  @override
  String get addPointsGuideNameLocationExample => '东京国际会展中心 / 東京ビッグサイト';

  @override
  String get addPointsGuideSceneSourceTitle => '场景标签与参考来源';

  @override
  String get addPointsGuideSceneSourceBody =>
      '场景标签只写集数、时间点或场景编号；参考来源填写该点位原来所在的平台，或原始上传者。';

  @override
  String get addPointsGuideSceneSourceExample =>
      'EP 1 / 12:32\n示例：小红书@BilyHurington / Bilibili@麦块晓天';

  @override
  String get addPointsNotesLabel => '备注';

  @override
  String get addPointsGuideNotesBody => '记录营业时间、闭店翻修、拍摄限制、推荐机位或其他到访前需要知道的信息。';

  @override
  String get addPointsGuideNotesExample => '2025年完成翻修；最佳拍摄时间为上午；周末游客较多；';

  @override
  String get addPointsGuideCoordinateImageTitle => '坐标与参考图';

  @override
  String get addPointsGuideCoordinateImageBody =>
      '优先从地图选择准确位置，也可粘贴纬度、经度。参考图建议使用能清楚辨认构图的原始画面。';

  @override
  String get addPointsGuideCheckMarkerTip =>
      '保存前建议核对地图标记是否落在正确建筑或道路一侧；坐标偏差会直接影响导航和现场查找。';

  @override
  String get addPointsGuideGotIt => '知道了';

  @override
  String get addPointsWorkGuideTitle => '作品填写指南';

  @override
  String get addPointsWorkGuideIntro => '填写作品本身的信息，点位名称、场景说明和具体地址请在添加点位时录入。';

  @override
  String get addPointsWorkGuideNameBody => '填写常用中文译名或最容易辨认的名称，不要填写集数或具体场景名。';

  @override
  String get addPointsWorkGuideOriginalTitleBody =>
      '可填写官方日文、英文或其他原始标题；没有可靠信息时可以留空。';

  @override
  String get addPointsWorkGuideTypeBody => '选择最接近作品发行形式的类型，方便在作品列表中辨认和筛选。';

  @override
  String get addPointsGuideWorkTypeExample => '动画';

  @override
  String get addPointsWorkGuideRegionBody =>
      '填写主要发生地或取景城市，可使用“城市 / 区域”的简洁格式；留空时沿用当前计划地区。';

  @override
  String get addPointsWorkGuideRegionExample => '京都市 / 宇治市';

  @override
  String get addPointsWorkGuideFooter =>
      '保存作品后，表单会清空以便继续添加。作品不会自动生成点位，可随后使用“手动添加点位”录入巡礼地点。';

  @override
  String addPointsGuideExample(String example) {
    return '示例：$example';
  }

  @override
  String get addPointsLatitudeAlsoRequired => '请同时填写纬度';

  @override
  String get addPointsLongitudeAlsoRequired => '请同时填写经度';

  @override
  String get addPointsLatitudeInvalid => '纬度格式不正确';

  @override
  String get addPointsLongitudeInvalid => '经度格式不正确';

  @override
  String get addPointsQuickManualAddPoint => '快速手动添加点位';

  @override
  String get addPointsSelectWorkRequired => '请选择作品';

  @override
  String get addPointsPointNameLabel => '点位名称';

  @override
  String get addPointsPointNameHint => '例如：东京国际会展中心';

  @override
  String get addPointsCoordinateLabel => '坐标位置';

  @override
  String get addPointsLatitude => '纬度';

  @override
  String get addPointsLongitude => '经度';

  @override
  String get addPointsLatitudeHint => '例如：35.712576';

  @override
  String get addPointsLongitudeHint => '例如：139.722166';

  @override
  String get addPointsPickFromMap => '从地图选择';

  @override
  String get addPointsPickFromMapShort => '地图选择';

  @override
  String get addPointsPickFromMapSemantic => '从地图选择坐标';

  @override
  String get addPointsPasteCoordinates => '粘贴剪贴板坐标';

  @override
  String get addPointsSavePoint => '保存点位';

  @override
  String get addPointsQuickGuideTitle => '快速添加填写指南';

  @override
  String get addPointsQuickGuideIntro =>
      '先录入最基本的信息，之后可从点位编辑页继续补充位置说明、场景标签、参考来源、备注和参考图。';

  @override
  String get addPointsQuickGuideWorkBody =>
      '选择点位对应的已有作品。若列表中没有目标作品，请先返回添加内容页添加作品。';

  @override
  String get addPointsQuickGuideNameBody => '填写便于识别和搜索的中文常用名称，后续可在编辑页修改。';

  @override
  String get addPointsGuidePointNameExample => '东京国际会展中心';

  @override
  String get addPointsQuickGuideCoordinateBody =>
      '暂时不知道准确位置时可以留空；填写时需同时提供纬度和经度，也可从地图选择或粘贴坐标。';

  @override
  String get addPointsSaveUnconfirmed => '保存结果未确认，请返回并刷新计划，检查点位是否已添加。';

  @override
  String get addPointsReferenceImageReadFailed => '参考图读取失败，请重新选择。';

  @override
  String get addPointsEditPoint => '编辑点位';

  @override
  String get addPointsManualAddPoint => '手动添加点位';

  @override
  String addPointsEditing(String name) {
    return '修改：$name';
  }

  @override
  String get addPointsLocationNoteLabel => '位置说明';

  @override
  String get addPointsLocationNoteHint => '例如：東京ビッグサイト';

  @override
  String get addPointsSceneTagLabel => '集数/场景标签';

  @override
  String get addPointsSceneTagHint => '例如：EP 1 / 12:32';

  @override
  String get addPointsReferenceSourceLabel => '参考来源';

  @override
  String get addPointsReferenceSourceHint =>
      '例如：小红书@BilyHurington / Bilibili@麦块晓天';

  @override
  String get addPointsNotesHint => '例如：2025年完成翻修；最佳拍摄时间为上午；周末游客较多';

  @override
  String get addPointsSaveChanges => '保存修改';

  @override
  String get addPointsLatitudeRequired => '请填写纬度';

  @override
  String get addPointsLongitudeRequired => '请填写经度';

  @override
  String get addPointsCoordinateInvalid => '请输入有效坐标';

  @override
  String get addPointsPickCoordinateTitle => '选择点位坐标';

  @override
  String get addPointsExitMapPick => '关闭地图选点';

  @override
  String get addPointsStartMapPick => '在地图上选点';

  @override
  String get addPointsMapPickHint => '点击地图任意位置设置点位坐标';

  @override
  String get addPointsMapPickIdleHint => '先点击右上角选点按钮，再点击地图设置坐标';

  @override
  String addPointsMapAdjustHint(String coordinates) {
    return '点击地图可继续调整位置\n$coordinates';
  }

  @override
  String get addPointsMapPickTitle => '地图选点';

  @override
  String get addPointsUse => '使用';

  @override
  String get addPointsLinkedWorks => '已关联作品';

  @override
  String addPointsLinkedWorksSummary(int workCount, int pointCount) {
    return '共 $workCount 部作品，$pointCount 个点位';
  }

  @override
  String get addPointsManageWorks => '管理作品';

  @override
  String get addPointsNoLinkedWorks => '还没有关联作品，可从 Bangumi 搜索或手动添加。';

  @override
  String get addPointsAddFromBangumi => '从Bangumi添加';

  @override
  String get addPointsAddFromBangumiSubtitle => '自动获取信息';

  @override
  String get addPointsManualAddWorkSubtitle => '未收录时使用';

  @override
  String get addPointsViewFullImage => '查看大图';

  @override
  String get addPointsNoReferenceImage => '暂无参考图';

  @override
  String get addPointsReferenceImageLabel => '参考图片';

  @override
  String get addPointsReferenceImagePending => '已选择新图片，保存后生效。';

  @override
  String get addPointsReferenceImageCurrent => '当前参考图，重新选择后需保存才会生效。';

  @override
  String get addPointsReferenceImageOptional => '可选，保存时会复制到 App 本地目录。';

  @override
  String get addPointsReselectImage => '重新选择';

  @override
  String get addPointsUploadReferenceImage => '上传参考图';

  @override
  String get addPointsRemoveImage => '移除';

  @override
  String get addPointsAdded => '已添加';

  @override
  String get addPointsAdd => '加入';

  @override
  String get addPointsSearchHelpTitle => '搜索说明';

  @override
  String get addPointsSearchHelpBody => '输入作品名后搜索，选择结果即可加入当前计划。';

  @override
  String get addPointsBangumiNetworkNote => 'Bangumi需要国际网络环境才能正常搜索。';

  @override
  String get addPointsRecommended => '推荐';

  @override
  String get addPointsQuickManualSubtitle => '只填写作品、名称和可选坐标';

  @override
  String get addPointsAddWorkFirst => '请先添加作品';

  @override
  String get addPointsManualAddPointSubtitle => '手动输入点位信息，逐个添加';

  @override
  String get groupAnchorPickerTitle => '选择关键点';

  @override
  String get groupAnchorPickerExitMapPick => '关闭地图点选';

  @override
  String get groupAnchorPickerStartMapPick => '在地图上选点';

  @override
  String get groupAnchorPickerEnterCoordinates => '输入经纬度';

  @override
  String get groupAnchorPickerClearSelection => '清除选点';

  @override
  String get groupAnchorPickerClearMessage => '将清除当前选择的关键点，可继续在本页重新选择。';

  @override
  String get groupAnchorPickerManualAnchor => '手动关键点';

  @override
  String get groupAnchorPickerSelectPoint => '选择点位';

  @override
  String get groupAnchorPickerNoneSelected => '尚未选择关键点';

  @override
  String get groupAnchorPickerMapPickHint => '点击地图任意位置设置关键点';

  @override
  String get groupAnchorPickerIdleHint => '可点选点位、地图或输入经纬度';

  @override
  String pointManagerSelectedCount(int count) {
    return '已选 $count';
  }

  @override
  String get pointManagerGroupManagement => '片区管理';

  @override
  String get pointManagerMoveGroupFailed => '移动片区失败';

  @override
  String get pointManagerMoveToGroup => '移动到片区';

  @override
  String get pointManagerMoveToGroupSubtitle => '选择一个片区作为当前点位所属片区';

  @override
  String get pointManagerNotInGroup => '未分入片区';

  @override
  String get pointManagerPointOrderSaveFailed => '点位顺序保存失败';

  @override
  String get pointManagerBatchDeleteTitle => '批量删除点位';

  @override
  String pointManagerBatchDeleteMessage(String countText) {
    return '将从计划中删除 $countText。';
  }

  @override
  String pointManagerSpotCount(int count) {
    return '$count 个点位';
  }

  @override
  String get pointManagerBatchDeleteFailed => '批量删除失败';

  @override
  String get pointManagerNearestAssign => '最近分配';

  @override
  String get pointManagerBoxAssign => '框选分配';

  @override
  String get pointManagerSelectAll => '全选';

  @override
  String get pointManagerMove => '移动';

  @override
  String get coordinateInputClipboardReadFailed => '无法读取剪贴板。';

  @override
  String get coordinateInputClipboardNoCoordinate => '剪贴板中没有可识别的坐标。';

  @override
  String get coordinateInputInvalid => '请输入有效经纬度';

  @override
  String get coordinateInputTitle => '输入经纬度';

  @override
  String get coordinateInputLatitude => '纬度';

  @override
  String get coordinateInputLongitude => '经度';

  @override
  String get coordinateInputConfirm => '确定';

  @override
  String get planGroupUtilsOrderPending => '待整理';

  @override
  String get planGroupUtilsOrderManual => '手动';

  @override
  String get planGroupUtilsOrderUnordered => '无序';

  @override
  String get planGroupUtilsAwaitingGroup => '等待分入片区';

  @override
  String get planGroupUtilsAnchorUnset => '未设置关键点';

  @override
  String planGroupUtilsAnchor(String name) {
    return '关键点：$name';
  }

  @override
  String get planGroupUtilsUngrouped => '未分组';

  @override
  String get planGroupPickerTitle => '选择区域';

  @override
  String planGroupPickerCount(int count) {
    return '共 $count 个区域';
  }

  @override
  String get planGroupPickerNewGroup => '新建片区';

  @override
  String get planManagerSwitchFailed => '切换计划失败，请稍后重试。';

  @override
  String get planManagerDeletePlan => '删除计划';

  @override
  String get planManagerCopyFailed => '复制计划失败，请稍后重试。';

  @override
  String get planManagerSaveOrderFailed => '保存计划顺序失败，已恢复原来的顺序。';

  @override
  String get planManagerReorderTitle => '调整计划顺序';

  @override
  String get planManagerTitle => '计划列表';

  @override
  String get planManagerDoneSorting => '完成排序';

  @override
  String get planManagerSortPlans => '计划排序';

  @override
  String get planManagerSkillLead => '不想手动整理点位？';

  @override
  String get planManagerAllPlans => '全部计划';

  @override
  String get planManagerEditInfo => '编辑计划信息';

  @override
  String get planManagerPlanName => '计划名称';

  @override
  String get planManagerNewPlan => '新建计划';

  @override
  String get planManagerPlanInfo => '计划信息';

  @override
  String get planManagerNoWorks => '暂无作品';

  @override
  String get planManagerCurrentPlan => '当前计划';

  @override
  String get planManagerDragSort => '拖动排序';

  @override
  String get planManagerMoreActions => '更多计划操作';

  @override
  String get planManagerImportExport => '导入导出';

  @override
  String get planManagerCopyPlan => '复制计划';

  @override
  String get planManagerReload => '重新加载计划';

  @override
  String planManagerNewPlanName(int number) {
    return '新巡礼计划 $number';
  }

  @override
  String planManagerDeleteMessage(String name) {
    return '将删除「$name」及其中的点位、片区、作品和巡礼记录。只属于这个计划的巡礼照片、调色图和参考图文件也会一并删除；其他计划或记录仍在使用的文件会保留。';
  }

  @override
  String planManagerCopyName(String name) {
    return '$name 副本';
  }

  @override
  String planManagerCopied(String name) {
    return '已复制「$name」';
  }

  @override
  String planManagerPlanSummary(int spotCount, int workCount) {
    return '$spotCount 个点位  /  $workCount 部作品';
  }

  @override
  String get planMemoUnsavedChanges => '未保存的修改';

  @override
  String planMemoImageUnsupported(String label) {
    return '备忘录不支持图片：$label';
  }

  @override
  String get planMemoDiscardTitle => '放弃未保存内容？';

  @override
  String get planMemoDiscardMessage => '当前备忘录还有未保存的修改。';

  @override
  String get planMemoDiscard => '放弃';

  @override
  String get planMemoKeepEditing => '继续编辑';

  @override
  String get planMemoDiscardNotice => '未保存的修改不会被保留';

  @override
  String get planMemoSavingWait => '正在保存备忘录，请稍候';

  @override
  String get planMemoSavedEditsPending => '已保存，后续输入仍待保存';

  @override
  String get planMemoSaved => '计划备忘录已保存';

  @override
  String get planMemoSaveFailed => '计划备忘录保存失败';

  @override
  String get planMemoTaskSaveFailed => '待办状态保存失败';

  @override
  String get planMemoHeading => '标题';

  @override
  String get planMemoBoldPlaceholder => '加粗文字';

  @override
  String get planMemoListPlaceholder => '列表项';

  @override
  String get planMemoTaskPlaceholder => '待办事项';

  @override
  String get planMemoQuotePlaceholder => '引用内容';

  @override
  String get planMemoLinkPlaceholder => '链接文字';

  @override
  String get planMemoCode => '代码';

  @override
  String get planMemoInvalidLink => '链接格式不正确';

  @override
  String get planMemoOpenLinkFailed => '无法打开链接';

  @override
  String get planMemoTitle => '计划备忘录';

  @override
  String get planMemoEdit => '编辑';

  @override
  String get planMemoContent => '备忘录内容';

  @override
  String get planMemoHint => '可以记录交通、预约、补拍事项、同行安排等。';

  @override
  String get planMemoBold => '加粗';

  @override
  String get planMemoList => '列表';

  @override
  String get planMemoTask => '待办';

  @override
  String get planMemoQuote => '引用';

  @override
  String get planMemoDivider => '分割线';

  @override
  String get planMemoLink => '链接';

  @override
  String get planMemoUncheck => '取消勾选';

  @override
  String get planMemoMarkDone => '标记完成';

  @override
  String get planMemoSuggestTransport => '交通安排';

  @override
  String get planMemoSuggestTransportDetail => '如车次、换乘方案、出发时间等';

  @override
  String get planMemoSuggestHotel => '酒店预约';

  @override
  String get planMemoSuggestHotelDetail => '酒店地址、入住时间、联系方式等';

  @override
  String get planMemoSuggestTickets => '活动门票';

  @override
  String get planMemoSuggestTicketsDetail => '活动门票、预约时间、注意事项等';

  @override
  String get planMemoSuggestShooting => '拍摄计划';

  @override
  String get planMemoSuggestShootingDetail => '拍摄地点、时间、天气备选方案等';

  @override
  String get planMemoSuggestNotes => '注意事项';

  @override
  String get planMemoSuggestNotesDetail => '携带物品、预算、当地注意事项等';

  @override
  String get planMemoEmptyTitle => '还没有计划备忘';

  @override
  String get planMemoEmptyBody => '记录本次巡礼的重要事项';

  @override
  String get planMemoSuggestionsTitle => '可记录内容';

  @override
  String get planMemoStart => '开始记录';

  @override
  String nearestGroupAssignUngroupedSpots(int count) {
    return '$count 个未分组点位';
  }

  @override
  String nearestGroupAssignConfirmMessage(String spots, String distance) {
    return '将把 $spots分配到最近的片区关键点，最大距离为 $distance。';
  }

  @override
  String nearestGroupAssignDone(int count) {
    return '已分配 $count 个点位';
  }

  @override
  String nearestGroupAssignDoneDistanceUnsaved(int count) {
    return '已分配 $count 个点位，距离设置未保存';
  }

  @override
  String nearestGroupAssignBoxConfirmMessage(String spots, String area) {
    return '将把 $spots移动到「$area」。';
  }

  @override
  String nearestGroupAssignAreaCount(int count) {
    return '共 $count 个片区';
  }

  @override
  String nearestGroupAssignBoxStatus(int selected, int ungrouped) {
    return '已框选 $selected / 待分配 $ungrouped';
  }

  @override
  String nearestGroupAssignMaxDistance(String distance) {
    return '最大距离 $distance';
  }

  @override
  String nearestGroupAssignAssignableCount(int assignable, int ungrouped) {
    return '可分配 $assignable/$ungrouped';
  }

  @override
  String nearestGroupAssignCurrentDistance(String distance) {
    return '当前 $distance';
  }

  @override
  String get nearestGroupAssignInRange => '在最大距离范围内';

  @override
  String get nearestGroupAssignOutOfRange => '超出最大距离';

  @override
  String nearestGroupAssignUngroupedHint(int count) {
    return '未分组 $count 个 · 点击地图点位查看详情';
  }

  @override
  String get nearestGroupAssignTitle => '最近分配';

  @override
  String get nearestGroupAssignNoneInRange => '当前距离内没有可分配点位';

  @override
  String get nearestGroupAssignConfirmTitle => '确认最近分配';

  @override
  String get nearestGroupAssignStart => '开始分配';

  @override
  String get nearestGroupAssignFailed => '最近分配失败';

  @override
  String get nearestGroupAssignFinishFirst => '请先完成片区分配';

  @override
  String get nearestGroupAssignBoxTitle => '框选分配';

  @override
  String get nearestGroupAssignBoxSelected => '已框选';

  @override
  String get nearestGroupAssignNotBoxSelected => '未框选';

  @override
  String get nearestGroupAssignCreateAreaFailed => '片区创建失败';

  @override
  String get nearestGroupAssignCreateAreaFirst => '请先创建片区';

  @override
  String get nearestGroupAssignBoxNoUngrouped => '框选范围内没有未分组点位';

  @override
  String get nearestGroupAssignBoxConfirmTitle => '确认框选分配';

  @override
  String get nearestGroupAssignAssign => '分配';

  @override
  String get nearestGroupAssignBoxFailed => '框选分配失败';

  @override
  String get nearestGroupAssignChooseArea => '选择片区';

  @override
  String get nearestGroupAssignNewArea => '新建片区';

  @override
  String get nearestGroupAssignAreaNameEmpty => '片区名不能为空';

  @override
  String get nearestGroupAssignAreaName => '片区名称';

  @override
  String get nearestGroupAssignCreate => '创建';

  @override
  String get nearestGroupAssignEndBox => '结束框选';

  @override
  String get nearestGroupAssignBox => '框选';

  @override
  String get nearestGroupAssignEnd => '结束';

  @override
  String get nearestGroupAssignStartBox => '开始框选';

  @override
  String get nearestGroupAssignAssigning => '分配中';

  @override
  String get nearestGroupAssignAssigningSpots => '正在分配';

  @override
  String get nearestGroupAssignAssignSelected => '分配选中点位';

  @override
  String get nearestGroupAssignExplain => '未分组点位会分配到距离最近、且在最大距离范围内的片区关键点。';

  @override
  String get nearestGroupAssignNoAnchor => '没有可用片区关键点';

  @override
  String get nearestGroupAssignSetAnchorFirst => '请先在片区管理中设置关键点';

  @override
  String get nearestGroupAssignAssignableSpot => '可分配点位';

  @override
  String get nearestGroupAssignOutOfRangeSpot => '距离外点位';

  @override
  String planCacheFullImageCount(int count) {
    return '$count 张';
  }

  @override
  String planCacheFullReferencesMessage(String images) {
    return '将缓存当前计划中 $images完整参考图，可能需要较长时间和网络流量。';
  }

  @override
  String planAreaProgress(
    String anchor,
    int completed,
    int total,
    String order,
  ) {
    return '$anchor · $completed/$total 完成 · $order';
  }

  @override
  String planSummary(int spotCount, String works) {
    return '$spotCount 个点位 / $works';
  }

  @override
  String planWorkCount(int count) {
    return '$count 部作品';
  }

  @override
  String get planAddSpots => '添加点位';

  @override
  String get planHideActions => '收起计划操作';

  @override
  String get planShowActions => '展开计划操作';

  @override
  String get planCreateAreaFailed => '片区创建失败，请稍后重试。';

  @override
  String get planNoReferencesToCache => '当前计划没有需要缓存的参考图';

  @override
  String get planCacheFullReferencesTitle => '缓存完整参考图';

  @override
  String get planStartCaching => '开始缓存';

  @override
  String get planCacheWifiNotice => '建议在 Wi-Fi 环境下进行缓存';

  @override
  String get planNewArea => '新建片区';

  @override
  String get planAreaName => '片区名称';

  @override
  String get planCreate => '创建';

  @override
  String get planSwitchPlan => '计划列表';

  @override
  String get planCacheReferences => '缓存参考图';

  @override
  String get planActionMemo => '计划备忘录';

  @override
  String get planActionImportExport => '导入导出';

  @override
  String get planPreviousArea => '上一个片区';

  @override
  String get planNextArea => '下一个片区';

  @override
  String get planHideMap => '收起地图';

  @override
  String get planMap => '地图';

  @override
  String get planSortDefaultOrder => '默认计划顺序';

  @override
  String get planSortByDistanceFromHere => '按距离当前位置';

  @override
  String get planSortDefault => '默认计划';

  @override
  String get planSortDistance => '按距离';

  @override
  String get planSortReversed => '反序';

  @override
  String get planSortForward => '正序';

  @override
  String get planSortFarToNear => '远到近';

  @override
  String get planSortNearToFar => '近到远';

  @override
  String get planHideLocation => '隐藏当前位置';

  @override
  String get planShowLocation => '显示当前位置';

  @override
  String get planNoSpotsYet => '还没有点位';

  @override
  String get planOnboardingSpotsTitle => '选点位';

  @override
  String get planOnboardingSpotsBody => '在地图上点选点位并导入，作品会自动加入这个计划。';

  @override
  String get planUndoCheckIn => '撤回打卡';

  @override
  String get planComplete => '完成';

  @override
  String get planShootReference => '拍摄参考';

  @override
  String anitabiMapImportAddAllMessage(int count) {
    return '将把当前作品中 $count 个还不在计划里的点位加入计划，并暂时放在未分组。';
  }

  @override
  String anitabiMapImportImporting(int count) {
    return '正在导入 $count 个点位...';
  }

  @override
  String anitabiMapImportCachingThumbnails(
    int processed,
    int total,
    int succeeded,
  ) {
    return '正在缓存缩略图 $processed/$total，成功 $succeeded';
  }

  @override
  String anitabiMapImportImportedPartialCache(int count, int cached) {
    return '已导入 $count 个点位，缩略图缓存 $cached/$count，其余稍后会自动补齐。';
  }

  @override
  String get anitabiMapImportBoxHint => '在地图上拖出一个框来选择点位';

  @override
  String anitabiMapImportBoxCount(int count, int newCount) {
    return '$count 个点位 · $newCount 个新点位';
  }

  @override
  String get anitabiMapImportBoxChooseArea => '选择片区';

  @override
  String get anitabiMapImportBoxAreaSubtitle => '新点位会导入到这个片区，已在计划里的点位会移到这里';

  @override
  String get anitabiMapImportBoxApply => '放入片区';

  @override
  String anitabiMapImportAssigned(int count, String area) {
    return '已将 $count 个点位分配到「$area」';
  }

  @override
  String anitabiMapImportDetailPartial(int loaded, int expected) {
    return '当前只取得 $loaded / 共 $expected 个点位。请重新加载，或检查网络是否能访问 Anitabi 地图数据。';
  }

  @override
  String anitabiMapImportSpotCount(int count) {
    return '$count 个点位';
  }

  @override
  String anitabiMapImportShownCount(int imported, int shown) {
    return '已导入 $imported / 当前显示 $shown';
  }

  @override
  String anitabiMapImportShownCountOfTotal(int imported, int shown, int total) {
    return '已导入 $imported / 当前显示 $shown / 共 $total';
  }

  @override
  String anitabiMapImportOpenAppFailed(String app) {
    return '无法打开$app。';
  }

  @override
  String anitabiMapImportNoImageSpots(int count) {
    return '当前作品共有 $count 个点位，但没有可导入的带图参考点位。';
  }

  @override
  String anitabiMapImportWorkNoSpots(String title) {
    return '「$title」暂无可导入的 Anitabi 点位。';
  }

  @override
  String get anitabiMapImportSettingsSaveFailed => '设置保存失败';

  @override
  String get anitabiMapImportTryLater => '请稍后重试';

  @override
  String get anitabiMapImportClearingCache => '正在清除缓存并重新加载 Anitabi 点位...';

  @override
  String get anitabiMapImportManualWorkNoId =>
      '手动添加的作品没有 Bangumi ID，无法从 Anitabi 地图导入点位。';

  @override
  String get anitabiMapImportManualWorkState =>
      '手动添加的作品没有 Bangumi ID，无法从 Anitabi 地图导入点位。\n\n请通过 Bangumi/Anitabi 搜索添加作品，或使用手动添加点位。';

  @override
  String get anitabiMapImportAddedContinue => '已加入计划，可继续选择点位。';

  @override
  String get anitabiMapImportSpotImportFailed => '点位导入失败，请稍后重试。';

  @override
  String get anitabiMapImportAddAll => '添加所有点位';

  @override
  String get anitabiMapImportAddAllConfirm => '添加全部';

  @override
  String get anitabiMapImportAddedAll => '已添加所有未加入的点位。';

  @override
  String get anitabiMapImportBulkFailed => '批量导入失败，请稍后重试。';

  @override
  String get anitabiMapImportAddedBox => '已添加框选点位。';

  @override
  String get anitabiMapImportBoxFailed => '框选点位导入失败，请稍后重试。';

  @override
  String get anitabiMapImportOrganizeOpenFailed =>
      '点位已导入，但整理流程打开失败，可以稍后在计划中调整片区。';

  @override
  String get anitabiMapImportAssignToArea => '分配到片区';

  @override
  String get anitabiMapImportAssignToAreaSubtitle => '选择一个片区作为刚导入点位的所属片区';

  @override
  String get anitabiMapImportNotInArea => '未分入片区';

  @override
  String get anitabiMapImportSelectedArea => '所选片区';

  @override
  String get anitabiMapImportAssignFailed => '点位分配失败，请稍后重试。';

  @override
  String get anitabiMapImportCreateAreaFailed => '片区创建失败，请稍后重试。';

  @override
  String get anitabiMapImportThumbnailMarkers => '缩略图标记';

  @override
  String get anitabiMapImportOnlyNotAdded => '只看未加入';

  @override
  String get anitabiMapImportOnlyNotAddedDesc => '隐藏已加入计划的点位';

  @override
  String get anitabiMapImportAreaBounds => '片区范围';

  @override
  String get anitabiMapImportAreaBoundsDesc => '显示计划中已有的片区';

  @override
  String get anitabiMapImportClustering => '自动聚合密集点位';

  @override
  String get anitabiMapImportAnitabiSpot => 'Anitabi 点位';

  @override
  String get anitabiMapImportTitle => '从作品地图导入';

  @override
  String get anitabiMapImportLayers => '图层';

  @override
  String get anitabiMapImportClearCacheReload => '清除缓存并重新加载 Anitabi 点位';

  @override
  String get anitabiMapImportAdded => '已加入';

  @override
  String get anitabiMapImportErrorDataUnavailable => 'Anitabi 地图数据无法加载';

  @override
  String get anitabiMapImportErrorWorkNotFound => 'Anitabi 中没有找到这个作品';

  @override
  String get anitabiMapImportErrorNoPoints => '当前作品暂无 Anitabi 点位';

  @override
  String get anitabiMapImportErrorPartial => 'Anitabi 点位只加载到一部分';

  @override
  String get anitabiMapImportError404 => '这个 Bangumi 条目暂无 Anitabi 地图数据';

  @override
  String get anitabiMapImportErrorPointNotFound => '没有找到这个 Anitabi 点位';

  @override
  String get anitabiMapImportErrorGeneric => 'Anitabi 点位加载失败';

  @override
  String get anitabiMapImportDetailDataUnavailableWeb =>
      '可能是 Anitabi 地图数据缓存版本不一致，或当前预览服务网络请求被拦截。请清除缓存并重新加载 Anitabi 点位。';

  @override
  String get anitabiMapImportDetailDataUnavailable =>
      '无法读取 Anitabi 地图索引。请检查网络连接，或清除缓存并重新加载 Anitabi 点位。';

  @override
  String get anitabiMapImportDetailWorkNotFound =>
      '这个 Bangumi 条目在 Anitabi 地图数据中没有对应作品。可以尝试添加同名动画、原作或其它关联条目。';

  @override
  String get anitabiMapImportDetailNoPoints =>
      'Anitabi 中能找到这个作品，但当前还没有可导入的地图点位。';

  @override
  String get anitabiMapImportDetail404 => '可以尝试在作品管理中添加同名的原作、游戏或其他关联条目。';

  @override
  String get anitabiMapImportDetailPointNotFound =>
      '链接里的点位 ID 可能已失效，或 Anitabi 地图数据尚未同步。';

  @override
  String get anitabiMapImportDetailGeneric => '请检查网络后重试，或稍后再重新加载。';

  @override
  String get anitabiMapImportOrganizeTitle => '整理刚导入的点位';

  @override
  String get anitabiMapImportOrganizeLead => '已导入 ';

  @override
  String get anitabiMapImportOrganizeTail => '，并暂时放在未分组。可以直接分配到片区，或按最近关键点快速分配。';

  @override
  String get anitabiMapImportNearestAssign => '最近分配';

  @override
  String get anitabiMapImportLater => '稍后';

  @override
  String get anitabiMapImportAreaNameEmpty => '片区名不能为空';

  @override
  String get anitabiMapImportNewArea => '新建片区';

  @override
  String get anitabiMapImportAreaName => '片区名称';

  @override
  String get anitabiMapImportCreate => '创建';

  @override
  String get anitabiMapImportImportedSpot => '已导入点位';

  @override
  String get anitabiMapImportImportableSpot => '可导入点位';

  @override
  String get anitabiMapImportLoadingSpots => '正在加载 Anitabi 点位';

  @override
  String get anitabiMapImportExitBox => '退出框选';

  @override
  String get anitabiMapImportBoxSelect => '框选点位';

  @override
  String get anitabiMapImportSpotName => '点位名称';

  @override
  String get anitabiMapImportSpotInfo => '点位信息';

  @override
  String get anitabiMapImportSource => '来源';

  @override
  String get anitabiMapImportNavigate => '导航';

  @override
  String get anitabiMapImportOpenNavigation => '打开导航';

  @override
  String get anitabiMapImportInPlan => '已加入计划';

  @override
  String get anitabiMapImportAddToPlan => '加入计划';

  @override
  String get anitabiMapImportAddShort => '加入';

  @override
  String get anitabiMapImportScene => '场景';

  @override
  String get anitabiMapImportNote => '备注';

  @override
  String get anitabiMapImportCoordinates => '坐标';

  @override
  String get anitabiMapImportTapSpotHint => '点击地图上的点位查看缩略图和详情。';

  @override
  String get anitabiMapImportNoImportableSpots => '当前作品没有可导入的 Anitabi 点位。';

  @override
  String get anitabiMapImportNoWorks => '还没有作品';

  @override
  String get anitabiMapImportFromBangumiTitle => '找到作品';

  @override
  String get anitabiMapImportFromBangumiBody =>
      '在 Bangumi 搜索作品，或粘贴从 anitabi.cn 复制的链接。作品的点位会显示在地图上，导入点位时作品会自动加入计划。';

  @override
  String get anitabiMapImportLoadingWorks => '正在加载 Anitabi 作品和点位';

  @override
  String get planGroupManagerTitle => '片区管理';

  @override
  String get planGroupManagerNewArea => '新建片区';

  @override
  String get planGroupManagerCreate => '创建';

  @override
  String get planGroupManagerCreateFailed => '片区创建失败';

  @override
  String get planGroupManagerRenameTitle => '重命名片区';

  @override
  String get planGroupManagerRenameFailed => '片区改名失败';

  @override
  String get planGroupManagerOrderModeSaveFailed => '排序方式保存失败';

  @override
  String get planGroupManagerAnchorSaveFailed => '关键点保存失败';

  @override
  String get planGroupManagerDeleteArea => '删除片区';

  @override
  String planGroupManagerDeleteMessage(String name, int count) {
    return '将删除「$name」，其中 $count 个点位会移入未分配点位。';
  }

  @override
  String get planGroupManagerDeleteFailed => '片区删除失败';

  @override
  String get planGroupManagerReorderFailed => '片区顺序保存失败';

  @override
  String get planGroupManagerUngroupedSpots => '未分配点位';

  @override
  String get planGroupManagerUnknownArea => '未知片区';

  @override
  String get planGroupManagerNameRequired => '片区名不能为空';

  @override
  String get planGroupManagerNameLabel => '片区名称';

  @override
  String planGroupManagerSummary(int groupCount, int pointCount) {
    return '$groupCount 个片区 · $pointCount 个点位';
  }

  @override
  String get planGroupManagerManualOrder => '手动排序';

  @override
  String get planGroupManagerUnordered => '无序';

  @override
  String get planGroupManagerEmpty => '空';

  @override
  String planGroupManagerAnchorLabel(String name) {
    return '关键点 · $name';
  }

  @override
  String get planGroupManagerNoAnchor => '未设置关键点';

  @override
  String get planGroupManagerAreaActions => '片区操作';

  @override
  String get planGroupManagerRename => '重命名';

  @override
  String get planGroupManagerSetAnchor => '设置关键点';

  @override
  String get planGroupManagerSwitchToUnordered => '切换为无序';

  @override
  String get planGroupManagerSwitchToManualOrder => '切换为手动排序';

  @override
  String planGroupManagerUngroupedWaiting(int count) {
    return '$count 个点位等待整理';
  }

  @override
  String get workManagerTitle => '作品管理';

  @override
  String get workManagerDeleteWork => '删除作品';

  @override
  String workManagerDeleteMessage(String title) {
    return '将删除「$title」。';
  }

  @override
  String workManagerDeleteMessageWithPoints(String title, int count) {
    return '将删除「$title」，并同时移除 $count 个相关点位和对应记录。';
  }

  @override
  String get workManagerDeleteFailed => '作品删除失败';

  @override
  String get workManagerAddFromBangumi => '从Bangumi添加';

  @override
  String get workManagerAddFromBangumiHint => '自动获取信息';

  @override
  String get workManagerAddManually => '手动添加作品';

  @override
  String get workManagerAddManuallyHint => '未收录时使用';

  @override
  String get workManagerCopyTitle => '作品名称';

  @override
  String get workManagerCopyInfo => '作品信息';

  @override
  String get workManagerMoreActions => '更多操作';

  @override
  String workManagerPointsAddedOfTotal(int added, int total) {
    return '已加入 $added · 共 $total 点位';
  }

  @override
  String workManagerPointsAddedOfUnknown(int added) {
    return '已加入 $added · 共 … 点位';
  }

  @override
  String workManagerPointsAdded(int added) {
    return '已加入 $added 点位';
  }

  @override
  String get workManagerManualBadge => '手动添加';

  @override
  String get workManagerEmptyTitle => '还没有作品';

  @override
  String get workManagerOnboardingBangumiTitle => '从Bangumi导入';

  @override
  String get workManagerOnboardingBangumiBody =>
      '点击上方按钮可从Bangumi搜索你想导入的作品并导入。之后你可以在“查找作品点位”直接查看对应作品在Anitabi上的点位。';

  @override
  String get workManagerOnboardingManualBody =>
      '若Bangumi未收录你想要添加到作品，你可以通过“手动添加”将作品加入到计划内。之后你可以通过“手动添加点位”自主上传想要巡礼的点位。';

  @override
  String get pilgrimageModelsSubjectBook => '书籍';

  @override
  String get pilgrimageModelsSubjectAnime => '动画';

  @override
  String get pilgrimageModelsSubjectMusic => '音乐';

  @override
  String get pilgrimageModelsSubjectGame => '游戏';

  @override
  String get pilgrimageModelsSubjectReal => '三次元';

  @override
  String get pilgrimageModelsPaletteCustom => '自定义';

  @override
  String get pilgrimageModelsThemeLight => '浅色';

  @override
  String get pilgrimageModelsThemeDark => '深色';

  @override
  String get pilgrimageModelsThemeSystem => '跟随系统';

  @override
  String get pilgrimageModelsAspectAuto => '自动';

  @override
  String get pilgrimageModelsAspectNative => '原生比例';

  @override
  String get pilgrimageModelsAspectCustom => '自定义';

  @override
  String get pilgrimageModelsNavAmap => '高德地图';

  @override
  String get pilgrimageModelsNavBaiduMaps => '百度地图';

  @override
  String get pilgrimageModelsLocationAskOnFirstCapture => '首次拍摄时询问';

  @override
  String get pilgrimageModelsLocationDisabled => '不记录定位';

  @override
  String get pilgrimageModelsLocationUseRecent => '使用最近一次定位';

  @override
  String get pilgrimageModelsLocationWaitOnConfirmation => '确认记录时获取定位（推荐）';

  @override
  String get referenceCacheProgressRetryAll => '重试全部';

  @override
  String get referenceCacheProgressRetryFailed => '重试失败';

  @override
  String get referenceCacheProgressInterrupted => '缓存中断，请重试；已保存的图片不会删除。';

  @override
  String get referenceCacheProgressTip => '缓存时请保持联网，锁屏可能会暂停缓存。';

  @override
  String get referenceCacheProgressBackground => '后台缓存';

  @override
  String get referenceCacheProgressRunning => '正在缓存参考图...';

  @override
  String get referenceCacheProgressDone => '参考图缓存完成';

  @override
  String get referenceCacheProgressFailedTitle => '参考图缓存失败';

  @override
  String referenceCacheProgressSuccessSummary(int succeeded, int total) {
    return '$succeeded / $total 张成功，已保存到本地';
  }

  @override
  String referenceCacheProgressPartialSummary(
    int succeeded,
    int total,
    int failed,
  ) {
    return '$succeeded / $total 张成功 · $failed 张失败';
  }

  @override
  String get referenceFullCacheRunnerNothing => '当前计划没有需要缓存的参考图';

  @override
  String referenceFullCacheRunnerDone(int succeeded, int total) {
    return '已缓存 $succeeded/$total 张完整参考图';
  }

  @override
  String referenceFullCacheRunnerDoneWithFailures(
    int succeeded,
    int total,
    int failed,
  ) {
    return '已缓存 $succeeded/$total 张完整参考图，失败 $failed 张';
  }

  @override
  String referenceFullCacheRunnerRunning(
    int processed,
    int total,
    int succeeded,
  ) {
    return '正在缓存完整参考图 $processed/$total，成功 $succeeded';
  }

  @override
  String get pilgrimageWorkDropdownManual => '手动';

  @override
  String get pilgrimageWorkDropdownWork => '作品';

  @override
  String pilgrimageWorkCoverLabel(String title) {
    return '$title封面';
  }

  @override
  String get valhallaServiceConfigUrlIncomplete => '请输入完整的服务地址';

  @override
  String get valhallaServiceConfigUrlScheme => '服务地址仅支持 HTTP 或 HTTPS';

  @override
  String get anitabiServiceConfigInvalidHttps => '请输入有效的 HTTPS 地址';

  @override
  String get anitabiServiceConfigNoExtras => '地址不能包含账号、查询参数或片段';

  @override
  String get anitabiServiceConfigNoLocal => '不能使用本机或局域网地址';

  @override
  String get bangumiApiClientNoRegion => '未设置地区';

  @override
  String get anitabiEndpointSyncUpdated => '已更新服务地址';

  @override
  String get anitabiEndpointSyncUnchanged => '服务地址已是最新';

  @override
  String get anitabiEndpointSyncOffline => '无法获取远程配置，请检查网络';

  @override
  String get anitabiEndpointSyncInvalid => '远程配置无效，已保留当前地址';

  @override
  String get anitabiEndpointSyncVerificationFailed => '新地址暂不可用，已保留当前地址';

  @override
  String get anitabiEndpointSyncRateLimited => '检查过于频繁，稍后再试';

  @override
  String get anitabiEndpointSyncDisabled => '已关闭自动更新';

  @override
  String get boundedImageFileStubUnsupported => '此平台无法读取此本地图片；原件未更改';

  @override
  String get anitabiClientNoRegion => '未设置地区';

  @override
  String get anitabiClientDefaultSpotName => 'Anitabi 点位';

  @override
  String get anitabiClientPointNotFound => '没有找到对应的 Anitabi 点位';

  @override
  String boundedImageDecoderEncodedTooLarge(int length, int maxBytes) {
    return '图片文件 $length 字节超过读取预算 $maxBytes 字节；原件未更改，可保存或导出原件';
  }

  @override
  String get boundedImageDecoderSizeUnreadable => '无法读取图片尺寸';

  @override
  String boundedImageDecoderSourceTooLarge(int width, int height) {
    return '图片 $width x $height 超过来源预算（16000000 像素，单边 16384）；原件未更改，可保存或导出原件';
  }

  @override
  String get boundedImageDecoderInvalidMetadata => '图片尺寸元数据无效或不一致；原件未更改';

  @override
  String get boundedImageDecoderUnsupportedFormat => '此平台暂不能安全预览此图片格式；原件未更改';

  @override
  String get boundedImageDecoderMetadataMismatch => '图片尺寸元数据不一致；原件未更改';

  @override
  String get boundedImageDecoderAnimatedFrameTooLarge => '动画首帧尺寸超过此处理预算；原件未更改';

  @override
  String get boundedImageDecoderTargetUnsupported => '平台无法满足图片处理尺寸预算';

  @override
  String get sqlitePilgrimageRepositoryImportedPlan => '导入的巡礼计划';

  @override
  String get sqlitePilgrimageRepositoryUnknownWork => '未知作品';

  @override
  String get sqlitePilgrimageRepositoryNoRegion => '未设置地区';

  @override
  String get samplePilgrimageRepositoryImportedPlan => '导入的巡礼计划';

  @override
  String get desktopRepositoryStateDefaultPlan => '桌面端计划';

  @override
  String get desktopRepositoryStateDefaultWork => '作品';

  @override
  String get desktopRepositoryStateDefaultGroup => '分组';

  @override
  String get desktopRepositoryStateUnknownWork => '未知作品';

  @override
  String get desktopRepositoryStateDefaultSpot => '点位';

  @override
  String tauriBridgeWebAssetTooLarge(int maxBytes, String error) {
    return '图片超过读取预算 $maxBytes 字节；原件未更改（$error）';
  }

  @override
  String get appShellSettingsSaveFailed => '设置保存失败';

  @override
  String get appShellSettingsSaveFailedHint => '修改未能保存，请稍后重试';

  @override
  String get appShellReadingPlanFile => '正在读取计划文件…';

  @override
  String get appShellPlanImportFailed => '计划文件导入失败';

  @override
  String get appShellNavPlan => '计划';

  @override
  String get appShellNavMap => '地图';

  @override
  String get appShellNavRecords => '记录';

  @override
  String get appShellNavSettings => '设置';

  @override
  String get appShellLoadFailed => '计划加载失败';

  @override
  String get appShellLoading => '正在加载巡礼计划';

  @override
  String get appShellLoadFailedHint => '请稍后重试。';

  @override
  String mainOpenDirectoryFailed(String error) {
    return '无法打开目录：$error';
  }

  @override
  String get mainStartupFailed => 'Koma 启动失败';

  @override
  String get mainStartupFailedHint => '用户数据没有被删除。请重试，或打开日志目录查看 startup.log。';

  @override
  String get mainOpenLogFolder => '打开日志目录';

  @override
  String get mainOpenDataFolder => '打开数据目录';

  @override
  String get mainErrorDetails => '错误详情';

  @override
  String get pointDetailReplacingReference => '正在替换参考图...';

  @override
  String get pointDetailReplaceReferenceFailed => '参考图替换失败，请稍后重试。';

  @override
  String get pointDetailReplaceReferenceCanceled => '参考图替换已取消';

  @override
  String get pointDetailReferenceReplaced => '已替换参考图';

  @override
  String pointDetailOpenNavigationFailed(String app) {
    return '无法打开$app。';
  }

  @override
  String get pointDetailMoveToArea => '移动到片区';

  @override
  String get pointDetailMoveToAreaHint => '选择一个片区作为当前点位所属片区';

  @override
  String get pointDetailNotInArea => '未分入片区';

  @override
  String get pointDetailCopySpotName => '点位名称';

  @override
  String get pointDetailWorkLabel => '作品';

  @override
  String get pointDetailSceneLabel => '场景';

  @override
  String get pointDetailCoordinatesLabel => '坐标';

  @override
  String get pointDetailCoordinatesMissing => '待补充';

  @override
  String get pointDetailReferenceLabel => '参考';

  @override
  String get pointDetailSourceLabel => '来源';

  @override
  String get pointDetailLinkLabel => '链接';

  @override
  String get pointDetailNoteLabel => '备注';

  @override
  String pointDetailManualSource(String reference) {
    return '手动录入 / $reference';
  }

  @override
  String get pointDetailUndoCheckIn => '撤回打卡';

  @override
  String get pointDetailMarkDone => '标记完成';

  @override
  String get pointDetailUnknownArea => '未知片区';

  @override
  String get pointDetailNoAnchor => '未设置关键点';

  @override
  String get pointDetailDeleteSpot => '删除点位';

  @override
  String pointDetailDeleteSpotMessage(String name) {
    return '将从计划中删除“$name”。已有巡礼记录及照片将保留。';
  }

  @override
  String get pointDetailDeleteSpotFailed => '删除点位失败，请稍后重试。';

  @override
  String get pointDetailDeletingSpot => '正在删除点位';

  @override
  String get pointDetailSpotDeleted => '点位已删除';

  @override
  String get pointDetailNavigate => '导航';

  @override
  String get pointDetailNoCoordinates => '坐标待补充';

  @override
  String get pointDetailShootReference => '拍摄参考';

  @override
  String get pointDetailShootShort => '拍摄';

  @override
  String get pointDetailSetCurrent => '设为当前';

  @override
  String get pointDetailSetCurrentShort => '当前';

  @override
  String get pointDetailSetCurrentTarget => '设为当前目标';

  @override
  String get pointDetailEditSpot => '编辑点位';

  @override
  String get pointDetailReplace => '替换';

  @override
  String get pointDetailArea => '片区';

  @override
  String get pointDetailAreaAnchor => '片区关键点';

  @override
  String get pointDetailChange => '更改';

  @override
  String get pointDetailStatusCurrent => '当前目标';

  @override
  String get pointDetailStatusCompleted => '已完成';

  @override
  String get pointDetailStatusPending => '待访问';

  @override
  String pointDetailRecordsCount(int count) {
    return '本点记录 $count';
  }

  @override
  String get pointDetailAll => '全部';

  @override
  String get importExportTitle => '导入导出';

  @override
  String get importExportImportSection => '导入';

  @override
  String get importExportImportSubtitleIos =>
      '从文件、聊天、浏览器或网盘等位置用 Koma 打开 .sjhplan。';

  @override
  String get importExportImportSubtitle => '选择 .sjhplan 文件，先预览内容再导入。';

  @override
  String get importExportReading => '读取中...';

  @override
  String get importExportOpenFromOtherApp => '从其他 App 打开 .sjhplan';

  @override
  String get importExportImportFile => '导入 Koma 文件';

  @override
  String get importExportOpenFromOtherAppSubtitle =>
      '在文件、聊天、浏览器下载页或网盘中选择 .sjhplan，然后分享或用 Koma 打开。';

  @override
  String get importExportImportFileSubtitle => '支持 v2 数据包和旧版 v1 JSON 计划包。';

  @override
  String get importExportImportFromLink => '从链接导入';

  @override
  String get importExportImportFromLinkSubtitle =>
      '粘贴 GitHub 发布或 .sjhplan / .zip 下载链接，下载后预览导入。';

  @override
  String get importExportPackageSection => 'Koma 数据包';

  @override
  String get importExportPackageSubtitle =>
      '新版 .sjhplan，内部为 zip，包含 manifest.json。';

  @override
  String get importExportMyMapsSubtitle => '导出点位 CSV。图片写成链接，可按 Type 列设置样式。';

  @override
  String get importExportMyMapsExport => '导出 My Maps CSV';

  @override
  String get importExportMyMapsExportSubtitle => '前 6 列贴近示例格式，作品、集数、来源等拆成独立列。';

  @override
  String get importExportExportCanceled => '已取消导出';

  @override
  String get importExportReadFailed => '导入文件读取失败';

  @override
  String get importExportIosHelpMessage =>
      '请在文件、聊天、浏览器下载页、网盘或其他保存位置找到 .sjhplan 文件，然后点开文件，或使用分享/更多菜单选择 Koma。\n\nKoma 收到文件后会自动进入导入预览页面。若列表里没有 Koma，可以先把文件保存到“文件”App，再长按文件选择分享或打开方式。';

  @override
  String importExportShareText(String planName) {
    return 'Koma数据包：$planName';
  }

  @override
  String get importExportPackageExported => '数据包已导出';

  @override
  String get importExportMissingAssetsTitle => '部分本地资源缺失';

  @override
  String get importExportContinueExport => '继续导出';

  @override
  String get importExportMissingAssetsNotice => '缺失资源不会进入数据包，导入后对应图片可能无法显示';

  @override
  String importExportMyMapsShareText(String planName) {
    return 'Koma My Maps CSV：$planName';
  }

  @override
  String get importExportPendingCoordinateWarning => '存在坐标待补充的点位';

  @override
  String get importExportMyMapsExported => 'My Maps CSV 已导出';

  @override
  String get importExportExporting => '正在导出...';

  @override
  String get importExportExportFailed => '导出失败';

  @override
  String get importExportTryAgainLater => '请稍后重试';

  @override
  String get importExportSavedLocally => '已保存到本地';

  @override
  String get importExportShared => '已通过系统分享送出';

  @override
  String get importExportSomeAssetsSkipped => '部分资源未能加入';

  @override
  String importExportWarnUserReferenceMissing(int count) {
    return '$count 张本地上传参考图缺失';
  }

  @override
  String importExportWarnThumbnailMissing(int count) {
    return '$count 张缩略图未加入';
  }

  @override
  String importExportWarnFullReferenceDownloadFailed(int count) {
    return '$count 张完整参考图下载失败';
  }

  @override
  String importExportWarnFullReferenceMissing(int count) {
    return '$count 张完整参考图缺失';
  }

  @override
  String importExportWarnVisitPhotoMissing(int count) {
    return '$count 张巡礼照片缺失';
  }

  @override
  String importExportWarnGradedPhotoMissing(int count) {
    return '$count 张调色照片缺失';
  }

  @override
  String importExportWarnPendingCoordinate(int count) {
    return '$count 个坐标待补充点位未导出';
  }

  @override
  String get importExportWarningSeparator => '，';

  @override
  String importExportAreaCount(int count) {
    return '$count 个片区';
  }

  @override
  String importExportSpotCount(int count) {
    return '$count 个点位';
  }

  @override
  String get importExportPlanOnly => '纯计划';

  @override
  String get importExportPlanWithRecords => '计划+记录';

  @override
  String get importExportIncludeFullReference => '包含完整参考图缓存';

  @override
  String get importExportIncludeFullReferenceSubtitle =>
      '开启后才会把完整参考图写入数据包；默认仍会包含缩略图和用户自己添加的参考图。';

  @override
  String get importExportExportingButton => '导出中...';

  @override
  String get importExportExportPackage => '导出 Koma 数据包';

  @override
  String get importExportEstimating => '正在估算数据包大小...';

  @override
  String get importExportEstimateUnavailable => '预计数据包大小：暂时无法估算';

  @override
  String planExportSizeEstimatorThumbnailsNotCached(int count) {
    return '$count 张缩略图未缓存，不会进入数据包';
  }

  @override
  String planExportSizeEstimatorFullReferencesToDownload(int count) {
    return '$count 张完整参考图将在导出时下载';
  }

  @override
  String planExportSizeEstimatorUserReferencesMissing(int count) {
    return '$count 张本地上传参考图文件缺失，导出后无法恢复';
  }

  @override
  String planExportSizeEstimatorVisitPhotosMissing(int count) {
    return '$count 张巡礼照片文件缺失';
  }

  @override
  String planExportSizeEstimatorGradedPhotosMissing(int count) {
    return '$count 张调色照片文件缺失';
  }

  @override
  String get planExportSizeEstimatorUnknownLocalAssets => '部分本地资源无法读取，实际包体可能变化';

  @override
  String planExportSizeEstimatorLabelWithDetails(String size, String details) {
    return '预计数据包大小：至少约 $size，$details';
  }

  @override
  String get planExportSizeEstimatorDetailSeparator => '；';

  @override
  String planExportSizeEstimatorLabel(String size) {
    return '预计数据包大小：约 $size';
  }

  @override
  String get planImportPreviewTitle => '导入内容';

  @override
  String get planImportPreviewChooseContent => '选择导入内容';

  @override
  String get planImportPreviewChooseContentSubtitle => '导入前不会修改当前数据。';

  @override
  String get planImportPreviewPlanStructure => '计划结构';

  @override
  String get planImportPreviewPlanStructureSubtitle => '作品、片区、点位、完成状态和当前目标。';

  @override
  String get planImportPreviewRecords => '拍摄记录';

  @override
  String get planImportPreviewRecordsLegacy => 'v1 文件不包含照片资源，仅导入计划结构。';

  @override
  String planImportPreviewRecordsCount(int count) {
    return '$count 条记录，包含照片路径和调色参数。';
  }

  @override
  String get planImportPreviewRecordsNone => '这个包里没有拍摄记录。';

  @override
  String get planImportPreviewAssets => '图片和资源文件';

  @override
  String get planImportPreviewPackageNotes => '包内提示';

  @override
  String get planImportPreviewPackageNotesSubtitle => '导出时记录的缺失或兼容信息。';

  @override
  String get planImportPreviewImporting => '导入中...';

  @override
  String get planImportPreviewImportSelected => '导入所选内容';

  @override
  String planImportPreviewImportedUnconfirmed(String name) {
    return '已导入计划「$name」，资源确认未完成';
  }

  @override
  String planImportPreviewImported(String name) {
    return '已导入计划「$name」';
  }

  @override
  String planImportPreviewImportedPartial(String name) {
    return '已导入计划「$name」，部分资源未恢复';
  }

  @override
  String get planImportPreviewCleanupIncomplete => '导入未确认完成，已保留资源以避免误删';

  @override
  String get planImportPreviewFailed => '导入失败';

  @override
  String get planImportPreviewNoAssets => '这个包里没有可恢复的资源文件。';

  @override
  String get planImportPreviewNoRestorableAssets => '包内记录了资源，但没有可恢复的资源文件。';

  @override
  String planImportPreviewAssetsUnsupported(int count) {
    return '包内有 $count 个资源文件；当前平台暂不支持恢复包内资源。';
  }

  @override
  String planImportPreviewAssetsRestore(int count) {
    return '包内有 $count 个资源文件，将恢复到本机存储。';
  }

  @override
  String get planImportPreviewStatWorks => '作品';

  @override
  String get planImportPreviewStatAreas => '片区';

  @override
  String get planImportPreviewStatSpots => '点位';

  @override
  String get planImportPreviewStatRecords => '记录';

  @override
  String get planImportPreviewStatFiles => '资源';

  @override
  String get planImportPreviewStatVersion => '版本';

  @override
  String get planImportPreviewStatExported => '导出';

  @override
  String get planLinkImportNoPlanFilesInRelease => '这个发布中没有 .sjhplan 或 .zip 文件';

  @override
  String get planLinkImportChooseArchiveEntry => '压缩包里有多个计划，选择要导入的一个';

  @override
  String get planLinkImportArchiveHasNoPlan => '压缩包里没有 .sjhplan 计划文件';

  @override
  String get planLinkImportNotAPlanPackage => '下载的文件不是 Koma 计划包';

  @override
  String get planLinkImportReadFailed => '读取失败，请重试';

  @override
  String get planLinkImportTitle => '从链接导入';

  @override
  String get planLinkImportIntro =>
      '粘贴 GitHub 发布页面或计划文件的下载链接，Koma 会下载计划并打开导入预览。';

  @override
  String get planLinkImportWebUnavailableTitle => '网页版无法直接下载';

  @override
  String get planLinkImportWebUnavailableSubtitle =>
      '请先在浏览器中下载 .sjhplan 或 .zip，再回到“导入导出”，用“导入 Koma 文件”导入。';

  @override
  String get planLinkImportLinkLabel => '链接';

  @override
  String get planLinkImportPaste => '粘贴';

  @override
  String get planLinkImportReadLink => '读取链接';

  @override
  String get planLinkImportHelp =>
      '支持：\n• GitHub 发布页面或仓库链接（自动列出最新发布中的计划文件）\n• GitHub 发布中的文件下载链接\n• 其他 https:// 开头的 .sjhplan 或 .zip 直链\n.zip 中可以带说明等其他文件，Koma 只读取其中的 .sjhplan。下载会连接你输入的地址（以及它跳转到的下载服务器）；GitHub 发布或仓库链接还会向 api.github.com 查询发布中的文件。';

  @override
  String get planLinkImportResolving => '正在查找发布中的计划文件…';

  @override
  String get planLinkImportChooseFile => '选择要导入的文件';

  @override
  String get planLinkImportArchiveTag => '压缩包';

  @override
  String planLinkImportDownloading(String name) {
    return '正在下载 $name';
  }

  @override
  String planLinkImportDownloaded(String size) {
    return '已下载 $size';
  }

  @override
  String get planLinkImportReadingPlan => '正在读取计划…';

  @override
  String get planLinkEnterLink => '请输入链接';

  @override
  String get planLinkUnrecognized => '无法识别这个链接';

  @override
  String get planLinkHttpsOnly => '只支持 https:// 开头的链接';

  @override
  String planLinkLatestRelease(String repository) {
    return '$repository 最新发布';
  }

  @override
  String get planLinkReleaseUnreadable => 'GitHub 返回的发布信息无法读取';

  @override
  String get planLinkTooLarge => '文件超过 128 MB 上限，无法导入';

  @override
  String get planLinkNotPublic => '不支持本机或局域网地址';

  @override
  String get planLinkFileNotFound => '链接指向的文件不存在（HTTP 404）';

  @override
  String planLinkServerRefused(String status) {
    return '服务器拒绝了下载（HTTP $status），请稍后再试';
  }

  @override
  String planLinkDownloadFailedStatus(String status) {
    return '下载失败（HTTP $status）';
  }

  @override
  String get planLinkReleaseNotFound =>
      '没有找到这个发布：仓库可能是私有的、还没有发布版本，或只有预发布版本（请粘贴具体发布页链接）';

  @override
  String get planLinkGitHubRateLimited => 'GitHub 请求过于频繁，请稍后再试';

  @override
  String planLinkReleaseFetchFailed(String status) {
    return 'GitHub 发布信息读取失败（HTTP $status）';
  }

  @override
  String get planLinkCannotReachGitHub => '无法连接 GitHub，请检查网络后重试';

  @override
  String get planLinkDownloadFailed => '下载失败，请检查网络后重试';

  @override
  String get planLinkServiceIoTempFileFailed => '无法创建临时文件，请检查存储空间';

  @override
  String get planLinkServiceIoSaveFailed => '无法保存下载的文件，请检查存储空间';

  @override
  String get planLinkServiceWebUnavailable =>
      '网页版无法直接下载，请先下载文件，再用“导入 Koma 文件”导入';

  @override
  String incomingPlanFileTooLarge(String limit) {
    return '导入超限：计划文件超过 $limit MiB 上限。请拆分计划或减少打包图片后重试。';
  }

  @override
  String get incomingPlanFileFailed => '计划文件导入失败';

  @override
  String planImportPackageLimitExceeded(
    String resource,
    String actual,
    String limit,
  ) {
    return '导入超限：$resource 为 $actual，上限 $limit。请拆分计划或减少打包图片后重试。';
  }

  @override
  String get planImportPackageResourceEntryBytes => '单文件解压字节数';

  @override
  String get planImportPackageResourceJsonBytes => 'JSON 字节数';

  @override
  String get planImportPackageResourceExpandedBytes => '总解压字节数';

  @override
  String get planImportPackageResourceArchiveBytes => '压缩包字节数';

  @override
  String get planImportPackageResourcePlanFileBytes => '计划文件字节数';

  @override
  String get planImportPackageResourceZipEntries => 'ZIP 条目数';

  @override
  String planImportPackageResourceImagePixels(
    String width,
    String height,
    String frames,
  ) {
    return '图片像素（$width x $height x $frames 帧）';
  }

  @override
  String get planImportPackageV2Label => 'v2 数据包';

  @override
  String planImportPackageInvalidCoordinates(int count) {
    return '$count 个点位坐标无效，已改为待补充坐标';
  }

  @override
  String get planImportPackageUnnamedArea => '未命名片区';

  @override
  String get planPackageDefaultPlanName => '导入的巡礼计划';

  @override
  String get planPackageNoArea => '未设置区域';

  @override
  String get planPackageUnknownWork => '未知作品';

  @override
  String get planPackageNoRegion => '未设置地区';

  @override
  String get planPackageUnnamedSpot => '未命名点位';

  @override
  String get planPackageUnknownReferenceMode => '未知';

  @override
  String planExportV2DeletedDuringExport(int count) {
    return '$count 个文件在导出过程中被删除，未包含在数据包中';
  }

  @override
  String get planExportV2CsvWork => '作品';

  @override
  String get planExportV2CsvArea => '片区';

  @override
  String get planExportV2CsvSpotName => '点位名';

  @override
  String get planExportV2CsvSubtitle => '副标题';

  @override
  String get planExportV2CsvLatitude => '纬度';

  @override
  String get planExportV2CsvLongitude => '经度';

  @override
  String get planExportV2CsvEpisode => '集数/场景';

  @override
  String get planExportV2CsvSource => '来源';

  @override
  String get planExportV2CsvSourceId => '来源ID';

  @override
  String get planExportV2CsvReferenceUrl => '参考图URL';

  @override
  String get planExportV2CsvCompleted => '已完成';

  @override
  String get planExportV2CsvRecordCount => '记录数';

  @override
  String get planExportV2CsvRecordId => '记录ID';

  @override
  String get planExportV2CsvCapturedAt => '拍摄时间';

  @override
  String get planExportV2CsvReferenceMode => '参考模式';

  @override
  String get planExportV2CsvColorMatched => '是否调色';

  @override
  String get planExportV2CsvPhotoFile => '照片文件名';

  @override
  String get planExportV2CsvGradedPhotoFile => '调色照片文件名';

  @override
  String get planExportV2CsvYes => '是';

  @override
  String get planExportV2CsvNo => '否';

  @override
  String get planExportV2Ungrouped => '未分组';

  @override
  String get planExportV2UnknownArea => '未知片区';

  @override
  String get myMapsCsvExportUngrouped => '未分组';

  @override
  String get colorGradingParamsModeNatural => '自然';

  @override
  String get colorGradingParamsModeStandard => '标准';

  @override
  String get colorGradingParamsModeStrong => '强匹配';

  @override
  String get colorGradingParameterSummaryIntensity => '调色强度';

  @override
  String get colorGradingParameterSummaryParameters => '调色参数';

  @override
  String get colorGradingParameterSummaryView => '查看';

  @override
  String get colorGradingParameterSummaryDescription => '显示当前调色强度下实际生效的参数。';

  @override
  String get colorGradingParameterSummaryBrightness => '亮度';

  @override
  String get colorGradingParameterSummaryExposure => '曝光';

  @override
  String get colorGradingParameterSummaryContrast => '对比度';

  @override
  String get colorGradingParameterSummarySaturation => '饱和度';

  @override
  String get colorGradingParameterSummaryTemperature => '色温';

  @override
  String get colorGradingParameterSummaryTint => '色调';

  @override
  String get colorGradingParameterSummaryHighlights => '高光';

  @override
  String get colorGradingParameterSummaryShadows => '阴影';

  @override
  String get colorGradingParameterSummaryRedShadowCurve => '红暗部曲线';

  @override
  String get colorGradingParameterSummaryRedMidCurve => '红中间调曲线';

  @override
  String get colorGradingParameterSummaryRedHighlightCurve => '红高光曲线';

  @override
  String get colorGradingParameterSummaryGreenShadowCurve => '绿暗部曲线';

  @override
  String get colorGradingParameterSummaryGreenMidCurve => '绿中间调曲线';

  @override
  String get colorGradingParameterSummaryGreenHighlightCurve => '绿高光曲线';

  @override
  String get colorGradingParameterSummaryBlueShadowCurve => '蓝暗部曲线';

  @override
  String get colorGradingParameterSummaryBlueMidCurve => '蓝中间调曲线';

  @override
  String get colorGradingParameterSummaryBlueHighlightCurve => '蓝高光曲线';

  @override
  String get colorGradingAutoMatchFailed => '自动调色失败';

  @override
  String get colorGradingPhotoReadFailed => '巡礼图读取失败';

  @override
  String get colorGradingNoReferenceForMatch => '没有可用于自动调色的参考图';

  @override
  String get colorGradingReferenceUnavailable => '参考图暂不可用，无法自动匹配色调';

  @override
  String get colorGradingAutoMatchDone => '已生成自动调色参数';

  @override
  String get colorGradingSaveFailedOriginalKept => '保存失败，原件未更改';

  @override
  String get colorGradingRestoredOriginal => '已还原为原图';

  @override
  String get colorGradingMatchFirst => '请先自动匹配色调';

  @override
  String get colorGradingSaveFailed => '保存失败';

  @override
  String get colorGradingSaved => '已保存调色结果';

  @override
  String get colorGradingResetTitle => '重置调色';

  @override
  String get colorGradingResetMessage => '将清除当前调色，恢复为原图。';

  @override
  String get colorGradingReset => '重置';

  @override
  String get colorGradingTitle => '自动调色';

  @override
  String get colorGradingMatching => '匹配中...';

  @override
  String get colorGradingAutoMatch => '自动匹配色调';

  @override
  String get colorGradingReference => '参考图';

  @override
  String get colorGradingNoReference => '没有参考图';

  @override
  String get colorGradingOriginal => '原图';

  @override
  String get colorGradingGraded => '调色后';

  @override
  String get colorGradingShowingOriginal => '正在显示原图';

  @override
  String get colorGradingHoldForOriginal => '按住显示原图';

  @override
  String get colorGradingMatchMode => '匹配模式';

  @override
  String get colorGradingParamsReady => '已恢复或生成调色参数，可保存结果';

  @override
  String get colorGradingMatchToSave => '自动匹配后可保存调色结果';

  @override
  String get colorGradingToneMatch => '色调匹配';

  @override
  String get colorGradingCurrent => '当前';

  @override
  String get colorGradingSaveResult => '保存结果';

  @override
  String get colorGradingSaveDescription => '保存后记录详情和导出会使用调色后的图片，原图和调色参数会保留。';

  @override
  String get colorGradingSaving => '保存中...';

  @override
  String get colorGradingSaveColorMatch => '保存调色结果';

  @override
  String get comparisonExportConfigJpegRecommended => 'JPEG 推荐 (85)';

  @override
  String get comparisonExportConfigJpegHighQuality => 'JPEG 高画质 (95)';

  @override
  String get comparisonExportConfigPngLossless => 'PNG 无损';

  @override
  String get comparisonExportConfigWidthAuto => '自动';

  @override
  String get comparisonExportConfigFieldCapturedAt => '拍摄时间';

  @override
  String get comparisonExportConfigFieldWork => '作品';

  @override
  String get comparisonExportConfigFieldPlace => '地点';

  @override
  String get comparisonExportConfigFieldCoordinates => '坐标';

  @override
  String get comparisonExportConfigFieldScene => '场景';

  @override
  String get comparisonExportConfigEditorColorWhite => '白色';

  @override
  String get comparisonExportConfigEditorColorBlack => '黑色';

  @override
  String get comparisonExportConfigEditorColorTheme => '主题色';

  @override
  String get comparisonExportConfigEditorAppearance => '外观';

  @override
  String get comparisonExportConfigEditorFormat => '图片格式与质量';

  @override
  String comparisonExportConfigEditorSummaryWidth(String width) {
    return '宽度 $width';
  }

  @override
  String get comparisonExportConfigEditorSummaryNoBorder => '无边框';

  @override
  String comparisonExportConfigEditorSummaryBorder(String percent) {
    return '边框 $percent%';
  }

  @override
  String get comparisonExportConfigEditorSummaryLabelsOn => '显示标签';

  @override
  String get comparisonExportConfigEditorSummaryLabelsOff => '不显示标签';

  @override
  String comparisonExportConfigEditorSummaryPilgrim(String name) {
    return '巡礼者 $name';
  }

  @override
  String get comparisonExportConfigEditorBorderWidth => '边框宽度';

  @override
  String get comparisonExportConfigEditorNone => '无';

  @override
  String get comparisonExportConfigEditorBorderColor => '边框颜色';

  @override
  String get comparisonExportConfigEditorAutoWidthTitle => '自动输出宽度';

  @override
  String get comparisonExportConfigEditorAutoWidthSubtitle => '根据图片尺寸自动确定输出宽度';

  @override
  String get comparisonExportConfigEditorShowLabelsTitle => '显示标签';

  @override
  String get comparisonExportConfigEditorShowLabelsSubtitle =>
      '在参考图上显示“参考”字样，在你拍的巡礼图上显示“巡礼”字样';

  @override
  String get comparisonExportConfigEditorMetadata => '元数据';

  @override
  String get comparisonExportConfigEditorShowPilgrimTitle => '显示巡礼者名字';

  @override
  String get comparisonExportConfigEditorShowPilgrimSubtitle => '在图片上显示巡礼者名字';

  @override
  String get comparisonExportConfigEditorPilgrimHint => '请输入巡礼者名字';

  @override
  String get comparisonExportConfigEditorShowGradingTitle => '显示调色参数';

  @override
  String get comparisonExportConfigEditorShowGradingSubtitle => '在图片底部显示调色相关参数';

  @override
  String get comparisonExportConfigEditorContent => '显示内容';

  @override
  String comparisonExportBudgetSizeUnfit(int maxPixels, int maxEdge) {
    return '对比图尺寸无法满足输出限制：最多 $maxPixels 像素，最长边 $maxEdge 像素。';
  }

  @override
  String comparisonExportBudgetTooNarrow(int maxPixels, int maxEdge) {
    return '对比图比例过于狭长，无法在 $maxPixels 像素、最长边 $maxEdge 像素内完整输出。';
  }

  @override
  String get comparisonExportSupportShareText => 'Koma 对比图';

  @override
  String get comparisonExportLoadSettingsFailed => '读取导出设置失败，请重试。';

  @override
  String get comparisonExportSaveSettingsFailed => '导出设置保存失败，导出时将重试。';

  @override
  String get comparisonExportBrowserDownload => '对比图已交给浏览器下载';

  @override
  String get comparisonExportFailed => '导出失败，设置或图片未能保存，请重试。';

  @override
  String get comparisonExportReferenceUnavailable => '参考图不可用，无法导出对比图片。';

  @override
  String get comparisonExportPhotoUnavailable => '巡礼图不可用，无法导出对比图片。';

  @override
  String get comparisonExportBudgetExceeded => '图片超过处理预算，原件未更改。';

  @override
  String get comparisonExportUnsupportedFormat => '当前平台不支持处理此图片格式。';

  @override
  String get comparisonExportInvalidData => '图片数据无法解码。';

  @override
  String get comparisonExportRenderFailed => '导出失败，请稍后重试。';

  @override
  String get comparisonExportTitle => '导出对比图';

  @override
  String get comparisonExportShortLabel => '导出';

  @override
  String get comparisonExportRendererReference => '参考';

  @override
  String get comparisonExportRendererPilgrimage => '巡礼';

  @override
  String get comparisonExportRendererPilgrim => '巡礼者';

  @override
  String get gallerySaveResultFailed => '保存失败，请稍后重试。';

  @override
  String get gallerySaveResultSaved => '已保存到相册';

  @override
  String get gallerySaveResultPermissionTitle => '需要相册权限';

  @override
  String get gallerySaveResultPermissionSubtitle => '请在系统设置中允许 Koma 添加照片。';

  @override
  String get gallerySaveResultSettings => '设置';

  @override
  String get photoCompareSliderViewReference => '查看参考图';

  @override
  String get photoCompareSliderViewPhoto => '查看巡礼图';

  @override
  String get photoCompareSliderSemantics => '滑动对比，左侧参考图，右侧巡礼图';

  @override
  String get photoCompareSliderReference => '参考图';

  @override
  String get photoCompareSliderPhoto => '巡礼图';

  @override
  String get pointVisitRecordsTitle => '点位拍摄记录';

  @override
  String pointVisitRecordsCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '条',
    );
    return '$_temp0';
  }

  @override
  String get pointVisitRecordsEmpty => '这个点位还没有拍摄记录';

  @override
  String get pointVisitRecordsListLabel => '拍摄记录';

  @override
  String get pointVisitRecordsColorMatched => '已调色';

  @override
  String get visitRecordDetailTitle => '记录详情';

  @override
  String get visitRecordDetailDeleteTooltip => '删除记录';

  @override
  String get visitRecordDetailCapturedAt => '拍摄时间';

  @override
  String get visitRecordDetailArea => '片区';

  @override
  String get visitRecordDetailScene => '场景';

  @override
  String get visitRecordDetailDeleteTitle => '删除记录';

  @override
  String get visitRecordDetailDeleteTarget => '这条巡礼记录';

  @override
  String visitRecordDetailDeleteMessage(String target) {
    return '将删除$target，不会改变点位完成状态。';
  }

  @override
  String get visitRecordDetailDeleteFiles => '同时删除照片文件';

  @override
  String get visitRecordDetailDeleteFailed => '删除记录失败，照片未删除，请重试';

  @override
  String get visitRecordDetailDeletedPartly => '记录已删除，部分照片未清理';

  @override
  String get visitRecordDetailPhotoUnavailable => '巡礼图不可用，无法导出对比图片。';

  @override
  String get visitRecordDetailNoPrefsStorage => '当前平台暂不支持保存导出偏好。';

  @override
  String get visitRecordDetailUngrouped => '未分组';

  @override
  String get visitRecordDetailUnknownArea => '未知片区';

  @override
  String get visitRecordDetailBrightness => '亮度';

  @override
  String get visitRecordDetailExposure => '曝光';

  @override
  String get visitRecordDetailContrast => '对比';

  @override
  String get visitRecordDetailSaturation => '饱和';

  @override
  String get visitRecordDetailTemperature => '色温';

  @override
  String get visitRecordDetailTint => '色调';

  @override
  String get visitRecordDetailHighlights => '高光';

  @override
  String get visitRecordDetailShadows => '阴影';

  @override
  String visitRecordDetailCurveShadows(String channel) {
    return '$channel暗';
  }

  @override
  String visitRecordDetailCurveMids(String channel) {
    return '$channel中';
  }

  @override
  String visitRecordDetailCurveHighlights(String channel) {
    return '$channel亮';
  }

  @override
  String get visitRecordDetailModeStacked => '上下';

  @override
  String get visitRecordDetailModeSlider => '滑动对比';

  @override
  String get visitRecordDetailReference => '参考图';

  @override
  String get visitRecordDetailPhoto => '巡礼图';

  @override
  String get visitRecordDetailOrphan => '这条记录对应的点位已不在当前计划中，照片和导出功能仍然可以使用。';

  @override
  String get visitRecordDetailColorMatchTitle => '自动调色';

  @override
  String get visitRecordDetailColorMatchSubtitle => '优化巡礼照片';

  @override
  String get visitRecordDetailExportTitle => '导出对比图';

  @override
  String get visitRecordDetailExportSubtitle => '生成分享图片';

  @override
  String get recordsTitle => '记录';

  @override
  String get recordsCollapseAll => '收起全部片区';

  @override
  String get recordsExpandAll => '展开全部片区';

  @override
  String get recordsUngrouped => '未分组';

  @override
  String get recordsUngroupedSubtitle => '还没有放入片区的记录';

  @override
  String get recordsOrphan => '孤立记录';

  @override
  String get recordsOrphanSubtitle => '对应点位已不在当前计划中';

  @override
  String get recordsNoCoordinates => '坐标待补充';

  @override
  String get recordsUnknownArea => '未知片区';

  @override
  String get recordsNoAnchor => '未设置关键点';

  @override
  String get recordsScopeFilterTooltip => '按作品和片区筛选';

  @override
  String get recordsWorks => '作品';

  @override
  String get recordsAreas => '片区';

  @override
  String get recordsFilterTitle => '筛选记录';

  @override
  String get recordsClear => '清除';

  @override
  String recordsScopeSummary(int works, int areas) {
    return '已选：作品 $works · 片区 $areas';
  }

  @override
  String get recordsAllWorks => '全部作品';

  @override
  String get recordsAllAreas => '全部片区';

  @override
  String recordsWorksPicked(int count) {
    return '已选 $count 个作品';
  }

  @override
  String recordsAreasPicked(int count) {
    return '已选 $count 个片区';
  }

  @override
  String get recordsApplyAll => '应用筛选（全部点位）';

  @override
  String get recordsApplySelected => '应用筛选（已选择）';

  @override
  String get recordsBackToFilter => '返回筛选记录';

  @override
  String get recordsSelectWorks => '选择作品';

  @override
  String get recordsSelectAreas => '选择片区';

  @override
  String get recordsNoOptions => '暂无可筛选项';

  @override
  String get recordsWorkBadge => '作品';

  @override
  String get recordsAreaBadge => '片区';

  @override
  String recordsWorksChosen(int count) {
    return '已选择 $count 个作品';
  }

  @override
  String recordsAreasChosen(int count) {
    return '已选择 $count 个片区';
  }

  @override
  String recordsConfirmCount(int count) {
    return '确定（$count）';
  }

  @override
  String get recordsStatusAll => '全部';

  @override
  String get recordsStatusCompleted => '已完成';

  @override
  String get recordsStatusPending => '未完成';

  @override
  String get recordsStatusTooltip => '按状态筛选';

  @override
  String get recordsSelectStatus => '选择状态';

  @override
  String get recordsSearchHint => '搜索记录';

  @override
  String get recordsClearSearchTooltip => '清空搜索';

  @override
  String get recordsPhotos => '巡礼照片';

  @override
  String recordsRecordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '条巡礼记录',
    );
    return '$_temp0';
  }

  @override
  String get recordsCompleted => '已完成';

  @override
  String get recordsEmptySearchTitle => '没有找到相关记录';

  @override
  String get recordsEmptyFilterTitle => '没有符合筛选条件的记录';

  @override
  String get recordsEmptyTitle => '还没有巡礼记录';

  @override
  String get recordsEmptySearchFilterBody =>
      '没有与当前关键词和筛选条件同时匹配的点位、作品或场景。试试更换关键词，或重置筛选条件。';

  @override
  String get recordsEmptySearchBody =>
      '没有与当前关键词匹配的点位、作品或场景。试试更换关键词，或清除搜索查看全部记录。';

  @override
  String get recordsEmptyFilterBody => '调整状态、作品或片区筛选条件后再试。';

  @override
  String get recordsEmptyBody => '完成一次点位拍摄后，记录会自动汇总到这里。';

  @override
  String get recordsClearSearch => '清除搜索';

  @override
  String get recordsResetFilters => '重置筛选';

  @override
  String get recordsColorMatched => '已调色';

  @override
  String get copyableTextCopy => '复制';

  @override
  String get confirmActionGotIt => '知道了';

  @override
  String get confirmActionIrreversible => '此操作无法撤销';

  @override
  String get appBackButtonLabel => '返回';

  @override
  String get clearAnchorSelectionButtonTooltip => '清除选点';

  @override
  String get inputPaste => '粘贴';

  @override
  String get imageViewerSaveOrShare => '保存或分享原件';

  @override
  String get imageViewerReadFailed => '图片读取失败';

  @override
  String get imageViewerShareFailed => '无法打开分享';

  @override
  String get imageViewerSaveFailed => '保存失败';

  @override
  String get imageViewerShareText => 'Koma 图片';

  @override
  String get imageViewerSaveCanceled => '已取消保存';

  @override
  String get imageViewerSaved => '图片已保存';

  @override
  String get imageViewerLoading => '图片加载中';

  @override
  String get imageViewerEmpty => '暂无图片';

  @override
  String get imageViewerUnavailable => '图片暂不可用';

  @override
  String get imageViewerSaveImage => '保存图片';

  @override
  String get imageViewerShare => '分享';

  @override
  String get imageViewerSaveToPhotos => '保存到相册';

  @override
  String get boundedImageUnavailable => '图片暂不可用';

  @override
  String get boundedImageBadSource => '无法读取图片来源';

  @override
  String get boundedImageLoading => '图片加载中';

  @override
  String splitNavigationButtonInApp(String label) {
    return '应用内导航：$label';
  }

  @override
  String get splitNavigationButtonExternal => '打开外部地图';

  @override
  String get mapThumbnailMarkerTooltip => '巡礼点';

  @override
  String get referenceImagePlaceholderLoading => '参考图加载中';

  @override
  String get referenceImagePlaceholderUnavailable => '参考图暂不可用';

  @override
  String get referenceImagePlaceholderEmpty => '暂无参考图';

  @override
  String get routePlannerSkillHintTitle => '用 AI 一键规划巡礼行程';

  @override
  String get routePlannerSkillHintDescription =>
      '让 ChatGPT、Claude Code、Codex 等 AI 助手调用 MiriaGo 路线规划 Skill。\n它会从 Anitabi、Google My Maps 等来源收集作品点位，自动划分区域、规划路线并生成行程备注；关键步骤会先向你确认，最终导出可直接使用的 .sjhplan 计划包。';

  @override
  String get routePlannerSkillHintOpenFailed => '无法打开链接';

  @override
  String get routePlannerSkillHintViewGuide => '查看使用说明';

  @override
  String get routePlannerSkillHintDismissFailed => '关闭提示失败，请重试。';

  @override
  String get routePlannerSkillHintTapForGuide => '点击查看使用说明';

  @override
  String get routePlannerSkillHintLinkText => '用 AI 一键规划行程并生成计划包';

  @override
  String get currentLocationResolverServiceDisabled => '定位服务未开启。';

  @override
  String get currentLocationResolverPermissionDenied => '需要定位权限来显示当前位置。';

  @override
  String get currentLocationResolverTimeout => '定位超时，请稍后重试。';

  @override
  String get mapLocationTrackerStopped => '定位更新已停止，请点击定位重试。';

  @override
  String get mapLocationTrackerStale => '暂未收到新的定位，当前位置可能已过期。';

  @override
  String get mapLocationTrackerServiceDisabled => '定位服务未开启，请开启后重试。';

  @override
  String get mapLocationTrackerPermissionDenied => '定位权限不可用，请检查权限后重试。';

  @override
  String get mapLocationTrackerFailed => '定位更新失败，请检查权限和定位服务后重试。';

  @override
  String get mapLayersPanelTitle => '图层';

  @override
  String mapLayersPanelCloseLabel(String title) {
    return '关闭$title';
  }

  @override
  String get mapTileConfigLibertyDescription => '默认样式，信息密度较高。';

  @override
  String get mapTileConfigBrightDescription => '明亮标准样式。';

  @override
  String get mapTileConfigPositronDescription => '浅色低干扰样式。';

  @override
  String get mapTileConfigDarkDescription => '深色地图样式。';

  @override
  String get mapTileConfigFiordDescription => '柔和地形风格。';

  @override
  String get mapTileConfigCustomXyzLabel => '自定义 XYZ';

  @override
  String get mapTileConfigCustomMapLibreLabel => '自定义 MapLibre';

  @override
  String get mapTileConfigOpenFreeMapDescription => '默认地图，使用 MapLibre style。';

  @override
  String get mapTileConfigOpenStreetMapDescription =>
      '使用 OpenStreetMap 标准 XYZ 瓦片。';

  @override
  String mapTileConfigCustomXyzDescription(String pattern) {
    return '使用包含 $pattern 的栅格瓦片 URL。';
  }

  @override
  String get mapTileConfigCustomMapLibreDescription =>
      '使用自定义 MapLibre style URL。';

  @override
  String mapTileConfigCustomXyzInvalid(String z, String x, String y) {
    return '自定义 XYZ URL 需要包含 $z、$x、$y，并使用 http/https。';
  }

  @override
  String get mapTileConfigCustomMapLibreInvalid =>
      '自定义 MapLibre style URL 需要使用 http/https。';

  @override
  String get navigationHeadingStale => '上次定位，等待更新';

  @override
  String get navigationHeadingNoHeading => '当前位置，朝向不可用';

  @override
  String get navigationHeadingWithHeading => '当前位置，手机朝向';

  @override
  String get photoLocationStatusPanelSkip => '跳过';

  @override
  String nativeCameraControllerPermissionRequestFailed(String error) {
    return '相机权限请求失败：$error';
  }

  @override
  String get nativeCameraControllerPermissionRequired => '需要相机权限';

  @override
  String get nativeCameraControllerInitFailed => '原生相机初始化失败';

  @override
  String nativeCameraControllerInitFailedWithError(String error) {
    return '原生相机初始化失败：$error';
  }

  @override
  String get photoLocationChoiceTitle => '是否在巡礼照片中记录定位？';

  @override
  String get photoLocationChoiceChangeLater => '以后可以在“拍摄设置”中修改。';

  @override
  String get photoLocationChoiceNoSpotCoordinates => '不会使用点位坐标代替实际定位。';

  @override
  String get photoLocationChoiceRecentTitle => '使用最近一次定位';

  @override
  String get photoLocationChoiceRecentSubtitle => '优先快速写入近期有效定位，没有时获取一次。';

  @override
  String get photoLocationChoiceConfirmTitle => '确认记录时获取定位';

  @override
  String get photoLocationChoiceConfirmSubtitle => '拍摄后在确认页面等待新定位，适合需要更准确位置时。';

  @override
  String get photoLocationChoiceDisabledTitle => '不记录定位';

  @override
  String get photoLocationChoiceRecommended => '推荐';

  @override
  String get mapMarkerClusteringTapToBrowse => '点击浏览';

  @override
  String get mapMarkerClusteringTapToZoom => '点击放大';

  @override
  String get mapMarkerClusteringDone => '已完成';

  @override
  String mapMarkerClusteringDoneSummary(int done, String doneLabel) {
    return '，其中 $done 个$doneLabel';
  }

  @override
  String mapMarkerClusteringBrowseOverlapping(int count) {
    return '浏览 $count 个重合点位';
  }

  @override
  String mapMarkerClusteringSpotCount(int count) {
    return '$count 个点位';
  }

  @override
  String mapMarkerClusteringSemantics(
    int count,
    String doneSummary,
    String action,
  ) {
    return '$count 个聚合点位$doneSummary，$action';
  }

  @override
  String mapMarkerClusteringTooltipDone(
    String tooltip,
    int done,
    String doneLabel,
  ) {
    return '$tooltip · $done 个$doneLabel';
  }

  @override
  String get mapMarkerClusteringPrevious => '上一个重合点位';

  @override
  String mapMarkerClusteringPager(int index, int total) {
    return '重合点位  $index / $total';
  }

  @override
  String get mapMarkerClusteringNext => '下一个重合点位';

  @override
  String get valhallaRouteClientNeedsTwoStops => '路线至少需要起点和终点';

  @override
  String get valhallaRouteClientTimeout => '路径规划服务响应超时，请稍后重试';

  @override
  String valhallaRouteClientConnectionFailed(String error) {
    return '无法连接路径规划服务：$error';
  }

  @override
  String get valhallaRouteClientRateLimited => '路径规划服务请求过于频繁，请稍后重试';

  @override
  String valhallaRouteClientServiceUnavailable(int status) {
    return '路径规划服务暂时不可用（$status）';
  }

  @override
  String valhallaRouteClientRouteFailed(int status) {
    return '无法规划这条步行路线（$status）';
  }

  @override
  String valhallaRouteClientStatus(int status) {
    return '服务返回 $status';
  }

  @override
  String get valhallaRouteClientTestTimeout => '连接测试超时';

  @override
  String get valhallaRouteClientBadResponse => '路径规划服务返回了无法识别的数据';

  @override
  String get valhallaRouteClientError170 => '起点和终点之间没有相连的步行道路';

  @override
  String get valhallaRouteClientError171 => '起点或点位附近没有可步行的道路，请换个位置再试';

  @override
  String get valhallaRouteClientError154 => '距离超过路径服务的步行路线上限';

  @override
  String get valhallaRouteClientError442 => '找不到可步行的路线';

  @override
  String get valhallaRouteClientStartWalking => '开始步行';

  @override
  String valhallaRouteClientStartAlong(String road) {
    return '沿$road出发';
  }

  @override
  String get valhallaRouteClientHeadRight => '向右出发';

  @override
  String valhallaRouteClientHeadRightOnto(String road) {
    return '向右出发，进入$road';
  }

  @override
  String get valhallaRouteClientHeadLeft => '向左出发';

  @override
  String valhallaRouteClientHeadLeftOnto(String road) {
    return '向左出发，进入$road';
  }

  @override
  String get valhallaRouteClientArrive => '到达终点';

  @override
  String valhallaRouteClientArriveNear(String road) {
    return '到达$road附近的终点';
  }

  @override
  String get valhallaRouteClientContinue => '继续前行';

  @override
  String valhallaRouteClientContinueOnto(String road) {
    return '继续前行，进入$road';
  }

  @override
  String get valhallaRouteClientGoStraight => '继续直行';

  @override
  String valhallaRouteClientGoStraightAlong(String road) {
    return '沿$road继续直行';
  }

  @override
  String get valhallaRouteClientBearRight => '稍向右转';

  @override
  String valhallaRouteClientBearRightOnto(String road) {
    return '稍向右转，进入$road';
  }

  @override
  String get valhallaRouteClientTurnRight => '向右转';

  @override
  String valhallaRouteClientTurnRightOnto(String road) {
    return '向右转，进入$road';
  }

  @override
  String get valhallaRouteClientSharpRight => '向右急转';

  @override
  String valhallaRouteClientSharpRightOnto(String road) {
    return '向右急转，进入$road';
  }

  @override
  String get valhallaRouteClientUTurn => '请掉头';

  @override
  String get valhallaRouteClientSharpLeft => '向左急转';

  @override
  String valhallaRouteClientSharpLeftOnto(String road) {
    return '向左急转，进入$road';
  }

  @override
  String get valhallaRouteClientTurnLeft => '向左转';

  @override
  String valhallaRouteClientTurnLeftOnto(String road) {
    return '向左转，进入$road';
  }

  @override
  String get valhallaRouteClientBearLeft => '稍向左转';

  @override
  String valhallaRouteClientBearLeftOnto(String road) {
    return '稍向左转，进入$road';
  }

  @override
  String get valhallaRouteClientRampStraight => '沿匝道直行';

  @override
  String valhallaRouteClientRampStraightAlong(String road) {
    return '沿$road沿匝道直行';
  }

  @override
  String get valhallaRouteClientRampRight => '沿右侧匝道前行';

  @override
  String valhallaRouteClientRampRightOnto(String road) {
    return '沿右侧匝道进入$road';
  }

  @override
  String get valhallaRouteClientRampLeft => '沿左侧匝道前行';

  @override
  String valhallaRouteClientRampLeftOnto(String road) {
    return '沿左侧匝道进入$road';
  }

  @override
  String get valhallaRouteClientExitRight => '从右侧出口离开';

  @override
  String get valhallaRouteClientExitLeft => '从左侧出口离开';

  @override
  String get valhallaRouteClientStayStraight => '保持直行';

  @override
  String valhallaRouteClientStayStraightAlong(String road) {
    return '沿$road保持直行';
  }

  @override
  String get valhallaRouteClientKeepRight => '靠右行走';

  @override
  String valhallaRouteClientKeepRightAlong(String road) {
    return '沿$road靠右行走';
  }

  @override
  String get valhallaRouteClientKeepLeft => '靠左行走';

  @override
  String valhallaRouteClientKeepLeftAlong(String road) {
    return '沿$road靠左行走';
  }

  @override
  String get valhallaRouteClientMerge => '汇入道路';

  @override
  String valhallaRouteClientMergeOnto(String road) {
    return '汇入道路，进入$road';
  }

  @override
  String get valhallaRouteClientEnterRoundabout => '进入环岛';

  @override
  String get valhallaRouteClientExitRoundabout => '驶出环岛';

  @override
  String get valhallaRouteClientBoardFerry => '进入渡轮';

  @override
  String get valhallaRouteClientLeaveFerry => '离开渡轮';

  @override
  String get valhallaRouteClientTakeTransit => '搭乘公共交通';

  @override
  String get valhallaRouteClientTransfer => '换乘';

  @override
  String get valhallaRouteClientStayOnLine => '继续乘坐当前线路';

  @override
  String get valhallaRouteClientToTransitConnection => '前往公共交通连接点';

  @override
  String get valhallaRouteClientTransitArrive => '到达公共交通目的地';

  @override
  String get valhallaRouteClientMergeRight => '向右汇入道路';

  @override
  String valhallaRouteClientMergeRightOnto(String road) {
    return '向右汇入道路，进入$road';
  }

  @override
  String get valhallaRouteClientMergeLeft => '向左汇入道路';

  @override
  String valhallaRouteClientMergeLeftOnto(String road) {
    return '向左汇入道路，进入$road';
  }

  @override
  String get valhallaRouteClientElevator => '乘坐电梯';

  @override
  String get valhallaRouteClientStairs => '走楼梯';

  @override
  String get valhallaRouteClientEscalator => '乘坐自动扶梯';

  @override
  String get valhallaRouteClientEnterBuilding => '进入建筑';

  @override
  String get valhallaRouteClientExitBuilding => '离开建筑';

  @override
  String get valhallaRouteClientOtherFloor => '前往其他楼层';

  @override
  String get valhallaRouteClientParkAndWalk => '停放车辆后继续步行';

  @override
  String valhallaRouteClientContinueAlong(String road) {
    return '沿$road继续前行';
  }

  @override
  String get navigationRouteConfirmLoadFailed => '路线加载失败，请检查定位和路径服务设置';

  @override
  String get navigationRouteConfirmTitle => '确认路线';

  @override
  String get navigationRouteConfirmChainArea => '串联整个片区';

  @override
  String get navigationRouteConfirmToSelected => '导航到选中点';

  @override
  String navigationRouteConfirmChainSummary(int count, String stops) {
    return '按顺序连接 $count 个点位：$stops';
  }

  @override
  String navigationRouteConfirmDestination(String name) {
    return '终点：$name';
  }

  @override
  String get navigationRouteConfirmLoading => '正在获取当前位置并规划步行路线…';

  @override
  String get navigationRouteConfirmReplan => '重新规划路线';

  @override
  String get navigationRouteConfirmExternalShort => '外部导航';

  @override
  String get navigationRouteConfirmExternalFailed => '无法打开外部地图';

  @override
  String get navigationRouteConfirmStart => '开始导航';

  @override
  String get navigationRouteConfirmStartArea => '串联整个片区导航';

  @override
  String get navigationRouteConfirmOnlySelected => '仅导航到选中点';

  @override
  String get navigationRouteConfirmOnlySelectedShort => '仅导航到点位';

  @override
  String get navigationRouteConfirmAreaBadge => '片区';

  @override
  String get inAppNavigationLocationStopped => '定位更新已停止，请重试。';

  @override
  String get inAppNavigationLocationStale => '暂未收到新的定位，当前位置可能已过期。';

  @override
  String get inAppNavigationPreciseOff => '精确位置已关闭，到达提醒和偏航判断可能不准确。';

  @override
  String get inAppNavigationOpenSettings => '去设置';

  @override
  String get inAppNavigationRetryLocation => '重试定位';

  @override
  String get inAppNavigationOnRoute => '路线中';

  @override
  String get inAppNavigationFollowRoute => '沿路线继续前行';

  @override
  String get inAppNavigationSideRight => '，在右侧';

  @override
  String get inAppNavigationSideLeft => '，在左侧';

  @override
  String inAppNavigationArriveDestination(String side) {
    return '到达终点$side';
  }

  @override
  String inAppNavigationArriveWaypoint(String side) {
    return '到达途经点$side';
  }

  @override
  String inAppNavigationArriveDestinationNamed(String name, String side) {
    return '到达终点 $name$side';
  }

  @override
  String inAppNavigationArriveWaypointNamed(String name, String side) {
    return '到达途经点 $name$side';
  }

  @override
  String inAppNavigationMeters(int meters) {
    return '$meters米';
  }

  @override
  String inAppNavigationKilometers(String km) {
    return '$km公里';
  }

  @override
  String inAppNavigationFinalStop(String name) {
    return '终点: $name';
  }

  @override
  String get inAppNavigationAllStops => '全部点位';

  @override
  String inAppNavigationStopCount(int count) {
    return '共 $count 个';
  }

  @override
  String get inAppNavigationArrived => '已到达';

  @override
  String get inAppNavigationEndRoute => '结束路线';

  @override
  String get inAppNavigationCollapse => '收起';

  @override
  String get inAppNavigationExpand => '展开';

  @override
  String get inAppNavigationMetricArrival => '到达';

  @override
  String get inAppNavigationMetricHours => '小时';

  @override
  String get inAppNavigationMetricKm => '公里';

  @override
  String get inAppNavigationAreaBadge => '片区';

  @override
  String get inAppNavigationRecenter => '回到当前位置';

  @override
  String get inAppNavigationArrivalTitle => '到达点位';

  @override
  String get inAppNavigationOpenCamera => '打开相机';

  @override
  String inAppNavigationRemainingStop(int stopNumber, int remainingCount) {
    return '第 $stopNumber / $remainingCount 个剩余点位';
  }

  @override
  String inAppNavigationNextStop(String subtitle) {
    return '下一点位 · $subtitle';
  }

  @override
  String get inAppNavigationGoNext => '前往下一点';

  @override
  String get pilgrimageMapLayerThumbnails => '缩略图标记';

  @override
  String get pilgrimageMapLayerAreas => '片区范围';

  @override
  String get pilgrimageMapLayerHideCompleted => '隐藏已完成点位';

  @override
  String get pilgrimageMapLayerClustering => '自动聚合密集点位';

  @override
  String get pilgrimageMapLayerContinuousLocation => '持续更新当前位置';

  @override
  String get pilgrimageMapLayerContinuousLocationHint => '关闭后只在点定位时获取一次位置，更省电';

  @override
  String pilgrimageMapOpenAppFailed(String app) {
    return '无法打开$app。';
  }

  @override
  String get pilgrimageMapNoSpotsSnack => '当前计划还没有点位。';

  @override
  String get pilgrimageMapCannotEdit => '当前环境无法编辑点位。';

  @override
  String get pilgrimageMapVisitedLabel => '已打卡';

  @override
  String get pilgrimageMapCurrentLocation => '当前位置';

  @override
  String get pilgrimageMapLocate => '定位';

  @override
  String get pilgrimageMapCurrentTarget => '当前目标';

  @override
  String get pilgrimageMapLayers => '图层';

  @override
  String get pilgrimageMapPointMarker => '巡礼点';

  @override
  String get pilgrimageMapCopySpotName => '点位名称';

  @override
  String get pilgrimageMapCopySpotInfo => '点位信息';

  @override
  String get pilgrimageMapNavigate => '导航';

  @override
  String get pilgrimageMapCoordinatesMissing => '坐标待补充';

  @override
  String get pilgrimageMapCamera => '拍摄参考';

  @override
  String get pilgrimageMapUndoVisit => '撤回打卡';

  @override
  String get pilgrimageMapMarkComplete => '标记完成';

  @override
  String get pilgrimageMapSetCurrent => '设为当前目标';

  @override
  String get pilgrimageMapEmptyTitle => '当前计划还没有点位';

  @override
  String get pilgrimageMapEmptyBody => '添加点位后会在地图上显示标记。';

  @override
  String get pilgrimageMapStatusCurrent => '当前';

  @override
  String get pilgrimageMapStatusCompleted => '完成';

  @override
  String get pilgrimageMapStatusPending => '待访';

  @override
  String get visitRecordConfirmationLocationReady => '已获取拍摄位置，保存时写入照片。';

  @override
  String get visitRecordConfirmationLocating => '正在获取拍摄位置...';

  @override
  String get visitRecordConfirmationLocationFailed =>
      '定位获取失败，本次不添加位置，保留照片原有信息。';

  @override
  String get visitRecordConfirmationStorageUnavailable => '记录存储不可用，请返回后重试。';

  @override
  String get visitRecordConfirmationStageSaving => '保存记录中...';

  @override
  String get visitRecordConfirmationStageWritingLocation => '正在写入照片定位，请稍候...';

  @override
  String get visitRecordConfirmationStageBackingUp => '备份巡礼照片中...';

  @override
  String get visitRecordConfirmationStageComparison => '生成对比图中...';

  @override
  String get visitRecordConfirmationStageUpdatingSpot => '更新点位状态中...';

  @override
  String get visitRecordConfirmationLocationWriteFailed => '；定位写入失败，保留照片原有信息';

  @override
  String get visitRecordConfirmationCompleteFailed => '；标记完成失败，请在计划中重试';

  @override
  String get visitRecordConfirmationSaveUncertain => '保存结果未确认，请返回记录页检查，勿重复保存。';

  @override
  String get visitRecordConfirmationSaveFailed => '保存记录失败，请重试。';

  @override
  String get visitRecordConfirmationSavingWait => '正在保存记录，请稍候。';

  @override
  String get visitRecordConfirmationTitle => '确认记录';

  @override
  String get visitRecordConfirmationLocationSkipped =>
      '已跳过定位，本次不添加位置，保留照片原有信息。';

  @override
  String get visitRecordConfirmationSavingButton => '保存中';

  @override
  String get visitRecordConfirmationSave => '保存记录';

  @override
  String get visitRecordConfirmationSaveAndComplete => '保存并标记完成';

  @override
  String get visitRecordConfirmationSavedAndCompleted => '已保存并标记完成';

  @override
  String get visitRecordConfirmationSaved => '记录已保存';

  @override
  String get visitRecordConfirmationBackedUp => '，并备份到相册';

  @override
  String get visitRecordConfirmationBackupFailed => '；相册备份失败';

  @override
  String visitRecordConfirmationNext(String name) {
    return '，下一个：$name';
  }

  @override
  String visitRecordConfirmationDetail(String message) {
    return '，$message';
  }

  @override
  String get visitRecordConfirmationComparisonSaved => '，对比图已保存到相册';

  @override
  String get visitRecordConfirmationComparisonNoReference => '，参考图不可用，未生成对比图';

  @override
  String get visitRecordConfirmationComparisonNoPhoto => '，巡礼图不可用，未生成对比图';

  @override
  String get visitRecordConfirmationComparisonGalleryFailed => '，对比图保存到相册失败';

  @override
  String get visitRecordConfirmationComparisonRenderFailed => '，对比图生成失败';

  @override
  String get visitRecordConfirmationSaveToGallery => '保存到相册';

  @override
  String get visitRecordConfirmationReferenceImage => '参考图';

  @override
  String get visitRecordConfirmationPilgrimagePhoto => '巡礼图';

  @override
  String get visitRecordConfirmationReferenceMode => '参考模式';

  @override
  String get camerawesomeReferenceModeOverlay => '叠影';

  @override
  String get camerawesomeReferenceModeSplit => '上下';

  @override
  String get camerawesomeReferenceModePinned => '小窗';

  @override
  String get camerawesomeReferenceReadFailed => '参考图读取失败';

  @override
  String get camerawesomeReferenceImportFailed => '照片导入失败，请重新选择。';

  @override
  String get camerawesomeReferenceReadingRatio => '正在读取参考图比例，请稍后拍摄。';

  @override
  String get camerawesomeReferenceNotReady => '相机尚未就绪，请稍后再拍。';

  @override
  String get camerawesomeReferenceCaptureFailed => '拍摄失败，请重试。';

  @override
  String get camerawesomeReferenceBack => '返回';

  @override
  String get camerawesomeReferenceReferenceImage => '参考图';

  @override
  String get camerawesomeReferenceLandscapeUi => '切换横屏 UI';

  @override
  String get camerawesomeReferencePortraitUi => '切换竖屏 UI';

  @override
  String get camerawesomeReferenceGalleryImport => '相册导入';

  @override
  String get camerawesomeReferenceSwitchLens => '切换镜头';

  @override
  String get camerawesomeReferenceReviewPhotos => '检查照片';

  @override
  String get camerawesomeReferenceFlashOff => '闪光灯：关闭';

  @override
  String get camerawesomeReferenceFlashOn => '闪光灯：开启';

  @override
  String get camerawesomeReferenceFlashTorch => '闪光灯：常亮';

  @override
  String get camerawesomeReferenceFlashAuto => '闪光灯：自动';

  @override
  String get camerawesomeReferenceSwitchCamera => '切换摄像头';

  @override
  String get camerawesomeReferenceImportFromGallery => '从相册导入';

  @override
  String get camerawesomeReferenceImport => '导入';

  @override
  String get camerawesomeReferenceWebPreview => 'Web 预览不启动实时相机';

  @override
  String get camerawesomeReferencePermissionTitle => '需要相机权限';

  @override
  String get camerawesomeReferencePermissionBody =>
      '请在系统设置中允许 Koma 使用相机，用于拍摄巡礼照片。';

  @override
  String get camerawesomeReferenceOpenSettings => '打开设置';

  @override
  String get camerawesomeReferencePickFromGallery => '从相册选择照片';

  @override
  String get camerawesomeReferenceUnavailableTitle => '相机无法启动';

  @override
  String get camerawesomeReferenceUnavailableBody =>
      '相机暂时无法使用，请稍后重试。如果问题持续，请重启 Koma。';

  @override
  String get addPointsPickWork => '查看点位';

  @override
  String get addPointsFindSpots => '查找作品点位';

  @override
  String get addPointsFindSpotsSubtitle => '搜索作品或粘贴 Anitabi 链接，在地图上挑选点位';

  @override
  String get addPointsOwnSpotsSection => '自行添加点位';

  @override
  String get anitabiMapImportSearchWork => '搜索作品';

  @override
  String get anitabiMapImportPasteLink => '粘贴 Anitabi 链接';

  @override
  String get anitabiMapImportClusterAdded => '已加入';

  @override
  String navigationRouteConfirmExternalWith(String app) {
    return '使用 $app 导航';
  }

  @override
  String get planOnboardingFindTitle => '找作品';

  @override
  String get planOnboardingFindBody =>
      '点击下方“添加点位”，选择“查找作品点位”，搜索作品或粘贴 Anitabi 链接。';

  @override
  String get planOnboardingShootTitle => '现场拍摄';

  @override
  String get planOnboardingShootBody => '到达点位后点相机按钮，对照动画画面取景。';

  @override
  String get pointDetailMarkDoneShort => '完成';

  @override
  String get pointDetailUndoShort => '撤销';

  @override
  String get splitNavigationRouteShort => '路线';

  @override
  String get splitNavigationMapsShort => '导航';

  @override
  String get appShellNoPlansTitle => '还没有计划';

  @override
  String get appShellNoPlansBody => '创建一个巡礼计划，把想去的作品点位加进来。';

  @override
  String get appShellCreatePlan => '创建计划';

  @override
  String get appShellCreatePlanFailed => '计划创建失败，请重试';

  @override
  String get appShellNewPlan => '新建计划';

  @override
  String get planManagerDeleteFailed => '删除计划失败，请重试';

  @override
  String get paletteFjord => '峡湾蓝';

  @override
  String get paletteSpruce => '云杉';

  @override
  String get paletteMoss => '苔绿';

  @override
  String get paletteLake => '湖蓝';

  @override
  String get paletteInk => '墨色';

  @override
  String get planAreaEmpty => '这个片区还没有点位，左右切换查看其他片区。';

  @override
  String get planManagerOpenPlan => '打开计划';

  @override
  String get planManagerEditDetails => '编辑详情';

  @override
  String get planManagerDetails => '详情';

  @override
  String get planManagerNoDetails => '暂无详情';

  @override
  String get planManagerFactSpots => '点位';

  @override
  String get planManagerFactAreas => '区域';

  @override
  String get planManagerFactCreated => '创建';

  @override
  String get planManagerFactUpdated => '更新';

  @override
  String planManagerSpotsDone(int total, int done) {
    return '$total · 已完成 $done';
  }

  @override
  String get planEdit => '编辑';

  @override
  String get planEditDone => '完成';

  @override
  String get planEditMarkVisited => '已到访';

  @override
  String get anitabiMapImportBoxArea => '区域';

  @override
  String get settingsBasedOn => '基于';
}
