import 'package:flutter/material.dart';

class RecordLogo extends StatelessWidget {
  const RecordLogo({
    super.key,
    this.size = 24,
    this.foregroundColor,
    this.dotColor = const Color(0xFFEF4444),
  });

  final double size;
  final Color? foregroundColor;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1C1917));

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.language_rounded,
            size: size,
            color: color,
          ),
          Container(
            width: size * 0.26,
            height: size * 0.26,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.38),
                  blurRadius: size * 0.18,
                  spreadRadius: size * 0.03,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
