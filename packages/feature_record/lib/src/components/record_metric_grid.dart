import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class RecordMetricGrid extends StatelessWidget {
  const RecordMetricGrid({
    super.key,
    required this.children,
    this.columns = 3,
    this.spacing = 10,
    this.minTileWidth = 96,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final requestedColumns = math.max(1, columns);
        final fittedColumns =
            ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
                .floor();
        final columnCount = math.max(
          1,
          math.min(requestedColumns, fittedColumns),
        );
        final totalSpacing = spacing * (columnCount - 1);
        final double tileWidth = math
            .max(
              0.0,
              (constraints.maxWidth - totalSpacing) / columnCount,
            )
            .toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(
                width: tileWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}
