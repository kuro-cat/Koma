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
  String get appLoading => 'Loading MiriaGo...';

  @override
  String get alignPhotoTitle => 'Align & crop';

  @override
  String get alignPhotoAction => 'Align & crop';

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
}
