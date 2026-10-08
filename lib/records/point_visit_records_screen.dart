import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../widgets/app_back_button.dart';
import 'visit_record_detail_screen.dart';
import '../camera_reference/camerawesome_reference_screen.dart'
    show referenceModeDisplayLabel;
import 'visit_record_photo_stub.dart'
    if (dart.library.io) 'visit_record_photo_io.dart';

class PointVisitRecordsScreen extends StatelessWidget {
  const PointVisitRecordsScreen({
    required this.point,
    required this.controller,
    required this.settings,
    super.key,
  });

  final PilgrimagePoint point;
  final PilgrimagePlanController controller;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: appTextScalerFor(context, settings.fontScale)),
      child: AppUiScaleView(
        scale: settings.uiScale,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final resolvedPoint = controller.pointById(point.id) ?? point;
            final records = controller.recordsForPoint(point.id);

            return Scaffold(
              appBar: AppBar(
                leading: appBackButtonIfCanPop(context),
                title: Text(l10n.pointVisitRecordsTitle),
              ),
              body: ListView(
                // Sections and rows run full width and pad themselves 12dp.
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                children: [
                  _PointRecordsHeader(
                    point: resolvedPoint,
                    count: records.length,
                  ),
                  const SizedBox(height: 16),
                  if (records.isEmpty)
                    const _EmptyPointRecords()
                  else ...[
                    const _PointRecordsListLabel(),
                    for (final record in records)
                      _PointVisitRecordCard(
                        record: record,
                        onTap: () =>
                            _openRecordDetail(context, record, resolvedPoint),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openRecordDetail(
    BuildContext context,
    PilgrimageVisitRecord record,
    PilgrimagePoint point,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: point,
          controller: controller,
          settings: settings,
          onDelete: () => controller.deleteVisitRecord(record),
        ),
      ),
    );
  }
}

class _PointRecordsHeader extends StatelessWidget {
  const _PointRecordsHeader({required this.point, required this.count});

  final PilgrimagePoint point;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            color: AppColors.surfaceMuted,
            child: Icon(LucideIcons.folders, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${point.work.title} / ${point.displayEpisodeLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                l10n.pointVisitRecordsCountUnit(count),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPointRecords extends StatelessWidget {
  const _EmptyPointRecords();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Column(
        children: [
          Icon(LucideIcons.images, color: AppColors.textSecondary, size: 34),
          SizedBox(height: 10),
          Text(
            l10n.pointVisitRecordsEmpty,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointRecordsListLabel extends StatelessWidget {
  const _PointRecordsListLabel();

  @override
  Widget build(BuildContext context) {
    // The list's caps name, hung over its 2px ink rule.
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: CapsLabel(l10n.pointVisitRecordsListLabel),
    );
  }
}

class _RecordCapturedAt {
  const _RecordCapturedAt({required this.date, required this.time});

  final String date;
  final String time;
}

class _RecordCapturedAtText extends StatelessWidget {
  const _RecordCapturedAtText({required this.capturedAt});

  final DateTime capturedAt;

  @override
  Widget build(BuildContext context) {
    final value = _formatCapturedAt(capturedAt);
    return SizedBox(
      width: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointVisitRecordCard extends StatelessWidget {
  const _PointVisitRecordCard({required this.record, required this.onTap});

  final PilgrimageVisitRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoPath = resolveVisitRecordDisplayPhotoPath(record);
    // A ruled row: page ground, 1px divider beneath, thumbnail inset 12dp.
    return Material(
      color: Colors.transparent,
      shape: Border(bottom: BorderSide(color: AppColors.divider)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 104, child: VisitRecordPhoto(path: photoPath)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RecordCapturedAtText(capturedAt: record.capturedAt),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _RecordMetaChip(
                              icon: LucideIcons.layers,
                              label: referenceModeDisplayLabel(
                                record.referenceMode,
                              ),
                            ),
                            if (record.hasColorGrading)
                              _RecordMetaChip(
                                icon: LucideIcons.wandSparkles,
                                label: l10n.pointVisitRecordsColorMatched,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordMetaChip extends StatelessWidget {
  const _RecordMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Ink-2 with no fill: a mist tag would vanish on the paper row.
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

_RecordCapturedAt _formatCapturedAt(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return _RecordCapturedAt(
    date: '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)}',
    time: '${twoDigits(value.hour)}:${twoDigits(value.minute)}',
  );
}
