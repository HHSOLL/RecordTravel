import 'package:flutter/material.dart';

import 'record_logo.dart';

class RecordWordmark extends StatelessWidget {
  const RecordWordmark({
    super.key,
    this.logoSize = 24,
    this.fontSize = 20,
    this.spacing = 8,
  });

  final double logoSize;
  final double fontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RecordLogo(size: logoSize),
        SizedBox(width: spacing),
        Text(
          'record',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
          ),
        ),
      ],
    );
  }
}
