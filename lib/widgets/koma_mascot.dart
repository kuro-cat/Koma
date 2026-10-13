import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Koma-chan, animated unless [still] or the system asks for less motion.
/// The art is drawn on white: in light mode its white is tinted to [ground]
/// so it sits on the page without a frame; in dark mode it gets a white panel.
class KomaMascot extends StatelessWidget {
  const KomaMascot({
    required this.height,
    this.still = false,
    this.ground = Colors.white,
    super.key,
  });

  final double height;
  final bool still;
  final Color ground;

  @override
  Widget build(BuildContext context) {
    final animated = !still && !MediaQuery.disableAnimationsOf(context);
    final image = Image.asset(
      animated
          ? 'assets/mascot/koma_loading.webp'
          : 'assets/mascot/koma_still.webp',
      height: height,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      color: AppColors.isDark ? null : ground,
      colorBlendMode: BlendMode.multiply,
    );
    if (!AppColors.isDark) {
      return image;
    }
    return ColoredBox(
      color: Colors.white,
      child: Padding(padding: const EdgeInsets.all(12), child: image),
    );
  }
}
