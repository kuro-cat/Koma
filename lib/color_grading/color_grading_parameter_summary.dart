import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_theme.dart';
import '../l10n/l10n.dart';
import 'color_grading_params.dart';

class ColorGradingParameterSummary extends StatelessWidget {
  const ColorGradingParameterSummary({
    required this.activeParams,
    required this.intensity,
    required this.onIntensityChanged,
    super.key,
  });

  final ColorGradingParams activeParams;
  final double intensity;
  final ValueChanged<double> onIntensityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.colorGradingParameterSummaryIntensity,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(intensity * 100).round()}%',
                style: TextStyle(
                  color: AppColors.accentStrongForeground,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: intensity,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: onIntensityChanged,
          ),
          Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.colorGradingParameterSummaryParameters,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showParameterSheet(context),
                style: AppButtonStyles.compactOutlinedButton(),
                icon: const Icon(LucideIcons.slidersHorizontal, size: 18),
                label: Text(l10n.colorGradingParameterSummaryView),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.colorGradingParameterSummaryDescription,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showParameterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) =>
          _ColorGradingParameterSheet(activeParams: activeParams),
    );
  }
}

class _ColorGradingParameterSheet extends StatelessWidget {
  const _ColorGradingParameterSheet({required this.activeParams});

  final ColorGradingParams activeParams;

  @override
  Widget build(BuildContext context) {
    final items = <_ParameterItem>[
      _ParameterItem(
        l10n.colorGradingParameterSummaryBrightness,
        activeParams.brightness,
        -0.25,
        0.25,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryExposure,
        activeParams.exposure,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryContrast,
        activeParams.contrast,
        0.7,
        1.4,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummarySaturation,
        activeParams.saturation,
        0.5,
        1.6,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryTemperature,
        activeParams.temperature,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryTint,
        activeParams.tint,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryHighlights,
        activeParams.highlights,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryShadows,
        activeParams.shadows,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryRedShadowCurve,
        activeParams.redShadowCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryRedMidCurve,
        activeParams.redMidCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryRedHighlightCurve,
        activeParams.redHighlightCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryGreenShadowCurve,
        activeParams.greenShadowCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryGreenMidCurve,
        activeParams.greenMidCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryGreenHighlightCurve,
        activeParams.greenHighlightCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryBlueShadowCurve,
        activeParams.blueShadowCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryBlueMidCurve,
        activeParams.blueMidCurve,
        -1.0,
        1.0,
      ),
      _ParameterItem(
        l10n.colorGradingParameterSummaryBlueHighlightCurve,
        activeParams.blueHighlightCurve,
        -1.0,
        1.0,
      ),
    ];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.74,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: items.length + 1,
          separatorBuilder: (_, index) => index == 0
              ? const SizedBox(height: 10)
              : const SizedBox(height: 18),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                l10n.colorGradingParameterSummaryParameters,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              );
            }
            return _ParameterRow(item: items[index - 1]);
          },
        ),
      ),
    );
  }
}

class _ParameterItem {
  const _ParameterItem(this.label, this.value, this.min, this.max);

  final String label;
  final double value;
  final double min;
  final double max;
}

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({required this.item});

  final _ParameterItem item;

  @override
  Widget build(BuildContext context) {
    final activeT = ((item.value - item.min) / (item.max - item.min))
        .clamp(0.0, 1.0)
        .toDouble();
    final activeText = item.value.toStringAsFixed(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Text(
              activeText,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: activeT,
            minHeight: 7,
            backgroundColor: AppColors.surfaceMuted,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}
