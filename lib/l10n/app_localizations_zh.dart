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
  String get appLoading => '正在加载 MiriaGo...';

  @override
  String get alignPhotoTitle => '对齐裁剪';

  @override
  String get alignPhotoAction => '对齐裁剪';

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
}
