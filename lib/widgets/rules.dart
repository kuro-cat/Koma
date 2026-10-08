import 'package:flutter/material.dart';

import '../app_theme.dart';

// Koma draws three lines and no others:
// - the 1px ink rule under the app bar and over the nav bar (themes);
// - [SectionRule], 2px ink over a section or a list;
// - [RowDivider], 1px divider between rows.
// Section rules and row dividers run the full width of the screen or sheet;
// the content between them carries its own 12dp inset.

/// 2px ink over a section or list, edge to edge.
class SectionRule extends StatelessWidget {
  const SectionRule({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: ColoredBox(color: AppColors.ink),
    );
  }
}

/// 1px divider between rows, edge to edge, never indented.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: AppColors.divider),
    );
  }
}

/// The bottom edge of a ruled row, for a row's own decoration or shape.
BorderSide get rowDividerSide => BorderSide(color: AppColors.divider);

/// The top edge of a section, for a section's own decoration or shape.
BorderSide get sectionRuleSide => BorderSide(color: AppColors.ink, width: 2);
