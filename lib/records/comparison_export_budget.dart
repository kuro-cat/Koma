import 'dart:math' as math;
import '../l10n/l10n.dart';

class ComparisonOutputLimitException implements Exception {
  const ComparisonOutputLimitException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ComparisonRenderBudget {
  const ComparisonRenderBudget({this.maxPixels = 8000000, this.maxEdge = 4096});
  final int maxPixels;
  final int maxEdge;

  ComparisonCanvasSize fit(double width, double height) {
    if (!width.isFinite ||
        !height.isFinite ||
        width <= 0 ||
        height <= 0 ||
        maxPixels < 1 ||
        maxEdge < 1) {
      throw ComparisonOutputLimitException(
        l10n.comparisonExportBudgetSizeUnfit(maxPixels, maxEdge),
      );
    }
    final scale = math.min(
      1.0,
      math.min(
        maxEdge / math.max(width, height),
        math.sqrt(maxPixels / (width * height)),
      ),
    );
    final targetWidth = (width * scale).floor();
    final targetHeight = (height * scale).floor();
    if (targetWidth < 1 || targetHeight < 1) {
      throw ComparisonOutputLimitException(
        l10n.comparisonExportBudgetTooNarrow(maxPixels, maxEdge),
      );
    }
    return ComparisonCanvasSize(
      targetWidth,
      targetHeight,
      math.min(targetWidth / width, targetHeight / height),
    );
  }
}

class ComparisonCanvasSize {
  const ComparisonCanvasSize(this.width, this.height, this.scale);
  final int width;
  final int height;
  final double scale;
}
